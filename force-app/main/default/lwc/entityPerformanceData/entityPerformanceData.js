import {
    LightningElement,
    track,
    api
} from 'lwc';
//import required apex methods
import checkPerformanceDataEnrolled from '@salesforce/apex/EntityScoreReport.checkPerformanceDataEnrolled';
import getContact from '@salesforce/apex/EntityScoreReport.getContact';
import getPerformanceData from '@salesforce/apex/EntityScoreReport.getPerformanceData';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMessage from '@salesforce/apex/RestrictedMessage.getMessage';
import performanceErrormsg from '@salesforce/label/c.Restriction_Service_Error_Message';
export default class EntityPerformanceData extends LightningElement {
    userId=Id;
    @track columnsPerformance = [{
            label: 'Rest of Name',
            fieldName: 'firstName',
            sortable: true
        },
        {
            label: 'Last Name',
            fieldName: 'lastName',
            sortable: true
        },
        {
            label: 'Student/Graduate',
            fieldName: 'enrollmentStatus',
            sortable: true
        },
        {
            label: 'USMLE ID',
            fieldName: 'usmleId',
            sortable: true
        },
        {
            label: 'Unique Medical School ID',
            fieldName: 'uniqueStudentId',
            sortable: true
        },
        {
            label: 'Exam Type',
            fieldName: 'examType',
            sortable: true
        },
        {
            label: 'Date of Exam',
            fieldName: 'dateOfExam',
            sortable: true
        },
        {
            label: 'Pass/Fail',
            fieldName: 'examResult',
            sortable: true
        },
        {
            label: '3 Digit Score',
            fieldName: 'threeDigitScore',
            type: 'number',
            sortable: true,
            cellAttributes: {
                alignment: 'left'
            }
        },
        {
            label: 'Score Available Until',
            fieldName: 'scoreAvailableUntil',
            sortable: true
        },
        {
            label: 'Remarks',
            fieldName: 'remarks',
            sortable: true
        }
    ];
    @track dataPerformance = [];
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;
    @track displayNoPerformanceDataEnrolled;
    @track errorMessagesText;
    @track performanceDataRecords = []; //All Records available
    @track recordsToDisplayPerformance = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
    @track hrefdata;
    @track attributesList = [];
    @track restrictedAccess;
    @track errorMessages;
    @track tempJson ={
        accountId: '',
        contactId: '',
        service: ''
    };
    @track jsonWrap;
    @api
    get currentEntity(){
        return this._currentEnt;
    }
    set currentEntity(value){
        this.setAttribute('currentEntity', value);
        this._currentEnt = value;
    }
    @track _currentEnt;
    @track spinner = false;
    connectedCallback(){
        this.loadPrimaryDetails();
    }
    loadPrimaryDetails(){
        this.displayNoPerformanceDataEnrolled = false;
        getContact({
            userId: this.userId
        }).then(conResult => {
            let tempJson ={
                accountId: this._currentEnt,
                contactId: conResult,
                service: 'Score Reporting - Internal and External'
            };
            getMessage({jsonInput: JSON.stringify(tempJson)}).then(result => {
                if(result){
                    this.restrictedAccess=true;
                    this.displayNoPerformanceDataEnrolled = false;
                    this.errorMessages=performanceErrormsg;
                    const evt = new ShowToastEvent({
                        title: 'Restriction Applied',
                        message: performanceErrormsg,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                }else{
                    this.restrictedAccess=false;
                    this.setup();
                }
            })
            .catch(error => {
                window.console.error(error);
            });
        })
    }
    setup(){
        this.dataPerformance = [];
        this.recordsToDisplayPerformance = [];
        this.performanceDataRecords = [];
        this.spinner = true;
        checkPerformanceDataEnrolled({
            currentEntityId: this._currentEnt
        })
        .then(result => {
            if (result){
                this.displayNoPerformanceDataEnrolled = false;
                getPerformanceData({
                        currentEntityId: this._currentEnt
                    }).then(performanceData => {
                        if (Object.keys(performanceData).length !== 0){
                            this.dataPerformance = [];
                            let rowNum = 0;
                            for (let key in performanceData){
                                if (performanceData.hasOwnProperty(key)){
                                    let tempRecord = {
                                        firstName: performanceData[key]['Applicant__r.FirstName'],
                                        lastName: performanceData[key]['Applicant__r.LastName'],
                                        enrollmentStatus: performanceData[key]['Applicant__r.School_Enrollment_Status__c'],
                                        id: performanceData[key].id !== undefined ? performanceData[key].id : '',
                                        usmleId: performanceData[key].USMLE_ID_CIBIS__c !== undefined ? performanceData[key].USMLE_ID_CIBIS__c : '',
                                        uniqueStudentId: performanceData[key].Unique_Student_Id !== undefined ? performanceData[key].Unique_Student_Id : '',
                                        examType: performanceData[key].Exam_Types__c !== undefined ? performanceData[key].Exam_Types__c : '',
                                        dateOfExam: performanceData[key].Exam_taken_date__c !== undefined ? performanceData[key].Exam_taken_date__c : '',
                                        examResult: performanceData[key].Pass_fail__c !== undefined ? performanceData[key].Pass_fail__c : '',
                                        threeDigitScore: performanceData[key].Three_Digit_Score__c !== undefined ? performanceData[key].Three_Digit_Score__c : '',
                                        remarks: performanceData[key].Remarks__c !== undefined ? performanceData[key].Remarks__c : ''
                                    }
                                    let tempScoreAvailableUntil = '';
                                    if (performanceData[key].Posted_Date__c !== undefined && performanceData[key].Posted_Date__c !== '' && performanceData[key].Posted_Date__c !== null){
                                        let year = parseInt(performanceData[key].Posted_Date__c.split('-')[0]) + 5;
                                        let month = performanceData[key].Posted_Date__c.split('-')[1];
                                        let day = performanceData[key].Posted_Date__c.split('-')[2];
                                        tempScoreAvailableUntil = year + '-' + month + '-' + day;
                                    }
                                    tempRecord.scoreAvailableUntil = tempScoreAvailableUntil;
                                    tempRecord.rowNumber = '' + (rowNum + 1);
                                    if (this.dataPerformance.length > 0){
                                        this.dataPerformance = [...this.dataPerformance, tempRecord];
                                    }else{
                                        this.dataPerformance = [tempRecord];
                                    }
                                    this.attributesList = ['id'];
                                }
                                rowNum = rowNum + 1;
                            }
                            this.performanceDataRecords = this.dataPerformance;
                            this.displayNoPerformanceDataEnrolled = false;
                            if (this.template.querySelector('.paginatorPerformance') !== null){
                                this.template.querySelector('.paginatorPerformance').records = this.performanceDataRecords;
                                this.template.querySelector('.paginatorPerformance').totalRecords = this.performanceDataRecords.length;
                                this.template.querySelector('.paginatorPerformance').setRecordsPerPage();
                            }
                        }else{
                            this.displayNoPerformanceDataEnrolled = true;
                            this.errorMessagesText = 'You do not have any valid records';
                        }
                    })
                    .catch(error => {
                        window.console.log('getPerformanceData Error: ' + JSON.stringify(error));
                    })
            }else{
                this.displayNoPerformanceDataEnrolled = true;
                //this.errorMessagesText = 'You have not enrolled for Performance Data';
                this.errorMessagesText = 'Either your entity does not currently participate in Performance Data through MyIntealth or you have not been granted access to this service by the Coordinator at your entity. Go to the Administration section if you would like to request access to this service.';
            }
            this.spinner = false;
        });
    }
    @api
    refreshDataOnTabSwitch(){
        this.setup();
        this.loadPrimaryDetails();
    }
    renderedCallback(){
        this.performanceDataRecords = this.dataPerformance;
        if (this.performanceDataRecords.length > 0){
            this.displayNoPerformanceDataEnrolled = false;
        }
    }
    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplayPerformance = event.detail;
        if (this.recordsToDisplayPerformance.length > 0){
            this.rowNumberOffset = this.recordsToDisplayPerformance[0].rowNumber - 1;
        }
    }
    // Used to sort the columns
    sortBy(field, reverse, primer){
        const key = primer ?
            function (x) {
                return primer(x[field]);
            } :
            function (x) {
                return x[field];
            };
        return function (a, b) {
            a = key(a) ? key(a).toLowerCase() : '';
            b = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((a > b) - (b > a));
        };
    }
    onHandleSort(event){
        const {
            fieldName: sortedBy,
            sortDirection
        } = event.detail;
        const cloneData = [...this.recordsToDisplayPerformance];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.recordsToDisplayPerformance = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    exportToCSV(){
        let columnHeader = ["Rest of Name", "Last Name", "Student / Graduate", "USMLE ID", "Unique Medical School ID", "Exam Type", "Date of Exam", "Pass / Fail", "3 Digit Score", "Score Available Until", "Remarks"];
        let jsonKeys = ["firstName", "lastName", "enrollmentStatus", "usmleId", "uniqueStudentId", "examType", "dateOfExam", "examResult", "threeDigitScore", "scoreAvailableUntil", "remarks"];
        var jsonRecordsData = this.dataPerformance;
        let csvIterativeData;
        let csvSeperator
        let newLineCharacter;
        csvSeperator = ",";
        newLineCharacter = "\n";
        csvIterativeData = "";
        csvIterativeData += columnHeader.join(csvSeperator);
        csvIterativeData += newLineCharacter;
        for (let i = 0; i < jsonRecordsData.length; i++){
            let counter = 0;
            for (let iteratorObj in jsonKeys){
                let dataKey = jsonKeys[iteratorObj];
                if (counter > 0){
                    csvIterativeData += csvSeperator;
                }
                if (jsonRecordsData[i][dataKey] !== null &&
                    jsonRecordsData[i][dataKey] !== undefined
                ){
                    csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';
                }else{
                    csvIterativeData += '""';
                }
                counter++;
            }
            csvIterativeData += newLineCharacter;
        }
        this.hrefdata = "data:text/csv;charset=utf-8," + encodeURI(csvIterativeData);
    }
}