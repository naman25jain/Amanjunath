import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import generateASLDocumentForAccount from "@salesforce/apex/Account_ActionableUploadClass.generateASLDocumentForAccount";
export default class GenerateASLDocument extends LightningElement {

    @track selectedLanguage;
    @api recordId;
    @api displaySpinner = false;

    //To retrieve options in the dropdown to choose new or archived reports
    get languageOptions(){
        return[
            { label: 'English', value: 'English' },
            { label: 'French', value: 'French' },
            { label: 'German', value: 'German' },
            { label: 'Italian', value: 'Italian' },
            { label: 'Polish', value: 'Polish' },
            { label: 'Romanian', value: 'Romanian' },
            { label: 'Russian', value: 'Russian' },
            { label: 'Spanish', value: 'Spanish' },
            { label: 'Serbian', value: 'Serbian' },
            { label: 'Ukrainian', value: 'Ukrainian' },
            { label: 'Mandarin', value: 'Mandarin' },
            { label: 'Farsi', value: 'Farsi' },
            { label: 'Arabic', value: 'Arabic' },
            { label: 'Portuguese', value: 'Portuguese' },
            { label: 'Greek', value: 'Greek' },
            { label: 'Turkish', value: 'Turkish' },
        ];
    }

    //To handle toggling of New & Archived Reports
    handleLanguageChange(event){
        this.selectedLanguage = event.detail.value;
    }

    confirmDocumentGeneration(event){ 
        this.displaySpinner = true;       
        generateASLDocumentForAccount({
            recordId: this.recordId,
            selectedLanguage: this.selectedLanguage
        })
        .then(result=> {
            if(result == true){ 
                this.displaySpinner = false;
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'The Authorized Signature List document has been successfully generated.',
                    variant: 'success'
                  });
                this.dispatchEvent(evt);
            } else if(result == false){
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'There was an issue generating your document. Please contact the System Administrator.',
                    variant: 'error'
                  });
                this.dispatchEvent(evt);
            }            
        })
        .catch(error => {
          console.error("Error: " + JSON.stringify(error));
        }); 
    }

}