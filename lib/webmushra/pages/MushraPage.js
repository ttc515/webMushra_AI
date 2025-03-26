/*************************************************************************
         (C) Copyright AudioLabs 2017 

This source code is protected by copyright law and international treaties. 
This source code is made available to You subject to the terms and conditions of the 
Software License for the webMUSHRA.js Software. Said terms and conditions have been 
made available to You prior to Your download of this source code. By downloading this 
source code You agree to be bound by the above mentioned terms and conditions, which 
can also be found here: https://www.audiolabs-erlangen.de/resources/webMUSHRA. Any 
unauthorised use of this source code may result in severe civil and criminal penalties, 
and will be prosecuted to the maximum extent possible under law.
**************************************************************************/

function MushraPage(
  _pageManager,
  _audioContext,
  _bufferSize,
  _audioFileLoader,
  _session,
  _pageConfig,
  _mushraValidator,
  _errorHandler,
  _language
) {
  this.isMushra = true;
  this.pageManager = _pageManager;
  this.audioContext = _audioContext;
  this.bufferSize = _bufferSize;
  this.audioFileLoader = _audioFileLoader;
  this.session = _session;
  this.pageConfig = _pageConfig;
  this.mushraValidator = _mushraValidator;
  this.errorHandler = _errorHandler;
  this.language = _language;

  this.mushraAudioControl = null;
  this.div = null;
  this.waveformVisualizer = null;
  this.macic = null;

  this.currentItem = null;
  this.tdLoop2 = null;

  // Create Stimulus objects for each condition
  this.conditions = [];
  for (var key in this.pageConfig.stimuli) {
    this.conditions.push(new Stimulus(key, this.pageConfig.stimuli[key]));
  }
  // Create Stimulus object for reference
  this.reference = new Stimulus("reference", this.pageConfig.reference);

  // Preload audio
  this.audioFileLoader.addFile(
    this.reference.getFilepath(),
    (function (_buffer, _stimulus) {
      _stimulus.setAudioBuffer(_buffer);
    }).bind(this),
    this.reference
  );
  for (var i = 0; i < this.conditions.length; i++) {
    this.audioFileLoader.addFile(
      this.conditions[i].getFilepath(),
      (function (_buffer, _stimulus) {
        _stimulus.setAudioBuffer(_buffer);
      }).bind(this),
      this.conditions[i]
    );
  }

  // Data
  // We store ratings in an object keyed by stimulus ID, 
  // e.g. this.ratings["C1"]["1"] for naturalness, ["C1"]["2"] for sound quality
  this.ratings = {};
  this.loop = { start: null, end: null };
  this.slider = { start: null, end: null };
  this.time = 0;
  this.startTimeOnPage = null;
}

MushraPage.prototype.getName = function () {
  return this.pageConfig.name;
};

MushraPage.prototype.init = function () {
  if (this.pageConfig.strict !== false) {
    this.mushraValidator.checkNumConditions(this.conditions);
    this.mushraValidator.checkStimulusDuration(this.reference);
  }

  this.mushraValidator.checkNumChannels(this.audioContext, this.reference);
  for (var i = 0; i < this.conditions.length; i++) {
    this.mushraValidator.checkSamplerate(
      this.audioContext.sampleRate,
      this.conditions[i]
    );
  }
  this.mushraValidator.checkConditionConsistency(
    this.reference,
    this.conditions
  );

  // Initialize MushraAudioControl
  this.mushraAudioControl = new MushraAudioControl(
    this.audioContext,
    this.bufferSize,
    this.reference,
    this.conditions,
    this.errorHandler,
    this.pageConfig.createAnchor35,
    this.pageConfig.createAnchor70,
    this.pageConfig.randomize,
    this.pageConfig.switchBack
  );

  // Listen for events (stop, playCondition, etc.)
  this.mushraAudioControl.addEventListener(
    (function (_event) {
      if (_event.name === "stopTriggered") {
        $(".audioControlElement").text(
          this.pageManager.getLocalizer().getFragment(this.language, "playButton")
        );

        if ($("#buttonReference").attr("active") === "true") {
          $.mobile.activePage
            .find("#buttonReference")
            .removeClass("ui-btn-b")
            .addClass("ui-btn-a")
            .attr("data-theme", "a");
          $("#buttonReference").attr("active", "false");
        }

        // Disable all condition sliders
        for (var i = 0; i < _event.conditionLength; i++) {
          var active = "#buttonConditions" + i;
          var toDisable = $(".scales").get(i); // This may need updating if we rely on indexing
          if ($(active).attr("active") === "true") {
            $.mobile.activePage
              .find(active)
              .removeClass("ui-btn-b")
              .addClass("ui-btn-a")
              .attr("data-theme", "a");
            $(toDisable).slider("disable");
            $(toDisable).attr("active", "false");
            $(active).attr("active", "false");
            break;
          }
        }

        $.mobile.activePage
          .find("#buttonStop")
          .removeClass("ui-btn-a")
          .addClass("ui-btn-b")
          .attr("data-theme", "b");
        $.mobile.activePage.find("#buttonStop").focus();
        $("#buttonStop").attr("active", "true");
      } else if (_event.name === "playReferenceTriggered") {
        if ($("#buttonStop").attr("active") === "true") {
          $.mobile.activePage
            .find("#buttonStop")
            .removeClass("ui-btn-b")
            .addClass("ui-btn-a")
            .attr("data-theme", "a");
          $("#buttonStop").attr("active", "false");
        }

        // Disable any active condition
        for (var j = 0; j < _event.conditionLength; j++) {
          var active = "#buttonConditions" + j;
          var toDisable = $(".scales").get(j);
          if ($(active).attr("active") === "true") {
            $.mobile.activePage
              .find(active)
              .removeClass("ui-btn-b")
              .addClass("ui-btn-a")
              .attr("data-theme", "a");
            $(active).attr("active", "false");
            $(toDisable).slider("disable");
            $(toDisable).attr("active", "false");
            break;
          }
        }

        // Highlight reference
        $.mobile.activePage
          .find("#buttonReference")
          .removeClass("ui-btn-a")
          .addClass("ui-btn-b")
          .attr("data-theme", "b");
        $.mobile.activePage.find("#buttonReference").focus();
        $("#buttonReference").attr("active", "true");
      } else if (_event.name === "playConditionTriggered") {
        // We rely mostly on btnCallbackCondition to enable the correct sliders.
        // You can put your logic here or in the button callback below.
      } else if (_event.name === "surpressLoop") {
        this.surpressLoop();
      }
    }).bind(this)
  );
};

MushraPage.prototype.render = function (_parent) {
  var div = $("<div></div>");
  _parent.append(div);

  var content =
    this.pageConfig.content === null ? "" : this.pageConfig.content;
  var p = $("<p>" + content + "</p>");
  div.append(p);

  var tableUp = $("<table id='mainUp'></table>");
  var tableDown = $("<table id='mainDown' align='center'></table>");
  div.append(tableUp);
  div.append(tableDown);

  // Row for the "Stop" button and Waveform area
  var trLoop = $("<tr id='trWs'></tr>");
  tableUp.append(trLoop);

  var tdLoop1 = $(
    "<td class='stopButton'>" +
      "<button data-role='button' data-inline='true' id='buttonStop' " +
      "onclick='" +
      this.pageManager.getPageVariableName(this) +
      ".mushraAudioControl.stop();'>" +
      this.pageManager.getLocalizer().getFragment(this.language, "stopButton") +
      "</button>" +
      "</td>"
  );
  trLoop.append(tdLoop1);

  var tdRight = $("<td></td>");
  trLoop.append(tdRight);

  var trMushra = $("<tr></tr>");
  tableDown.append(trMushra);
  var tdMushra = $("<td id='td_Mushra' colspan='2'></td>");
  trMushra.append(tdMushra);

  var tableMushra = $("<table id='mushra_items'></table>");
  tdMushra.append(tableMushra);

  // Row: Condition labels
  var trConditionNames = $("<tr></tr>");
  tableMushra.append(trConditionNames);

  // First cell for "Reference" label
  var tdConditionNamesReference = $(
    "<td>" +
      this.pageManager.getLocalizer().getFragment(this.language, "reference") +
      "</td>"
  );
  trConditionNames.append(tdConditionNamesReference);

  // Possibly an empty cell or a "Conditions" label cell
  var tdConditionNamesScale = $("<td id='conditionNameScale'></td>");
  trConditionNames.append(tdConditionNamesScale);

  // Condition name columns
  var conditions = this.mushraAudioControl.getConditions();
  for (var i = 0; i < conditions.length; i++) {
    var str = "";
    if (this.pageConfig.showConditionNames === true) {
      if (this.language === "en") {
        str = "<br/>" + conditions[i].id;
      } else {
        // handle local language reference or anchor naming
        if (conditions[i].id === "reference") {
          str =
            "<br/>" +
            this.pageManager.getLocalizer().getFragment(this.language, "reference");
        } else if (conditions[i].id === "anchor35") {
          str = "<br/>" + this.pageManager.getLocalizer().getFragment(this.language, "35");
        } else if (conditions[i].id === "anchor70") {
          str = "<br/>" + this.pageManager.getLocalizer().getFragment(this.language, "70");
        } else {
          str = "<br/>" + conditions[i].id;
        }
      }
    }
    var td = $(
      "<td>" +
        this.pageManager.getLocalizer().getFragment(this.language, "cond") +
        (i + 1) +
        str +
        "</td>"
    );
    trConditionNames.append(td);
  }

  // Row: Condition play buttons
  var trConditionPlay = $("<tr></tr>");
  tableMushra.append(trConditionPlay);

  // Reference play button cell
  var tdConditionPlayReference = $("<td></td>");
  trConditionPlay.append(tdConditionPlayReference);

  var buttonPlayReference = $(
    "<button data-theme='a' id='buttonReference' data-role='button' " +
      "class='audioControlElement' onclick='" +
      this.pageManager.getPageVariableName(this) +
      ".btnCallbackReference()' style='margin:0 auto;'>" +
      this.pageManager.getLocalizer().getFragment(this.language, "playButton") +
      "</button>"
  );
  tdConditionPlayReference.append(buttonPlayReference);

  // Possibly empty cell or label
  var tdConditionPlayScale = $("<td></td>");
  trConditionPlay.append(tdConditionPlayScale);

  // Condition play buttons
  for (var i = 0; i < conditions.length; i++) {
    var td = $("<td></td>");
    var buttonPlay = $(
      "<button data-role='button' class='center audioControlElement' " +
        "onclick='" +
        this.pageManager.getPageVariableName(this) +
        ".btnCallbackCondition(" +
        i +
        ");'>" +
        this.pageManager.getLocalizer().getFragment(this.language, "playButton") +
        "</button>"
    );
    buttonPlay.attr("id", "buttonConditions" + i);
    td.append(buttonPlay);
    trConditionPlay.append(td);
  }

  // Now create TWO ROWS for the two metrics (Naturalness & Sound Quality)
  // Row 1
  var trNaturalness = $("<tr id='tr_Naturalness'></tr>");
  tableMushra.append(trNaturalness);

  // Label cell for row 1
  trNaturalness.append($("<td><strong>Naturalness</strong></td>"));

  // Possibly an empty cell or alignment cell
  trNaturalness.append($("<td></td>"));

  // For each condition, create a cell with the "naturalness" slider
  for (var i = 0; i < conditions.length; i++) {
    var tdNat = $("<td class='spaceForSlider'></td>");
    var sliderNat = $(
      "<span><input type='range' " +
        "name='" +
        conditions[i].getId() +
        "_1' " + // suffix "_1" for naturalness
        "class='scales' value='100' min='0' max='100' " +
        "data-vertical='true' data-highlight='true' " +
        "style='display:inline-block; float:none;' /></span>"
    );
    tdNat.append(sliderNat);
    trNaturalness.append(tdNat);
  }

  // Row 2
  var trSoundQuality = $("<tr id='tr_SoundQuality'></tr>");
  tableMushra.append(trSoundQuality);

  // Label cell for row 2
  trSoundQuality.append($("<td><strong>Sound Quality</strong></td>"));

  // Possibly an empty cell or alignment cell
  trSoundQuality.append($("<td></td>"));

  // For each condition, create a cell with the "sound quality" slider
  for (var i = 0; i < conditions.length; i++) {
    var tdSQ = $("<td class='spaceForSlider'></td>");
    var sliderSQ = $(
      "<span><input type='range' " +
        "name='" +
        conditions[i].getId() +
        "_2' " + // suffix "_2" for sound quality
        "class='scales' value='100' min='0' max='100' " +
        "data-vertical='true' data-highlight='true' " +
        "style='display:inline-block; float:none;' /></span>"
    );
    tdSQ.append(sliderSQ);
    trSoundQuality.append(tdSQ);
  }

  // Unbind leftover keydown events
  $(".ui-slider-handle").unbind("keydown");

  // Setup the input controller for loop/pause
  this.macic = new MushraAudioControlInputController(
    this.mushraAudioControl,
    this.pageConfig.enableLooping
  );
  this.macic.bind();

  // Waveform visualizer (if showWaveform is true)
  this.waveformVisualizer = new WaveformVisualizer(
    this.pageManager.getPageVariableName(this) + ".waveformVisualizer",
    tdRight,
    this.reference,
    this.pageConfig.showWaveform,
    this.pageConfig.enableLooping,
    this.mushraAudioControl
  );
  this.waveformVisualizer.create();
  this.waveformVisualizer.load();
};

MushraPage.prototype.pause = function () {
  this.mushraAudioControl.pause();
};

MushraPage.prototype.setLoopStart = function () {
  var slider = document.getElementById("slider");
  var startSliderSamples = this.mushraAudioControl.audioCurrentPosition;
  var endSliderSamples = parseFloat(slider.noUiSlider.get()[1]);
  this.mushraAudioControl.setLoop(startSliderSamples, endSliderSamples);
};

MushraPage.prototype.setLoopEnd = function () {
  var slider = document.getElementById("slider");
  var startSliderSamples = parseFloat(slider.noUiSlider.get()[0]);
  var endSliderSamples = this.mushraAudioControl.audioCurrentPosition;
  this.mushraAudioControl.setLoop(startSliderSamples, endSliderSamples);
};

MushraPage.prototype.btnCallbackReference = function () {
  this.currentItem = "ref";
  var label = $("#buttonReference").text();
  if (
    label === this.pageManager.getLocalizer().getFragment(this.language, "pauseButton")
  ) {
    this.mushraAudioControl.pause();
    $("#buttonReference").text(
      this.pageManager.getLocalizer().getFragment(this.language, "playButton")
    );
  } else if (
    label === this.pageManager.getLocalizer().getFragment(this.language, "playButton")
  ) {
    $(".audioControlElement").text(
      this.pageManager.getLocalizer().getFragment(this.language, "playButton")
    );
    this.mushraAudioControl.playReference();
    $("#buttonReference").text(
      this.pageManager.getLocalizer().getFragment(this.language, "pauseButton")
    );
  }
};

MushraPage.prototype.surpressLoop = function () {
  var id =
    this.currentItem === "ref"
      ? $("#buttonReference")
      : $("#buttonConditions" + this.currentItem);
  id.text(this.pageManager.getLocalizer().getFragment(this.language, "playButton"));
};

// This function is called when user clicks "Play" on a condition
MushraPage.prototype.btnCallbackCondition = function (_index) {
  this.currentItem = _index;

  // Stop any playing audio
  this.mushraAudioControl.pause();

  // Reset all play buttons to "Play"
  $(".audioControlElement").text(
    this.pageManager.getLocalizer().getFragment(this.language, "playButton")
  );

  // Disable all sliders
  var allSliders = $(".scales");
  allSliders.each(function () {
    $(this).slider("disable");
    $(this).attr("active", "false");
  });

  // Highlight the selected condition's button
  for (var i = 0; i < this.conditions.length; i++) {
    var btn = "#buttonConditions" + i;
    $.mobile.activePage
      .find(btn)
      .removeClass("ui-btn-b")
      .addClass("ui-btn-a")
      .attr("data-theme", "a");
    $(btn).attr("active", "false");
  }
  var btnSelector = "#buttonConditions" + _index;
  $.mobile.activePage
    .find(btnSelector)
    .removeClass("ui-btn-a")
    .addClass("ui-btn-b")
    .attr("data-theme", "b");
  $(btnSelector).attr("active", "true");

  // Enable both sliders for condition _index
  // We have N conditions total
  var N = this.conditions.length;
  // For top row (naturalness), slider is at DOM index _index
  // For bottom row (sound quality), slider is at DOM index _index + N
  var sliderNat = allSliders.get(_index);
  var sliderSQ = allSliders.get(_index + N);

  $(sliderNat).slider("enable");
  $(sliderNat).attr("active", "true");

  $(sliderSQ).slider("enable");
  $(sliderSQ).attr("active", "true");

  // Start playing the condition
  this.mushraAudioControl.playCondition(_index);
};

MushraPage.prototype.renderCanvas = function (_parentId) {
  $("#mushra_canvas").remove();
  var parent = $("#" + _parentId);
  var canvas = document.createElement("canvas");
  canvas.style.position = "absolute";
  canvas.style.left = 0;
  canvas.style.top = 0;
  canvas.style.zIndex = 0;
  canvas.setAttribute("id", "mushra_canvas");
  parent.get(0).appendChild(canvas);
  $("#mushra_canvas").offset({
    top: $("#refCanvas1").offset()
      ? $("#refCanvas1").offset().top
      : $("#refCanvas").offset().top,
    left: $("#refCanvas1").offset()
      ? $("#refCanvas1").offset().left
      : $("#refCanvas").offset().left,
  });

  canvas.height =
    parent.get(0).offsetHeight -
    (parent.get(0).offsetHeight - $("#tr_SoundQuality").height());
  canvas.width = parent.get(0).offsetWidth;

  $(".scales").siblings().css("zIndex", "1");
  $(".scales").slider("disable");

  var canvasContext = canvas.getContext("2d");

  // The following logic for drawing lines might need adjusting
  // now that you have two rows of sliders.
  // You can adapt the lines to show multiple sets or keep it simple.
  // For brevity, we’ll leave the existing logic:
  var YfreeCanvasSpace =
    $(".scales").prev().offset().top - $(".scales").parent().offset().top;
  var YfirstLine =
    $(".scales").parent().get(0).offsetTop +
    parseInt($(".scales").css("borderTopWidth"), 10) +
    YfreeCanvasSpace;
  var prevScalesHeight = $(".scales").prev().height();
  var xDrawingStart =
    $("#spaceForScale").offset().left -
    $("#spaceForScale").parent().offset().left +
    canvasContext.measureText("100 ").width *
      1.5;
  var xAbsTableOffset =
    -$("#mushra_items").offset().left -
    ($("#mushra_canvas").offset().left - $("#mushra_items").offset().left);
  var xDrawingBeforeScales =
    $(".scales").first().prev().children().eq(0).offset().left + xAbsTableOffset;
  var xDrawingEnd =
    $(".scales").last().offset().left -
    $("#mushra_items").offset().left +
    $(".scales").last().width() / 2;

  canvasContext.beginPath();
  canvasContext.moveTo(xDrawingStart, YfirstLine);
  canvasContext.lineTo(xDrawingEnd, YfirstLine);
  canvasContext.stroke();

  var scaleSegments = [0.2, 0.4, 0.6, 0.8];
  for (var i = 0; i < scaleSegments.length; ++i) {
    canvasContext.beginPath();
    canvasContext.moveTo(
      xDrawingStart,
      prevScalesHeight * scaleSegments[i] + YfirstLine
    );
    canvasContext.lineTo(
      xDrawingBeforeScales,
      prevScalesHeight * scaleSegments[i] + YfirstLine
    );
    canvasContext.stroke();

    var predecessorXEnd = null;
    $(".scales").each(function (index) {
      var sliderElement = $(this).prev().first();
      if (index > 0) {
        canvasContext.beginPath();
        canvasContext.moveTo(
          predecessorXEnd,
          prevScalesHeight * scaleSegments[i] + YfirstLine
        );
        canvasContext.lineTo(
          sliderElement.offset().left + xAbsTableOffset,
          prevScalesHeight * scaleSegments[i] + YfirstLine
        );
        canvasContext.stroke();
      }
      predecessorXEnd =
        sliderElement.offset().left +
        sliderElement.width() +
        xAbsTableOffset +
        1;
    });
  }

  canvasContext.beginPath();
  canvasContext.moveTo(xDrawingStart, prevScalesHeight + YfirstLine);
  canvasContext.lineTo(xDrawingEnd, prevScalesHeight + YfirstLine);
  canvasContext.stroke();

  canvasContext.font = "1.25em Calibri";
  canvasContext.textBaseline = "middle";
  canvasContext.textAlign = "center";
  var xLetters =
    $("#refCanvas1").width() +
    ($("#spaceForScale").width() + canvasContext.measureText("1 ").width) / 2.0;

  canvasContext.fillText(
    this.pageManager.getLocalizer().getFragment(this.language, "excellent"),
    xLetters,
    prevScalesHeight * 0.1 + YfirstLine
  );
  canvasContext.fillText(
    this.pageManager.getLocalizer().getFragment(this.language, "good"),
    xLetters,
    prevScalesHeight * 0.3 + YfirstLine
  );
  canvasContext.fillText(
    this.pageManager.getLocalizer().getFragment(this.language, "fair"),
    xLetters,
    prevScalesHeight * 0.5 + YfirstLine
  );
  canvasContext.fillText(
    this.pageManager.getLocalizer().getFragment(this.language, "poor"),
    xLetters,
    prevScalesHeight * 0.7 + YfirstLine
  );
  canvasContext.fillText(
    this.pageManager.getLocalizer().getFragment(this.language, "bad"),
    xLetters,
    prevScalesHeight * 0.9 + YfirstLine
  );

  canvasContext.font = "1em Calibri";
  canvasContext.textAlign = "right";
  var xTextScoreRanges =
    xDrawingStart - canvasContext.measureText("100 ").width * 0.25;
  canvasContext.fillText("100", xTextScoreRanges, YfirstLine);
  canvasContext.fillText(
    "80",
    xTextScoreRanges,
    prevScalesHeight * 0.2 + YfirstLine
  );
  canvasContext.fillText(
    "60",
    xTextScoreRanges,
    prevScalesHeight * 0.4 + YfirstLine
  );
  canvasContext.fillText(
    "40",
    xTextScoreRanges,
    prevScalesHeight * 0.6 + YfirstLine
  );
  canvasContext.fillText(
    "20",
    xTextScoreRanges,
    prevScalesHeight * 0.8 + YfirstLine
  );
  canvasContext.fillText("0", xTextScoreRanges, prevScalesHeight + YfirstLine);
};

MushraPage.prototype.load = function () {
  this.startTimeOnPage = new Date();

  this.renderCanvas("mushra_items");
  this.mushraAudioControl.initAudio();

  // Restore slider values from this.ratings
  if (Object.keys(this.ratings).length !== 0) {
    var scales = $(".scales");
    for (var i = 0; i < scales.length; i++) {
      var parts = scales[i].name.split("_"); // e.g., "C1_1"
      var stimID = parts[0];
      var metric = parts[1];
      if (this.ratings[stimID] && this.ratings[stimID][metric] !== undefined) {
        $(scales[i]).val(this.ratings[stimID][metric]).slider("refresh");
      }
    }
  }
  if (this.loop.start !== null && this.loop.end !== null) {
    this.mushraAudioControl.setLoop(
      0,
      0,
      this.mushraAudioControl.getDuration(),
      this.mushraAudioControl.getDuration() /
        this.waveformVisualizer.stimulus.audioBuffer.sampleRate
    );
    this.mushraAudioControl.setPosition(0);
  }
};

MushraPage.prototype.save = function () {
  this.macic.unbind();
  this.time += new Date() - this.startTimeOnPage;
  this.mushraAudioControl.freeAudio();
  this.mushraAudioControl.removeEventListener(
    this.waveformVisualizer.numberEventListener
  );

  // Collect slider values into this.ratings
  this.ratings = {};
  var scales = $(".scales");
  for (var i = 0; i < scales.length; i++) {
    var parts = scales[i].name.split("_"); // e.g. "C1_1"
    var stimID = parts[0]; // "C1"
    var metric = parts[1]; // "1" or "2"
    if (!this.ratings[stimID]) {
      this.ratings[stimID] = {};
    }
    this.ratings[stimID][metric] = scales[i].value;
  }

  this.loop.start = parseInt(this.mushraAudioControl.audioLoopStart);
  this.loop.end = parseInt(this.mushraAudioControl.audioLoopEnd);
};

MushraPage.prototype.store = function () {
  var trial = new Trial();
  trial.type = this.pageConfig.type;
  trial.id = this.pageConfig.id;

  // Convert ratings object into MUSHRARating objects
  for (var stimID in this.ratings) {
    if (this.ratings.hasOwnProperty(stimID)) {
      for (var metric in this.ratings[stimID]) {
        if (this.ratings[stimID].hasOwnProperty(metric)) {
          var ratingObj = new MUSHRARating();
          ratingObj.stimulus = stimID + "_" + metric; // e.g. "C1_1" or "C1_2"
          ratingObj.score = this.ratings[stimID][metric];
          ratingObj.time = this.time;
          trial.responses.push(ratingObj);
        }
      }
    }
  }

  this.session.trials.push(trial);
};
