function LanguageFamiliarityPage(_pageManager, _session, _pageConfig, _language) {
  this.pageManager = _pageManager;
  this.session = _session;
  this.pageConfig = _pageConfig;
  this.language = _language;
  // Ratings will be stored as a key/value pair: language id -> slider value.
  this.ratings = {};
  
  // Define the languages; these keys will also be used as the 'name' attribute on the slider.
  this.languages = [
    { id: "Lang_eng", label: "English" },
    { id: "Lang_jp", label: "Japanese" },
    { id: "Lang_man", label: "Mandarin" },
    { id: "Lang_canto", label: "Cantonese" }
  ];
  
  this.time = 0;
  this.startTimeOnPage = null;
}

LanguageFamiliarityPage.prototype.getName = function () {
  return this.pageConfig.name;
};

LanguageFamiliarityPage.prototype.init = function () {
  // No additional initialization needed.
};

LanguageFamiliarityPage.prototype.render = function (_parent) {
  // Record the start time for time tracking.
  this.startTimeOnPage = new Date();

  // Create and append the main container.
  this.div = $("<div></div>");
  _parent.append(this.div);
  
  // Add any descriptive content from the page config.
  var content = this.pageConfig.content || "";
  this.div.append("<p>" + content + "</p>");
  
  // Create a table layout similar to the MUSHRA page.
  // The first row will contain the language labels, and the second row will contain the sliders.
  var table = $("<table id='lang_fam_items' style='width:100%; text-align:center;'></table>");
  var trLabels = $("<tr></tr>");
  var trSliders = $("<tr id='tr_ConditionRatings'></tr>");
  table.append(trLabels);
  table.append(trSliders);
  
  // Insert an empty cell for the left column (kept for consistent layout with MUSHRA page).
  trLabels.append("<td></td>");
  trSliders.append("<td></td>");
  
  // For each language, add a label cell and a slider cell.
  for (var i = 0; i < this.languages.length; i++) {
    var lang = this.languages[i];
    
    // Add the label.
    trLabels.append("<td><b>" + lang.label + "</b></td>");
    
    // Create a slider element that uses the same slider widget as in your MUSHRA page.
    // Note: the slider is vertical, with a range of 0 to 100. Initial value is 0.
    var td = $("<td class='spaceForSlider'></td>");
    var slider = $("<span><input type='range' name='" + lang.id + "' class='scales' value='0' min='0' max='100' data-vertical='true' data-highlight='true' style='display:inline-block; float:none;'/></span>");
    td.append(slider);
    trSliders.append(td);
  }
  
  this.div.append(table);
  
  // Initialize the jQuery Mobile slider widget (same as used in your MUSHRA page).
  $(".scales").slider();
};

LanguageFamiliarityPage.prototype.load = function () {
  // If any ratings are already stored, refresh the slider values.
  if (Object.keys(this.ratings).length !== 0) {
    var scales = $(".scales");
    for (var i = 0; i < scales.length; i++) {
      var name = scales[i].name; // Expecting values such as "Lang_eng"
      if (this.ratings[name] !== undefined) {
        $(scales[i]).val(this.ratings[name]).slider("refresh");
      }
    }
  }
};

LanguageFamiliarityPage.prototype.save = function () {
  // Update the total time on the page.
  this.time += (new Date() - this.startTimeOnPage);
  
  // Save slider values into the ratings object.
  // We assume each slider's "name" attribute is one of Lang_eng, Lang_jp, etc.
  this.ratings = {};
  var scales = $(".scales");
  for (var i = 0; i < scales.length; i++) {
    var name = scales[i].name;
    this.ratings[name] = scales[i].value;
  }
};

LanguageFamiliarityPage.prototype.store = function () {
  // Create a new trial object and fill it with the slider responses.
  var trial = new Trial();
  trial.type = this.pageConfig.type;
  trial.id = this.pageConfig.id;
  
  // For each language slider, create a MUSHRARating response.
  for (var lang in this.ratings) {
    if (this.ratings.hasOwnProperty(lang)) {
      var ratingObj = new MUSHRARating();
      ratingObj.stimulus = lang;      // e.g., "Lang_eng"
      ratingObj.score = this.ratings[lang];
      ratingObj.time = this.time;
      trial.responses.push(ratingObj);
    }
  }
  
  this.session.trials.push(trial);
};
