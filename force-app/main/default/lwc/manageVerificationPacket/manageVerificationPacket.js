import {LightningElement,api,track,wire} from 'lwc';
import VERIFICATION_PACKET from '@salesforce/schema/Verification_Packet__c';
import SEND_LANGUAGE from '@salesforce/schema/Verification_Packet__c.Send_Language__c';
import {getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import getCaseEntity from '@salesforce/apex/ComplieVerificationPacketController.getCaseEntity';
import createVerificationPacket from '@salesforce/apex/ComplieVerificationPacketController.createVerificationPacket';
import getVerificationPacket from '@salesforce/apex/ComplieVerificationPacketController.getVerificationPacket';
import getCATSCredentialIntake from '@salesforce/apex/ComplieVerificationPacketController.getCATSCredentialIntake';
import uploadInCompleteCoverLetter from '@salesforce/apex/ComplieVerificationPacketController.uploadInCompleteCoverLetter';
export default class ManageVerificationPacket extends LightningElement{
    @api recordId;
    @api caseRecTypeDevName;
    @api showCheckboxFieldsVeriPacket;
    @track sendLangOptions = [];
    @track sendLanguage = 'English';
    @track reqEntity = false;
    @track inclTrans = false;
    @track addInfo = '';
    @track entity = '';
    @track credentialType;
    @track requestedSentToECFMG = false;
    @track showCheckboxFields = false;
    @track msgText='';
    @wire(getObjectInfo,{
        objectApiName: VERIFICATION_PACKET
    })
    objectInfo;
    @wire(getPicklistValues,{
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: SEND_LANGUAGE
    })
    sendLangValues({error, data}){
        if(data){
            this.sendLangOptions = data.values;
        }else if(error){
            window.console.error('Error: ' + JSON.stringify(error));
        }
    }
    connectedCallback(){        
        if(this.caseRecTypeDevName === 'Credential_Verification'){
            this.getCaseCATSRecord();
        }
        this.getEntity();                
        getVerificationPacket({caseId : this.recordId}).then(result=>{
            if(result){
                if(result.Send_Language__c){
                    this.sendLanguage = result.Send_Language__c;
                }
                this.reqEntity = result.Entity_provide_the_credential__c;
                this.inclTrans = result.Translation_included__c;
                this.addInfo = result.Request_additional_information__c;
            }
        });
    }
    getEntity(){
        getCaseEntity({
            caseId: this.recordId,
            caseRecordTypeDevName: this.caseRecTypeDevName
        })
        .then(result=>{
            this.entity = result;
        })
        .catch(error=>{
            window.console.error('Error: ' + JSON.stringify(error));
        });
    }
    getCaseCATSRecord(){
        getCATSCredentialIntake({
            caseId: this.recordId
        })
        .then(result=>{
            if(result){
                this.credentialType = result.Credential_Type__c;
                this.requestedSentToECFMG = result.Requested_to_be_sent_to_ECFMG__c;
            }
        })
        .catch(error=>{
            window.console.error('Error: ' + JSON.stringify(error));
        });
    }
    handleLangChange(event){
        this.sendLanguage = event.target.value;
    }
    handleReqEntityChange(event){
        if(event.target.checked){
            this.reqEntity = true;
        }else{
            this.reqEntity = false;
        }
    }
    handleInclTransChange(event){
        if(event.target.checked){
            this.inclTrans = true;
        }else{
            this.inclTrans = false;
        }
    }
    handleAddInfoChange(event){
        this.addInfo = event.target.value;
    }
    nextButton(){
        this.msgText = '';
        if(this.credentialType === 'Certificate of Good Standing'){
            this.msgText = 'Document type is \'Certificate of Good Standing\'. So, please select the \'Request the Entity provide the credential.\'';
        }
        else if(this.credentialType === 'Final Medical School Transcript'){
            this.msgText = 'Document type is \'Final Medical School Transcript\'. So, please select the \'Request the Entity provide the credential.\'';
        }
        if(this.caseRecTypeDevName === 'Credential_Verification' && this.reqEntity === false && this.requestedSentToECFMG === true && (this.credentialType === 'Certificate of Good Standing' || this.credentialType === 'Final Medical School Transcript')){
            const evtcert = new ShowToastEvent({
                title: "Error",
                message: this.msgText,
                variant: "error",
                type: 'error',
                mode: "dismissable"
            });
            this.dispatchEvent(evtcert);          
        }else{
            let vpPayload = {
                "sendLang": this.sendLanguage,
                "reqEntity": this.reqEntity,
                "inclTrans": this.inclTrans,
                "addInfo": this.addInfo
            };
            createVerificationPacket({
                caseId : this.recordId, vpJson : JSON.stringify(vpPayload)
            })
            .then(result=>{
                if(result){
                    this.showConfirmationMessage();                   
                }
            })
            .catch(error=>{
                window.console.error('Error: ' + JSON.stringify(error));
            });
        }
    }
    showConfirmationMessage(){
        const evt = new ShowToastEvent({
            title: "Success",
            message: "Data saved successfully",
            variant: "success",
            mode: "dismissable"
        });
        if(this.caseRecTypeDevName === 'Medical_Education_Form'){
            this.dispatchEvent(evt);
            const selectEvent = new CustomEvent('showfinalscreen', {});
            this.dispatchEvent(selectEvent);
        }else{             
            uploadInCompleteCoverLetter({caserecId : this.recordId}).then(resultForm=>{
                if(resultForm){
                    this.dispatchEvent(evt);
                    const selectEvent = new CustomEvent('showfinalscreen', {});
                    this.dispatchEvent(selectEvent);
                }
            });
        }
    }
}