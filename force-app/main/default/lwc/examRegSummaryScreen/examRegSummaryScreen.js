import {LightningElement,track,api} from "lwc";
import contactStagingLicenseVal from "@salesforce/apex/ExamRegistrationController.contactStagingLicenseVal";
import getExamRegistrations from "@salesforce/apex/ExamRegistrationController.getExamRegistrations";
import examRegTableHeader from "@salesforce/label/c.Exam_Reg_Table_Header1";
import getStagingRecord from "@salesforce/apex/ExamRegistrationController.getStagingRecord";
import isApplicantStudentOrGraduate from "@salesforce/apex/AppForCertController.isApplicantStudentOrGraduate";
export default class ExamRegSummaryScreen extends LightningElement{
  @track showMultiple = true;
  @track activeSections = ["physicianLicense"];
  @track optionVal;
  @track examRegistrationsList = [];
  @track showExamRegList = false;
  @track ethnicity;
  @track nationalIDCountry;
  @track nationalIdentification;
  @track nativeLanguage;
  @track socialSecurityNumber;
  @track officiallyEnrolled;
  @track basicSciencesRequirement;
  @track isStudent;
  @track otherNativeLanguage;
  @track hasOtherNativeLanguage = false;
  @track otherLanguagesSpoken;
  @track hasOtherLanguageSpoken = false;
  @track additionalLanguagesSpoken;
  @api caseRecordId;
  label = {examRegTableHeader};
  connectedCallback(){
    //check if applicant is graduate or not on load of page
    isApplicantStudentOrGraduate().then(data=>{
      this.isStudent = !data;
    });
    contactStagingLicenseVal().then(data=>{
      if(data !== ""){
        if(data === "Yes"){
          this.optionVal = "Yes, I have been granted a physician license by a U.S. medical licensing authority based on other licensure examinations.";
        }else if(data === "No"){
          this.optionVal = "No, I have not been granted a physician license by a U.S. medical licensing authority based on other licensure examinations.";
        }
      }else{
        this.optionVal = "";
      }
    });
    this.getExamRegistrationsRecords();
    getStagingRecord().then(result=>{
      if(result){
        if(result.ethnicity){
          this.ethnicity = result.ethnicity.split(";");
        }
          this.nationalIDCountry = result.nationalIDCountry;
          this.nationalIdentification = result.nationalIdentification;
          this.nativeLanguage = result.nativeLanguage;
        if(this.nativeLanguage === "Other"){
          this.hasOtherNativeLanguage = true;
            this.otherNativeLanguage = result.otherNativeLanguage;
        }
        if(result.otherLanguagesSpoken){
          this.otherLanguagesSpoken = result.otherLanguagesSpoken.split(";");
        }
        if(this.otherLanguagesSpoken && this.otherLanguagesSpoken.includes("Other")){
          this.hasOtherLanguageSpoken = true;
            this.additionalLanguagesSpoken = result.addLanguagesSpoken;
        }
          this.socialSecurityNumber = result.socialSecurityNumber;
          this.officiallyEnrolled = result.officiallyEnrolled;
          this.basicSciencesRequirement = result.basicSciencesRequirement;
      }
    });
  }
  getExamRegistrationsRecords(){
    getExamRegistrations()
            .then(value=>{
                if(value){
                    if(value.length > 0){
                        this.showExamRegList = true;
                        this.examRegistrationsList = [];
                        for(let key in value){
                            if(value.hasOwnProperty(key)){
                                let tempRecord = {
                                    recordIdVal: value[key].recordIdVal,
                                    examType: value[key].examType,
                                    eligibilityPeriod: value[key].eligibilityPeriod,
                                    testingRegion: value[key].testingRegion,
                                    testAccomodations: value[key].testAccomodations,
                                };
                                this.examRegistrationsList.push(tempRecord);
                              }
                            }
                          }else{
                            this.examRegistrationsList = [];
                            this.showExamRegList = false;
                          }
                        }
                      })
                      .catch(error=>{
                        window.console.log('Error: ' + JSON.stringify(error));
                      });
                    }
  navigateToLicensePage(event){
    event.preventDefault();
    const selectEvent = new CustomEvent("licenseredirect",{});
    this.dispatchEvent(selectEvent);
  }
  navigateToLandingPage(event){
    event.preventDefault();
    const selectEvent = new CustomEvent("landingredirect",{});
    this.dispatchEvent(selectEvent);
  }
  navigateToEnthnicityPage(event) {
    event.preventDefault();
    const selectEvent = new CustomEvent("ethnicityredirect",{});
    this.dispatchEvent(selectEvent);
  }
  prevButton(event) {
    event.preventDefault();
    const selectEvent = new CustomEvent("previousevent",{detail:{caserecordidexamreg:this.caseRecordId}});
    this.dispatchEvent(selectEvent);
  }

  nextButton(event){
    event.preventDefault();
    const selectEvent = new CustomEvent("nextevent",{});
    this.dispatchEvent(selectEvent);
  }

  cancelButton(event){
    event.preventDefault();
    const selectEvent = new CustomEvent("cancelevent",{});
    this.dispatchEvent(selectEvent);
  }
}