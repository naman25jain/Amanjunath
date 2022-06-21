import{LightningElement, api, track, wire} from 'lwc';
import{refreshApex} from '@salesforce/apex';
import{getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';
import{ShowToastEvent} from "lightning/platformShowToastEvent";
import START_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type__c.Start_Month__c';
import END_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type__c.End_Month__c';
import DEGREE_ISSUE_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type__c.Degree_Issue_Month__c';
import FROM_YEAR from '@salesforce/schema/Contact_Association_Type__c.Personal_Family_from_year__c';
import getRecTypeId from '@salesforce/apex/GenericUtilities.getRecordTypeIdByDevName';
import CONTACT_ASSOCIATION_TYPE_OBJECT from '@salesforce/schema/Contact_Association_Type__c';
import Status_FIELD from '@salesforce/schema/Contact_Association_Type__c.Status__c';
import CONTACT_ASSOCIATION_TYPE_STAGING_OBJECT from '@salesforce/schema/Contact_Association_Type_Staging__c';
import GraduationMonth_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.Graduation_Month__c';
import getSelectedValues from '@salesforce/apex/AppForCertController.getSelectedValues';
import getSchoolRecords from '@salesforce/apex/AppForCertController.getSchoolRecords';
import getGradYearValues from '@salesforce/apex/AppForCertController.getGradYearValues';
import getDegreeRecords from '@salesforce/apex/AppForCertController.getDegreeRecords';
import errorMessageOFACSoft from '@salesforce/apex/AppForCertController.errorMessageOFACSoft';
import manageAppforCertCases from '@salesforce/apex/AppForCertController.manageAppforCertCases';
import errorMessageNewStartDateEndDate from '@salesforce/apex/AppForCertController.errorMessageNewStartDateEndDate';
import errorMessageNewGraduationDate from '@salesforce/apex/AppForCertController.errorMessageNewGraduationDate';
import errorMessageNewCurrentDate from '@salesforce/apex/AppForCertController.errorMessageNewCurrentDate';
import startAndEndDateValidation from '@salesforce/apex/AppForCertController.startAndEndDateValidation';
import isApplicantStudentOrGraduate from '@salesforce/apex/AppForCertController.isApplicantStudentOrGraduate';
import countryWarning from '@salesforce/label/c.OFAC_warning_error_message';
import getCATDegMedSchFMDStatus from '@salesforce/apex/AppForCertHelper.getCATDegMedSchFMDStatus';
import newDateValidationMessage from '@salesforce/label/c.Start_and_End_date_validation';
import newDateValidation from '@salesforce/label/c.Student_newDate_validation';
import endDateGreaterThanStartDate from '@salesforce/label/c.End_date_always_greater_than_Start_date';
import degreeIssueDateGreaterThanEndDate from '@salesforce/label/c.Degree_Issue_date_always_greater_than_End_date';
import graduationDateGreaterThanEndDate from '@salesforce/label/c.Graduation_Date_always_greater_than_End_Date';
import blankStartDateLabel from '@salesforce/label/c.Blank_Start_Date_Label';
import blankEndDateLabel from '@salesforce/label/c.Blank_End_Date_Label';
import degMedSchoolSaved from '@salesforce/label/c.Degree_medical_school_saved';
import degDisabledLabel from '@salesforce/label/c.Degree_disabled_message';
import gradYearDisabledLabel from '@salesforce/label/c.Graduation_Year_disabled_message';
import MedicalEducationTypeGraduate from '@salesforce/label/c.Medical_Education_type_Graduate';
import blankStatusLabel from '@salesforce/label/c.Blank_Status_Validation_Message';
import blankDegMedSchoolLabel from '@salesforce/label/c.Degree_Medical_School_Blank_Validation';
import blankDegTitleLabel from '@salesforce/label/c.Degree_Title_Blank_Validation';
import blankGradYearMonthLabel from '@salesforce/label/c.Graduation_Year_Blank_Validation';
import blankDegIssueDateLabel from '@salesforce/label/c.Blank_Degree_Issue_Date_Validation';
import degMedSchoolValidNameLabel from '@salesforce/label/c.Degree_Medical_School_Name_Validation';
export default class AppForCertSchoolReviewComponent extends LightningElement{

    @api objectType;
    @api objectId;
    @api showExamRegActionButton;

    @track statusOptions = [];
    @track spinner = false;

    @wire(getSchoolRecords) schoolRecordValues;
    @api name = '';
    required = true;
    @api placeholder = '';
    initialized = false;

    @track medicalSchool;
    @track degreetitle = '';
    @track selectedStatus;

    graduationDateFetched;
    @track selectedMedicalSchoolId;
    @track selectedGradYear = '';
    @track selectedGradMonth = '';

    //Code added by Shailaja. Date format stories. User story#7596 & 7597 - 9/8/2020
    @track endMonth = '';
    @track startMonth = '';
    @track selectedStartYear = '';
    @track selectedEndYear = '';
    @track degreeMonth ='';
    @track selectedDegreeIssueYear = '';
    
    @track startMonthPicklistOptions = [];
    @track endMonthPicklistOptions = [];
    @track degreeIssueMonthPicklistOptions = [];

    @track degreeDisabled = true;
    @track gradYearDisabled = true;
    @track formsubmit;
    @track selectedValue;
    @track attdate;
    @track degdate;
    @track clickedBtn;
    @track fromdate;
    @track todate;
    @track degreeissuedate;
    @track schoolprog;
    @track numberOfYearsAttended;
    @track studentid;
    @track specialty;

    _wiredstatusval;

    @track degreeDisabledMessage = degDisabledLabel;
    @track gradYearDisabledMessage = gradYearDisabledLabel;

    @track wiredParameters = {
        error: '',
        data: null
    };
    @track showError = false;
    @track errorMessagesText = '';
    @track successMessageText = '';
    @track showWarning = false;
    @track warningMessagesText = "";

    @track hasTwentyNine = true;
    @track hasThirty = true;
    @track hasThirtyOne = true;
    
    @api reSubmitFromAppForCert;
    @api caseRecordId;
    @track disabledMedSchoolDetails = false;    
    noneVal = {label:'--None--',value:''};
    @track gradYears = [];
    @track degNameList = [];
    recordTypeId;
    recordTypeDevName = 'Degree_Medical_School';
    @track optionsYears = [];
    // Modified by Ajoy
    @wire(getGradYearValues, {
        entityId: '$selectedMedicalSchoolId'
    }) gradYearRecordValues(value){
        // Hold on to the provisioned value so we can refresh it later.
        this.wiredParameters = value; // track the provisioned value
        this.gradYears = [this.noneVal];
        if(this.wiredParameters.data){
            (this.wiredParameters.data).forEach(i=>{
                this.gradYears.push({label:i,value:i})
            })
        }
    }

    // Modified by Ajoy
    @wire(getDegreeRecords, {
        entityId: '$selectedMedicalSchoolId',
        graduationYear: '$selectedGradYear'
    }) degreeRecordValue(value){
        this.degNameList = [this.noneVal];
        this.degreeRecordValues = value;
        if(this.degreeRecordValues.data){
            (this.degreeRecordValues.data).forEach(i=>{
                this.degNameList.push({label:i.Name,value:i.Name})
            });
        }
    }
    @wire(getRecTypeId, {objectName: 'Contact_Association_Type__c', recordTypeDevName: '$recordTypeDevName'})
    getRecordTypeId(data,error){
        if(data.data){
            this.recordTypeId = data.data;
        }else if(error){
            window.console.error(error);
        }
    }
    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: FROM_YEAR})
    optionsYearsPickVal(data,error){
        if(data.data){
            this.optionsYears = data.data.values;
        }else if(error){
            window.console.error(error);
        }
    }

    // object info using wire service
    @wire(getObjectInfo, {
        objectApiName: CONTACT_ASSOCIATION_TYPE_OBJECT
    })
    objectInfo;

    // Getting Contact Association Type Status Picklist values using wire service
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: Status_FIELD
    })
    statusPicklistValues({
        error,
        data
    }) {
        if (data) {
            this.statusOptions = data.values;
        } else if (error) {
            window.console.log('Error: ' + JSON.stringify(error));
        }
    }

    //Code added by Shailaja. Date format stories. 9/8/2020
    // object info using wire service
    
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: START_MONTH_FIELD
    })
    startMonthPicklistValues({
        error,
        data
    }) {
        if (data) {
            this.startMonthPicklistOptions = data.values;
        } else if (error) {
            window.console.log('Error: ' + JSON.stringify(error));
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: END_MONTH_FIELD
    })
    endMonthPicklistValues({
        error,
        data
    }) {
        if (data) {
            this.endMonthPicklistOptions = data.values;
        } else if (error) {
            window.console.log('Error: ' + JSON.stringify(error));
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: DEGREE_ISSUE_MONTH_FIELD
    })
    degreeIssueMonthPicklistValues({
        error,
        data
    }) {
        if (data) {
            this.degreeIssueMonthPicklistOptions = data.values;
        } else if (error) {
            window.console.log('Error: ' + JSON.stringify(error));
        }
    }


    // object info using wire service
    @wire(getObjectInfo, {
        objectApiName: CONTACT_ASSOCIATION_TYPE_STAGING_OBJECT
    }) objectMonthInfo;
    @wire(getPicklistValues, {
        recordTypeId: '$objectMonthInfo.data.defaultRecordTypeId',
        fieldApiName: GraduationMonth_FIELD
    }) monthPicklistValues;

    @wire(getSelectedValues, {
        showExamRegActionButton: '$showExamRegActionButton'
    }) objectValues(result) {
        this._wiredstatusval = result;
        if (result.data) {
            this.selectedValue = result.data.Status__c;
            isApplicantStudentOrGraduate().then(data => {
                if(data && this.showExamRegActionButton && this.reSubmitFromAppForCert){
                    this.disabledMedSchoolDetails = true;
                }
            });
            //Code added by Shailaja. 9/11/2020. Date format stories. #7596 & 7597
            this.startMonth = result.data.Start_Month__c; //Start Month
            this.endMonth = result.data.End_Month__c; //endMonth
            this.selectedStartYear = result.data.Start_Year__c; //Start Year
            this.selectedEndYear = result.data.End_Year__c; //End Year
            this.selectedDegreeIssueYear = result.data.Degree_Issue_Year__c; //Degree Issue Year
            this.degreeMonth = result.data.Degree_Issue_Month__c; //Degree Issue Month
            this.schoolprog = result.data.School_Program__c;
            this.numberOfYearsAttended = result.data.Number_of_Years_Attended__c;
            this.studentid = result.data.Student_ID__c;
            this.specialty = result.data.Specialty__c;
            this.selectedGradYear = result.data.Graduation_Year__c;
            this.selectedGradMonth = result.data.Graduation_Month__c;
            if (result.data.Account_Name__c !== undefined) {
                this.medicalSchool = result.data.Account_Name__c;
                this.selectedMedicalSchoolId = result.data.Account__c;
            }
            if (result.data.Degree_Title__c !== undefined) {
                this.degreetitle = result.data.Degree_Title__c;
                this.degreeDisabled = false;
            }
            if (this.schoolprog === undefined) {
                this.schoolprog = '';
            }
            if (this.numberOfYearsAttended === undefined) {
                this.numberOfYearsAttended = '';
            }
            if (this.studentid === undefined) {
                this.studentid = '';
            }
            if (this.specialty === undefined) {
                this.specialty = '';
            }
            if (this.selectedGradYear === undefined) {
                this.selectedGradYear = '';
            }
            if (this.selectedGradMonth === undefined) {
                this.selectedGradMonth = '';
            }
        } else if (result.error) {
            window.console.log('Error: ' + JSON.stringify(result.error));
        }
    }
    @wire(getCATDegMedSchFMDStatus,{
        currentContactId: ''
    }) objectFMDValues(result){
        this._wiredstatusval = result;
        if(result.data){
            this.disabledMedSchoolDetails = true;
        } else if (result.error) {
            window.console.log('Error: ' + JSON.stringify(result.error));
        }
    }
    renderedCallback() {
        if (this._wiredstatusval.data !== undefined) {
            refreshApex(this._wiredstatusval);
        }

        if (this.initialized) {
            return;
        }
        this.initialized = true;

        let listId = this.template.querySelector('datalist.schoolRecordDatalist').id;
        this.template.querySelector("input.schoolRecord").setAttribute("list", listId);

        //let listId4 = this.template.querySelector('datalist.gradMonthRecordDatalist').id;
        //this.template.querySelector("input.gradMonthRecord").setAttribute("list", listId4);

        //let listId5 = this.template.querySelector('datalist.gradDayRecordDatalist').id;
        //this.template.querySelector("input.gradDayRecord").setAttribute("list", listId5);


    }

    handleSchoolChange(event) {
        this.medicalSchool = event.target.value;
        this.selectedGradYear = '';
        this.selectedGradMonth = '';
        this.degreetitle = '';
        this.selectedMedicalSchoolId = this.template.querySelector(".schoolRecordDatalist option[value=\"" + event.target.value + "\"]").getAttribute("data-entityid");

        if (this.selectedMedicalSchoolId) {
            // For Year Field
            this.gradYearDisabled = false;
            this.gradYearDisabledMessage = '';
        } else {
            // For Year Field
            this.gradYearDisabled = true;
            this.gradYearDisabledMessage = gradYearDisabledLabel;
        }

        getGradYearValues({
                entityId: this.selectedMedicalSchoolId
            })
            .then(() => {
                refreshApex(this.wiredParameters);
            })
            .catch((error) => {
                this.message = 'Error received: code' + error.errorCode + ', ' +
                    'message ' + error.body.message;
            });
    }

    handleGradYearChange(event) {
        this.selectedGradYear = event.target.value;
        this.degreetitle = '';
        if (event.target.value) {
            this.degreeDisabled = false;
            this.degreeDisabledMessage = '';
        } else {
            this.degreeDisabled = true;
            this.degreeDisabledMessage = degDisabledLabel;
        }

        getDegreeRecords({
                entityId: this.selectedMedicalSchoolId,
                graduationYear: this.selectedGradYear
            })
            .then(() => {
                return refreshApex(this.degreeRecordValues);
            })
            .catch((error) => {
                this.message = 'Error received: code' + error.errorCode + ', ' +
                    'message ' + error.body.message;
            });
    }

    handleDegreeChange(event) {
        this.degreetitle = event.target.value;
    }

    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fieldvals = event.detail.fields;
        this.attdate = true;
        this.degdate = true;
        this.spinner = true;

        fieldvals.Status__c = this.template.querySelector('[data-radiogroup]').value;
        this.selectedValue = this.template.querySelector('[data-radiogroup]').value;
        fieldvals.Account__c = this.selectedMedicalSchoolId;
        fieldvals.Degree_Title__c = this.template.querySelector('[data-degreetitle]').value;
        fieldvals.gradYear = this.template.querySelector('[data-gradyear]').value;
        this.selectedGradYear = this.template.querySelector('[data-gradyear]').value;
        fieldvals.gradMonth = fieldvals.Graduation_Month__c;
        this.selectedGradMonth = fieldvals.Graduation_Month__c;

        //code added by shailaja
        fieldvals.Start_Month__c = this.startMonth;
        fieldvals.Start_Year__c = this.selectedStartYear;
        fieldvals.End_Month__c = this.endMonth;
        fieldvals.End_Year__c = this.selectedEndYear;
        fieldvals.Degree_Issue_Month__c = this.degreeMonth;
        fieldvals.Degree_Issue_Year__c = this.selectedDegreeIssueYear;
        
        this.numberOfYearsAttended = fieldvals.Number_of_Years_Attended__c;
        fieldvals.showExamRegActionButton = this.showExamRegActionButton;
        this.errorMessagesText = '';
        this.successMessageText = '';
        this.formsubmit = true;

        // blank status check
        if (fieldvals.Status__c === undefined) {
            this.showError = true;
            this.formsubmit = false;
            this.spinner = false;

            if (this.template.querySelector('#statusError') === null) {
                let elem = document.createElement("div");
                elem.id = 'statusError';
                elem.textContent = blankStatusLabel;
                elem.style = 'color:#ff0000; clear:both;';
                this.template.querySelector('[data-radiogroup]').classList.add('slds-has-error');
                this.template.querySelector('[data-radiogroup]').parentNode.insertBefore(elem, this.template.querySelector('[data-radiogroup]').nextSibling);
            }
        } else {
            this.template.querySelector('[data-radiogroup]').classList.remove('slds-has-error');
            if (this.template.querySelector('#statusError') !== null) {
                let elem = this.template.querySelector('#statusError');
                elem.parentNode.removeChild(elem);
            }

        }
        // Number of years attended check
        if (fieldvals.Number_of_Years_Attended__c === undefined || fieldvals.Number_of_Years_Attended__c === '' || fieldvals.Number_of_Years_Attended__c <= parseFloat('0') || fieldvals.Number_of_Years_Attended__c > parseFloat('20')) {
            this.showError = true;
            this.formsubmit = false;
            this.spinner = false;
            let elem2 = document.createElement("div");
            elem2.id = 'attendedYearsError';
            elem2.textContent = 'Enter valid number of years attended';
            if (fieldvals.Number_of_Years_Attended__c > parseFloat('20')) {
                elem2.textContent = 'Maximum number of years allowed is 20';
            }
            elem2.style = 'color:#ff0000; clear:both;';
            this.template.querySelector('.attendedYears').classList.add('slds-has-error');
            if (this.template.querySelector('#attendedYearsError') === null) {
                this.template.querySelector('.attendedYears').parentNode.insertBefore(elem2, this.template.querySelector('.attendedYears').nextSibling);
            } else {
                let elem = this.template.querySelector('#attendedYearsError');
                elem.parentNode.removeChild(elem);
                this.template.querySelector('.attendedYears').parentNode.insertBefore(elem2, this.template.querySelector('.attendedYears').nextSibling);
            }
        } else {
            if (this.template.querySelector('#attendedYearsError') !== null) {
                let elem = this.template.querySelector('#attendedYearsError');
                elem.parentNode.removeChild(elem);
                this.template.querySelector('.attendedYears').classList.remove('slds-has-error');
            }
        }

        // blank Degree Medical School check
        if (fieldvals.Account__c === undefined || fieldvals.Account__c === '') {
            this.showError = true;
            this.formsubmit = false;
            this.spinner = false;
            if (this.template.querySelector('#degMedSchoolError') === null) {
                let elem = document.createElement("div");
                elem.id = 'degMedSchoolError';
                elem.textContent = blankDegMedSchoolLabel;
                elem.style = 'color:#ff0000; clear:both;';
                this.template.querySelector('input.schoolRecord').classList.add('slds-has-error');
                this.template.querySelector('input.schoolRecord').parentNode.insertBefore(elem, this.template.querySelector('input.schoolRecord').nextSibling);
            }
        } else {
            //Select valid Degree Medical School         
            const medicalSchoolList = [];
            this.template.querySelectorAll('.schoolRecordDatalist option').forEach(element => {
                medicalSchoolList.push(element.value);
            });

            this.template.querySelector('input.schoolRecord').classList.remove('slds-has-error');
            if (this.template.querySelector('#degMedSchoolError') !== null) {
                let elem = this.template.querySelector('#degMedSchoolError');
                elem.parentNode.removeChild(elem);
            }

            if (medicalSchoolList.indexOf(this.medicalSchool) === -1) {
                this.showError = true;
                this.formsubmit = false;
                this.spinner = false;

                if (this.template.querySelector('#degMedSchoolError') === null) {
                    let elem2 = document.createElement("div");
                    elem2.id = 'degMedSchoolError';
                    elem2.textContent = degMedSchoolValidNameLabel;
                    elem2.style = 'color:#ff0000; clear:both;';
                    this.template.querySelector('input.schoolRecord').classList.add('slds-has-error');
                    this.template.querySelector('input.schoolRecord').parentNode.insertBefore(elem2, this.template.querySelector('input.schoolRecord').nextSibling);
                }
            }
        }

        //code added by shailaja. 9/15/2020. Date format stories.#7596 & #7597
        //Blank Attendance Start Month & Year validations
        if (fieldvals.Start_Month__c === undefined || fieldvals.Start_Month__c === '' || fieldvals.Start_Month__c === null || 
                        fieldvals.Start_Year__c === undefined || fieldvals.Start_Year__c === '' || fieldvals.Start_Year__c === null) {
            this.showError = true;
            this.formsubmit = false;
            this.attdate = false;
            this.spinner = false;
            if (this.template.querySelector('#startDateError') === null) {
                let elem = document.createElement("div");
                elem.id = 'startDateError';
                elem.textContent = blankStartDateLabel;
                elem.style = 'color:#ff0000; clear:both;';
                this.template.querySelector('.start-date-error').appendChild(elem);
            }
        } else {
            if (this.template.querySelector('#startDateError') !== null && this.attdate) {
                let elem = this.template.querySelector('#startDateError');
                elem.parentNode.removeChild(elem);
            }
        }

        //code added by shailaja. 9/15/2020. Date format stories.User story$7596 & 7597
        //Blank Attendance End Month & Year validations
        if (fieldvals.End_Month__c === undefined || fieldvals.End_Month__c === '' || fieldvals.End_Month__c === null || 
                        fieldvals.End_Year__c === undefined || fieldvals.End_Year__c === '' || fieldvals.End_Year__c === null) {
            this.showError = true;
            this.formsubmit = false;
            this.attdate = false;
            this.spinner = false;

            if (this.template.querySelector('#endDateError') === null) {
                let elem = document.createElement("div");
                elem.id = 'endDateError';
                elem.textContent = blankEndDateLabel;
                elem.style = 'color:#ff0000; clear:both;';
                this.template.querySelector('.end-date-error').appendChild(elem);
            }
        } else {
            if (this.template.querySelector('#endDateError') !== null && this.attdate) {
                let elem = this.template.querySelector('#endDateError');
                elem.parentNode.removeChild(elem);
            }
        }
        //Code added by Shailaja. 9/16/2020. Date Format stories.
        //Attendance End Date greater than Attendance Start Date.
        errorMessageNewStartDateEndDate({
            startMonth: fieldvals.Start_Month__c,
            startYear: fieldvals.Start_Year__c,
            endMonth: fieldvals.End_Month__c,
            endYear: fieldvals.End_Year__c
        })
        .then(result => {
            if (result) {
                this.showError = true;
                this.formsubmit = false;
                this.attdate = false;
                this.spinner = false;

                if (this.template.querySelector('#startEndDateError') === null) {
                    let elem = document.createElement("div");
                    elem.id = 'startEndDateError';
                    elem.textContent = endDateGreaterThanStartDate;
                    elem.style = 'color:#ff0000; clear:both;';
                    this.template.querySelector('.end-date-error').appendChild(elem);
                }
            }else {
                if (this.template.querySelector('#startEndDateError') !== null && this.attdate) {
                    let elem = this.template.querySelector('#startEndDateError');
                    elem.parentNode.removeChild(elem);
                }
            }
        })
        .catch(error => {
            this.spinner = false;
            window.console.log('Error: ' + JSON.stringify(error));
        });

        // blank degree title check
        if (fieldvals.Degree_Title__c === undefined || fieldvals.Degree_Title__c === '') {
            this.showError = true;
            this.formsubmit = false;
            this.spinner = false;

            if (this.template.querySelector('#degTitleError') === null) {
                let elem = document.createElement("div");
                elem.id = 'degTitleError';
                elem.textContent = blankDegTitleLabel;
                elem.style = 'color:#ff0000; clear:both;';
                this.template.querySelector('[data-degreetitle]').classList.add('slds-has-error');
                this.template.querySelector('[data-degreetitle]').parentNode.insertBefore(elem, this.template.querySelector('[data-degreetitle]').nextSibling);
            }
        } else {
            //Select valid Degree Title    
            this.template.querySelector('[data-degreetitle]').classList.remove('slds-has-error');
            if (this.template.querySelector('#degTitleError') !== null) {
                let elem = this.template.querySelector('#degTitleError');
                elem.parentNode.removeChild(elem);
            }
        }

        // blank Graduation Year check
        if (fieldvals.gradYear === undefined || fieldvals.gradYear === '' ||
            fieldvals.gradMonth === undefined || fieldvals.gradMonth === '') {
            this.showError = true;
            this.formsubmit = false;
            this.spinner = false;

            if (this.template.querySelector('#gradDateError') === null) {
                let elem = document.createElement("div");
                elem.id = 'gradDateError';
                elem.textContent = blankGradYearMonthLabel;
                elem.style = 'color:#ff0000; clear:both;';
                this.template.querySelector('.gradMonthRecord').classList.add('slds-has-error');
                this.template.querySelector('.gradYearRecord').classList.add('slds-has-error');
                this.template.querySelector('.grad-date-error').appendChild(elem); // insertBefore(elem, this.template.querySelector('input.schoolRecord').nextSibling);
            }
        } else {
            //Select valid graduation year   
            this.template.querySelector('.gradYearRecord').classList.remove('slds-has-error');
            this.template.querySelector('.gradMonthRecord').classList.remove('slds-has-error');
            if (this.template.querySelector('#gradDateError') !== null) {
                let elem = this.template.querySelector('#gradDateError');
                elem.parentNode.removeChild(elem);
            }
        }

        //Add code to validate Degree Issue Year & Month.
        //Code added below by Shailaja. 9/29/2020.
        if (fieldvals.Degree_Issue_Month__c === undefined || fieldvals.Degree_Issue_Month__c === '' || fieldvals.Degree_Issue_Month__c === null || 
                        fieldvals.Degree_Issue_Year__c === undefined || fieldvals.Degree_Issue_Year__c === '' || fieldvals.Degree_Issue_Year__c === null) {
                this.showError = true;
                this.formsubmit = false;
                this.degdate = false;
                this.spinner = false;

            if (this.template.querySelector('#degDateError') === null) {
                let elemDeg = document.createElement("div");
                elemDeg.id = 'degDateError';
                elemDeg.textContent = blankDegIssueDateLabel;
                elemDeg.style = 'color:#ff0000; clear:both;';
                this.template.querySelector('.degree-date-error').appendChild(elemDeg);
            }
        } else {
            if (this.template.querySelector('#degDateError') !== null && this.degdate) {
                let elem = this.template.querySelector('#degDateError');
                elem.parentNode.removeChild(elem);
            }
        }
        this.checkDegreeDate(fieldvals.End_Month__c, fieldvals.End_Year__c, fieldvals.Degree_Issue_Month__c, fieldvals.Degree_Issue_Year__c); 
        errorMessageOFACSoft({
                accountId: fieldvals.Account__c
            })
            .then(result => {
                if (result) {
                    this.spinner = false;
                    this.showWarning = true;
                    this.warningMessagesText = countryWarning;
                }
            })
            .catch(error => {
                this.spinner = false;
                window.console.log('Error: ' + JSON.stringify(error));
            });

        //New code by Shailaja. Date format stories. New Start Month & Year & End Month & Year
        // Checking From Date and To Date Validation for Student  - New Start & End Dates
        
        //Code added to calculate teh month index and construct teh date.
        var startMonthIndex;
        var endMonthIndex;
        if(fieldvals.Start_Year__c !== '' && fieldvals.Start_Year__c !== null && fieldvals.Start_Month__c !=='' && fieldvals.Start_Month__c !== null){
            let sTempDate = fieldvals.Start_Year__c+'-'+fieldvals.Start_Month__c+'-'+'01';
            var sDate = new Date(sTempDate);
            startMonthIndex = String(sDate.getMonth() + 1).padStart(2, '0');
        }
        if(fieldvals.End_Year__c !== '' && fieldvals.End_Year__c !== null && fieldvals.End_Month__c !=='' && fieldvals.End_Month__c !== null){
            let eTempDate = fieldvals.End_Year__c+'-'+fieldvals.End_Month__c+'-'+'01';
            var eDate = new Date(eTempDate);
            endMonthIndex = String(eDate.getMonth() + 1).padStart(2, '0');
        }
        
        /*errorMessageNewCurrentDate({
            type: fieldvals.Status__c,
            startMonth: fieldvals.Start_Month__c,
            startYear: fieldvals.Start_Year__c,
            endMonth: fieldvals.End_Month__c,
            endYear: fieldvals.End_Year__c
        })*/
        errorMessageNewCurrentDate({
            type: fieldvals.Status__c,
            startMonth: startMonthIndex,
            startYear: fieldvals.Start_Year__c,
            endMonth: endMonthIndex,
            endYear: fieldvals.End_Year__c
        })
        .then(result => {
            if (result) {
                this.showError = true;
                this.formsubmit = false;
                this.degdate = false;
                this.spinner = false;
                if (this.template.querySelector('#endDatefutureErrorStudent') === null) {
                    let elem = document.createElement("div");
                    elem.id = 'endDatefutureErrorStudent';
                    elem.textContent = newDateValidation;
                    elem.style = 'color:#ff0000; clear:both;';
                    this.template.querySelector('.start-date-error').appendChild(elem);
                }
            }
            else{
                if (this.template.querySelector('#endDatefutureError') != null) {
                    let elem = this.template.querySelector('#endDatefutureError');
                    elem.parentNode.removeChild(elem);
                }
                if (this.template.querySelector('#endDatefutureErrorStudent') != null) {
                    let elem = this.template.querySelector('#endDatefutureErrorStudent');
                    elem.parentNode.removeChild(elem);
                }
                if (fieldvals.Status__c === MedicalEducationTypeGraduate) {
                    startAndEndDateValidation({
                        startMonth: fieldvals.Start_Month__c,
                        startYear: fieldvals.Start_Year__c,
                        endMonth: fieldvals.End_Month__c,
                        endYear: fieldvals.End_Year__c
                    }).then(value => {
                        if (value) {
                            this.showError = true;
                            this.formsubmit = false;
                            this.degdate = false;
                            this.spinner = false;
                            if (this.template.querySelector('#endDatefutureError') === null) {
                                let elem = document.createElement("div");
                                elem.id = 'endDatefutureError';
                                elem.textContent = newDateValidationMessage;
                                elem.style = 'color:#ff0000; clear:both;';
                                this.template.querySelector('.start-date-error').appendChild(elem);
                            }
                        }
                        else{
                            if (this.template.querySelector('#endDatefutureError') != null) {
                                let elem = this.template.querySelector('#endDatefutureError');
                                elem.parentNode.removeChild(elem);
                            }
                            this.formSubmitDegreeMedicalSchool(fieldvals.gradMonth, fieldvals.gradYear, fieldvals.End_Month__c, fieldvals.End_Year__c, fieldvals);
                        }
                    })
                }
                else {
                    this.formSubmitDegreeMedicalSchool(fieldvals.gradMonth, fieldvals.gradYear, fieldvals.End_Month__c, fieldvals.End_Year__c, fieldvals);
                }
            }
        })
        .catch(error => {
            this.spinner = false;
            window.console.log('Error: ' + JSON.stringify(error));
        });
        
        window.scrollTo(0, 0);
    }

    checkDegreeDate(endMonth, endYear, degMonth, degYear){

        var addtendaceEndDate = new Date(endMonth +"-" + "01" + "-" + endYear)
        var degreeDate =  new Date(degMonth +"-" + "01" + "-" + degYear)

        if (degreeDate < addtendaceEndDate){
            this.showError = true;
                this.formsubmit = false;
                this.degdate = false;
                this.spinner = false;
                if (this.template.querySelector('#degDateErrorNew') === null) {
                    let elem = document.createElement("div");
                    elem.id = 'degDateErrorNew';
                    elem.textContent = degreeIssueDateGreaterThanEndDate;
                    elem.style = 'color:#ff0000; clear:both;';
                    this.template.querySelector('.degree-date-error').appendChild(elem);
                }

        }else{
            if (this.template.querySelector('#degDateErrorNew') !== null && this.degdate) {
                let elem = this.template.querySelector('#degDateErrorNew');
                elem.parentNode.removeChild(elem);
            }
        }
    }

    //formSubmitDegreeMedicalSchool(gradYear, gradMonth, endDate, fieldvals) {
    formSubmitDegreeMedicalSchool(gradMonth, gradYear, endMonth, endYear, fieldvals) {
        // Graduation date always greater than TO date
        errorMessageNewGraduationDate({
                gradMonth: gradMonth,
                gradYear: gradYear,                
                endMonth: endMonth,
                endYear: endYear
            })
            .then(result1 => {
                if (result1) {
                    this.showError = true;
                    this.formsubmit = false;
                    this.spinner = false;
                    if (this.template.querySelector('#gradDateError') === null) {
                        let elem2 = document.createElement("div");
                        elem2.id = 'gradDateError';
                        //elem2.textContent = graduationDateGreaterThanToDate;
                        elem2.textContent = graduationDateGreaterThanEndDate;
                        elem2.style = 'color:#ff0000; clear:both;';
                        this.template.querySelector('.gradYearRecord').classList.add('slds-has-error');
                        this.template.querySelector('.gradMonthRecord').classList.add('slds-has-error');
                        this.template.querySelector('.grad-date-error').appendChild(elem2); // insertBefore(elem, this.template.querySelector('input.schoolRecord').nextSibling);
                    }
                } else {
                   // this.checkDegreeDate(fieldvals.End_Month__c, fieldvals.End_Year__c, fieldvals.Degree_Issue_Month__c, fieldvals.Degree_Issue_Year__c); 
                    if (this.formsubmit) {
                        this.template.querySelector('.gradYearRecord').classList.remove('slds-has-error');
                        this.template.querySelector('.gradMonthRecord').classList.remove('slds-has-error');
                        if (this.template.querySelector('#gradDateError') !== null) {
                            let elem5 = this.template.querySelector('#gradDateError');
                            elem5.parentNode.removeChild(elem5);
                        }
                        manageAppforCertCases({
                                fieldvals: JSON.stringify(fieldvals),defscreen:false
                            })
                            .then(saveresult => {
                                this.spinner = false;
                                if(saveresult !== ''){
                                    this.caseRecordId = saveresult;
                                    this.showError = true;

                                    if(this.errorMessagesText === ''){
                                        this.successMessageText = degMedSchoolSaved;
                                    }else{
                                        this.successMessageText += '<br/>' + degMedSchoolSaved;
                                    }
                                    if(this.clickedBtn === 'Next'){
                                        if (this.showWarning) {
                                            const evt = new ShowToastEvent({
                                                title: "Warning",
                                                message: this.warningMessagesText,
                                                variant: "warning"
                                            });
                                            this.dispatchEvent(evt);
                                            let that = this;
                                            setTimeout(function () {
                                                const selectEvent = new CustomEvent("nextevent", {detail:{caserecordid:this.caseRecordId}});
                                                that.dispatchEvent(selectEvent);
                                            }, 5000);
                                        } else {
                                            const selectEvent = new CustomEvent("nextevent", {detail:{caserecordid:this.caseRecordId}});
                                            this.dispatchEvent(selectEvent);
                                        }
                                    } else {
                                        if (this.showWarning) {
                                            const warnevt = new ShowToastEvent({
                                                title: "Warning",
                                                message: this.warningMessagesText,
                                                variant: "warning"
                                            });
                                            this.dispatchEvent(warnevt);
                                        }
                                    }
                                }
                            })
                            .catch(error => {
                                this.spinner = false;
                                window.console.log('Error: ' + JSON.stringify(error));
                            });
                    }
                }

            })
            .catch(error => {
                this.spinner = false;
                window.console.log('Error: ' + JSON.stringify(error));
            });
    }

    handleOnLoad(event) {
        // eslint-disable-next-line vars-on-top
        var record = event.detail.records;
        // eslint-disable-next-line vars-on-top
        var fields = record[this.objectId].fields;
        const gradYearValue = fields.Account__c.value; 
        if (gradYearValue != null && this.selectedGradYear === '') {
            this.gradYearDisabled = false;
        } else if (this.selectedGradYear !== '') {
            this.gradYearDisabled = false;
        }

        if (fields.Account_Name__c.value !== '') {
            if ((fields.Degree_Title__c.value === null ||
                    fields.Degree_Title__c.value === undefined) &&
                this.degreeDisabled === true) {
                const e = new Event("change");
                this.template.querySelector("input.schoolRecord").dispatchEvent(e);
            }
        }
    }

    checkMonth(event) {
        this.selectedGradYear = this.template.querySelector("[data-gradyear]").value;
        this.selectedGradMonth = this.template.querySelector("input.gradMonthRecord").value;
        this.selectedGradDay = this.template.querySelector("input.gradDayRecord").value;
        if (this.template.querySelector("[data-gradyear]").value !== '' || this.template.querySelector("[data-gradyear]").value !== undefined) {

            let currentYear = parseInt(this.template.querySelector("[data-gradyear]").value, 10);
            let leapCheck = (currentYear % 100 === 0) ? (currentYear % 400 === 0) : currentYear % 4 === 0;
            if (event.target.value === '2') {
                if (leapCheck) {
                    this.hasThirtyOne = false;
                    this.hasThirty = false;
                    this.hasTwentyNine = true;
                } else {
                    this.hasThirtyOne = false;
                    this.hasThirty = false;
                    this.hasTwentyNine = false;
                }
            } else if ([1, 3, 5, 7, 8, 10, 12].indexOf(parseInt(event.target.value, 10)) > -1) {
                this.hasThirtyOne = true;
                this.hasThirty = true;
                this.hasTwentyNine = true;
            }
        } else {
            this.hasThirtyOne = true;
            this.hasThirty = true;
            this.hasTwentyNine = true;
        }
    }
    prevButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('previousevent', {});
        this.dispatchEvent(selectEvent);
    }
    nextButton(event) {
        event.preventDefault();
        this.clickedBtn = 'Next';
    }
    saveButton(event) {
        event.preventDefault();
        this.clickedBtn = 'Save';
    }
    cancelButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }
    discardButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('discardevent', {});
        this.dispatchEvent(selectEvent);
    }
    //Code added by Shailaja. change event for date fields
    handleChangeForInputValue(event) {
        if (event.target.name === 'startMonth') {
            this.startMonth = event.target.value;
        }
        if (event.target.name === 'startYear') {
            //this.startYear = event.target.value;
            this.selectedStartYear = event.target.value;
        }
        if (event.target.name === 'endMonth') {
            this.endMonth = event.target.value;
        }        
        if (event.target.name === 'endYear') {
            //this.endYear = event.target.value;
            this.selectedEndYear = event.target.value;
        }        
        if (event.target.name === 'degreeMonth') {
            this.degreeMonth = event.target.value;
        }
        if (event.target.name === 'degreeYear') {
            this.selectedDegreeIssueYear = event.target.value;
        }
    }
}