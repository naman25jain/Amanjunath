import {LightningElement,track,api} from 'lwc';
import checkTheFinalDoc from '@salesforce/apex/ComplieVerificationPacketController.checkTheFinalDoc';
import createVpandAsset2VerRecords from '@salesforce/apex/ComplieVerificationPacketController.createVpandAsset2VerRecords';
export default class CompileVerificationPacketWebsiteScreen extends LightningElement{
    @track spinner = false;
    @track displayError = false;
    @track errorMsg = "Please attach the online verification packet to the case before completing.";
    @api caseRecordId;
    connectedCallback(){
        createVpandAsset2VerRecords({caseRecordId: this.caseRecordId});
    }
    finishButton(){
        this.spinner = true;
        checkTheFinalDoc({caseRecordId : this.caseRecordId}).then(result=>{
            if(!result){
                this.displayError = true;
                this.spinner = false;
            }
            else{
                window.location.reload();
                this.spinner = false;
            }
        });
    }    
}