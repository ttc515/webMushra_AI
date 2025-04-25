/**
* @class GenderPage
* Set up to match structural style of MushraPage.
*/
function GenderPage(_pageManager, _session, _pageConfig, _language) {
  this.pageManager = _pageManager;
  this.session = _session;
  this.pageConfig = _pageConfig;
  this.language = _language;
  this.genderSelection = null;
  this.startTimeOnPage = null;
}

GenderPage.prototype.getName = function () {
  return this.pageConfig.name;
};

GenderPage.prototype.init = function () {
  // No specific init logic needed
};

GenderPage.prototype.render = function (_parent) {
  var div = $('<div></div>');
  _parent.append(div);

  var content = (this.pageConfig.content === null) ? "" : this.pageConfig.content;
  var p = $('<p>' + content + '</p>');
  div.append(p);

  var label = $("<label for='genderSelect'><br>Gender:</label>");
  var select = $("<select id='genderSelect'></select>");
  select.append("<option value='' disabled selected>Select your gender</option>");
  select.append("<option value='female'>Female</option>");
  select.append("<option value='male'>Male</option>");
  select.append("<option value='nonbinary'>Non-binary</option>");
  select.append("<option value='other'>Other</option>");
  select.append("<option value='prefer_not_to_say'>Prefer not to say</option>");

  div.append(label).append("<br>").append(select);

  var self = this;
  select.on("change", function () {
    self.genderSelection = $(this).val();
    self.pageManager.pageUpdate(self, true); // enable next button
  });

  this.pageManager.pageUpdate(this, true); //  Unlocks the Next button

};

GenderPage.prototype.load = function () {
  this.startTimeOnPage = new Date();
};

GenderPage.prototype.save = function () {
  var trial = new Trial();
  trial.type = this.pageConfig.type || "gender";
  trial.id = this.pageConfig.id || "demographics_gender";

  if (this.genderSelection) {
    var response = new FreeTextResponse();
    response.id = "gender";
    response.text = this.genderSelection;
    trial.responses.push(response);
  }

  this.session.trials.push(trial);
};

GenderPage.prototype.store = function () {
  // No additional storage logic needed
};
