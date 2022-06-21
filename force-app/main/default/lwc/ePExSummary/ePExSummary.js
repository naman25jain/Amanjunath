import {LightningElement, track} from 'lwc';
import getEpexCaseDetails from "@salesforce/apex/EPExController.getEpexCaseDetails";
export default class EPeXSummary extends LightningElement{
  @track examRegistrationsList;
  @track showbtn = false;
  connectedCallback(){
    this.loaddetails();
    this.showbtn = false;
  }
  loaddetails(){
    getEpexCaseDetails().then(result=>{
      if(result.length > 0){
        this.examRegistrationsList = result;
        this.showbtn = true;
      }
    })
    .catch(error=>{
      window.console.error("Error: " + JSON.stringify(error));
    });
  }
  prevButton(event){
    event.preventDefault();
    const selectEvent = new CustomEvent("previousevent", {});
    this.dispatchEvent(selectEvent);
  }
  nextButton(event){
    event.preventDefault();
    const selectEvent = new CustomEvent("nextevent", {});
    this.dispatchEvent(selectEvent);
  }
  cancelButton(event){
    event.preventDefault();
    const selectEvent = new CustomEvent("cancelevent", {});
    this.dispatchEvent(selectEvent);
  }
  cancelButtonToOpen(){
    this.template.querySelector('[data-id="newModalAlert"]').show();
  }
  closeModal(){
    this.template.querySelector('[data-id="newModalAlert"]').hide();
  }
}