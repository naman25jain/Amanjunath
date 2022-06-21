import { LightningElement,track } from 'lwc';
import getRegionChangeCaseforSummary from "@salesforce/apex/RegionChangeController.getRegionChangeCaseforSummary";

export default class RegionChangeSummary extends LightningElement{
@track examRegistrationsList;
@track showbtn = false;
@track showMedDetails= false;

connectedCallback(){  
    this.loaddetails();
    this.showbtn = false;  
}

    loaddetails(){
      this.showMedDetails= true;
      getRegionChangeCaseforSummary()
        .then(result=> {
          this.examRegistrationsList = result;
          this.showbtn = true; 
        })
        .catch(error => {
          console.log("Error: " + JSON.stringify(error));
        });      
    }

      prevButton(event){
        this.examRegistrationsList =[];
        this.showbtn = false;
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

}