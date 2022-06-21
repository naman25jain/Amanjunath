import {LightningElement,api,track,wire} from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import getCaseRecTypeDevName from '@salesforce/apex/ComplieVerificationPacketController.getCaseRecTypeDevName';
export default class CompileVerificationPacket extends LightningElement{
    @api recordId;
    @api caseRecTypeDevName;
    @api showCheckboxFieldsVeriPacket = false;
    @track showSendMethod = true;    
    @track showManageVP = false;
    @track sendMethod = '';
    @track showWebsiteScreen = false;
    @track showFinalScreen = false;    
    @wire(getRecord, {recordId:'$recordId', fields:'Case.Send_Method__c'})
    wiredSendMethod(result){
        if(result.data){
            this.sendMethod = result.data.fields.Send_Method__c.value;
        }
    }
    connectedCallback(){
        this.getCaseRecTypeName();
    }
    getCaseRecTypeName(){
        getCaseRecTypeDevName({
            caseId: this.recordId
        })
        .then(result=>{
            this.caseRecTypeDevName = result;
            if(result === 'Medical_Education_Form'){
                this.showCheckboxFieldsVeriPacket = true;
            }
        })
        .catch(error=>{
            window.console.error('Error: ' + JSON.stringify(error));
        });
    }
    showManageVPScreen(){
        this.showSendMethod = false;
        if(this.sendMethod != 'Website'){
            this.showManageVP = true;
        }
        else{
            this.showWebsiteScreen = true;     
        }
    }
    showVPFinalScreen(){
        this.showFinalScreen = true;
        this.showManageVP = false;
    }
    showManageScreen(){
        this.showFinalScreen = false;
        this.showManageVP = true;
    }
}