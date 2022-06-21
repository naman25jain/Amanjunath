import {LightningElement,api} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getDefData from '@salesforce/apex/GRecordPrePopValues.getDefData';
import getRecTypeId from '@salesforce/apex/GRecordPrePopValues.getRecTypeId';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class GRecordPrePopValues extends NavigationMixin(LightningElement){
    // Variable declartion
    @api recordId;
    @api bName;
    @api tObjName;
    connectedCallback(){
        // get recordTypeId based on RecordType Developer Name
        getRecTypeId({bName:this.bName}).then(recType=>{
            // get Prepopulated Values to record
            getDefData({recordId:this.recordId, bName:this.bName}).then(defRecVal=>{
                if(defRecVal !== null && defRecVal.length>0){
                    if(!defRecVal.toUpperCase().includes('ERROR')){
                        this[NavigationMixin.Navigate]({
                            type: 'standard__objectPage',
                            attributes: {
                                objectApiName: this.tObjName,
                                actionName: 'new'
                            },
                            state : {
                                nooverride: '1',
                                recordTypeId: recType,
                                defaultFieldValues: defRecVal
                            }
                        }, this.tObjName);
                    }else{
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Error',
                            message: defRecVal,
                            variant: 'Error',
                            mode: 'dismissable'
                        }));
                        this.dispatchEvent(new CustomEvent('close'));
                    }
                }else{
                    this[NavigationMixin.Navigate]({
                        type: 'standard__objectPage',
                        attributes: {
                            objectApiName: this.tObjName,
                            actionName: 'new'
                        },                
                        state : {
                            nooverride: '1',
                            recordTypeId: recType
                        }
                    }, this.tObjName);
                }
            }).catch(e=>{
                const errorDefVal = 'Error:'+JSON.stringify(e);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: errorDefVal,
                    variant: 'Error',
                    mode: 'dismissable'
                }));                
            });
        }).catch(e=>{
            const errorRecTyp = 'Error:'+JSON.stringify(e);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: errorRecTyp,
                variant: 'Error',
                mode: 'dismissable'
            }));            
        });
    } 
}