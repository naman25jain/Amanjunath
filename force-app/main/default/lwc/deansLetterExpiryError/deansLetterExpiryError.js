import { LightningElement ,track} from 'lwc';
import deansLetterOrFinalDiplomaError from '@salesforce/apex/AppForCertHelper.deansLetterOrFinalDiplomaError';


export default class DeansLetterExpiryError extends LightningElement {
    @track showDeansLetterError;
    connectedCallback() {
        deansLetterOrFinalDiplomaError().then(data => {
            this.showDeansLetterError = data;
        })
    }
}