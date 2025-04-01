function LanguageFamiliarityPage(_pageManager, _session, _pageConfig, _language) {
  this.pageManager = _pageManager;
  this.session = _session;
  this.pageConfig = _pageConfig;
  this.language = _language;

  this.ratings = {};

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
  // No special setup required
};

LanguageFamiliarityPage.prototype.render = function (_parent) {
  this.startTimeOnPage = new Date();

  this.div = $("<div></div>");
  _parent.append(this.div);

  var content = this.pageConfig.content || "";
  this.div.append("<p>" + content + "</p>");

  var table = $("<table id='lang_fam_items' style='width:100%; text-align:center;'></table>");
  var trLabels = $("<tr></tr>");
  var trSliders = $("<tr id='tr_ConditionRatings'></tr>");
  table.append(trLabels);
  table.append(trSliders);

  // Add blank cell for left margin
  trLabels.append("<td></td>");
  trSliders.append("<td></td>");

  for (var i = 0; i < this.languages.length; i++) {
    var lang = this.languages[i];

    // Label
    trLabels.append("<td><b>" + lang.label + "</b></td>");

    // Slider
    var td = $("<td class='spaceForSlider'></td>");
    var slider = $("<span><input type='range' name='" + lang.id + "' class='scales' value='0' min='0' max='100' data-vertical='true' data-highlight='true' style='display:inline-block; float:none;'/></span>");
    td.append(slider);
    trSliders.append(td);
  }

  this.div.append(table);

  // Only initialize sliders in this page
  this.div.find(".scales").slider();
};

LanguageFamiliarityPage.prototype.load = function () {
  if (Object.keys(this.ratings).length !== 0) {
    var scales = this.div.find(".scales");
    for (var i = 0; i < scales.length; i++) {
      var name = scales[i].name;
      if (this.ratings[name] !== undefined) {
        $(scales[i]).val(this.ratings[name]).slider("refresh");
      }
    }
  }
};

LanguageFamiliarityPage.prototype.save = function () {
  this.time += (new Date() - this.startTimeOnPage);

  this.ratings = {};
  var scales = this.div.find(".scales");
  for (var i = 0; i < scales.length; i++) {
    var name = scales[i].name;
    this.ratings[name] = scales[i].value;
  }
};

LanguageFamiliarityPage.prototype.store = function () {
  var trial = new Trial();
  trial.type = this.pageConfig.type;
  trial.id = this.pageConfig.id;

  for (var lang in this.ratings) {
    if (this.ratings.hasOwnProperty(lang)) {
      var ratingObj = new MUSHRARating();
      ratingObj.stimulus = lang;
      ratingObj.score = this.ratings[lang];
      ratingObj.time = this.time;
      trial.responses.push(ratingObj);
    }
  }

  this.session.trials.push(trial);
};
