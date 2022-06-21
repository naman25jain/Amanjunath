import {LightningElement,api} from 'lwc';
import getAsset from '@salesforce/apex/EntityCredVerController.getAsset';
import {updateScreenNumer} from 'c/util';
export default class EntityCredReviewAsset extends LightningElement{
    _caseId;
    maxsize = 10;
    payLoadList = [];
    @api showBackButton;
    @api
    get caseId(){
        return this._casedId;
    }
    set caseId(value){
        if(value){
            this._caseId = value;
        }
        this.getContactAsset();
    }
    connectedCallback(){
        updateScreenNumer(this._caseId,1);
    }
    getContactAsset(){
        getAsset({
            caseId: this._caseId
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
    returnCredRevList(event){
        // Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        const selectEvent = new CustomEvent('credverreviewlist');
        this.dispatchEvent(selectEvent);
    }
    nextButton(event){
        // Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        const selectEvent = new CustomEvent('fromassetnextbutton');
        this.dispatchEvent(selectEvent);
    }
    backButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('backevent');
        this.dispatchEvent(selectEvent);
    }
}