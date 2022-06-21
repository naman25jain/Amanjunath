import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAssets from '@salesforce/apex/DocumentsPrintController.getAssets';
import sentDocumentsToPrint from '@salesforce/apex/DocumentsPrintController.sentDocumentsToPrint';
import ContentManagerRecords from '@salesforce/apex/ContentManagerRecords.FetchContentManagerRecords';
import { reduceErrors } from 'c/lwcUtilities';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import TOASTMESSAGECSS from '@salesforce/resourceUrl/ToastMessageCSS';
import { loadStyle } from 'lightning/platformResourceLoader';

// columns
const columns = [
    {
        label: 'Name', fieldName: 'assetName', type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    { label: 'Type', fieldName: 'Type__c', type: 'string' },
    { label: 'Azure URL', fieldName: 'Azure_Storage_URL__c', type: 'url' },
    { label: 'Status', fieldName: 'Status', type: 'string' }
];

export default class DocumentsPrint extends LightningElement {
    @api recordId;
    isSpinner = false;
    assetsData;
    preSelectedData = [];
    columns = columns;
    isValid = true;
    strMessage = '';
    wrapperData;
    contentManagerRecords = {};
    isCssLoaded = false;


    renderedCallback() {
        if (this.isCssLoaded) return
        this.isCssLoaded = true;
        loadStyle(this, TOASTMESSAGECSS).then(() => {
            console.log('loaded');
        })
            .catch(error => {
                console.log('error => ', error);
            });
    }

    @wire(getRecord, { recordId: '$recordId', fields: ['Case.Internal_Status__c'] })
    caseRecord;

    async connectedCallback() {
        await this.recordId;
        await this.caseRecord;
        await this.fetchContentManagerRecords();

        this.isSpinner = true;
        setTimeout(() => {
            let csStatus = ['Print Error', 'Pending Print', 'Pending Print - Resend', 'Pending Print - Verification Incomplete'];
            if(this.caseRecord && csStatus.includes(this.caseRecord.data.fields.Internal_Status__c.value)) {
                this.getAssetDocs();
                this.isValid = true;
            }else {
                this.isSpinner = false; 
                this.template.querySelector('.message').innerHTML = this.contentManagerRecords.PlanetPressCaseStatusError;
                this.isValid = false;
            }
        }, 1000);
    }

    getAssetDocs() {
        getAssets({ strRecordId: this.recordId}).then(data => {
            if (data) {
                let tempAssetList = [];
                this.wrapperData = data;
                data.assetsRecs.forEach(record => {
                    let tempAsetRec = Object.assign({}, record);
                    if(tempAsetRec.Id) {
                        tempAsetRec.assetName = '/' + tempAsetRec.Id;
                    }
                    else {
                        tempAsetRec.Id = tempAsetRec.ContactId;
                        tempAsetRec.assetName = '/' + tempAsetRec.ContactId;
                    }
                   
                    tempAssetList.push(tempAsetRec);
                });
                this.assetsData = tempAssetList;
                this.preSelectedData = this.assetsData.map(ele => ele.Id);
                this.isSpinner = false;
            }
        }).catch(error => {
            console.error(error);
            this.isSpinner = false;
            this.closeAction();
            this.showToastMessage('error', reduceErrors(error)[0] ? reduceErrors(error)[0] : JSON.stringify(error), 'Error!');
        })
    }

    handlePrintDocument() {
        const selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        this.isSpinner = true;
        sentDocumentsToPrint({lstCaseObjects:this.wrapperData.lstCaseObjects, lstMdts:this.wrapperData.lstMdts, lstAssetsToPrint : selectedRecords}).then(data => {
            if(data) {
                console.log('data => ',data);
                data = Array.from(new Set(data.split('@~'))).join('\n');
                console.log('data after => ',data);
                //this.showToastMessage('error', this.contentManagerRecords.PlanetPressError.replace(/<[^>]*>?/gm, ''), 'Error!');
                this.showToastMessage('info', data, 'info!');
            }
            else {
                this.showToastMessage('success', this.contentManagerRecords.PalentPressSuccessMsg.replace(/<[^>]*>?/gm, ''), 'Success!');
                getRecordNotifyChange([{recordId: this.recordId}]);
                
            }

            this.isSpinner = false;
           
            this.closeAction();

        }).catch(error => {
            this.closeAction();
            this.isSpinner = false;
            this.showToastMessage('error', reduceErrors(error)[0] ? reduceErrors(error)[0] : JSON.stringify(error), 'Error!');
        })
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }


    processErrorMessage(message) {
        let errorMsg = '';
        if (message) {
            if (message.body) {
                if (Array.isArray(message.body)) {
                    errorMsg = message.body.map(e => e.message).join(', ');
                } else if (typeof message.body.message === 'string') {
                    errorMsg = message.body.message;
                }
            }
            else {
                errorMsg = message;
            }
        }
        this.showToastMessage('error', errorMsg, 'Error!');
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

    fetchContentManagerRecords() {
        const unqiueRecords = ['PlanetPressCaseStatusError', 'PlanetPressError', 'PalentPressSuccessMsg'];
        ContentManagerRecords({ cmUniqueNames: unqiueRecords })
        .then(result => {
            this.contentManagerRecords = result;
        })
        .catch(error => {
            this.showToastMessage('error', reduceErrors(error)[0] ? reduceErrors(error)[0] : JSON.stringify(error), 'Error!');
        })
    }
}