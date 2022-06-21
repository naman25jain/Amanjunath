import {LightningElement, api, track} from "lwc";
import getDispContent from '@salesforce/apex/GContentManager.getContent';
export default class GDisplayContent extends LightningElement{
    @api uniqueContentValue;
    @track displayContent;
    @track spinner = false;
    connectedCallback(){
        this.spinner = true;
        getDispContent({uniqueName:this.uniqueContentValue}).then(data => {
            this.displayContent = data;
            this.spinner = false;
        });
    }
}