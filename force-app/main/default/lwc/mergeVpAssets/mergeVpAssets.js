import {LightningElement, wire, track, api} from 'lwc';
import {NavigationMixin, CurrentPageReference} from 'lightning/navigation';
import {fireEvent, registerListener, unregisterAllListeners} from 'c/pubsub';
import getAssetsForMerge from '@salesforce/apex/ComplieVerificationPacketController.getAssetsForMerge';
import {CloseActionScreenEvent} from 'lightning/actions';
export default class MergeVpAssets extends NavigationMixin(LightningElement){
    @api recordId;
    isSpinner = false;
    @track uiInitialized = false;
    @track calloutInitialized = false;
    @track pageRef;
    @track title = "Download In Progress";
    @wire(CurrentPageReference)
    getCurrentPageReference(CurrPageRef){
        this.pageRef = CurrPageRef;
        this.recordId = CurrPageRef.state.recordId;
    }
    connectedCallback(){
        registerListener('getAssets', this.getFiles, this);
        registerListener('closeaction', this.closeActionevent, this);
    }
    disconnectedCallback(){
        unregisterAllListeners(this);
    }
    closeActionevent(value){
        this.isSpinner = false;
        this.closeAction();
    }
    getFiles(){
        getAssetsForMerge({recordId : this.recordId})
        .then(result=>{
            this.isSpinner =true;
            let payload = JSON.stringify(result);
            fireEvent(this.pageRef, 'blobSelected', payload);
        })
        .catch(error=>{
            console.log('error => ', error);
        })
    }
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
        window.history.go(-1);
    }
}