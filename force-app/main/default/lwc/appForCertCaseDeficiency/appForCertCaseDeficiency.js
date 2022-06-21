import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getIncompleteCase from '@salesforce/apex/AppForCertController.getIncompleteCase';


export default class AppForCertCaseDeficiency extends NavigationMixin(LightningElement) {

    
    @api showincompleteCase = false;
       
    @track caseCheck = false;

    refreshCase

    
    @wire(getIncompleteCase)
    getIncompleteCase(result){ 
      
        this.refreshCase = result;       
        if(result.data !== undefined){
            this.caseCheck = result.data;
            if(this.caseCheck){
                this.showincompleteCase = true;                
                                                    
            }
            else{
                this.navigateToWebPage();
            }
                     
        }
     
    }

 
    navigateToWebPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/s/my-cases'
            }
        });
    }

   
}