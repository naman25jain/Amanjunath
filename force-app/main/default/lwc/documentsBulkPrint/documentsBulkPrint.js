import { LightningElement, api, track } from 'lwc'; getCaseStatusinfo
import { reduceErrors } from 'c/lwcUtilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getCaseStatusinfo from '@salesforce/apex/DocumentsPrintController.getCaseStatusinfo'; 
import sendBulkDocsToPrint from '@salesforce/apex/DocumentsPrintController.sendBulkDocsToPrint';
import updateInternalExtStatus from '@salesforce/apex/DocumentsPrintController.updateInternalExtStatus';

export default class DocumentsBulkPrint extends NavigationMixin(LightningElement) {
    // variables
    @api selectedRecords;
    @api returnURL;
    messageInfo;
    isSpinner = false;
    lstids = [];
    msgStyle = "";


    async connectedCallback() {
        await this.selectedRecords;

        if(this.selectedRecords) {
            this.selectedRecords.slice(1,-1).split(',').forEach(val => {
                this.lstids.push(val.trim());
            })
        }
        this.lstids = this.lstids.filter((e) => {return e}); 
        if(this.lstids.length == 0) {
            this.messageInfo = 'Please Select at least one record to process';
        }
        else {
            this.getStatus();
        }
    }

    getStatus() {
        getCaseStatusinfo({lstCaseIds : this.lstids}).then(data =>{
            if(!data) {
                this.msgStyle = 'color:red;';
                this.messageInfo = 'Document Print will process only when the case status is \'Pending Print\' or \'Print Error\'';
            }
            else {
                this.isSpinner = true;
                this.processBulkPrint();
                this.updateStatus();
                
            }
        }).catch(error => {
            this.showToastMessage('error', reduceErrors(error), 'Error!');
            this.isSpinner = false;
        })
    }

    updateStatus(){
        updateInternalExtStatus({lstCaseIds : this.lstids})
        .then(data =>{
            
        }).catch(error => {
            this.showToastMessage('error', reduceErrors(error), 'Error!');
            this.isSpinner = false;
        })
    }
    processBulkPrint() {
        sendBulkDocsToPrint({lstIds : this.lstids}).then((result) => {
            if(result) {
                this.msgStyle = 'color:red;';
                this.messageInfo = Array.from(new Set(result.split('@~'))).join('\n');
            }
            else {
                this.msgStyle = 'color:green;';
                this.messageInfo = 'Documents are sent to print successfully!';
            }
            this.isSpinner = false;
        }).catch((error) => {
            console.error(error);
            this.showToastMessage('error', (reduceErrors(error) ? reduceErrors(error)[0] : '') , 'Error!');
            this.isSpinner = false;
        })
    }

    closeModal() {
        if(this.returnURL) {
            window.location.assign(this.returnURL);
        }
        else {
            window.history.back();
        }
       
    }

    showToastMessage(variant, message, title) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}