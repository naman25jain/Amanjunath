import {LightningElement,api,track} from 'lwc';
import getCredVerfDefLang from '@salesforce/apex/CredVerfRejectedDefScreen.getCredVerfDefLang';
export default class CredVerfDefScreen extends LightningElement{
    @api caseId;
    @track rejLang = [];
    loadDefLanguages(){
        getCredVerfDefLang({
            caseId: this.caseId
        }).then(rejectedListLang=>{          
            this.rejLang = rejectedListLang;
        })
    }
    connectedCallback(){       
        this.loadDefLanguages();        
    }
}