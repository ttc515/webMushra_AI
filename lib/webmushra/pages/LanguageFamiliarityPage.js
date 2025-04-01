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

    // Label row
    trLabels.append(`<td style="padding: 10px;"><b>${lang.label}</b></td>`);

    // Slider (with no inline size and MUSHRA-style class)
    const slider = $(`
      <input 
        type="range" 
        name="${lang.id}" 
        class="lang-slider scales" 
        min="0" max="100" value="0" 
        data-highlight="true" 
        data-vertical="true"
        data-popup-enabled="false"
      />
    `);

    const tdSlider = $("<td style='padding: 10px;'></td>");
    slider.appendTo(tdSlider);
    trSliders.append(tdSlider);

    // Value label below slider
    const valDisplay = $(`<div id="${lang.id}_val" class="value-display">0</div>`);
    const tdValue = $("<td></td>").append(valDisplay);
    trValues.append(tdValue);

    // Update value display when slider moves
    slider.on("input change", function () {
      $(`#${lang.id}_val`).text($(this).val());
    });
  }

  this.div.append(table);

  // Ensure proper rendering
  setTimeout(() => {
    const sliders = this.div.find(".lang-slider");
    sliders.each(function () {
      $(this).slider({ popupEnabled: false });
    });
  }, 0);
};
