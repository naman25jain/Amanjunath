import {
    LightningElement,
    api,
    track
} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const DELAY = 300;
const recordsPerPage = [5, 10, 25, 50, 100];
const pageNumber = 1;
const showIt = 'visibility:visible';
const hideIt = 'visibility:hidden'; //visibility keeps the component space, but display:none doesn't
export default class Paginator extends LightningElement {
    @api showSearchBox = false; //Show/hide search box; valid values are true/false
    @api showPagination; //Show/hide pagination; valid values are true/false
    @api pageSizeOptions = recordsPerPage; //Page size options; valid values are array of integers
    @api totalRecords; //Total no.of records; valid type is Integer
    @api records; //All records available in the data table; valid type is Array
    @api attributesToAvoid;
    @track pageSize; //No.of records to be displayed per page
    @track totalPages; //Total no.of pages
    @track pageNumber = pageNumber; //Page number
    @track searchKey; //Search Input
    @track controlPagination = showIt;
    @track controlPrevious = hideIt; //Controls the visibility of Previous page button
    @track controlNext = showIt; //Controls the visibility of Next page button
    recordsToDisplay = []; //Records to be displayed on the page

    //Called after the component finishes inserting to DOM
    connectedCallback() {
        if (this.pageSizeOptions && this.pageSizeOptions.length > 0)
            this.pageSize = this.pageSizeOptions[3];
        else {
            this.pageSize = this.totalRecords;
            this.showPagination = false;
        }
        this.controlPagination = this.showPagination === false ? hideIt : showIt;
        this.setRecordsToDisplay();
    }

    renderedCallback() {
        if (this.template.querySelector(".slds-select") !== null) {
            this.template.querySelector("option[value='" + this.pageSize + "']").setAttribute("selected", "");
        }
    }

    @api handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.setRecordsToDisplay();
    }
    @api setRecordsPerPage(){
        this.pageSize = this.pageSizeOptions[3];
        this.pageNumber = 1;
        this.controlPagination = showIt;
        if (this.template.querySelector(".slds-select") !== null) {
            const setVal = this.template.querySelector('.slds-select');
            setVal.value = this.pageSize;   
            setVal.options[setVal.selectedIndex].defaultSelected = true;
        }
        if(this.template.querySelector("lightning-input") !== null) {
            this.template.querySelector("lightning-input").value = '';
        }
        this.setRecordsToDisplay();
    }
    handlePageNumberChange(event) {
        this.pageNumber = event.target.value;
        if(this.pageNumber < 0){
            const evt1 = new ShowToastEvent({
                title: 'Error',
                message: 'Pagination value should be greater than Zero.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt1);       
            this.pageNumber = 1;             
        }
        else if(this.pageNumber > this.totalPages){
            const evt2 = new ShowToastEvent({
                title: 'Error',
                message: 'Navigating page number should be less than total pages shown.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt2);                    
            this.pageNumber = 1;
        }
        else if(this.pageNumber > 0 && this.pageNumber <= this.totalPages){
                this.setRecordsToDisplay();
        }
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.setRecordsToDisplay();
    }
    @api nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.setRecordsToDisplay();
    }
    setRecordsToDisplay() {
        this.recordsToDisplay = [];
        if (!this.pageSize)
            this.pageSize = this.totalRecords;

        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        if(this.totalPages == 0){
            this.totalPages = 1;
        }
        this.setPaginationControls();

        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) break;
            this.recordsToDisplay.push(this.records[i]);
        }
        this.dispatchEvent(new CustomEvent('paginatorchange', {
            detail: this.recordsToDisplay
        })); //Send records to display on table to the parent component
    }
    setPaginationControls(){
        //Control Pre/Next buttons visibility by Total pages
        if (this.totalPages <= 1) {
            this.controlPrevious = hideIt;
            this.controlNext = hideIt;
        } else if (this.totalPages > 1) {
            this.controlPrevious = showIt;
            this.controlNext = showIt;
        }
        //Control Pre/Next buttons visibility by Page number
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
            this.controlPrevious = hideIt;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
            this.controlNext = hideIt;
        }
        //Control Pre/Next buttons visibility by Pagination visibility
        if (this.controlPagination === hideIt) {
            this.controlPrevious = hideIt;
            this.controlNext = hideIt;
        }
    }
    handleKeyChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        if (searchKey) {
            this.delayTimeout = setTimeout(() => {
                this.controlPagination = hideIt;
                this.setPaginationControls();

                this.searchKey = searchKey;
                //Use other field name here in place of 'Name' field if you want to search by other field
                //Search with any column value (Updated as per the feedback)
                this.recordsToDisplay = this.records.filter(rec => {
                    if(this.attributesToAvoid && JSON.stringify(rec).toLowerCase().includes(this.attributesToAvoid[0].toLowerCase())){
                        //Bug Fixed Added rec.enrollmentStatus field in below line #155
                        let newRec = [rec.caseNumber, rec.lastName,rec.enrollmentStatus, rec.firstName, rec.caseType, rec.serviceNamesList, rec.caseStatus, rec.actionNeeded, rec.dateOpened, rec.lastModifiedDate, 
                            rec.restOfName, rec.usmleId, rec.uniqueMedicalSchoolID, rec.dateOfBirth, rec.examType, rec.eligibilityPeriod, rec.recordAvailableDate, rec.status,
                            rec.uniqueStudentId, rec.dateOfExam, rec.examResult, rec.threeDigitScore, rec.remarks, rec.scoreAvailableUntil, rec.rowNumber,
                            rec.className, rec.isVisible, rec.jobTitle, rec.role, rec.serviceName, rec.userName, rec.documentType, rec.ContactName, rec.ecfmgId, rec.referenceNumber, 
                            rec.status, rec.dateReportReceived, rec.availableUntil, rec.entityName, rec.credentialType, rec.attendanceStartDate, rec.attendanceEndDate, rec.dateDegreeIssued, rec.medicalDegreeTitle, 
                            rec.nameOnDocument, rec.applicantName, rec.ecfmgID, rec.credentialStatus, rec.issuingInstitution, rec.issuingInstitutionCountry, rec.firstVerificationRequestSentDate,
                            rec.LastName, rec.USMLE_ID__c, rec.AAMC_ID__c, rec.caseNumber, rec.entity, rec.deliveryMethod, rec.status, rec.requestDate, rec.sentDate];                          
                        return (JSON.stringify(newRec).toLowerCase()).includes(searchKey.toLowerCase())
                    }
                    else{
                        return (JSON.stringify(rec).toLowerCase()).includes(searchKey.toLowerCase())
                    }                    
                });
                this.dispatchEvent(new CustomEvent('paginatorchange', {
                        detail: this.recordsToDisplay
                })); //Send records to display on table to the parent component
            }, DELAY);
        }else{
            this.controlPagination = showIt;
            this.setRecordsToDisplay();
        }
    }
}