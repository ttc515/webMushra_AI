/**
* @class GenericPage
* @property {string} title the page title
* @property {string} the page content
*/
function GenericPage(_pageManager, _pageConfig) {
  this.pageManager = _pageManager;
  this.title = _pageConfig.name;
  this.content = _pageConfig.content;
  this.language = _pageConfig.language;
  this.config = _pageConfig;
}

/**
* Returns the page title.
* @memberof GenericPage
* @returns {string}
*/
GenericPage.prototype.getName = function () {
  return this.title;
};

/**
* Renders the page
* @memberof GenericPage
*/
GenericPage.prototype.render = function (_parent) {
  var contentDiv = $("<div>" + this.content + "</div>");
  _parent.append(contentDiv);

  
    var labelGender = $("<label for='genderSelect'><br>Gender:</label>");
    var select = $("<select id='genderSelect'></select>");
    select.append("<option value='' disabled selected>Select your gender</option>");
    select.append("<option value='female'>Female</option>");
    select.append("<option value='male'>Male</option>");
    select.append("<option value='nonbinary'>Non-binary</option>");
    select.append("<option value='other'>Other</option>");
    select.append("<option value='prefer_not_to_say'>Prefer not to say</option>");
    _parent.append(labelGender).append("<br>").append(select);
  

  if (this.config.aiReasoning === true) {
    var labelReason = $("<label for='aiReason'><br><br>Please list the main features that influenced your decision in bullet points:</label>");
    var textarea = $("<textarea id='aiReason' rows='6' cols='70'></textarea>");
    _parent.append(labelReason).append("<br>").append(textarea);
  }


this.pageManager.pageTemplateRenderer.unlockNextButton();

};



/**
* Saves the page
* @memberof GenericPage
*/
GenericPage.prototype.save = function () {
  var trial = new Trial();
  trial.type = "generic";
  trial.id = this.config.id;

  if (this.config.gender === true) {
    var genderValue = $("#genderSelect").val();
    if (genderValue) {
      var genderResponse = new FreeTextResponse();
      genderResponse.id = "gender";
      genderResponse.text = genderValue;
      trial.responses.push(genderResponse);
    }
  }

  if (this.config.aiReasoning === true) {
    var reasonText = $("#aiReason").val();
    if (reasonText && reasonText.trim() !== "") {
      var reasonResponse = new FreeTextResponse();
      reasonResponse.id = "ai_decision_reason";
      reasonResponse.text = reasonText.trim();
      trial.responses.push(reasonResponse);
    }
  }

  this.pageManager.session.trials.push(trial);
};
