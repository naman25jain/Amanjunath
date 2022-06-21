import {
  LightningElement,
  track,
  api
} from "lwc";
import {
  NavigationMixin
} from "lightning/navigation";
import {
  ShowToastEvent
} from "lightning/platformShowToastEvent";

//import required custom labels
import reviewConfirmation from "@salesforce/label/c.App_for_Cert_Review_Confirmation";
import reviewMessage from "@salesforce/label/c.App_for_Cert_Review_Instruction";
import appForCertReviewStep from "@salesforce/label/c.Exam_Reg_AppForCert_Review";
import countryWarning from "@salesforce/label/c.OFAC_warning_error_message";
import dateValidation from "@salesforce/label/c.Student_date_validation";
import studentStatus from "@salesforce/label/c.Medical_Education_type_Student";
import appForCertError from "@salesforce/label/c.Exam_Reg_AppForCert_Error";

//import required apex methods
import getOtherMedicalSchoolRecords from "@salesforce/apex/ExamRegistrationController.getOtherMedicalSchoolsWithTransferCredits";
import getOtherInstitutionRecords from "@salesforce/apex/ExamRegistrationController.getOtherInstitutionsWithTransferCredits";
import getAssetsAndDocuments from "@salesforce/apex/ExamRegistrationController.getAssetsAndDocuments";
import getInstAssetsAndDocuments from "@salesforce/apex/ExamRegistrationController.getInstAssetsAndDocuments";
import getStartDateAndEndDate from "@salesforce/apex/ExamRegistrationController.getStartDateAndEndDate";
//Code added by Shailaja. 10/19/2020.
import getStartEndAndDegreeMonthYear from "@salesforce/apex/ExamRegistrationController.getStartEndAndDegreeMonthYear";

import getContactAssociationType from "@salesforce/apex/ExamRegistrationController.getContactAssociationType";
import getSchoolData from "@salesforce/apex/ExamRegistrationController.getSchoolData";
import errorMessageOFACSoft from "@salesforce/apex/AppForCertController.errorMessageOFACSoft";
import errorMessageCurrentDate from "@salesforce/apex/AppForCertController.errorMessageCurrentDate";

export default class ExamRegAppForCertSummary extends NavigationMixin(
  LightningElement
) {
  //api variables
  @api objectType;
  @api objectId;
  @api getIdFromParent;

  //track variables
  @track multiple = true;
  @track parameters = {};
  @track getOtherMedSchoolData;
  @track otherMedicalSchoolRecId;
  @track getOtherInstitutionData;
  @track isOthIns = false;
  @track isOthMed = false;
  @track assetsList = [];
  @track instAssetsList = [];
  @track tctNameCond = false;
  @track tctTransCond = false;

  @track showOtMedFile = false;
  @track showtctFile = false;
  @track showpmlFile = false;
  @track showMultiple = true;
  @track activeSections = ["medSchoolSection"];

  @track showMedDetails = false;
  @track showOtherIns = false;
  @track showOtherMed = false;
  @track degreeIssueDate = new Date();
  @track startDate = new Date();
  @track endDate = new Date();
  //New code added by Shailaja. 10/19/2020
  @track startMonth ='';
  @track startYear ='';
  @track endMonth ='';
  @track endYear ='';
  @track degreeIssueMonth ='';
  @track degreeIssueYear ='';

  @track reviewConfirm = false;
  @track btnNotDisabled = false;
  @track appForCertURL;
  @track accId;
  @track showError = false;
  @track errorMessagesText = "";
  @track showWarning = false;
  @track warningMessagesText = "";
  @track spinner = false;
  @track assetsPayloadList = [];
  @track tempPayload = {
    contactId: null,
    caseId: null,
    catsId: null,
    documentType: null,
    assetRecordType: null,
    createOrReplace: null,
    assetStatus: null,
    assetCreationRequired: null,
    assetId: null
  };
  label = {
    reviewMessage,
    reviewConfirmation,
    appForCertReviewStep
  };

  constructor() {
    super();
    this.getContactAssocObjIdAndName();
  }

  getContactAssocObjIdAndName() {
    // Getting Object Id and Object Name
    getContactAssociationType()
      .then(result => {
        if (result) {
          this.objectId = result.split(",")[0];
          this.objectType = result.split(",")[1];
          this.getSchoolValues(this.objectId);
          this.getDateValues(this.objectId, this.objectType);
        }
      })
      .catch(error => {
        window.console.log("Error: " + JSON.stringify(error));
      });
  }

  getDateValues(objectIdVal, objectTypeVal) {
    getStartDateAndEndDate({
      objectId: objectIdVal,
      objectType: objectTypeVal
    }).then(value => {
      this.startDate = value.Start_Date__c;
      this.endDate = value.End_Date__c;
      this.degreeIssueDate = value.Degree_Issue_Date__c;
    });

    //code added by Shailaja
    getStartEndAndDegreeMonthYear({
      objectId: objectIdVal,
      objectType: objectTypeVal
    }).then(value => {
      this.startMonth = value.Start_Month__c;
      this.startYear = value.Start_Year__c;
      this.endMonth = value.End_Month__c;
      this.endYear = value.End_Year__c;
      this.degreeIssueMonth = value.Degree_Issue_Month__c;
      this.degreeIssueYear = value.Degree_Issue_Year__c;
    });
  }

  getSchoolValues(objectIdVal) {
    getSchoolData({
      objectId: objectIdVal
    }).then(value => {
      this.accId = value.Account__c;
    });
  }

  handleConfirmationChange(event) {
    if (event.target.checked) {
      this.btnNotDisabled = true;
    } else {
      this.btnNotDisabled = false;
    }
  }

  loadDateValue() {
    this.showMedDetails = true;
    this.showOtherIns = true;
    this.showOtherMed = true;
  }

  connectedCallback(){
    this.spinner = true;
    this.loadDateValue();
    this.tempPayload.documentType = "Transfer Credit Transcript";
    this.assetsPayloadList.tctPayload = JSON.stringify(this.tempPayload);
    this.tempPayload.documentType = "TCT Name Document";
    this.assetsPayloadList.tctNameDocPayload = JSON.stringify(this.tempPayload);
    this.tempPayload.documentType = "TCT Translation";
    this.assetsPayloadList.tctTransPayload = JSON.stringify(this.tempPayload);
    this.tempPayload.documentType = "Pre-Med Letter";
    this.assetsPayloadList.pmlPayload = JSON.stringify(this.tempPayload);
    this.tempPayload.documentType = "Pre-Med Letter Name Document";
    this.assetsPayloadList.pmlNameDocPayload = JSON.stringify(this.tempPayload);
    this.tempPayload.documentType = "Pre-Med Letter Translation";
    this.assetsPayloadList.pmlTransFilePayload = JSON.stringify(this.tempPayload);
    //Get the medical school records on load of page on FED
    let otherMedRecordsPromise = getOtherMedicalSchoolRecords()
      .then(data => {
        if (data) {
          if (data.length > 0) {
            this.getOtherMedSchoolData = data;
            this.isOthMed = true;
          }
          if (this.isOthMed) {
            for (const key in this.getOtherMedSchoolData) {
              if (this.getOtherMedSchoolData.hasOwnProperty(key)) {
                let ele = this.getOtherMedSchoolData[key];
                if (ele.Transfer_Credit_to_Degree_School__c) {
                  this.otherMedicalSchoolRecId = ele.Id;
                  //Get the Assets with files on load of page on FED
                  getAssetsAndDocuments({
                      recId: this.otherMedicalSchoolRecId
                    })
                    .then(result=>{
                      if(result){
                        this.assetsList = result;
                        if(
                          this.assetsList.tctNameDiff === "Yes" &&
                          this.assetsList.tctNameDoc !== "" &&
                          this.assetsList.tctNameDoc !== undefined
                        ){
                          this.tctNameCond = true;
                        }
                        if(
                          this.assetsList.tctTrans === "Yes" &&
                          this.assetsList.tctTransFile !== "" &&
                          this.assetsList.tctTransFile !== undefined
                        ){
                          this.tctTransCond = true;
                        }
                        if(this.assetsList.tctFile !== "" && 
                           this.assetsList.tctFile !== undefined
                        ){
                          this.showOtMedFile = true;
                        }
                      }
                    })
                    .catch(error => {
                      window.console.log("Error: " + JSON.stringify(error));
                    });
                }
              }
            }
          }
        }
      })
      .catch(error => {
        this.spinner = false;
        window.console.log("Error: " + JSON.stringify(error));
      });

    //Get the other institution records on load of page on FED
    let otherInstRecordsPromise = getOtherInstitutionRecords()
      .then(data => {
        if (data) {
          if (data.length > 0) {
            this.getOtherInstitutionData = data;
            this.isOthIns = true;
            //Get the Institution Assets with files on load of page on FED
            getInstAssetsAndDocuments().then(data2=>{
              if(data2){
                this.instAssetsList = data2;
                for(const key in this.getOtherInstitutionData){
                  if(this.getOtherInstitutionData.hasOwnProperty(key)){
                    let ele = this.getOtherInstitutionData[key];
      
                    for(const assKey in this.instAssetsList){
                      if(this.instAssetsList.hasOwnProperty(assKey)){
                        if(ele.Id === assKey){
                          let assEle = this.instAssetsList[assKey];
                          ele.tctId = assEle.tctId;
                          ele.tctFile = assEle.tctFile;
                          ele.tctName = assEle.tctName;
                          ele.tctNameDiff = assEle.tctNameDiff;
                          ele.tctNameDoc = assEle.tctNameDoc;
                          ele.tctTransId = assEle.tctTransId;
                          ele.tctTrans = assEle.tctTrans;
                          ele.tctTransInEng = assEle.tctTransInEng;
                          ele.tctTransFile = assEle.tctTransFile;
                          ele.pmlId = assEle.pmlId;
                          ele.pmlFile = assEle.pmlFile;
                          ele.pmlName = assEle.pmlName;
                          ele.pmlNameDiff = assEle.pmlNameDiff;
                          ele.pmlNameDoc = assEle.pmlNameDoc;
                          ele.pmlTransId = assEle.pmlTransId;
                          ele.pmlTrans = assEle.pmlTrans;
                          ele.pmlTransInEng = assEle.pmlTransInEng;
                          ele.pmlTransFile = assEle.pmlTransFile;
                          if(
                            assEle.tctNameDiff === "Yes" &&
                            assEle.tctNameDoc !== "" &&
                            assEle.tctNameDoc !== undefined
                          ){
                            ele.tctNameCond = true;
                          }
                          if(
                            assEle.tctTrans === "Yes" &&
                            assEle.tctTransFile !== ""
                          ){
                            ele.tctTransCond = true;
                          }
                          if(
                            assEle.pmlNameDiff === "Yes" &&
                            assEle.pmlNameDoc !== "" &&
                            assEle.pmlNameDoc !== undefined
                          ){
                            ele.pmlNameCond = true;
                          }
                          if(
                            assEle.pmlTrans === "Yes" &&
                            assEle.pmlTransFile !== ""
                          ){
                            ele.pmlTransCond = true;
                          }
                          if(assEle.tctFile !== "" && assEle.tctFile !== undefined){
                            ele.showtctFile = true;
                          }
                          if(assEle.pmlFile !== "" && assEle.pmlFile !== undefined){
                            ele.showpmlFile = true;
                          }
                        }
                      }
                    }
                  }
                }
              }
            });
          }
        }
      })
      .catch(error => {
        this.spinner = false;
        window.console.log("Error: " + JSON.stringify(error));
      });
    Promise.all([otherMedRecordsPromise, otherInstRecordsPromise]).then(()=>{
      this.spinner = false;
    });
  }

  navigateToFiles(event) {
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "filePreview"
      },
      state: {
        recordIds: event.target.value,
        selectedRecordId: event.target.value
      }
    });
  }

  navigateToAppForCert(event) {
    event.preventDefault();
    const selectEvent = new CustomEvent("editappforcert", {});
    this.dispatchEvent(selectEvent);
  }

  downloadFiles(event) {
    let fileId = event.target.value;
    window.open(
      window.location.origin +
      `/sfc/servlet.shepherd/document/download/${fileId}?operationContext=S1`
    );
  }

  prevButton(event) {
    event.preventDefault();
    const selectEvent = new CustomEvent("previousevent", {});
    this.dispatchEvent(selectEvent);
  }

  nextButton(event) {
    event.preventDefault();

    errorMessageCurrentDate({
        type: studentStatus,
        fromDate: this.startDate,
        toDate: this.endDate
      })
      .then(result => {
        if (result) {
          this.showError = true;
          if (
            this.template.querySelector("#toDatefutureErrorStudent") === null
          ) {
            let elem = document.createElement("div");
            elem.id = "toDatefutureErrorStudent";
            elem.textContent = dateValidation;
            elem.style = "color:#ff0000; clear:both;";
            this.template
              .querySelector(".attendance-date-error")
              .appendChild(elem);
          }
          this.errorMessagesText = appForCertError;
          window.scrollTo(0, 0);
        } else {
          if (
            this.template.querySelector("#toDatefutureErrorStudent") != null
          ) {
            let elem = this.template.querySelector("#toDatefutureErrorStudent");
            elem.parentNode.removeChild(elem);
          }
          errorMessageOFACSoft({
              accountId: this.accId
            })
            .then(res => {
              if (res) {
                this.showWarning = true;
                this.warningMessagesText = countryWarning;
              }
              if (this.showWarning) {
                const evt = new ShowToastEvent({
                  title: "Warning",
                  message: this.warningMessagesText,
                  variant: "warning"
                });
                this.dispatchEvent(evt);
                let that = this;
                setTimeout(function () {
                  const selectEvent = new CustomEvent("nextevent", {});
                  that.dispatchEvent(selectEvent);
                }, 5000);
              } else {
                const selectEvent = new CustomEvent("nextevent", {});
                this.dispatchEvent(selectEvent);
              }
            })
            .catch(error => {
              window.console.log("Error: " + JSON.stringify(error));
            });
        }
      })
      .catch(error => {
        window.console.log("Error: " + JSON.stringify(error));
      });
  }

  cancelButton(event) {
    event.preventDefault();
    const selectEvent = new CustomEvent("cancelevent", {});
    this.dispatchEvent(selectEvent);
  }
}