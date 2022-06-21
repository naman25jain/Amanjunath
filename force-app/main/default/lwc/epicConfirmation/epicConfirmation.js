import { LightningElement, api, track} from 'lwc';
import getCaseNumber from '@salesforce/apex/EpicCredVerController.getCaseNumber';
export default class EpicConfirmation extends LightningElement{
    @api caseNumber;
    @track firstLine;
    @track secondLine;
    @track thirdLine;
    @track fourthLine;
    @track fifthLine;
    @api casesListConfScreen;
    @track spinner = false;
    @track showPageReload = false;    
    connectedCallback(){
        this.fetchCaseNumber();
    }
    fetchCaseNumber(){
        this.spinner = true;
        getCaseNumber().then(data=>{
            this.caseNumber = data;  
            this.spinner = false;              
        })
        .catch(error => {
            this.spinner = false;
        });
    }
    cancelButton(event){
        window.location.reload();
    }
}