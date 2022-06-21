import { LightningElement, track,api } from "lwc";
import previousLicenseUpdate from "@salesforce/apex/AppForCertController.previousLicenseUpdate";
import contactStagingLicenseVal from "@salesforce/apex/ExamRegistrationController.contactStagingLicenseVal";

export default class ExamRegPreviousLicense extends LightningElement {
  @track btnNotDisabled = false;
  @track unsetCheckbox = false;
  @track viewSection;
  @track optionVal;
  @track hasFetchedValue = false;
  @api showBackToSummary;

  renderedCallback() {
    if (this.hasFetchedValue && this.optionVal === "option1") {
      this.template
        .querySelectorAll(".headerSection1.checkbox")
        .forEach(elem => {
          elem.checked = true;
        });
    }
  }

  connectedCallback() {
    contactStagingLicenseVal().then(data => {
      if (data !== "") {
        if (data === "Yes") {
          this.optionVal = "option1";
          this.btnNotDisabled = true;
          this.hasFetchedValue = true;
          this.licenseValChange(this.optionVal);
          this.template.querySelectorAll(".radio.radioButton").forEach(elem => {
            if (elem.value === "option1") {
              elem.checked = true;
            }
          });  
            
        } else if (data === "No") {
          this.optionVal = "option2";
          this.btnNotDisabled = true;
          this.licenseValChange(this.optionVal);
          this.template.querySelectorAll(".radio.radioButton").forEach(elem => {
            if (elem.value === "option2") {
              elem.checked = true;
            }
          });  
        }
      } else {
        this.optionVal = "";
      }
    });
  }
  backToSummary(event){
    previousLicenseUpdate({
      selectedOption: this.optionVal
    }).then(saveresult => {
      if (saveresult === "Success") {
        this.backToSummaryButton();
      }
    });
  }
  handleClick(event) {
    previousLicenseUpdate({
      selectedOption: this.optionVal
    }).then(saveresult => {
      if (saveresult === "Success") {
        this.nextButton();
      }
    });
  }

  handleChangeCheckBox(event) {
    this.btnNotDisabled = false;
    this.hasFetchedValue = false;
    if (event.target.checked) {
      this.btnNotDisabled = true;
      this.hasFetchedValue = true;
    }
    if (this.unsetCheckbox === true) {
      event.target.checked = false;
    }
  }

  handleChange(event) {
    const selectedOption = event.target.value;
    this.optionVal = selectedOption;
    this.licenseValChange(selectedOption);
  }

  licenseValChange(receivedOption) {
    if (receivedOption === "option2") {
      this.btnNotDisabled = true;
      this.unsetCheckbox = true;
      this.viewSection = false;
    } else {  
      this.viewSection = true;
      this.unsetCheckbox = false;
      if(!this.hasFetchedValue){
        this.btnNotDisabled = false;
      }     
    }
  }

  prevButton(event) {
    event.preventDefault();
    const selectEvent = new CustomEvent("previousevent", {});
    this.dispatchEvent(selectEvent);
  }

  nextButton() {
    const selectEvent = new CustomEvent("nextevent", {});
    this.dispatchEvent(selectEvent);
  }

  cancelButton(event) {
    event.preventDefault();
    const selectEvent = new CustomEvent("cancelevent", {});
    this.dispatchEvent(selectEvent);
  }
  backToSummaryButton(){
    const selectEvent = new CustomEvent("backtosummary", {});
    this.dispatchEvent(selectEvent)
  }
}