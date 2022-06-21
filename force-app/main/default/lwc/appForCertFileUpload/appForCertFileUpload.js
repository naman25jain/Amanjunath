import {
    LightningElement,
    api
} from 'lwc';
import createAsset from '@salesforce/apex/AppForCertController.createAsset';
import getDocument from '@salesforce/apex/AppForCertController.getDocument';


export default class AppForCertFileUpload extends LightningElement {
    @api parentId;
    @api conDocId;
    @api contactId;
    @api contactAssociationType;
    @api type;
    @api keyval;
    @api parentkeyval;
    @api labelval;
    @api assetId;

    @api isUploaded = false;
    @api fileType;
    @api fileName;
    @api fileURL;
    @api fileData = '';

    @api examType;

    constructor() {
        super();
        this.loadFileDetails();
    }
    connectedCallback() {

        this.loadFileDetails();
    }

    loadFileDetails() {
        if (this.contactId !== undefined &&
            this.contactAssociationType !== undefined &&
            this.keyval !== undefined) {
            getDocument({
                    contactId: this.contactId,
                    keyval: this.keyval,
                    contactAssociationType: this.contactAssociationType,
                    parentId: ''
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

        if (this.parentId !== undefined && this.keyval == 'Visa Exception Documentation Document') {
            getDocument({
                    contactId: this.contactId,
                    keyval: this.keyval,
                    contactAssociationType: '',
                    parentId: this.parentId
                })
                .then(result => {
                    if (result !== '') {
                        this.fileData = JSON.stringify(result).split(':`:');
                        this.isUploaded = true;
                        this.fileName = this.fileData[0].replace('"', '');
                        this.fileType = this.fileData[1].replace('"', '');
                        this.fileURL = this.fileData[2].replace('"', '');
                    }

                    // Creates the event with the data.
                    const selectedEvent = new CustomEvent("assetloaded", {
                        detail: {
                            assetId: this.assetId,
                            fileName: this.fileName,
                            fileType: this.fileType
                        }
                    });

                    // Dispatch the event.
                    this.dispatchEvent(selectedEvent);
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

            createAsset({
                    contentDocId: uploadedFiles[0].documentId,
                    caseId: this.parentId,
                    type: this.type,
                    contactId: this.contactId,
                    contactAssociationType: this.contactAssociationType,
                    val: this.keyval + "++" + this.parentkeyval,
                    examType: this.examType
                })
                .then(result => {
                    if (result !== '') {
                        this.fileData = JSON.stringify(result).split(':`:');
                        this.isUploaded = true;
                        this.fileName = this.fileData[0].replace('"', '');
                        this.fileType = this.fileData[1].replace('"', '');
                        this.fileURL = this.fileData[2].replace('"', '');
                        this.assetId = this.fileData[3].replace('"', '');

                        // Creates the event with the data.
                        const selectedEvent = new CustomEvent("assetinserted", {
                            detail: {
                                assetId: this.assetId,
                                fileName: this.fileName,
                                fileType: this.fileType,
                                catsId: this.contactAssociationType
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