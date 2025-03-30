/*************************************************************************
         (C) Copyright AudioLabs 2017 

This source code is protected by copyright law and international treaties.
This source code is made available to You subject to the terms and conditions 
of the Software License for the webMUSHRA.js Software. Said terms and conditions 
have been made available to You prior to Your download of this source code. By 
downloading this source code You agree to be bound by the above mentioned terms 
and conditions, which can also be found here: https://www.audiolabs-erlangen.de/resources/webMUSHRA.
Any unauthorised use of this source code may result in severe civil and criminal penalties,
and will be prosecuted to the maximum extent possible under law.
**************************************************************************/

function LanguageFamiliarityPage(pageManager, pageConfig, language) {
  this.pageManager = pageManager;
  this.pageConfig = pageConfig;
  this.language = language;
  // Object to store slider values, keys will be: Lang_eng, Lang_jp, Lang_man, Lang_canto
  this.ratings = {};
  this.startTime = null;
  this.time = 0;
}

LanguageFamiliarityPage.prototype.getName = function() {
  return this.pageConfig.name;
};

LanguageFamiliarityPage.prototype.render = function(parent) {
  // Create a container div and append it to parent.
  var div = $("<div></div>");
  parent.append(div);

  // Instruction text
  var instruction = this.pageConfig.content || "Please rate your familiarity with the following languages (0 = not familiar, 100 = very familiar):";
  div.append($("<p>" + instruction + "</p>"));

  // Create a table to lay out the sliders
  var table = $("<table></table>");
  div.append(table);

  // Define the languages with keys and labels
  var languages = [
    { key: "Lang_eng", label: "English" },
    { key: "Lang_jp",  label: "Japanese" },
    { key: "Lang_man", label: "Mandarin" },
    { key: "Lang_canto", label: "Cantonese" }
  ];

  // Create one row per language
  for (var i = 0; i < languages.length; i++) {
    var row = $("<tr></tr>");
    table.append(row);
    
    // Label cell
    var labelCell = $("<td></td>").text(languages[i].label);
    row.append(labelCell);
    
    // Slider cell
    var sliderCell = $("<td></td>");
    row.append(sliderCell);
    
    // Create slider input element
    var slider = $("<input type='range' min='0' max='100' step='1' value='50' class='langSlider' />");
    // Set the name attribute to the language key; this is used for saving.
    slider.attr("name", languages[i].key);
    sliderCell.append(slider);
    
    // Create a span to display the current slider value
    var valueDisplay = $("<span class='sliderValue'>50</span>");
    sliderCell.append(valueDisplay);
    
    // Update the display on slider input
    slider.on("input", function() {
      $(this).next(".sliderValue").text($(this).val());
    });
  }
};

LanguageFamiliarityPage.prototype.load = function() {
  // Record the start time
  this.startTime = new Date();
  // If ratings were previously saved, restore slider values.
  if (Object.keys(this.ratings).length !== 0) {
    $(".langSlider").each(function() {
      var name = $(this).attr("name");
      if (this.ratings && this.ratings[name] !== undefined) {
        $(this).val(this.ratings[name]).trigger("input");
      }
    }.bind(this));
  }
};

LanguageFamiliarityPage.prototype.save = function() {
  // Update total time spent on the page.
  this.time += (new Date() - this.startTime);
  // Collect values from each slider.
  this.ratings = {};
  $(".langSlider").each(function() {
    var name = $(this).attr("name");
    var value = $(this).val();
    this.ratings[name] = value;
  }.bind(this));
};

LanguageFamiliarityPage.prototype.store = function() {
  var trial = new Trial();
  trial.type = this.pageConfig.type;
  trial.id = this.pageConfig.id;
  
  // For each language slider, create a MUSHRARating object.
  for (var key in this.ratings) {
    if (this.ratings.hasOwnProperty(key)) {
      var ratingObj = new MUSHRARating();
      ratingObj.stimulus = key;     // e.g., Lang_eng
      ratingObj.score = this.ratings[key]; // the slider value
      ratingObj.time = this.time;
      trial.responses.push(ratingObj);
    }
  }
  
  // Save the trial to the session.
  this.pageManager.getSession().trials.push(trial);
};
