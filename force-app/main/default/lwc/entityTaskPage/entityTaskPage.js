import {LightningElement, track, api} from 'lwc';
import getEntityTaskData from '@salesforce/apex/EntityTaskRecord.getEntityTaskData';
import updateTaskStatus from '@salesforce/apex/EntityTaskRecord.updateTaskStatus';
import {NavigationMixin} from 'lightning/navigation';
import {showMessage} from "c/common";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const actions = [
    {label: 'View', name: 'view'},
    {label: 'Edit', name: 'edit'},
];
const column = [
    {
        label: 'Applicant Name',
        fieldName: 'applicantName', 
        sortable: "true",        
    },
    {
        label: 'Task Subject',
        fieldName: 'subject',
        type: "button",
        sortable: "true",
        typeAttributes: {label:{fieldName: 'subject'}}
    },
    {
        label: 'Related To',
        fieldName: 'relatedTo',
        sortable: "true"   
    },
    {
        label: 'Assigned To',
        fieldName: 'assignedTo',
        sortable: "true"
    },
    {
        label: 'Status',
        fieldName: 'status',
        sortable: "true"
    },
    {
        label: 'Last Updated',
        fieldName: 'lastUpdated',
        sortable: "true"  
    }, 
];
export default class EntityTaskPage extends NavigationMixin( LightningElement ){
    @track data = [];
    @track columns = column;
    @track sortBy;
    @track sortDirection;
    @track isTaskClicked = false;
    @track applicantName;
    @track subject;
    @track relatedTo;
    @track assignedTo;
    @track status;
    @track externalComments;
    @track documentToReUpload;
    @track payloadMspe;
    @track mspeUrl;
    @track isUploadButtonEnabled = false;
    @track showCredSummScreen = true;
    @track documentToReUploadString;
    @track row;
    @track datasetId;
    @track mspeSize = '1.2';
    @track isUpdateSuccess;
    @track value = '';
    @track currentEntity;
    @track tempPayloadMspe = {
        documentType: 'Medical School Performance Evaluation',
        assetRecordType: 'Credential',
        createOrReplace: 'Create',
        assetStatus: 'New',
        assetCreationRequired: 'true',
        assetName: 'Medical School Performance Evaluation',
        assetId: null,
        caseId: null,
        createFromPB: 'true'
    };
    
    @api
    get curEntity(){
        return this.currentEntity;
    }
    set curEntity(value){
        this.setAttribute('curEntity', value);
        this.currentEntity = value;
        this.setup();
    }
    
    setup(){
        this.data = [];
        getEntityTaskData({currentEntity : this.currentEntity })
        .then(prData =>{
            if(prData){
                for(let key in prData){
                    if(prData.hasOwnProperty(key)){
                        let tempRecord = {
                            taskId : prData[key]['taskId'],
                            nameUrl:prData[key]['taskId'],
                            applicantName:prData[key]['applicantName'],
                            subject:prData[key]['subject'],
                            relatedTo:prData[key]['relatedTo'],
                            assignedTo:prData[key]['assignedTo'],
                            status:prData[key]['status'],
                            lastUpdated:prData[key]['lastUpdated'],
                            documentUpload:prData[key]['documentUpload'],
                            caseId:prData[key]['caseId'],
                            whoId:prData[key]['whoId'],
                            externalComments:prData[key]['externalComments'],
                        };
                        if(tempRecord.applicantName == '' || tempRecord.applicantName == null){
                            tempRecord.nameUrl = '';
                        }

                        if(this.data.length > 0){
                            this.data = [...this.data, tempRecord];
                        }else{
                            this.data = [tempRecord];
                        }
                    }
                }
            }
        })
        .catch(error => {
            window.console.error('get Error: ' + JSON.stringify(error));
        });     
    }
    handleSortdata(event){
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }
    sortData(fieldname, direction){
        let parseData = JSON.parse(JSON.stringify(this.data));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x).toLowerCase() : ''; // handling null values
            y = keyValue(y) ? keyValue(y).toLowerCase(): '';
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
        this.recordsToDisplay = this.data;
    }
    handleRowAction(event){
        const row = event.detail.row;
        const datasetId = event.currentTarget.dataset.id;
        this.row = row;
        this.datasetId = datasetId;
        let taskInfo = {taskId:row.taskId,applicantName:row.applicantName,relatedTo:row.relatedTo, taskClicked:true};
        this.isTaskClicked = true;
        this.applicantName = row.applicantName;
        this.assignedTo = row.assignedTo;
        this.status = row.status;
        this.relatedTo = row.relatedTo;
        this.subject = row.subject;
        this.value = row.status;
        this.externalComments = row.externalComments;
        if(this.subject == 'Reupload MSPE'){
            this.documentToReUploadString = 'Upload Medical School Performance Evaluation';
            this.tempPayloadMspe.documentType = 'Medical School Performance Evaluation';
            this.tempPayloadMspe.assetName = 'Medical School Performance Evaluation';
        }else if(this.subject == 'Reupload MS Transcript'){
            this.documentToReUploadString = 'Upload Medical School Transcript';
            this.tempPayloadMspe.documentType = 'Final Medical School Transcript';
            this.tempPayloadMspe.assetName = 'ERAS Final Medical School Transcript';
        }
        const selectEvent = new CustomEvent("taskevent",{
            detail:taskInfo
        });
        this.dispatchEvent(selectEvent);
        this.tempPayloadMspe.contactId = row.whoId;
        this.tempPayloadMspe.caseId = row.caseId;
        this.payloadMspe = JSON.stringify(this.tempPayloadMspe);
	}
    showTaskList(){
        this.isTaskClicked = false;
        this.isUploadButtonEnabled = false;
        this.photoUrl = null;
        this.mspeUrl = null;
        this.fmstUrl = null;
        this.payloadMspe = null;
        this.showUploadMain = true;
        this.showReqTransLink = true;
    }
    handleOnMspeUpload(event){
        this.mspeUrl = event.detail.url;
        this.isUploadButtonEnabled = true;
    }
    handleStatusChange(event){
        const statusVal = event.currentTarget.value;
        this.value = statusVal;
    }
    handleReUploadButton(event){
        const statusValue = this.value;
            this.showCredSummScreen = true;
            this.isTaskClicked = false;
            this.data.splice(this.data.findIndex(row => row.taskId === this.row.taskId), 1);
            this.photoUrl = null;
            this.mspeUrl = null;
            this.fmstUrl = null;
            this.showUploadMain = true;
            this.showReqTransLink = true;
            
            
            updateTaskStatus({taskId : this.row.taskId})
            .then(result =>{
                this.isUpdateSuccess = result; 
            })
            .catch(error =>{
                console.error('Error--->'+JSON.stringify(error));
            });
    }

    get options() {
        return [
            { label: 'New', value: 'New' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Closed', value: 'Closed' }
        ];
    }

    showErrorToast() {
        const evt = new ShowToastEvent({
            message: 'Please change the status to closed',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}