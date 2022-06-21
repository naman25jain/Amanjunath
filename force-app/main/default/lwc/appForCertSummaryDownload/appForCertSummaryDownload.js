import {LightningElement, track, api} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getBase64Pdf from '@salesforce/apex/CloudStorageUtils.getBase64Pdf';
import getFileUrlWithSAS from '@salesforce/apex/CloudStorageUtils.getFileUrlWithSAS';
import getAppForCertSummaryPDFUrl from '@salesforce/apex/AppForCertHelper.getAppForCertSummaryPDFUrl';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class AppForCertSummaryDownload extends NavigationMixin(LightningElement){
    @track appForCertSummaryURL;
    @track assetReportURL;
    @api caseId;
    connectedCallback(){
        getAppForCertSummaryPDFUrl({
            caseId: this.caseId
        })
        .then(result => {
            if(result!==''){
                this.appForCertSummaryURL = result; 
            }
        })
    }
    refactorViewReport(event){
        this.assetReportURL = event.currentTarget.dataset.key;
        let azureUrl = this.assetReportURL;
        let splitParams = azureUrl.split("/");
        if(splitParams.length > 0){
            let tempFileName = splitParams[splitParams.length - 1];
            if(this.assetReportURL){
                getFileUrlWithSAS({
                    fileName: tempFileName
                })
                .then(result=>{
                    if(result){
                        this.documentUrl = result;
                        let temp = result;
                        //call apex method to get base64
                        getBase64Pdf({surl: temp})
                        .then(data=>{
                            var bbody = data; 
                            var byteCharacters = atob(bbody);
                            var byteCharacters = atob(bbody.replace(/^data:image\/(png|jpeg|jpg);base64,/, ''));                
                            const buf = new Array(byteCharacters.length);
                            for (var i = 0; i != byteCharacters.length; ++i) buf[i] = byteCharacters.charCodeAt(i);      
                            const view = new Uint8Array(buf);      
                            const blob = new Blob([view], {
                                type: 'application/octet-stream'
                            });
                            const a = window.document.createElement('a');
                            a.href = window.URL.createObjectURL(blob);
                            a.download = tempFileName;
                            document.body.appendChild(a);
                            a.click();
                            document.body.removeChild(a);
                        }).catch(error => {
                            dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error downloading Asset!',
                                    message: error.message,
                                    variant: 'error',
                                })
                            );
                            })
                        this.spinner = false;
                    }                    
                })
            }
        }    
    }      
}