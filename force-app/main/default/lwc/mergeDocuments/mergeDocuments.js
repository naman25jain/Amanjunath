import {LightningElement, api, wire, track} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import {loadScript} from "lightning/platformResourceLoader";
import libUrl from "@salesforce/resourceUrl/pdftron_lib";
import myfilesUrl from "@salesforce/resourceUrl/pdftron_myfiles";
import {fireEvent, registerListener, unregisterAllListeners} from 'c/pubsub';
import mimeTypes from './mimeTypes';
function _base64ToArrayBuffer(base64){
    var binary_string = window.atob(base64);
    var len = binary_string.length;
    var bytes = new Uint8Array(len);
    for(var i = 0; i < len; i++){
        bytes[i] = binary_string.charCodeAt(i);
    }
    return bytes.buffer;
}
export default class MergeDocuments extends LightningElement{
    fullAPI = true;
    @api recordId;
    @track this_handleReceiveMessage;
    @track caseNumber;
    @api source = null;
    @wire(CurrentPageReference)
    pageRef;
    connectedCallback(){ 
        registerListener('blobSelected', this.handleBlobSelected, this);
        this.this_handleReceiveMessage = this.handleReceiveMessage.bind(this);
        window.addEventListener('message', this.this_handleReceiveMessage);
    }
    disconnectedCallback(){
        unregisterAllListeners(this);
        window.removeEventListener('message', this.this_handleReceiveMessage);
    }
    handleBlobSelected(records){
        records = JSON.parse(records);
        let temprecords = [];
        if(records[0].caseNumber){
            this.caseNumber = records[0].caseNumber;
        }
        records.forEach(record=>{
            let blobby;
            if(this.source === 'ERAS'){
                blobby = new Blob([_base64ToArrayBuffer(record.base64)], {
                    type: mimeTypes[record.FileExtension]
                });
            }else{
                blobby = record.base64;
            }
            let payload = {
                blob: blobby,
                extension: record.FileExtension,
                filename: record.FileName,
                documentId: record.Id
            };
            temprecords = [...temprecords, payload];
        });
        this.iframeWindow.postMessage({type: 'OPEN_DOCUMENT_LIST', temprecords}, this.pageRef);
    }
    renderedCallback(){
        var self = this;
        if(this.uiInitialized){
            return;
        }
        this.uiInitialized = true;
        Promise.all([
            loadScript(self, libUrl + '/webviewer.min.js')
        ]).then(()=>this.initUI())
        .catch(console.error);
    }
    initUI(){
        var myObj = {
            libUrl: libUrl,
            fullAPI: this.fullAPI || false,
            namespacePrefix: '',
        };
        const viewerElement = this.template.querySelector('div')
        // eslint-disable-next-line no-unused-vars
        const viewer = new PDFTron.WebViewer({
            path: libUrl, // path to the PDFTron 'lib' folder on your server
            custom: JSON.stringify(myObj),
            backendType: 'ems',
            config: myfilesUrl + '/configMerge.js',
            fullAPI: this.fullAPI,
            l: 'Educational Commission for Foreign Medical Graduates(ECFMG.org):OEM:See Agreement::B+:AMS(20211230):99A5A20D0477580AB360B13AC982536B60614F8B5C703A1BCB6C05432C3C3EB604C2B6F5C7',
        }, viewerElement);
        viewerElement.addEventListener('ready', ()=>{
            this.iframeWindow = viewerElement.querySelector('iframe').contentWindow;
            fireEvent(this.pageRef, 'getAssets', 'assets');
        })
    }
    handleReceiveMessage(event){
        if(event.isTrusted && typeof event.data === 'object'){
            if(event.data.type === 'SAVE_DOCUMENT'){
                const blob = new Blob([_base64ToArrayBuffer(event.data.payload.base64Data)], {type: 'application/pdf'});
                if(this.source === 'ERAS'){
                    fireEvent(this.pageRef, 'mergeComplete', blob);
                }else{
                    this.downloadFile(blob, this.caseNumber + '.pdf');
                    fireEvent(this.pageRef, 'closeaction', 'close');
                }
            }
        }
    }
    downloadFile(blob, fileName){
        const link = document.createElement('a');
        // create a blobURI pointing to our Blob
        link.setAttribute('href', URL.createObjectURL(blob));
        link.setAttribute('download', fileName);
        // some browser needs the anchor to be in the doc
        document.body.appendChild(link);
        link.click();
        link.remove();
        // in case the Blob uses a lot of memory
        setTimeout(()=>URL.revokeObjectURL(link.href), 7000);
    }
}