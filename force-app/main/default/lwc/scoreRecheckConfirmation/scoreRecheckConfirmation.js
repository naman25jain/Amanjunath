import {LightningElement,api,wire,track} from 'lwc';
import getMetadataId from '@salesforce/apex/AppForCertController.getMetadataId';
import {getRecord} from 'lightning/uiRecordApi';
import getConstantsClass from '@salesforce/apex/ExamRegistrationController.getConstantsClass';
export default class ScoreRecheckConfirmation extends LightningElement{
    @api caseNumber;
    @track metarecordId;
    @track firstLine;
    @track secondLine;
    @track thirdLine;
    @track fourthLine;
    @track fifthLine;
    @track secondLineScoreRecheck;
    @track showMessage = false;
    @track spinner = false;
    @track showPageReload = false;
    @wire(getMetadataId)
    metadatafromController(result){ 
        if(result.data !== undefined){
        this.metarecordId = result.data;
        }        
    }
    @wire(getConstantsClass) 
    allConstants({error, data}){
        if(data){
            this.secondLineScoreRecheck = data.LWC_METADATA_CONFIRMATIONSCREEN_SECONDLINE_SCORE_RECHECK;
        }else{
            this.error = error;
        }
    } 
    @wire(getRecord, { recordId: '$metarecordId', fields: ['Confirmation_Message__mdt.First_Line__c', 'Confirmation_Message__mdt.Second_Line__c', 'Confirmation_Message__mdt.Third_Line__c','Confirmation_Message__mdt.Fourth_Line__c','Confirmation_Message__mdt.Fifth_Line__c'] })
    getMetadata(result){
        if(result.data !== undefined){
            this.firstLine = result.data.fields.First_Line__c.value;            
            this.secondLine = this.secondLineScoreRecheck;
            this.thirdLine = result.data.fields.Third_Line__c.value;
            this.fourthLine = result.data.fields.Fourth_Line__c.value;
            this.fifthLine = result.data.fields.Fifth_Line__c.value;
            this.showMessage = true;
        }
    }
    cancelButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }
}