/**
* @class GenderPage
* @property {string} title the page title
* @property {string} the page content
*/
function GenderPage(_pageManager, _pageConfig) {
  this.pageManager = _pageManager;
  this.title = _pageConfig.name;
  this.content = _pageConfig.content;
  this.language = _pageConfig.language;
}

/**
* Returns the page title.
* @memberof GenderPage
* @returns {string}
*/
GenderPage.prototype.getName = function () {
  return this.title;
};

/**
* Renders the page
* @memberof GenderPage
*/
GenderPage.prototype.render = function (_parent) {
  var contentDiv = $('<div>' + this.content + '</div>');
  _parent.append(contentDiv);

  var label = $("<label for='genderSelect'><br>Gender:</label>");
  var select = $("<select id='genderSelect'></select>");
  select.append("<option value='' disabled selected>Select your gender</option>");
  select.append("<option value='female'>Female</option>");
  select.append("<option value='male'>Male</option>");
  select.append("<option value='nonbinary'>Non-binary</option>");
  select.append("<option value='other'>Other</option>");
  select.append("<option value='prefer_not_to_say'>Prefer not to say</option>");
  _parent.append(label).append("<br>").append(select);

  // Unlock Next only when a selection is made
  var self = this;
  select.on("change", function () {
    if ($(this).val()) {
      self.pageManager.pageUpdate(self, true);
    } else {
      self.pageManager.pageUpdate(self, false);
    }
  });

  // Initially lock Next
  this.pageManager.pageUpdate(this, false);
};

/**
* Saves the page
* @memberof GenderPage
*/
GenderPage.prototype.save = function () {
  var trial = new Trial();
  trial.type = "gender";
  trial.id = "demographics_gender";

  var genderValue = $('#genderSelect').val();
  if (genderValue) {
    var response = new FreeTextResponse();
    response.id = "gender";
    response.text = genderValue;
    trial.responses.push(response);
  }

  this.pageManager.session.trials.push(trial);
};
