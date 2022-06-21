import {LightningElement, api, track} from 'lwc';
import fetchCaseNumber from '@salesforce/apex/DupEcfmgCertificateController.fetchCaseNumber';
export default class ScoreRecheckConfirmation extends LightningElement{
    @api caseNumber;
    @track showMessage = false;
    @track spinner = true;
    @track showPageReload = false;
    @api reasonDuplicate;
    @api additionalDtl;  
    connectedCallback(){
        this.spinner = true;
        this.fetchCaseNo();
    }
    fetchCaseNo(){
        fetchCaseNumber().then(data=>{
            this.caseNumber = data;  
            this.showMessage = true; 
            this.spinner = false;      
        })
        .catch(error => {
            this.spinner = false;
            this.showMessage = true;
        });
    }
    cancelButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }
}