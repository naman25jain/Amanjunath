import { LightningElement, wire, track, api } from 'lwc';
import getEpicSummaryDetails from '@salesforce/apex/EpicCredVerController.getEpicSummaryDetails';
import getEpicAssetsAndDocuments from '@salesforce/apex/EpicCredVerController.getEpicAssetsAndDocuments';
export default class EpicReportSummary extends LightningElement {
    @track caseData = [];
    reportRecipient;
    reportRcptCountry;
    reportRcptAddress;
    reportType;
    reportRcptStreet = '';
    reportRcptCity = '';
    reportRcptState = '';
    reportRcptZip = '';
    showAddress = false;
    getRejectReason;
    caseRejectionReason;
    secondaryParentCaseId;
    @track epicReportPayload;
    @track epicAzureUrl;
    @api getEpicCaseId;
    @api getSecondaryParentCaseId;
    @wire(getEpicSummaryDetails, {caseId: '$getEpicCaseId'})
    wiredCases({data, error}){
        if(data){
            this.caseData = data;
            this.reportType = this.caseData.Report_Type__c;
            this.caseRejectionReason = this.caseData.Rejection_Reason__c;
            if(this.caseData.Report_Type__c == 'Volume Entity'){
                this.showAddress = true;
                if(this.caseData.Entity__r.Name){
                    this.reportRecipient = this.caseData.Entity__r.Name;
                }
                if(this.caseData.Entity__r.BillingCountry){
                    this.reportRcptCountry = this.caseData.Entity__r.BillingCountry;
                }
                if(this.caseData.Entity__r.BillingAddress.street)
                    this.reportRcptStreet = this.caseData.Entity__r.BillingAddress.street; 
                if(this.caseData.Entity__r.BillingAddress.city)
                    this.reportRcptCity  = this.caseData.Entity__r.BillingAddress.city; 
                if(this.caseData.Entity__r.BillingAddress.state)
                    this.reportRcptState = this.caseData.Entity__r.BillingAddress.state;  
                if(this.caseData.Entity__r.BillingAddress.postalCode)
                    this.reportRcptZip = this.caseData.Entity__r.BillingAddress.postalCode;
                this.reportRcptAddress = this.reportRcptStreet +'\n'+ this.reportRcptCity +'\n'+ this.reportRcptState +'\n'+ this.reportRcptZip;                
            }
            else if(this.caseData.Report_Type__c == 'Self'){
                this.showAddress = true;
                if(this.caseData.Contact.Name){
                    this.reportRecipient = this.caseData.Contact.Name;
                }
                if(this.caseData.Contact.MailingCountry){
                    this.reportRcptCountry = this.caseData.Contact.MailingCountry;
                } 
                if(this.caseData.Contact.MailingAddress.street)
                    this.reportRcptStreet = this.caseData.Contact.MailingAddress.street; 
                if(this.caseData.Contact.MailingAddress.city)
                    this.reportRcptCity  = this.caseData.Contact.MailingAddress.city; 
                if(this.caseData.Contact.MailingAddress.state)
                    this.reportRcptState = this.caseData.Contact.MailingAddress.state;  
                if(this.caseData.Contact.MailingAddress.postalCode)
                    this.reportRcptZip = this.caseData.Contact.MailingAddress.postalCode;
                this.reportRcptAddress = this.reportRcptStreet +'\n'+ this.reportRcptCity +'\n'+ this.reportRcptState +'\n'+ this.reportRcptZip;             
            }
            else if(this.caseData.Report_Type__c == 'Other Entity'){
                this.showAddress = false;
                if(this.caseData.EPIC_Report_Entity__c){
                    this.reportRecipient = this.caseData.EPIC_Report_Entity__c;
                }
                if(this.caseData.EPIC_Report_Entity_Country__c){
                    this.reportRcptCountry = this.caseData.EPIC_Report_Entity_Country__c;
                }
                if(this.caseData.EPIC_Report_Entity_Address__c){
                    this.reportRcptAddress = this.caseData.EPIC_Report_Entity_Address__c;  
                }  
            }
            this.secondaryParentCaseId = this.caseData.Secondary_Parent_Case__c;
            this.getEpicPayload();     
        }
        else if(error) {
            window.console.log('Error: ' + JSON.stringify(error));
        }
    }
    connectedCallback(){
        if(this.getSecondaryParentCaseId){
           this.getEpicPayload();
        }
    }
    getEpicPayload(){
        getEpicAssetsAndDocuments({
            recId: this.getSecondaryParentCaseId
        }).then(result => {
            console.log('result --- '+result);
            if(result !== null){
                this.epicAzureUrl = result;
                let tempPayloadEPIC = {
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
                //tempPayloadEPIC.assetId = result;
                tempPayloadEPIC.documentType = "Credential Request";
                this.epicReportPayload = JSON.stringify(tempPayloadEPIC);
                //this.template.querySelector('c-cloud-document-upload-wrapper').handleEpicReportSummary();
                this.template.querySelector('.cloudDocumentUpload').auraThumbnailLoaderAzureURL();


            }
        })
        .catch(error => {
            this.error = error;
            console.log('Error', error);
        });
        
    }
}