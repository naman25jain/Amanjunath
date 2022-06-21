import {LightningElement,api,track} from 'lwc';
import {updateScreenNumer} from 'c/util';
import getEcfmgVerFormURL from '@salesforce/apex/EntityCredVerController.getEcfmgVerFormURL';
export default class EntityCredVerReviewVerForm extends LightningElement{
    @api azureDocUrl;
    @api caseId;
    @track spinner = true;
    @track tempPayload =  {
        contactId: null,
        caseId: null,
        catsId: null,
        documentType: null,
        assetRecordType: null,
        createOrReplace: null,
        assetStatus: null,
        assetCreationRequired: null,
        assetId: null,
        createFromPB: 'true'
    };
    @track finalPayload;
    @track showVerForm = false;
    @track showThumbnail = false;
    connectedCallback(){
        updateScreenNumer(this.caseId,4);
        if(!this.azureDocUrl){
            getEcfmgVerFormURL({
                caseId: this.caseId
            }).then(result=>{
                if(result){
                    this.azureDocUrl = result;
                    this.updatePayload();
                }                
            }).catch(err=>window.console.error('Error: ',err));
        }
        else if(this.azureDocUrl){
            this.updatePayload();
        }
    }
    updatePayload(){
        this.finalPayload = JSON.stringify(this.tempPayload);
        this.showVerForm = true;
        this.showThumbnail = true;
        this.spinner = false;
    }
    showCredRevLandPage(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('showscredintland',{});
        this.dispatchEvent(selectEvent);
    }
    showCredRevPrevPage(event){
        event.preventDefault();
        const selectEvent = new CustomEvent("prevevent",{});
        this.dispatchEvent(selectEvent);
    }
    showCredRevNextPage(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('nextevent',{});
        this.dispatchEvent(selectEvent);
    }
}