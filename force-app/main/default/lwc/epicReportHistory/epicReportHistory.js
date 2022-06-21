import {LightningElement,track} from 'lwc';
import getReportData from "@salesforce/apex/EpicReptHistoryListController.getReportData";
import getVerifiedCredentialURL from "@salesforce/apex/EpicReptHistoryListController.getVerifiedCredentialURL";
import getEPICReport from "@salesforce/apex/EpicReptHistoryListController.getEPICReport";
import getFileUrlWithSAS from '@salesforce/apex/CloudStorageUtils.getFileUrlWithSAS';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class EpicReportHistory extends LightningElement{
@track showReportData = false;
@track showNoReportMsg = false;
@track epicHistoryData = [];
@track verCredURL;
@track epicReportURL;
@track showDocument;
@track spinner = false;
header;
documentUrl;
connectedCallback(){
    this.handleInitialData();
}
handleInitialData(){
    getReportData().then(value=>{
        if(value){
            if(value.length > 0){
                this.showReportData = true;
                this.showNoReportMsg = false;
                this.epicHistoryData = [];
                this.refactorGetReportdata(value);
            }
        }else{
            this.epicHistoryData = [];
            this.showReportData = false;
            this.showNoReportMsg = true;
        }
    }).catch(error=>{
        window.console.error('Error: ' + JSON.stringify(error));
    });
}
refactorGetReportdata(value){
    for(let key in value){
        if(value.hasOwnProperty(key)){
            let hasApplicant = false;
            let hasEntity = false;
            let showVerCred = false;
            let showReport = false;
            if(value[key].reportType == 'Self'){
                hasApplicant = true;
                showReport = true;
            }else{
                hasEntity = true;
                showVerCred = true;
            }
            let tempRecord = {
                recId: value[key].caseId,
                entityName: value[key].entity,
                applicantName: value[key].applicant,
                verifiedCred: value[key].credential,
                status: value[key].status,
                updatedDate: value[key].updDate,
                paymentHistory: value[key].payHistory,
                reportType: value[key].reportType,
                hasApplicantName: hasApplicant,
                hasEntity: hasEntity,
                showVerCreds: showVerCred,
                showRep: showReport
            };
            this.epicHistoryData.push(tempRecord);
        }
    }
}
handleViewCredential(event){
    let caseId =  event.target.dataset.recordid;
    let credType = event.target.dataset.credtype;
    getVerifiedCredentialURL({caseId: caseId})
    .then(res=>{
        if(res){
            this.verCredURL = res;
        }
        if(!this.spinner){
            this.spinner = true;
        }
        let azureUrl = this.verCredURL;
        let splitParams = azureUrl.split("/");    
        if(splitParams.length > 0){
            let tempFileName = splitParams[splitParams.length - 1]; 
            if(this.verCredURL){
                getFileUrlWithSAS({
                fileName: tempFileName
                })
                .then(result=>{
                    this.showDocument = true;
                    if(result && this.template.querySelector("c-modal")){ 
                        this.header = credType;
                        this.documentUrl = result;
                        this.template.querySelector("c-modal").show();
                        this.spinner = false;  
                    }
                })
            }
        }
    }).catch(error=>{
        window.console.error('Error: '+JSON.stringify(error));
        this.spinner = false;                    
    }); 
}
handleViewEpicReport(event){
    let seeReport = event.target.dataset.showreport;
    let caseId =  event.target.dataset.recordid;
    let status = event.target.dataset.status;
    if(seeReport == 'true' && status != 'Report Expired'){
        this.refactorViewReport(caseId);
    }
    else if(seeReport == 'true' && status == 'Report Expired'){
        const evt = new ShowToastEvent({
            title: 'Report Expired',
            message: 'Cannot access expired Report',
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }
    else{
        const evt = new ShowToastEvent({
            title: 'Report Not Accessible',
            message: 'Only Report recipients may access Reports.',
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }
}
refactorViewReport(caseId){
    getEPICReport({caseId: caseId})
        .then(res=>{
            if(res){
                this.epicReportURL = res;
            }
            if(!this.spinner){
                this.spinner = true;
            }
            let azureUrl = this.epicReportURL;
            let splitParams = azureUrl.split("/");    
            if(splitParams.length > 0){
                let tempFileName = splitParams[splitParams.length - 1]; 
                if(this.epicReportURL){
                    getFileUrlWithSAS({
                        fileName: tempFileName
                    })
                    .then(result=>{
                        this.showDocument = true;
                        if(result && this.template.querySelector("c-modal")){ 
                            this.header = 'EPIC Verification Report';
                            this.documentUrl = result;
                            this.template.querySelector("c-modal").show();
                            this.spinner = false;  
                        }
                    })
                }
            }
        }).catch(error=>{
        window.console.error('Error: '+JSON.stringify(error));
        this.spinner = false;                    
        }); 
}
handleShowDocument(){
    this.template.querySelector("c-document-viewer").viewUrl(this.documentUrl);
}
handleCloseModal() {
    this.header = null;
    this.documentUrl = null;
    this.showDocument = false;
  }
}