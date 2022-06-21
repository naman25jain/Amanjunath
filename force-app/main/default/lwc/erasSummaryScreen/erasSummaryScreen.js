import{LightningElement, api, track} from 'lwc';
import getContactAssociationOrStaging from "@salesforce/apex/ERASController.getContactAssociationOrStaging";
import getActiveErasSeason from "@salesforce/apex/ERASController.getActiveErasSeason";
import getERASPSubmissionCase from "@salesforce/apex/ERASController.getERASPSubmissionCase";
export default class ErasSummaryScreen extends LightningElement {
    @api objectId;
    @api objectType;
    @track activeSeasonMonth;
    @track seasonStartDate;
    @track showSummary = true;
    @track erasCaseRecordId = '';
    constructor(){
        super();
        this.getActiveERASSeasonDetails();
    }
    connectedCallback(){
        getERASPSubmissionCase().then(result=>{
            if(result){
                this.erasCaseRecordId = result;    
            } 
        })
        .catch(error=>{
            window.console.log("Error: " + JSON.stringify(error));
        });
     }
    getContactAssocObjIdAndName(){
        getContactAssociationOrStaging().then(result=>{
            if(result){
                this.objectId = result.split(",")[0];
                this.objectType = result.split(",")[1];            
            } 
        })
        .catch(error=>{
            window.console.log("Error: " + JSON.stringify(error));
        });
    }
    getActiveERASSeasonDetails(){
        getActiveErasSeason().then(result=>{
            if(result){
                this.activeSeasonMonth = result.split("-")[0];
                this.seasonStartDate = result.split("-")[1];            
            } 
        })
        .catch(error=>{
            window.console.log("Error: " + JSON.stringify(error));
        });
    }
    handleBackClick(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('prevevent',{});
        this.dispatchEvent(selectEvent);
    }
    handleNextClick(){
        this.showNextScreen=true;
        this.showbackScreen=false;
        this.showSummary = false;
    }
    showSummaryScreen(){
        this.showNextScreen=false;
        this.showbackScreen=false;
        this.showSummary = true;
    }
}