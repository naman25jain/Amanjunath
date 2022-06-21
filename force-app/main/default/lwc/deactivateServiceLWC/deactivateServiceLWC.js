import { LightningElement, track, api, wire } from 'lwc';
import deactivateService from '@salesforce/apex/DeactivateServiceController.deactivateService';
import perfDataCheck from '@salesforce/apex/DeactivateServiceController.perfDataCheck';
export default class deactivateServiceLWC extends LightningElement {
  @track displayMessage = '';
  @track openModal = true;
  @track noPerfData;
  @api recordId;
  @track spinner = false;
  @wire(perfDataCheck, { ac2ServId: '$recordId'}) 
  recordResult({error, data}) {
    if(data){
      this.noPerfData = data;
    } else if(error){
      this.error = error;
    }
  }
  

  save() {
    this.spinner = true;
    deactivateService({
      ac2ServId : this.recordId
    })
    .then(result => {
      if(result !== ''){
        if(result == 'true'){
          this.spinner = false;
          const closeQA = new CustomEvent('close');
          // Dispatches the event.
          this.dispatchEvent(closeQA);
          window.location.reload();
        }
      }
    })
  }
  cancel() {
    this.openModal = false;
    const closeQA = new CustomEvent('close');
    // Dispatches the event.
    this.dispatchEvent(closeQA);
  }
}