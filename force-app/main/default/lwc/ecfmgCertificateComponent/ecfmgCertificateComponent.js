import {LightningElement, wire, track ,api} from 'lwc';
import getContactId from "@salesforce/apex/ServicesComponentController.getContactId";
import enableDuplicateRequest from "@salesforce/apex/DupEcfmgCertificateController.enableDuplicateRequest";
import checkDupCertSubmission from "@salesforce/apex/DupEcfmgCertificateController.checkDupCertSubmission";
import fetchReasonAndDetails from "@salesforce/apex/DupEcfmgCertificateController.fetchReasonAndDetails";
import markforDelete from "@salesforce/apex/DupEcfmgCertificateController.markforDelete";
import getRestrictedMessage from '@salesforce/apex/RestrictedMessage.getMessage';
import restrictionServiceErrorMessage from "@salesforce/label/c.Restriction_Service_Error_Message";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class EcfmgCertificateComponent extends LightningElement{
    @track contactId;
    @track enableDupCertRequest = false;
    @track showContact;
    @track showHeader = true;
    @track showDupCertReason = false;
    @track showLegal = false;
    @track showPayment = false;
    @track showConfirm = false;
    @track showErrorDupCert = false;
    @api reasonDuplicate;
    @api additionalDtl;
    @track caserecordid;
    @wire(getContactId)
    contactIdfromController({ data }){
        this.contactId = data;
        enableDuplicateRequest({contactId: this.contactId}).then(result =>{
            this.enableDupCertRequest = result;
        });   
    }
    showProfileReview(event){
        let messageWrapper = {"accountId" : '', "contactId" : this.contactId, "caseId" : '', "service" : "Duplicate ECFMG certificate - Internal and External"};
        let jsonMessageWrapper = JSON.stringify(messageWrapper);
        getRestrictedMessage({jsonInput: jsonMessageWrapper})
        .then(restrictionresult=>{
            if(restrictionresult){
                const evt = new ShowToastEvent({
                title: 'Restriction Applied',
                message: restrictionServiceErrorMessage,
                variant: 'error'
                });
                this.dispatchEvent(evt);
            }else{
                checkDupCertSubmission()
                .then(result=>{
                    if(result){
                        this.showErrorDupCert = true;
                    }
                    else{
                        fetchReasonAndDetails()
                        .then(result => {
                            if(result[0] !== ''){
                                this.reasonDuplicate = result[0];
                                this.additionalDtl = result[1];
                            }
                        });
                        this.showErrorDupCert = false;
                        this.showContact = true;
                        this.showHeader=false;
                        this.reasonDuplicate = event.detail.rson;
                        this.additionalDtl = event.detail.addn;
                        this.showDupCertReason = false;     
                        this.showLegal = false;
                    }
                })
            }
        })    
    }
    cancelDupCertReq(){
        markforDelete()
        .then(result => {
            if(result){
                const evt = new ShowToastEvent({
                    title: 'Case Discarded',
                    message: 'Case Discarded',
                    });
                    this.dispatchEvent(evt);
            }
        })
        this.showContact = false;
        this.showHeader=true;
        this.showDupCertReason = false;        
        this.showLegal = false;
    }   
    showDupCertReasonScreen(event){
        this.showContact = false;
        this.showHeader=false; 
        this.showDupCertReason = true;        
        this.showLegal = false;
    }
    showLegalScreen(event){        
        this.showContact = false;
        this.showHeader=false;
        this.reasonDuplicate = event.detail.rson;
        this.additionalDtl = event.detail.addn;
        this.showLegal = true;
        this.showDupCertReason = false;   
        this.showPayment = false;     
    }
    showLegLangScreen(event){        
        this.showContact = false;
        this.showHeader=false;
        this.showLegal = true;
        this.showDupCertReason = false;   
        this.showPayment = false;     
    }
    showPaymentScreen(event){
        this.caserecordid = event.detail.caserecordid;
        this.showContact = false;
        this.showHeader=false;
        this.showLegal = false;
        this.showDupCertReason = false;
        this.showPayment = true;
        this.showConfirm = false;
    }
    showConfScreen(event){
        this.showContact = false;
        this.showHeader=false;
        this.showLegal = false;
        this.showDupCertReason = false;
        this.showPayment = false;
        this.showConfirm = true;
    }
    confirmAndCancel(){
        window.location.reload();
    }
}