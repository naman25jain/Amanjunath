import {LightningElement,track,wire,api} from 'lwc';
import saveDupCertReason from "@salesforce/apex/DupEcfmgCertificateController.saveDupCertReason";
import REASON_DUPLICATE_CERTIFICATE from '@salesforce/schema/Case.Reason_for_Duplicate_Certificate__c';
import CASE from '@salesforce/schema/Case';
import {getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';
export default class DupCertReasonScreen extends LightningElement{
    @track spinner = false;
    @track reasonOptions = [];
    @track selectedReason;
    @track recordTypeId;
    @track showNameOnRecordChange = false;
    @track additionalInfo = '';
    @track errorReason = false;
    @track errorAddtnInfo = false;
    @api reasonDuplicate;
    @api additionalDtl;  
    @api textPlaceHolder='';
    @wire(getObjectInfo,{objectApiName:CASE})
    getobjectInfo(result){
        if(result.data){
            const rtis = result.data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find((rti) => rtis[rti].name === 'ECFMG Certification');
        }        
    }
    @wire(getPicklistValues,{
        recordTypeId: '$recordTypeId',
        fieldApiName: REASON_DUPLICATE_CERTIFICATE
    })
    statusPicklistValues({
        error,
        data
    }){
        if(data){
            this.reasonOptions = data.values;
            if(this.reasonDuplicate !== undefined && this.reasonDuplicate !== '' && this.reasonDuplicate !== null){
                this.selectedReason = this.reasonDuplicate;
                if (this.selectedReason==='Name on Record Changed'){
                    this.showNameOnRecordChange = true;            
                }
            }
            if(this.additionalDtl !== undefined && this.additionalDtl !== '' && this.additionalDtl !== null){
                this.additionalInfo = this.additionalDtl;
                this.textPlaceHolder = this.additionalDtl;
            } 
        }else if(error){
            window.console.log('Error: ' + JSON.stringify(error));
        }
    }
    handleChangeForReason(event){
        this.selectedReason = event.target.value;        
        if (this.selectedReason==='Name on Record Changed'){
            this.showNameOnRecordChange = true;            
        }else{
            this.showNameOnRecordChange = false;            
        }
    }
    handleChangeForInputValue(event){       
        this.additionalInfo = event.target.value;   
    }
    preventBackslash(event){
        if(event.which === 8 || event.which === 46){
            event.preventDefault();
        }
    }
    prevbtn(event){
        event.preventDefault();
        this.errorReason = false;
        this.errorAddtnInfo = false;
        let  reason= {rson:this.selectedReason,addn:this.additionalInfo};
        const selectEvent = new CustomEvent('prevevent',{detail:reason});
            this.dispatchEvent(selectEvent);
    }
    nextbtn(event){        
        event.preventDefault();
        this.spinner = true;
        this.errorReason = false;
        this.errorAddtnInfo = false;
        if((this.selectedReason !== undefined && this.selectedReason !== '' && this.selectedReason !== null)&&
            (this.additionalInfo !== undefined && this.additionalInfo !== '' && this.additionalInfo !== null)){
            let reason = {rson: this.selectedReason, addn: this.additionalInfo};
            // Save the selectedReason and additionalInfo and create Duplicate ECFMG cert
            saveDupCertReason({dupCertReason: this.selectedReason, dupCertAdditionalInfo: this.additionalInfo})
            .then(result =>{
                if(result === true){
                    this.spinner = false;
                    const selectEvent = new CustomEvent('nextevent', {detail : reason});
                    this.dispatchEvent(selectEvent);
                }else{
                    this.spinner = false;
                }
            });            
        }
        else{
            if(this.selectedReason === undefined || this.selectedReason === '' || this.selectedReason === null){
                this.template.querySelector('.reason').classList.add('slds-has-error');
                this.errorReason = true;                
            }
            if(this.additionalInfo === undefined || this.additionalInfo === '' || this.additionalInfo === null){
                this.template.querySelector('.addnInfo').classList.add('slds-has-error');
                this.errorAddtnInfo = true;
            }          
        }        
    }    
    discardChanges(){         
        const selectEvent = new CustomEvent('cancelevent',{});
        this.dispatchEvent(selectEvent);
    }
}