import {LightningElement,track,api} from 'lwc';
import getCourierSelectedByApplicant from '@salesforce/apex/ComplieVerificationPacketController.getCourierSelectedByApplicant';
import getCourierFeePicklistValues from '@salesforce/apex/ComplieVerificationPacketController.getCourierFeePicklistValues';
import getCourierTypePicklistValues from '@salesforce/apex/ComplieVerificationPacketController.getCourierTypePicklistValues';
import updateCredVerCase from '@salesforce/apex/ComplieVerificationPacketController.updateCredVerCase';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
export default class CompileVPFinalScreen extends LightningElement{
    @api recordId;
    @api caseRecTypeDevName;
    @api sendMethod;
    @track showCourierSection = false;
    @track courierSelectedByApplicant = false;
    @track showCourierSelectedByApplicant = true;
    @track picklistOptions = [];
    @track typeOptions = [];
    @track courierSelectedByAnalyst = false;
    @track showCourierFeeSection = false;
    @track selectedValue = null;
    @track showCourierAccountSection = false;
    @track showCourierTypeSection = false;
    @track courierAccount = null;
    @track courierType = 'FedEx';
    @track reqSentViaCourier = false;
    @track isErrProceed = false;
    @track isCourierTypeErr = false;
    @track breakSave = false;
    @track spinner = false;
    previousButton(){
        const selectEvent = new CustomEvent('showmanagevpscreen', {});
        this.dispatchEvent(selectEvent);
    }
    connectedCallback(){
        if(this.caseRecTypeDevName === 'Medical_Education_Form'){
            this.showCourierSelectedByApplicant = false;
        }
        if(this.sendMethod === 'Paper'){
            this.showCourierSection = true;
            if(this.caseRecTypeDevName === 'Credential_Verification'){
                getCourierSelectedByApplicant({caseId : this.recordId}).then(result=>{
                    this.courierSelectedByApplicant = result;                
                });
            }
            getCourierFeePicklistValues().then(data=>{
                if(data){
                    for(var picklistValue of data){
                        this.picklistOptions = [...this.picklistOptions,{value: picklistValue, label: picklistValue}];  
                    }                                 
                }
            });
            getCourierTypePicklistValues().then(data=>{
                if(data){
                    for(var picklistValue of data){
                        this.typeOptions = [...this.typeOptions,{value: picklistValue, label: picklistValue}]; 
                    }
                }
            });
        }          
    }
    handleSendRequest(event){
        this.courierSelectedByAnalyst = event.target.checked;
        this.selectedValue = null;
        this.courierAccount = null;
        this.showCourierAccountSection = false;
        if(this.courierSelectedByAnalyst){
            this.showCourierFeeSection = true;
            this.showCourierTypeSection = true;
        }else{
            this.showCourierFeeSection = false;
            this.showCourierTypeSection = false;
        }
    }
    preventBackslash(event){
        if(event.which === 8 || event.which === 46){
            event.preventDefault();
        }
    }
    handlePicklistChange(event){
        this.isErrProceed = false;
        this.selectedValue = event.detail.value;
        this.courierAccount = null;
        if(this.selectedValue === 'Applicant' || this.selectedValue === 'Client'){
            this.showCourierAccountSection = true;
        }else{
            this.showCourierAccountSection = false;
        }
    }
    handleChangeCourierAccount(event){
        this.courierAccount = event.target.value;
    }
    handleChangeCourierType(event){
        this.isCourierTypeErr = false;
        this.courierType = event.target.value;
    }
    finishButton(){
        this.breakSave = false;
        if(this.showCourierFeeSection && !this.selectedValue){
            this.isErrProceed = true;
            this.breakSave = true; 
        }
        if(this.showCourierTypeSection && !this.courierType){
            this.isCourierTypeErr = true;
            this.breakSave = true; 
        }
        if(this.courierSelectedByApplicant || this.courierSelectedByAnalyst){
            this.reqSentViaCourier = true;
        }
        if(this.courierSelectedByApplicant){
            this.selectedValue = 'Applicant';
        }
        let sendReqPayload = {
            "reqSentViaCour": this.reqSentViaCourier,
            "courFeePayableBy": this.selectedValue,
            "courAccount": this.courierAccount,
            "courierType": this.courierType
        };
        if(!this.breakSave){
            this.spinner = true;
            updateCredVerCase({caseId : this.recordId, sendReqJson : JSON.stringify(sendReqPayload)}).then(result=>{
                if(result){
                    this.spinner = false;
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: "Data saved successfully",
                        variant: "success",
                        mode: "dismissable"
                    });
                    this.dispatchEvent(evt);
                    window.location.reload();
                }
            })
            .catch(error=>{
                window.console.error('Error: ' + JSON.stringify(error));
            });
        }
    }
}