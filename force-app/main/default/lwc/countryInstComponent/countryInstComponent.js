import { LightningElement,track,api,wire } from 'lwc';
import getCountryInst from "@salesforce/apex/EntityReviewController.getCountryInst";
import { getRecord } from 'lightning/uiRecordApi';
export default class CountryInstComponent extends LightningElement{
    @api recordId;
    @track entCountName;
    @track countryInst;
    @wire(getRecord, {recordId:'$recordId', fields:'Account.Country__c'})
    wiredCountryName(result){
        if(result.data){
            this.entCountName = result.data.fields.Country__c.value;
            this.getCountryName();
        }
        else{
            this.countryInst = null;
        }
    }
    getCountryName(){
        getCountryInst({countryName:this.entCountName})
        .then(result=>{
            if(result){
                this.countryInst = result;
            }
        }).catch(error=>{
            this.countryInst = null;
        })
    }
}