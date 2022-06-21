import { LightningElement, wire, track, api } from "lwc";
import getContactId from "@salesforce/apex/ServicesComponentController.getContactId";
import isApplicantCertified from "@salesforce/apex/CVSRequestController.isApplicantCertified";
import checkBiographicRequest from '@salesforce/apex/CVSRequestController.checkApplicantBiographicPending';
import getMessage from "@salesforce/apex/RestrictedMessage.getMessage";
import checkOFACRestriction from "@salesforce/apex/ERASController.checkOFACRestriction";
export default class CvsRequests extends LightningElement {
    
    @track showDetails;
    @track showCVSHome = true;
    @track showSelectAuthority;
    @track contactId;
    @track visible;
    @track caseId;
    @api linkSource;
    @track isApplicantBio;
    @track disableRequestCVSButton;
    @track showSummary = false;
    @track showShoppingCart = false;
    @track caseRecordId;
    @track restrictedServiceName = 'CVS reports - Internal and External';
    @track showError = false;
    @wire(getContactId)
    contactIdfromController({ data }) {
        this.contactId = data;
    }
    requestRep(){
        let params = {"contactId": this.contactId, "service": this.restrictedServiceName};
        let paramsString = JSON.stringify(params);
        getMessage({ jsonInput : paramsString })
        .then((msg)=>{
            if(msg !== null && msg !== undefined ){
                this.showError = true;
            }else{
                checkOFACRestriction().then(OFACheck=>{
                    if(OFACheck){
                        this.showError = true;
                    }else{
                        this.showError = false;
                        checkBiographicRequest()
                        .then(result=>{
                            if(result === true){
                                this.isApplicantBio = true;
                                this.disableRequestCVSButton = true;
                            }
                            else if(result === false){
                                this.isApplicantBio = false;
                                this.disableRequestCVSButton = true;
                                this.showCVSHome = false;
                                this.showDetails = true;              
                            }
                        })
                    }
                })
            }
        }).catch((error)=>{
            window.console.error("Error: "+ JSON.stringify(error))
        });
    }
    showCVSLandingScreen(){
        this.caseId = null;
        this.showCVSHome = true;
        this.disableRequestCVSButton = false;
        this.showDetails = false;
        this.showSummary = false;  
        this.showShoppingCart = false;      
    }

    showCVSLandingScreen1(){
        this.caseId = null;
        this.showCVSHome = true;
        this.disableRequestCVSButton = false;
        this.showDetails = false;
        this.showSummary = false;  
        this.showShoppingCart = false;
        this.showSelectAuthority = false;      
    }
    showCVSDetails(){
        isApplicantCertified({})
            .then((result) => {
            var appstatus = result;
            if(appstatus === "Not Certified"){
                        this.visible = true;
                        this.showDetails = false;
                    }else if(appstatus === "Certified"){
                        this.showSelectAuthority = true; 
                        this.showDetails = false;
                    }
                })
            .catch((error) => {
                    this.error = error;
            });  
    }
    reqcancel(){
      this.showCVSHome = true;
      this.disableRequestCVSButton = false;
      this.visible = false;
   }   
   reqconfirm(){
     this.showSelectAuthority = true; 
     this.showCVSHome = false;
     this.visible = false;
     this.showSummary = false;
     this.showShoppingCart = false;
   }
   showPrevScreen(){
        if(this.caseId !== null && this.caseId !== undefined){
            this.showCVSHome = false;
            this.showDetails = false;
            this.showSelectAuthority = false;
            this.showSummary = true;
            this.showShoppingCart = false;
        }else{
            this.showSelectAuthority = false;
            this.showCVSHome = false;
            this.showDetails = true;
            this.showSummary = false;
            this.showShoppingCart = false;
        }
    }
    showSummaryScreen(){
        this.showCVSHome = false;
        this.showDetails = false;
        this.showSelectAuthority = false;
        this.showSummary = true;
        this.showShoppingCart = false;
    }
    showEntitySelection(){
        this.caseId = null;
        this.showCVSHome = false;
        this.showDetails = false;
        this.showSelectAuthority = true;
        this.showSummary = false;
        this.showShoppingCart = false;
    }
    showUpdateSelection(event){
        this.caseId =  event.detail.caseId;
        this.showCVSHome = false;
        this.showDetails = false;
        this.showSelectAuthority = true;
        this.showSummary = false;
        this.showShoppingCart = false;
    }
    showShoppingCartPage(event){
        this.caseRecordId = event.detail.caserecordid;
        this.showCVSHome = false;
        this.showDetails = false;
        this.showSelectAuthority = false;
        this.showSummary = false;
        this.showShoppingCart = true;
    }
}