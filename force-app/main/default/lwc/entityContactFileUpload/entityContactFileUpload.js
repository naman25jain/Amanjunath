import {
    LightningElement,
    track,
    api
} from 'lwc';
import getDocumentbyId from '@salesforce/apex/EntityServiceRequestController.getDocumentbyId';
import getDocumentByAssetType from '@salesforce/apex/EntityServiceRequestController.getDocumentByAssetType';

export default class EntityContactFileUpload extends LightningElement {
    @api contactId;
    @api type;
    @api assetSignatureForm;

    @api isUploaded = false;
    @api fileType;
    @api fileName;
    @api fileURL;
    @api fileData = '';
    @api contentDocumentId;

    @track assetStatusInProgress = 'In Progress';

    constructor() {
        super();
        this.loadFileDetails();
    }
    connectedCallback() {
        this.loadFileDetails();
    }
    
    loadFileDetails() {
        if (this.assetSignatureForm == true) {
            getDocumentByAssetType({
                contactId : this.contactId,
                assetStatus: this.assetStatusInProgress // Status is In Progress
            })
            .then(result => {
                if (result !== '') {
                    this.fileData = JSON.stringify(result).split(':`:');
                    this.isUploaded = true;
                    this.fileName = this.fileData[0].replace('"', '');
                    this.fileType = this.fileData[1].replace('"', '');
                    this.fileURL = this.fileData[2].replace('"', '');
                }
            })
            .catch(error => {
                window.console.log('Error: ' + JSON.stringify(error));
            });
        }

    }
    // accepted parameters
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        if (uploadedFiles.length > 0) {
            getDocumentbyId({
                    contentDocId: uploadedFiles[0].documentId
                })
                .then(result => {
                    if (result !== '') {
                        this.fileData = JSON.stringify(result).split(':`:');
                        this.isUploaded = true;
                        this.fileName = this.fileData[0].replace('"', '');
                        this.fileType = this.fileData[1].replace('"', '');
                        this.fileURL = this.fileData[2].replace('"', '');
  
                        // Creates the event with the data.
                        const selectedEvent = new CustomEvent("assetinserted", {
                            detail: {
                                fileName: this.fileName,
                                fileType: this.fileType,
                                contentDocumentId: uploadedFiles[0].documentId
                            }
                        });

                        // Dispatch the event.
                        this.dispatchEvent(selectedEvent);
                    }
                })
                .catch();

        }

    }


}