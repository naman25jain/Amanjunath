import { LightningElement,track } from 'lwc';
import countryWarning from "@salesforce/label/c.OFAC_Not_Allowed_Error_Message";
import checkEligibilityForErasTokenReq from '@salesforce/apex/ERASController.checkEligibilityForErasTokenReq';
import checkExistingErasTokenReq from '@salesforce/apex/ERASController.checkExistingErasTokenReq';
import createERASCase from '@salesforce/apex/ERASController.createERASCase';
import checkActiveErasSeason from '@salesforce/apex/ERASController.checkActiveErasSeason';
import checkRestriction from '@salesforce/apex/ERASController.checkRestriction';
import checkApplicantBiographic from '@salesforce/apex/ERASController.checkApplicantBiographic';

export default class ErasTokenRequest extends LightningElement {
    @track disableRequestERASTokenButton;
    @track showErasReqButtonScreen;
    @track showDisclosureScreen;
    @track erasTokenReqExists;
    @track erasReqCaseId;
    @track seasonYear;
    @track isSubmittedOrInReview;
    @track isActiveSeason = true;
    @track hasRestriction;
    @track spinner = false;
    @track isApplicantBio;
    @track restrictedCountry = false;
    @track countryError = countryWarning;

    connectedCallback(){
        checkExistingErasTokenReq()
        .then(data => {  
            this.disableRequestERASTokenButton = false;
            this.showErasReqButtonScreen = true;
            this.showDisclosureScreen = false;
            this.erasTokenReqExists = false;
            this.seasonYear = '';
            if(data.length > 0){ 
                this.erasReqCaseId = data[0].Id;
                this.erasTokenReqExists = true;
                this.seasonYear = data[0].Eligibility_Period__r.Season__c.split(" ")[1];
                if(data[0].Internal_Status__c == 'Submitted' || data[0].Internal_Status__c == 'In Review'){
                    this.isSubmittedOrInReview = true;
                }
            }else{
                checkEligibilityForErasTokenReq()
                .then(result =>{  
                    this.disableRequestERASTokenButton = !result;
                    this.erasTokenReqExists = false;
                    checkRestriction()
                        .then(result => {
                        if(result != null)
                            {
                            this.hasRestriction  = true;
                            this.disableRequestERASTokenButton = true;
                            if(result === countryWarning){
                                this.restrictedCountry = true;
                            }
                            }
                        })
                    checkActiveErasSeason()
                        .then(result => {	
                            this.isActiveSeason  = result;
                        })
                    }) 
            }
        })     
    }
    showERASDisclosure(){
        checkApplicantBiographic()
                        .then(result => {
                            this.isApplicantBio  = result;
                            if(result === true){
                                this.isApplicantBio = true;
                                this.disableRequestERASTokenButton = true;
                            }
                            else if(result === false){
                                this.isApplicantBio = false;
                                createERASCase().then(result=>{
                                    if(result){
                                    this.caseNumber = data;  
                                    this.spinner = false; 
                                    }
                                })
                                .catch(error=>{
                                    this.spinner = false;
                                });
                                this.showDisclosureScreen = true;
                                this.showErasReqButtonScreen = false;
                            }
                        })
        
        
        
    }
    showErasTokenReqButton(){
        this.showDisclosureScreen = false;
        this.showErasReqButtonScreen = true;    
    }
}