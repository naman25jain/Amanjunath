import {LightningElement,track} from 'lwc';
import getMessage from "@salesforce/apex/RestrictedMessage.getMessage";
import getContact from '@salesforce/apex/EpicReportsController.getContact';
import Id from '@salesforce/user/Id';
export default class EpicReport extends LightningElement{
@track spinner = false;
@track EpicRepReq = '';
@track showErrorEpicReportButton;
@track showEpicReport;
@track reqRepBtn = true;
@track reqRepDtl = false;
@track reqRepSum = false;
@track reqRepLeg = false;
@track reqRepPayment = false;
@track reqRepConfirm = false;
@track cs = [];
@track caseNumbers;
@track parentCVCases;
connectedCallback(){
    this.getRestrictedMessage();
}
getRestrictedMessage(){
    getContact({
        userId: Id
    }).then(conResult => {
        let fieldvals={
            "contactId" : conResult,
            "service" : 'EPIC Reports - Internal and External'
        }; 
    
    getMessage({
        jsonInput : JSON.stringify(fieldvals)
    }).then(result=>{ 
        if(result){
            this.showErrorEpicReportButton = true; 
            this.reqRepBtn = false;
            }else{ 
            this.showEpicReport = true; 
            this.EpicRepReq = 'In progress with development' ; 
            }        
    })
  })
}  
showRegRepDetails(){
    this.reqRepBtn = false;
    this.reqRepDtl = true;
    this.reqRepSum = false;
    this.reqRepLeg = false;
    this.reqRepPayment = false;
    this.reqRepConfirm = false;
}
showRegRepBack(){
    this.reqRepBtn = true;
    this.reqRepDtl = false;
    this.reqRepSum = false; 
    this.reqRepLeg = false;  
    this.reqRepPayment = false; 
    this.reqRepConfirm = false;
}
showRegRep(event){
    this.cs = [];
    const caseIds = event.detail;    
    this.cs = caseIds;
    this.reqRepBtn = false;
    this.reqRepDtl = false;
    this.reqRepSum = true;
    this.reqRepLeg = false;
    this.reqRepPayment = false;
    this.reqRepConfirm = false;
}  
showReqDet(){
    this.reqRepBtn = false;
    this.reqRepDtl = true;
    this.reqRepSum = false;  
    this.reqRepLeg = false;
    this.reqRepPayment = false;
    this.reqRepConfirm = false;
}
showReqLeg(event){
    this.parentCVCases = event.detail;
    this.reqRepBtn = false;
    this.reqRepDtl = false;
    this.reqRepSum = false;  
    this.reqRepLeg = true; 
    this.reqRepPayment = false;
    this.reqRepConfirm = false;
}
showReqPay(event){
    this.parentCVCases = event.detail;
    this.reqRepBtn = false;
    this.reqRepDtl = false;
    this.reqRepSum = false;  
    this.reqRepLeg = false;
    this.reqRepPayment = true; 
    this.reqRepConfirm = false;
}
showConfirm(event){
    this.caseNumbers = event.detail;
    this.reqRepBtn = false;
    this.reqRepDtl = false;
    this.reqRepSum = false;  
    this.reqRepLeg = false;
    this.reqRepPayment = false; 
    this.reqRepConfirm = true;
}
showEpicRepMain(){
    this.reqRepBtn = true;
    this.reqRepDtl = false;
    this.reqRepSum = false;  
    this.reqRepLeg = false;
    this.reqRepPayment = false; 
    this.reqRepConfirm = false;
}
}