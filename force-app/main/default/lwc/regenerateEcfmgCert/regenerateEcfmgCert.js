import {LightningElement, track, api, wire} from 'lwc';
import fetchPickListValue from '@salesforce/apex/TranscriptRequestController.fatchPickListValue';
import createAssetAndCallout from '@salesforce/apex/EcfmgCertificateReGeneration.createRegenAsset';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
export default class RegenerateEcfmgCert extends LightningElement{
    @api assetRecordId;
    @track reasonOptions;
    @track comments;
    @track enableSubmitutton = false;
    @wire(fetchPickListValue,{objInfo: {'sobjectType' : 'Asset'},
         picklistFieldApi: 'Reason_for_Regeneration__c'
     }) reasonValues(result){  
        let dataList = [];
        if(result.data !== undefined){
        let tempVal = [];
        dataList = result.data;
        for(let i = 0; i < dataList.length; i++){  
            let tempTcRecord = {value: dataList[i].svalue , label: dataList[i].slabel}               
            tempVal.push(tempTcRecord);
            }            
        this.reasonOptions = tempVal;             
        }
    }
    handleChangeForInputValue(event){
        this.comments = event.detail.value;
        this.showSubmitButton();
    }
    handleChangeReasonValue(event){
        if(event.detail.value){
            this.reasonValue = event.detail.value;
            this.showSubmitButton();
        }
    }
    showSubmitButton() {
        if(this.comments && this.reasonValue){
            this.enableSubmitutton = true;
        }
        else{
            this.enableSubmitutton = false;
        }
    }
    submitButton(){
        createAssetAndCallout({comments: this.comments,reason: this.reasonValue, recordId:this.assetRecordId})
        const successMsg = new ShowToastEvent({
            title: "Success",
            message: "Your certificate is generating and a new asset will be created under the ECFMG Certification case.",
            variant: "success"
        });
        this.dispatchEvent(successMsg);
        const closeQuickActEvent = new CustomEvent('closeqaevent', {});
        this.dispatchEvent(closeQuickActEvent);
    }
}