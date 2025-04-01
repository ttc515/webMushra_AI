function LanguageFamiliarityPage(_pageManager, _session, _pageConfig, _language) {
  this.pageManager = _pageManager;
  this.session = _session;
  this.pageConfig = _pageConfig;
  this.language = _language;

  this.ratings = {};
  this.time = 0;
  this.startTimeOnPage = null;

  this.languages = [
    { id: "Lang_eng", label: "English" },
    { id: "Lang_jp", label: "Japanese" },
    { id: "Lang_man", label: "Mandarin" },
    { id: "Lang_canto", label: "Cantonese" }
  ];
}

LanguageFamiliarityPage.prototype.getName = function () {
  return this.pageConfig.name;
};

LanguageFamiliarityPage.prototype.init = function () {};

LanguageFamiliarityPage.prototype.render = function (_parent) {
  this.startTimeOnPage = new Date();

  this.div = $("<div></div>").css({
    "min-height": "500px",
    "padding": "30px 0",
    "text-align": "center"
  });
  _parent.append(this.div);

  const content = this.pageConfig.content || "";
  this.div.append(`<p style="font-size: 1.2em;">${content}</p>`);

  const table = $("<table style='margin: 0 auto;'><tr></tr><tr></tr><tr></tr></table>");
  const trLabels = table.find("tr").eq(0);
  const trSliders = table.find("tr").eq(1);
  const trValues = table.find("tr").eq(2);

  for (let i = 0; i < this.languages.length; i++) {
    const lang = this.languages[i];

    // Label
    trLabels.append(`<td><b>${lang.label}</b></td>`);

    // Slider
    const slider = $(`
      <input 
        type='range' 
        name='${lang.id}' 
        class='lang-slider' 
        value='0' 
        min='0' 
        max='100' 
        data-highlight='true' 
        data-vertical='true' 
        style='height: 200px; width: 50px;'
      />
    `);
    const tdSlider = $("<td></td>").append(slider);
    trSliders.append(tdSlider);

    // Value display (optional)
    const valueDisplay = $(`<td><div id='${lang.id}_val'>0</div></td>`);
    trValues.append(valueDisplay);

    // Bind slider to live update
    slider.on("input change", function () {
      $(`#${lang.id}_val`).text($(this).val());
    });
  }

  this.div.append(table);

  // Initialize the sliders just in this page
  this.div.find(".lang-slider").slider();
};

LanguageFamiliarityPage.prototype.load = function () {
  const sliders = this.div.find(".lang-slider");
  sliders.each((i, el) => {
    const name = el.name;
    if (this.ratings[name] !== undefined) {
      $(el).val(this.ratings[name]).slider("refresh");
      $(`#${name}_val`).text(this.ratings[name]);
    }
  });
};

LanguageFamiliarityPage.prototype.save = function () {
  this.time += (new Date() - this.startTimeOnPage);
  this.ratings = {};
  const sliders = this.div.find(".lang-slider");
  sliders.each((i, el) => {
    this.ratings[el.name] = el.value;
  });
};

LanguageFamiliarityPage.prototype.store = function () {
  const trial = new Trial();
  trial.type = this.pageConfig.type;
  trial.id = this.pageConfig.id;

  for (let lang in this.ratings) {
    if (this.ratings.hasOwnProperty(lang)) {
      const rating = new MUSHRARating();
      rating.stimulus = lang;
      rating.score = this.ratings[lang];
      rating.time = this.time;
      trial.responses.push(rating);
    }
  }

  this.session.trials.push(trial);
};
