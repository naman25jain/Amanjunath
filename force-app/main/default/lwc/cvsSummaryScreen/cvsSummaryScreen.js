// This is reused in entity portal
import {LightningElement,track,api} from 'lwc';
import getUnpaidCVS from '@salesforce/apex/CVSRequestController.getUnpaidCVS';
import removeUnpaidCase from '@salesforce/apex/CVSRequestController.removeUnpaidCase';
export default class CvsSummaryScreen extends LightningElement{
    @track spinner;
    @track pendCVSReqs = [];
    @track showNoRecs;
    @track caseRecordId;
    isApplicant = false;
    _source = '';
    @api
    get source(){
        return 
    }
    set source(value){
        this._source = value;
        if(value == 'entity'){            
            this.isApplicant = false;
        }else if(value == 'applicant'){
            this.isApplicant = true
        }
    }
    connectedCallback(){
        this.loadUnpaidCVSReqs();
    }
    loadUnpaidCVSReqs(){
        this.spinner = true;
        getUnpaidCVS().then(cvsresult=>{
            if(cvsresult.length>0){
                this.pendCVSReqs = cvsresult;
                this.showNoRecs = false;
                this.spinner = false;
                this.cvsRequestCases = [];
                for(let key in cvsresult){ 
                    if(cvsresult.hasOwnProperty(key)){
                        this.cvsRequestCases.push(cvsresult[key].Id);
                    }
                }
                this.caseRecordId = this.cvsRequestCases.toString();
            }else{
                this.pendCVSReqs = null;
                this.showNoRecs = true;
                this.spinner = false;
            }
        }).catch(error=>{
            window.console.error(error);
        })
    }
    handleRemoval(event){
        var delCaseId = event.target.dataset.recordid;
        this.spinner = true;
        removeUnpaidCase({caseId: delCaseId}).then(res=>{
            if(res){
                this.loadUnpaidCVSReqs();
            }
        }).catch(error=>{
            window.console.error(error);
        })
    }
    handleEditReq(event){
        var editCaseId = event.target.dataset.recordid;
        var editCase = true;
        let caseInfo = {
            caseId: editCaseId,
            editCase: editCase
        }
        const selectEvent = new CustomEvent("editevent", {detail: caseInfo});
        this.dispatchEvent(selectEvent);
    }
    handleCancel(event){
        //redirect to landing screen
        event.preventDefault();
        const selectEvent = new CustomEvent("cancelevent",{});
        this.dispatchEvent(selectEvent);
    }
    handleAnotherReq(){
        //redirect to state medical board selection screen
        const selectEvent = new CustomEvent("addnewreq",{});
        this.dispatchEvent(selectEvent);
    }
    handleNext(event){
        //redirect to payment cart page
        event.preventDefault();
        const selectEvent = new CustomEvent("nextevent",{detail:{caserecordid:this.caseRecordId}});
        this.dispatchEvent(selectEvent);
    }
}