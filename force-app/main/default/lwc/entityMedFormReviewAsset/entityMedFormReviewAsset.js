import {LightningElement,api} from 'lwc';
import getAsset from '@salesforce/apex/EntityCredVerController.getAsset';
import getFMDAsset from '@salesforce/apex/EntityCredVerController.getFMDAsset';
import getFSTAsset from '@salesforce/apex/EntityCredVerController.getFSTAsset';
import {updateScreenNumer} from 'c/util';
export default class EntityMedFormReviewAsset extends LightningElement{
    _caseId;
    maxsize = 10;
    payLoadList = [];
    payLoadFMD = [];
    payLoadFST = [];
    @api
    get caseId(){
        return this._casedId;
    }
    set caseId(value){
        if(value){
            this._caseId = value;
        }
        this.getContactAsset();
        this.getFMDAsset();
        this.getFSTAsset();
    }
    connectedCallback(){
        updateScreenNumer(this._caseId,1);
    }
    getContactAsset(){
        getAsset({
            caseId : this._caseId
        }).then(result=>{
            let temppayLoad = [];
            result.forEach(item=>{
                let payLoadItems = JSON.parse(JSON.stringify(item));
                payLoadItems.payLoad = JSON.stringify(item);
                temppayLoad.push(payLoadItems);
            });
            this.payLoadList = temppayLoad;
        }).catch(err=>window.console.error('Error: ',err));
    }
    getFMDAsset(){
        getFMDAsset({
            caseId : this._caseId
        }).then(result=>{
            let temppayLoad = [];
            result.forEach(item=>{
                let payLoadItems = JSON.parse(JSON.stringify(item));
                payLoadItems.payLoad = JSON.stringify(item);
                temppayLoad.push(payLoadItems);
            });
            this.payLoadFMD = temppayLoad;
        }).catch(err=>window.console.error('Error: ',err));
    }
    getFSTAsset(){
        getFSTAsset({
            caseId : this._caseId
        }).then(result=>{
            let temppayLoad = [];
            result.forEach(item=>{
                let payLoadItems = JSON.parse(JSON.stringify(item));
                payLoadItems.payLoad = JSON.stringify(item);
                temppayLoad.push(payLoadItems);
            });
            this.payLoadFST = temppayLoad;
        }).catch(err=>window.console.error('Error: ',err));
    }
    returnCredRevList(event){
        // Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        const selectEvent = new CustomEvent('showlist');
        this.dispatchEvent(selectEvent);
    }
    showQuestionnaire(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('showquest', {});
        this.dispatchEvent(selectEvent);
    }
}