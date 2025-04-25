function GenderPage(_pageManager, _session, _pageConfig, _language) {
  this.pageManager = _pageManager;
  this.session = _session;
  this.pageConfig = _pageConfig;
  this.language = _language;

  this.ratings = {};
  this.time = 0;
  this.startTimeOnPage = null;

  this.genders = [
    { id: "M", label: "Male" },
    { id: "F", label: "Female" },
    { id: "NB", label: "Non-Binary" },
    { id: "NA", label: "Prefer not to say" }
  ];
}

GenderPage.prototype.getName = function () {
  return this.pageConfig.name;
};

GenderPage.prototype.init = function () {
  // Nothing needed here
};

GenderPage.prototype.render = function (_parent) {
  this.startTimeOnPage = new Date();

  this.div = $("<div></div>").css({
    "min-height": "500px",
    "padding": "30px 0",
    "text-align": "center"
  });
  _parent.append(this.div);

  const content = this.pageConfig.content || "";
  this.div.append(`<p style="font-size: 1.2em;">${content}</p>`);

  const scrollWrapper = $("<div style='overflow-x: auto; width: 100%;'></div>");
  const table = $("<table style='min-width: 600px; margin: 0 auto;'><tr></tr><tr></tr></table>");
  const trLabels = table.find("tr").eq(0);
  const trSliders = table.find("tr").eq(1);

  for (let i = 0; i < this.genders.length; i++) {
    const gender = this.genders[i];

    trLabels.append(`<td style="padding: 10px;"><b>${gender.label}</b></td>`);

    const slider = $(`
      <input 
        type="range" 
        name="${gender.id}" 
        class="gender-slider scales" 
        min="0" max="1" value="0" 
        data-highlight="true" 
        data-popup-enabled="false"
        data-vertical="true"
      />
    `);

    const tdSlider = $("<td style='padding: 10px;'></td>");
    tdSlider.append(slider);
    trSliders.append(tdSlider);
  }

  scrollWrapper.append(table);
  this.div.append(scrollWrapper);

  setTimeout(() => {
    this.div.find(".gender-slider").each(function () {
      $(this).slider();
    });
  }, 0);
};

GenderPage.prototype.load = function () {
  const sliders = this.div.find(".gender-slider");
  sliders.each((i, el) => {
    const name = el.name;
    if (this.ratings[name] !== undefined) {
      $(el).val(this.ratings[name]).slider("refresh");
    }
  });
};

GenderPage.prototype.save = function () {
  this.time += (new Date() - this.startTimeOnPage);
  this.ratings = {};
  const sliders = this.div.find(".gender-slider");
  sliders.each((i, el) => {
    this.ratings[el.name] = el.value;
  });
};

GenderPage.prototype.store = function () {
  const trial = new Trial();
  trial.type = this.pageConfig.type;
  trial.id = this.pageConfig.id;

  for (let gender in this.ratings) {
    if (this.ratings.hasOwnProperty(gender)) {
      const rating = new MUSHRARating();
      rating.stimulus = gender;
      rating.score = this.ratings[gender];
      rating.time = this.time;
      trial.responses.push(rating);
    }
  }

  this.session.trials.push(trial);
};
