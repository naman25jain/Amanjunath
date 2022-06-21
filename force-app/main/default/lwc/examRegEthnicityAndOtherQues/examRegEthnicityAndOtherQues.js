import { LightningElement, track, wire, api } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import nationalIdCountryField from "@salesforce/schema/Contact.National_ID_Country__c";
import ethnicityField from "@salesforce/schema/Contact.Ethnicity__c";
import officiallyEnrolledField from "@salesforce/schema/Exam_Registration__c.Officially_Enrolled__c";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import examRegObject from "@salesforce/schema/Exam_Registration__c";
import saveStagingRecord from "@salesforce/apex/ExamRegistrationController.saveStagingRecord";
import getStagingRecord from "@salesforce/apex/ExamRegistrationController.getStagingRecord";
import isApplicantStudentOrGraduate from "@salesforce/apex/AppForCertController.isApplicantStudentOrGraduate";

export default class ExamRegEthnicityAndOtherQues extends LightningElement {
  @track listOptions;
  @track nativeLanguageOptions = [
    {value: 'Do not wish to respond', label: 'Do not wish to respond'},
    {value: 'English', label: 'English'},
    {value: 'Other', label: 'Other'}
  ];
  @track picklist;

  @track nativeLanguage;
  @track selectedOptions;
  @track hasResponse = true;
  @track socialSecurityNumber;
  @track nationalIdentification;
  @track nationalIDCountry;
  @track countryList;
  @track spinner;
  @track ethnicity;
  @track noResponse = false;
  @track selectedEthnicities;
  @track selectedLanguage;
  @track showMsg;
  @track isStudent;
  @track officiallyEnrolled;
  @track basicSciencesRequirement;
  @track clickBtn;
  @track otherNativeLanguage;
  @track hasOtherNativeLanguage = false;
  @track listLanguagesSpoken = [
    {value: 'Arabic', label: 'Arabic'},
    {value: 'Chinese', label: 'Chinese'},
    {value: 'French', label: 'French'},
    {value: 'Italian', label: 'Italian'},
    {value: 'Korean', label: 'Korean'},
    {value: 'Russian', label: 'Russian'},
    {value: 'Spanish', label: 'Spanish'},
    {value: 'Tagalog', label: 'Tagalog'},
    {value: 'Vietnamese', label: 'Vietnamese'},
    {value: 'Other', label: 'Other'}
  ];
  @track selectedLanguagesSpoken;
  @track selectedLangSpoken;
  @track hasAddLanguagesSpoken = false;
  @track addLanguagesSpoken;
  @api showBackToSummary;

  connectedCallback() {
    //check if applicant is graduate or not on load of page
    isApplicantStudentOrGraduate().then(data => {
      this.isStudent = !data;
    });
    getStagingRecord().then(result=>{
        if (result) {
            if (result.ethnicity !== "" && result.ethnicity !== undefined) {
              this.selectedOptions = result.ethnicity.split(";");

              if(this.selectedOptions[0] ==='Do not wish to respond'){
                  this.hasResponse = false;
                  this.noResponse =true;
              }else{
                this.selectedEthnicities = JSON.stringify(this.selectedOptions);
              }
            }
            if (result.nationalIDCountry !== "") {
              this.nationalIDCountry = result.nationalIDCountry;
            }
            if (result.nationalIdentification !== "") {
              this.nationalIdentification = result.nationalIdentification;
            }
            if (result.nativeLanguage !== "") {
              this.nativeLanguage = result.nativeLanguage;
              this.selectedLanguage = result.nativeLanguage;
              this.hasOtherNativeLanguage = false;
              if(this.selectedLanguage === 'Other') {
                this.hasOtherNativeLanguage = true;
              }
            }
            if (result.otherNativeLanguage !== "") {
              this.otherNativeLanguage = result.otherNativeLanguage;
            }
            if (result.otherLanguagesSpoken !== "" && result.otherLanguagesSpoken !== undefined) {
              this.selectedLanguagesSpoken = result.otherLanguagesSpoken.split(";");
              this.hasAddLanguagesSpoken = false;
              if(this.selectedLanguagesSpoken.includes("Other")){
                  this.hasAddLanguagesSpoken = true;
              }
              this.selectedLangSpoken = JSON.stringify(this.selectedLanguagesSpoken);
            }
            if (result.addLanguagesSpoken !== "") {
              this.addLanguagesSpoken = result.addLanguagesSpoken;
            }
            if (result.socialSecurityNumber !== "") {
              this.socialSecurityNumber = result.socialSecurityNumber;
            }
            if (result.officiallyEnrolled !== "") {
              this.officiallyEnrolled = result.officiallyEnrolled;
            }
            if (result.officiallyEnrolled !== "") {
              this.basicSciencesRequirement = result.basicSciencesRequirement;
            }
          }

    });
  }

  @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
  objectInfo;

  @wire(getObjectInfo, { objectApiName: examRegObject})
  objectInfoExamReg;
  @wire(getPicklistValues, {
    recordTypeId: "$objectInfoExamReg.data.defaultRecordTypeId",
    fieldApiName: officiallyEnrolledField
  })
  getPickList(result) {
    if (result !== undefined) {
      if (result.data) {
        this.picklist = result.data.values;
      }
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: nationalIdCountryField
  })
  getCountryList(result) {
    if (result !== undefined) {
      if (result.data) {
        this.countryList = result.data.values;
      }
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: ethnicityField
  })
  getEthnicityList(result) {
    if (result !== undefined) {
      if (result.data) {
        let picklist;
        picklist = result.data.values;
        this.listOptions =  picklist.filter(pick => pick.value !== 'Do not wish to respond');
      }
    }
  }

  handleCountry(event) {
    this.nationalIDCountry = event.detail.value;
  }

  handleCheckbox(event) {
    this.hasResponse = true;
    if (event.target.checked) {
      this.hasResponse = false;
    }
  }

  handleChange(event) {
    this.selectedEthnicities = JSON.stringify(event.detail.value);
  }

  handleLanguage(event) {
    this.selectedLanguage = event.detail.value;
    this.hasOtherNativeLanguage = false;
    if(this.selectedLanguage === "Other") {
      this.hasOtherNativeLanguage = true;
    }
  }

  handleLangSpokenChange(event) {
    this.selectedLangSpoken = JSON.stringify(event.detail.value);
    this.hasAddLanguagesSpoken = false;
    if(this.selectedLangSpoken.includes("Other")){
      this.hasAddLanguagesSpoken = true;
    }
  }

  handleQn1(event) {
      this.officiallyEnrolled = event.detail.value;
  }
  handleQn2(event) {
    this.basicSciencesRequirement = event.detail.value;
}

  saveStagingContactRecord() {
    let breakSave = false;
    if (this.selectedLanguage === undefined || this.selectedLanguage === "") {
      breakSave = true;
      if (this.template.querySelector("#nativeLanguageError") === null) {
        let elem = document.createElement("div");
        elem.id = "nativeLanguageError";
        elem.textContent = "Select valid native language";
        elem.style = "color:#ff0000; clear:both;";
        this.template.querySelector(".language").appendChild(elem);
        this.template
          .querySelector(".language")
          .classList.add("slds-has-error");
      }
    } else {
      if (this.template.querySelector("#nativeLanguageError") !== null) {
        let elem = this.template.querySelector("#nativeLanguageError");
        elem.parentNode.removeChild(elem);
        this.template
          .querySelector(".language")
          .classList.remove("slds-has-error");
      }
    }
    if (this.selectedLanguage === "Other" && (this.template.querySelector(".otherNativeLanguage").value === undefined || this.template.querySelector(".otherNativeLanguage").value === "")) {
      breakSave = true;
      if (this.template.querySelector("#otherNativeLanguageError") === null) {
        let elem = document.createElement("div");
        elem.id = "otherNativeLanguageError";
        elem.textContent = "Please enter other native language";
        elem.style = "color:#ff0000; clear:both;";
        this.template.querySelector(".language").appendChild(elem);
        this.template
          .querySelector(".language")
          .classList.add("slds-has-error");
      }
    } else {
      if (this.template.querySelector("#otherNativeLanguageError") !== null) {
        let elem = this.template.querySelector("#otherNativeLanguageError");
        elem.parentNode.removeChild(elem);
        this.template
          .querySelector(".language")
          .classList.remove("slds-has-error");
      }
    }
    if(this.isStudent){
        if(this.officiallyEnrolled === undefined || this.basicSciencesRequirement ===undefined){
            breakSave = true;
          if (this.template.querySelector("#qnError") === null) {
            let elem = document.createElement("div");
            elem.id = "qnError";
            elem.textContent = "You must provide a response to the questions on student status and exam eligibility in order to proceed.";
            elem.style = "color:#ff0000; clear:both;";
            this.template.querySelector(".medicalSchool").appendChild(elem);
          }
        } else {
          if (this.template.querySelector("#qnError") !== null) {
            let elem = this.template.querySelector("#qnError");
            elem.parentNode.removeChild(elem);
          }
        }
        if(this.officiallyEnrolled === 'No' ){
          breakSave = true;
        if (this.template.querySelector("#qnError1") === null) {
          let elem = document.createElement("div");
          elem.id = "qnError1";
          elem.innerHTML = "You do not meet the minimum eligibility requirements to apply for USMLE and cannot continue with your application at this time. Please <a href=\x22https://www.ecfmg.org/contact.html#general-inquiries\x22 target=\x22_blank\x22>contact us</a> if you have questions about your student status and eligibility for USMLE.";
          elem.style = "color:#ff0000; clear:both;";
          this.template.querySelector(".officiallyEnrolled").appendChild(elem);
        }
      } else {
        if (this.template.querySelector("#qnError1") !== null) {
          let elem = this.template.querySelector("#qnError1");
          elem.parentNode.removeChild(elem);
        }
      }
      if(this.basicSciencesRequirement === 'No' ){
        breakSave = true;
      if (this.template.querySelector("#qnError2") === null) {
        let elem = document.createElement("div");
        elem.id = "qnError2";
        elem.innerHTML = "You do not meet the minimum eligibility requirements to apply for USMLE and cannot continue with your application at this time. Please <a href=\x22https://www.ecfmg.org/contact.html#general-inquiries\x22 target=\x22_blank\x22>contact us</a> if you have questions about your student status and eligibility for USMLE.";
        elem.style = "color:#ff0000; clear:both;";
        this.template.querySelector(".basicSciences").appendChild(elem);
      }
    } else {
      if (this.template.querySelector("#qnError2") !== null) {
        let elem = this.template.querySelector("#qnError2");
        elem.parentNode.removeChild(elem);
      }
    }
    }
    if (!breakSave) {
      this.spinner = true;
      let updateRecord = {};
      updateRecord.ethnicity = "";
      updateRecord.nationalIDCountry = "";
      updateRecord.nationalIdentification = "";
      updateRecord.nativeLanguage = "";
      updateRecord.socialSecurityNumber = "";
      updateRecord.officiallyEnrolled="";
      updateRecord.basicSciencesRequirement="";
      updateRecord.otherNativeLanguage = "";
      updateRecord.otherLanguagesSpoken = "";
      updateRecord.addLanguagesSpoken = "";
      if (this.selectedEthnicities !== undefined) {
        let ethn = JSON.parse(this.selectedEthnicities);
        let selected = [];
        let ethValues = [];
        for(var y in this.listOptions){
          ethValues.push(this.listOptions[y].value);
        }
        for(var x in ethn){
          if(ethValues.includes(ethn[x])){
            selected.push(ethn[x]);
          }
        }
        updateRecord.ethnicity = JSON.stringify(selected);
      }
      if (this.nationalIDCountry !== undefined) {
        updateRecord.nationalIDCountry = this.nationalIDCountry;
      }
      if (this.officiallyEnrolled !== undefined) {
        updateRecord.officiallyEnrolled = this.officiallyEnrolled;
      }
      if (this.basicSciencesRequirement !== undefined) {
        updateRecord.basicSciencesRequirement = this.basicSciencesRequirement;
      }
      if (
        this.template.querySelector(".nationalIdentification").value !==
          undefined ||
        this.template.querySelector(".nationalIdentification").value !== ""
      ) {
        updateRecord.nationalIdentification = this.template.querySelector(
          ".nationalIdentification"
        ).value;
      }
      if (this.selectedLanguage !== undefined) {
        updateRecord.nativeLanguage = this.selectedLanguage;
      }
      if(this.template.querySelector(".otherNativeLanguage") !== null){
        if (
          this.template.querySelector(".otherNativeLanguage").value !==
            undefined ||
          this.template.querySelector(".otherNativeLanguage").value !== ""
        ) {
          updateRecord.otherNativeLanguage = this.template.querySelector(
            ".otherNativeLanguage"
          ).value;
        }
      }
      if (this.selectedLangSpoken !== undefined) {
        let lang = JSON.parse(this.selectedLangSpoken);
        let selectedLang = [];
        let langValues = [];
        for(var i in this.listLanguagesSpoken){
          langValues.push(this.listLanguagesSpoken[i].value);
        }
        for(var j in lang){
          if(langValues.includes(lang[j])){
            selectedLang.push(lang[j]);
          }
        }
        updateRecord.otherLanguagesSpoken = JSON.stringify(selectedLang);
      }
      if(this.template.querySelector(".addLanguagesSpoken") !== null){
        if (
          this.template.querySelector(".addLanguagesSpoken").value !==
            undefined ||
          this.template.querySelector(".addLanguagesSpoken").value !== ""
        ) {
          updateRecord.addLanguagesSpoken = this.template.querySelector(
            ".addLanguagesSpoken"
          ).value;
        }
      }
      if (
        this.template.querySelector(".socialSecurityNumber").value !==
          undefined ||
        this.template.querySelector(".socialSecurityNumber").value !== ""
      ) {
        updateRecord.socialSecurityNumber = this.template.querySelector(
          ".socialSecurityNumber"
        ).value;
      }
      if(this.hasResponse === false){
        let updateValue =[];
        updateValue[0]='Do not wish to respond';
        updateRecord.ethnicity = JSON.stringify(updateValue);
      }

      saveStagingRecord({ updateValues: JSON.stringify(updateRecord) })
        .then(result => {
          if (result !== undefined) {
            this.spinner = false;
            this.showMsg = true;
            this.successMessageText = "Successfully updated";
            this.template.querySelector(".content").scrollIntoView();
            if(this.clickBtn ==='next'){
                const selectEvent = new CustomEvent("nextevent", {});
                this.dispatchEvent(selectEvent);
            }
            if(this.clickBtn ==='summary'){
              const selectEvent = new CustomEvent("backtosummary", {});
              this.dispatchEvent(selectEvent);
          }
          }
        })
        .catch(error => {
          this.message = "Error received: code" + error.errorCode;
        });
    }
  }

  nextButton(event) {
    event.preventDefault();
    this.saveStagingContactRecord();
    this.clickBtn = 'next';


  }
  backToSummary(event){
    this.clickBtn = 'summary';
    this.saveStagingContactRecord();
  }
  prevButton(event) {
    event.preventDefault();
    const selectEvent = new CustomEvent("previousevent", {});
    this.dispatchEvent(selectEvent);
  }
  cancelButton(event) {
    event.preventDefault();
    const selectEvent = new CustomEvent("cancelevent", {});
    this.dispatchEvent(selectEvent);
  }
}