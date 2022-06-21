import {
    api,
    LightningElement,
    track,
    wire
} from 'lwc';
import {
    getPicklistValues,
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import fetchApplicantDetails from '@salesforce/apex/EnrollmentVerificationFormController.fetchApplicantDetails';
import saveApplicantDetails from '@salesforce/apex/EnrollmentVerificationFormController.saveApplicantDetails';
import createAcceptedPhotoPayload from '@salesforce/apex/ApplicantMyProfileController.createAcceptedPhotoPayload';
import instructionMessage from '@salesforce/label/c.Enrollment_Verification_Form_Instruction';
import CASE_OBJECT from '@salesforce/schema/Case';
import GRADUATION_MONTH_FIELD from '@salesforce/schema/Case.Graduation_Month__c';
import VERIFICATION_STATUS_FIELD from '@salesforce/schema/Case.Verification_Status__c';
export default class EnrollmentVerificationForm extends LightningElement {
    @api selectedApplicantId;
    @api selectedCaseId;
    @track fetchedValues = [];
    @track examDetails = [];
    @track gradMonth;
    @track gradYearVar;
    @track numOfYearsAttendedVar;
    @track monthPicklistOptions = [];
    @track verificationStatustOptions = [];
    @track passedBasicScience;
    @track verificationStatusSelected;
    @track spinner = false;
    @track showPassedBasicScience = false;
    @track showSubmitButton = false;
    @track showDisabledAttendanceStartDate = true;
    @track disablePassedBasicScience = false;
    @track showFullDate = false;
    @track showDateSection = false;
    @track modalTitle = 'Success!';
    @track modalContent = 'You have successfully submitted your response to the enrollment verification request for this individual. This record will now be moved to the Completed Request(s) section of your Enrollment Verification Request List.';
    @track renderedOnce = false;
    @track verificationMonth;
    @track verificationYear;
    @track verificationDate;
    @track payloadPhotoAccepted;
    @track maxsize = 10;
    @track displayPhoto = false;
    degreeYearVar;
    degreeMonthVar;
    attendanceStartMonthVar;
    attendanceStartYearVar;
    attendanceEndYearVar;
    attendanceEndMonthVar;
    validYearInput = true;
    validAttStartYear = true;
    validattEndYear = true;
    validDegreeYear = true;
    validGradYear = true;
    firstLoad = true;
    label = {
        instructionMessage
    };
    // object info using wire service
    @wire(getObjectInfo, {
        objectApiName: CASE_OBJECT
    })
    objectInfo;
    @wire(getPicklistValues,{
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: GRADUATION_MONTH_FIELD
    })
    monthPicklistValues({
        error,
        data
    }) {
        if(data){
            this.monthPicklistOptions = data.values;
        }else if(error){
            window.console.log('Error: ' + JSON.stringify(error));
        }
    }
    @wire(getPicklistValues,{
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: VERIFICATION_STATUS_FIELD
    })
    verificationStatusPicklistValues({
        error,
        data
    }){
        if(data){
            this.verificationStatustOptions = data.values;
        }else if(error){
            window.console.log('Error: ' + JSON.stringify(error));
        }
    }
    get passedBasicSciencesCourseOptions(){
        return [{
                label: 'Yes',
                value: 'Yes'
            },
            {
                label: 'No',
                value: 'No'
            },
        ];
    }
    connectedCallback(){
        this.spinner = true;
        fetchApplicantDetails({
                applicantId: this.selectedApplicantId,
                caseId: this.selectedCaseId
            })
            .then(result => {
                this.fetchedValues = [];
                if(result){
                    if(result.length > 0){
                        let firstName = result[0].Applicant__r.FirstName === undefined ? '' : result[0].Applicant__r.FirstName;
                        let lastName = result[0].Applicant__r.LastName === undefined ? '' : result[0].Applicant__r.LastName;
                        let tempRecord = {
                            nameOnRecord: firstName + ' ' + lastName,
                            usmleId: result[0].Case__r.Enrollment_Verification_Parent__r.USMLE_ID__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.USMLE_ID__c,
                            dateOfBirth: result[0].Applicant__r.Birthdate === undefined ? '' : result[0].Applicant__r.Birthdate,
                            uniqueMedicalSchoolId: result[0].Case__r.Enrollment_Verification_Parent__r.Unique_Medical_School__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Unique_Medical_School__c,
                            nameOnDiploma: result[0].Case__r.Enrollment_Verification_Parent__r.Name_on_Diploma__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Name_on_Diploma__c,
                            schoolProgram: result[0].Case__r.Enrollment_Verification_Parent__r.School_Program__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.School_Program__c,
                            showSchoolProgram: result[0].Case__r.Enrollment_Verification_Parent__r.School_Program__c !== undefined,
                            gradMonth: result[0].Case__r.Enrollment_Verification_Parent__r.Graduation_Month__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Graduation_Month__c,
                            gradYear: result[0].Case__r.Enrollment_Verification_Parent__r.Graduation_Year__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Graduation_Year__c,
                            numOfYearsAttended: result[0].Case__r.Enrollment_Verification_Parent__r.Number_of_Years_Attended__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Number_of_Years_Attended__c,
                            verificationStatus: result[0].Case__r.Enrollment_Verification_Parent__r.Verification_Status__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Verification_Status__c,
                            passedBasicScience: result[0].Case__r.Enrollment_Verification_Parent__r.Passed_basic_sciences_course__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Passed_basic_sciences_course__c,
                            verificationMonth: result[0].Case__r.Enrollment_Verification_Parent__r.Verification_Status_Month__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Verification_Status_Month__c,
                            verificationYear: result[0].Case__r.Enrollment_Verification_Parent__r.Verification_Status_Year__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Verification_Status_Year__c,
                            verificationDate: result[0].Case__r.Enrollment_Verification_Parent__r.Verification_Status_Date__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Verification_Status_Date__c,
                            degreeYear: result[0].Case__r.Enrollment_Verification_Parent__r.Degree_Year__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Degree_Year__c,
                            degreeMonth: result[0].Case__r.Enrollment_Verification_Parent__r.Degree_Month__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Degree_Month__c,
                            attendanceStartYear: result[0].Case__r.Enrollment_Verification_Parent__r.Attendance_Start_Year__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Attendance_Start_Year__c,
                            attendanceStartMonth: result[0].Case__r.Enrollment_Verification_Parent__r.Attendance_Start_Month__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Attendance_Start_Month__c,
                            attendanceEndYear: result[0].Case__r.Enrollment_Verification_Parent__r.Attendance_End_Year__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Attendance_End_Year__c,
                            attendanceEndMonth: result[0].Case__r.Enrollment_Verification_Parent__r.Attendance_End_Month__c === undefined ? '' : result[0].Case__r.Enrollment_Verification_Parent__r.Attendance_End_Month__c
                        }
                        this.fetchedValues = [tempRecord];
                        this.showPassedBasicScience = result[0].Case__r.Enrollment_Verification_Parent__r.Verification_Status__c !== undefined && result[0].Case__r.Enrollment_Verification_Parent__r.Verification_Status__c === 'Enrolled';
                        this.gradMonth = tempRecord.gradMonth;
                        this.passedBasicScience = tempRecord.passedBasicScience;
                        this.verificationStatusSelected = tempRecord.verificationStatus;
                        this.showDisabledAttendanceStartDate = result[0].Case__r.Enrollment_Verification_Parent__r.Enrollment_Verification_Form_Submitted__c;
                        this.disablePassedBasicScience = this.passedBasicScience === 'Yes';
                        this.gradYearVar = tempRecord.gradYear;
                        this.numOfYearsAttendedVar = tempRecord.numOfYearsAttended;
                        this.verificationMonth = tempRecord.verificationMonth;
                        this.verificationYear = tempRecord.verificationYear;
                        this.verificationDate = tempRecord.verificationDate;
                        this.degreeMonthVar =  tempRecord.degreeMonth;
                        this.degreeYearVar = tempRecord.degreeYear;
                        this.attendanceStartMonthVar = tempRecord.attendanceStartMonth;
                        this.attendanceStartYearVar = tempRecord.attendanceStartYear;
                        this.attendanceEndMonthVar = tempRecord.attendanceEndMonth;
                        this.attendanceEndYearVar = tempRecord.attendanceEndYear;
                        this.handleStatusChange();
                        for(let i in result){
                            let attendanceStartDateTemp = this.getMonthAndYearOfDate(result[i].EP_start_Date__c);
                            let attendanceEndDateTemp = this.getMonthAndYearOfDate(result[i].EP_end_Date__c);
                            let tempExamDetail = {
                                examType: result[i].Exam_Types__c,
                                eligibilityPeriod: attendanceStartDateTemp + ' - ' + attendanceEndDateTemp,
                                hasScheduledTestDate: result[i].Scheduled_Test_Date__c !== undefined,
                                scheduledTestDate: result[i].Scheduled_Test_Date__c === undefined ? '' : result[i].Scheduled_Test_Date__c
                            }
                            if(this.examDetails.length > 0){
                                this.examDetails = [...this.examDetails, tempExamDetail];
                            }else{
                                this.examDetails = [tempExamDetail];
                            }
                        }
                    }

                }
                this.firstLoad = false;
                this.spinner = false;
            })
            .catch((error) => {
                this.spinner = false;
                window.console.log('fetchApplicantDetails Error:', error);
            });
        createAcceptedPhotoPayload({
            contactId: this.selectedApplicantId,
			assetName: "Photo"
        })
            .then(result => {
                if(result){
                    var acceptedPhotoPayloadState = result.assetId;
                    if(acceptedPhotoPayloadState !== "" && acceptedPhotoPayloadState !== null && acceptedPhotoPayloadState !== undefined ) {
                        this.payloadPhotoAccepted = JSON.stringify(result);
                        this.displayPhoto = true;
                    }
                }
            })
            .catch((error) => {
                window.console.log('fetchApplicantPhotoId Error:', error);
            });
    }
    getMonthAndYearOfDate(inputDate){
        var returnRslt = ''
        if(inputDate !== undefined){
            var splittedDate = inputDate.split('-');
            var year = splittedDate[0];
            var month = splittedDate[1];
            var d = splittedDate[2];
            var monthValue = '';
            if(month == '01'){
                monthValue = 'January';
            }else if(month == '02'){
                monthValue = 'February';
            }else if(month == '03'){
                monthValue = 'March';
            }else if(month == '04'){
                monthValue = 'April';
            }else if(month == '05'){
                monthValue = 'May';
            }else if(month == '06'){
                monthValue = 'June';
            }else if(month == '07'){
                monthValue = 'July';
            }else if(month == '08'){
                monthValue = 'August';
            }else if(month == '09'){
                monthValue = 'September';
            }else if(month == '10'){
                monthValue = 'October';
            }else if(month == '11'){
                monthValue = 'November';
            }else{
                monthValue = 'December';
            }
            returnRslt = monthValue + ' ' + d + ',' + year;
        }
        return returnRslt;
    }
    renderedCallback(){
        if(!this.renderedOnce){
            let monthUpdated = false,
                verificationStatusUpdated = false,
                gradYearUpdated = false,
                numOfYearUpdated = false
            // code to set selected month on load
            if(this.template.querySelectorAll('.monthPicklist') !== null){
                this.template.querySelectorAll('.monthPicklist').forEach(element => {
                    if(element.getAttribute('data-selected-month') !== '' &&
                        element.getAttribute('data-selected-month') !== 'true' &&
                        element.getAttribute('data-selected-month') !== null){
                        element.value = element.getAttribute('data-selected-month');
                        if(element.value === this.gradMonth){
                            monthUpdated = true;
                        }
                    }
                });
            }
            // code to set selected verification status on load
            if(this.template.querySelectorAll('.verificationStatusPicklist') !== null){
                this.template.querySelectorAll('.verificationStatusPicklist').forEach(element =>{
                    if(element.getAttribute('data-selected-status') !== '' &&
                        element.getAttribute('data-selected-status') !== 'true' &&
                        element.getAttribute('data-selected-status') !== null){
                        element.value = this.verificationStatusSelected;
                        if(element.value !== ''){
                            verificationStatusUpdated = true;
                        }
                    }
                });
            }
            // code to set inputted grad year on load
            if(this.template.querySelectorAll('.gradYear') !== null){
                this.template.querySelectorAll('.gradYear').forEach(element => {
                    if(element.getAttribute('data-inputted-year') !== '' &&
                        element.getAttribute('data-inputted-year') !== 'true' &&
                        element.getAttribute('data-inputted-year') !== null) {
                        element.value = element.getAttribute('data-inputted-year');
                        gradYearUpdated = true;
                    }
                });
            }
            // code to set inputted num of years on load
            if(this.template.querySelectorAll('.numOfYearsAttended') !== null){
                this.template.querySelectorAll('.numOfYearsAttended').forEach(element => {
                    if(element.getAttribute('data-inputted-numofyear') !== '' &&
                        element.getAttribute('data-inputted-numofyear') !== 'true' &&
                        element.getAttribute('data-inputted-numofyear') !== null){
                        element.value = element.getAttribute('data-inputted-numofyear');
                        numOfYearUpdated = true;
                    }
                });
            }
            // code to set  verification month on load
            if(this.template.querySelectorAll('.verificationStatusMonthPicklist') !== null){
                this.template.querySelectorAll('.verificationStatusMonthPicklist').forEach(element =>{
                    if(element.getAttribute('data-verification-month') !== '' &&
                        element.getAttribute('data-verification-month') !== 'true' &&
                        element.getAttribute('data-verification-month') !== null){
                        element.value = element.getAttribute('data-verification-month');
                    }
                });
            }
            // code to set  verification year on load
            if(this.template.querySelectorAll('.verificationStatusYear') !== null){
                this.template.querySelectorAll('.verificationStatusYear').forEach(element => {
                    if(element.getAttribute('data-verification-year') !== '' &&
                        element.getAttribute('data-verification-year') !== 'true' &&
                        element.getAttribute('data-verification-year') !== null) {
                        element.value = element.getAttribute('data-verification-year');
                    }
                });
            }
            // code to set  verification status date on load
            if(this.template.querySelectorAll('.verificationStatusDate') !== null){
                this.template.querySelectorAll('.verificationStatusDate').forEach(element => {
                    if(element.getAttribute('data-verification-date') !== '' &&
                        element.getAttribute('data-verification-date') !== 'true' &&
                        element.getAttribute('data-verification-date') !== null){
                        element.value = element.getAttribute('data-verification-date');
                    }
                });
            }
            // code to set inputted degree year on load
            if(this.template.querySelectorAll('.degreeYear') !== null){
                this.template.querySelectorAll('.degreeYear').forEach(element => {
                    if(element.getAttribute('data-inputted-year') !== '' &&
                        element.getAttribute('data-inputted-year') !== 'true' &&
                        element.getAttribute('data-inputted-year') !== null){
                        element.value = element.getAttribute('data-inputted-year');
                    }
                });
            }
            // code to set selected degree month on load
            if(this.template.querySelectorAll('.degreeMonthPicklist') !== null){
                this.template.querySelectorAll('.degreeMonthPicklist').forEach(element => {
                    if(element.getAttribute('data-degree-month') !== '' &&
                        element.getAttribute('data-degree-month') !== 'true' &&
                        element.getAttribute('data-degree-month') !== null){
                        element.value = element.getAttribute('data-degree-month');
                    }
                });
            }
            if(this.template.querySelectorAll('.attendanceStartYear') !== null){
                this.template.querySelectorAll('.attendanceStartYear').forEach(element =>{
                    if(element.getAttribute('data-inputted-year') !== '' &&
                        element.getAttribute('data-inputted-year') !== 'true' &&
                        element.getAttribute('data-inputted-year') !== null){
                        element.value = element.getAttribute('data-inputted-year');
                    }
                });
            }
            // code to set selected degree month on load
            if(this.template.querySelectorAll('.attendanceStartMonthPicklist') !== null){
                this.template.querySelectorAll('.attendanceStartMonthPicklist').forEach(element => {
                    if(element.getAttribute('data-attendance-start-month') !== '' &&
                        element.getAttribute('data-attendance-start-month') !== 'true' &&
                        element.getAttribute('data-attendance-start-month') !== null){
                        element.value = element.getAttribute('data-attendance-start-month');
                    }
                });
            }
            if(this.template.querySelectorAll('.attendanceEndYear') !== null){
                this.template.querySelectorAll('.attendanceEndYear').forEach(element => {
                    if(element.getAttribute('data-inputted-year') !== '' &&
                        element.getAttribute('data-inputted-year') !== 'true' &&
                        element.getAttribute('data-inputted-year') !== null){
                        element.value = element.getAttribute('data-inputted-year');
                    }
                });
            }
            if(this.template.querySelectorAll('.attendanceEndMonthPicklist') !== null){
                this.template.querySelectorAll('.attendanceEndMonthPicklist').forEach(element => {
                    if(element.getAttribute('data-attendance-end-month') !== '' &&
                        element.getAttribute('data-attendance-end-month') !== 'true' &&
                        element.getAttribute('data-attendance-end-month') !== null){
                        element.value = element.getAttribute('data-attendance-end-month');
                    }
                });
            }
            if(monthUpdated && verificationStatusUpdated && gradYearUpdated && numOfYearUpdated){
                this.renderedOnce = true;
            }
        }
    }
    handleStatusChange(){
        if(this.firstLoad === false){
            this.verificationStatusSelected = this.template.querySelector('.verificationStatusPicklist').value;
            if(this.template.querySelector('.verificationStatusDate') !== null){
                this.template.querySelector('.verificationStatusDate').value = '';
            }
            if(this.template.querySelector('.verificationStatusMonthPicklist') !== null){
                this.template.querySelector('.verificationStatusMonthPicklist').value = '';
            }
            if(this.template.querySelector('.verificationStatusYear') !== null){
                this.template.querySelector('.verificationStatusYear').value = '';
            }
        }
        if(this.verificationStatusSelected === 'Enrolled'){
            this.showPassedBasicScience = true;
        }else{
            this.showPassedBasicScience = false;
        }
        if(this.verificationStatusSelected === 'Not Reviewed' || this.verificationStatusSelected === ''){
            this.showSubmitButton = false;
        }else{
            this.showSubmitButton = true;
        }
        if(this.verificationStatusSelected === 'Graduated' || this.verificationStatusSelected === 'Deceased' ||
            this.verificationStatusSelected === 'Dismissed' || this.verificationStatusSelected === 'Transferred' ||
            this.verificationStatusSelected === 'Withdrawn'){
            this.showDateSection = true;
        }else{
            this.showDateSection = false;
        }
        if(this.verificationStatusSelected === 'Graduated' || this.verificationStatusSelected === 'Deceased'){
            this.showFullDate = false;
        }
        if(this.verificationStatusSelected === 'Dismissed' || this.verificationStatusSelected === 'Transferred' ||
            this.verificationStatusSelected === 'Withdrawn'){
            this.showFullDate = true;
        }
    }
    checkValidNumber(number, divClass, qSelector ){
        let breturn;
        breturn =true;
        var isNumber =  /[1-9][0-9]{3}/.test(number);
        if(isNumber===false){
            let element = this.template.querySelector(qSelector);
            element.classList.add('slds-has-error');
            let elem = document.createElement("div");
            elem.id = divClass; //'blankAttendanceStartYearError';
            elem.setAttribute('class', divClass);
            elem.textContent = 'Please enter valid year ';
            elem.style = 'color:#ff0000; clear:both;';
            element.insertBefore(elem, element.nextSibling);
            breturn =false;
            this.validYearInput = false
        }
        return breturn;
    }
    saveCaseDetails(){
        this.spinner = true;
        let allowSave = true;
        let allValidDate = true;
        this.validYearInput = true;
        this.clearDateError();
        if(this.template.querySelectorAll('.slds-has-error') !== null){
            this.template.querySelectorAll('.slds-has-error').forEach(element => element.classList.remove('slds-has-error'));
        }
        let monthPicklistVar, gradYearVar, graduationDateVar,  degreeIssueDateVar, numOfYearsAttendedVar,
            verificationStatusPicklistVar, verificationStatusDateVar, verificationStatusDateMonthVar, verificationStatusDateYearVar, passedBasicScienceVar,
            attStartMonth, attStartYear, attEndYear, attEndMonth, tempDegreeMonthVar, tempDegreeYearVar, tempdate;
        //Start date
        if(this.template.querySelector('.attendanceStartYear').value !=null){
            attStartYear = this.template.querySelector('.attendanceStartYear').value;
            if(attStartYear ==='' || attStartYear === null || attStartYear === undefined){
                let element = this.template.querySelector('.attendanceStartYearWrapper');
                element.classList.add('slds-has-error');
                allowSave = false;
                let elem = document.createElement("div");
                elem.id = 'blankAttendanceStartYearError';
                elem.setAttribute('class', 'blankAttendanceStartYearError');
                elem.textContent = 'Please enter Attendance Start Year ';
                elem.style = 'color:#ff0000; clear:both;';
                element.insertBefore(elem, element.nextSibling);
            }else{
                this.template.querySelectorAll('.blankAttendanceStartYearError').forEach(element => element.remove());
                this.validAttStartYear = this.checkValidNumber(attStartYear, 'blankAttendanceStartYearError', '.attendanceStartYearWrapper');
            }
        }
        if(this.template.querySelector('.attendanceStartMonthPicklist').value !== null){
            attStartMonth = this.template.querySelector('.attendanceStartMonthPicklist').value;
            if(attStartMonth === '' || attStartMonth === null || attStartMonth === undefined){
                let element = this.template.querySelector('.attendanceMonthWrapper');
                element.classList.add('slds-has-error');
                allowSave = false;
                let elem = document.createElement("div");
                elem.id = 'blankAttendanceStartMonthError';
                elem.setAttribute('class', 'blankAttendanceStartMonthError');
                elem.textContent = 'Please enter Attendance Start Month ';
                elem.style = 'color:#ff0000; clear:both;';
                element.insertBefore(elem, element.nextSibling);
            }else{
                this.template.querySelectorAll('.blankAttendanceStartMonthError').forEach(element => element.remove());
            }
        }
        if(this.template.querySelector('.attendanceStartMonthPicklist').value !== null || this.template.querySelector('.attendanceStartYear').value !=null){
            let attMonth = this.template.querySelector('.attendanceStartMonthPicklist').value;
            let attYear = this.template.querySelector('.attendanceStartYear').value;
            this.attendanceStartYearVar = attYear;
            this.attendanceStartMonthVar = attMonth;
            tempdate = attYear +'-'+attMonth+'-'+'01';
            this.attendanceStartDateVar = new Date(tempdate);
        }
        //end start date
        //Start End date
        if(this.template.querySelector('.attendanceEndYear').value !=null){
            attEndYear = this.template.querySelector('.attendanceEndYear').value;
            if(attEndYear ==='' || attEndYear === null || attEndYear === undefined){
                let element = this.template.querySelector('.attendanceEndYearWrapper');
                element.classList.add('slds-has-error');
                allowSave = false;
                let elem = document.createElement("div");
                elem.id = 'blankAttendanceEndYearError';
                elem.setAttribute('class', 'blankAttendanceEndYearError');
                elem.textContent = 'Please enter Attendance End Year ';
                elem.style = 'color:#ff0000; clear:both;';
                element.insertBefore(elem, element.nextSibling);
            }else{
                this.template.querySelectorAll('.blankAttendanceEndYearError').forEach(element => element.remove());
               this.validattEndYear = this.checkValidNumber(attEndYear, 'blankAttendanceEndYearError', '.attendanceEndYearWrapper');
            }
        }
        if(this.template.querySelector('.attendanceEndMonthPicklist').value !== null){
            attEndMonth = this.template.querySelector('.attendanceEndMonthPicklist').value;
            if(attEndMonth === '' || attEndMonth === null || attEndMonth === undefined){
                let element = this.template.querySelector('.attendanceEndMonthWrapper');
                element.classList.add('slds-has-error');
                allowSave = false;
                let elem = document.createElement("div");
                elem.id = 'blankAttendanceEndMonthError';
                elem.setAttribute('class', 'blankAttendanceEndMonthError');
                elem.textContent = 'Please enter Attendance End Month ';
                elem.style = 'color:#ff0000; clear:both;';
                element.insertBefore(elem, element.nextSibling);
            }else{
                this.template.querySelectorAll('.blankAttendanceEndMonthError').forEach(element => element.remove());
            }
        }
        if(this.template.querySelector('.attendanceEndMonthPicklist').value !== null || this.template.querySelector('.attendanceEndYear').value !=null){
            attEndMonth = this.template.querySelector('.attendanceEndMonthPicklist').value;
            let attYear = this.template.querySelector('.attendanceEndYear').value;
            this.attendanceEndYearVar = attYear;
            this.attendanceEndMonthVar = attEndMonth;
            tempdate = attYear +'-'+attEndMonth+'-'+'01';
            this.attendanceEndDateVar = new Date(tempdate);
        }
        //End End date
        //Start Degree date
        if(this.template.querySelector('.degreeYear').value !=null){
            tempDegreeYearVar = this.template.querySelector('.degreeYear').value;
            if(tempDegreeYearVar ==='' || tempDegreeYearVar === null || tempDegreeYearVar === undefined){
                let element = this.template.querySelector('.degreeYearWrapper');
                element.classList.add('slds-has-error');
                allowSave = false;
                let elem = document.createElement("div");
                elem.id = 'blankDegreeYearError';
                elem.setAttribute('class', 'blankDegreeYearError');
                elem.textContent = 'Please enter Degree Year ';
                elem.style = 'color:#ff0000; clear:both;';
                element.insertBefore(elem, element.nextSibling);
            }else{
                this.template.querySelectorAll('.blankDegreeYearError').forEach(element => element.remove());
                this.validDegreeYear = this.checkValidNumber(tempDegreeYearVar, 'blankDegreeYearError', '.degreeYearWrapper');
            }
        }
        if(this.template.querySelector('.degreeMonthPicklist').value !== null){
            tempDegreeMonthVar = this.template.querySelector('.degreeMonthPicklist').value;
            if(tempDegreeMonthVar === '' || tempDegreeMonthVar === null || tempDegreeMonthVar === undefined){
                let element = this.template.querySelector('.degreeMonthWrapper');
                element.classList.add('slds-has-error');
                allowSave = false;
                let elem = document.createElement("div");
                elem.id = 'blankDegreeMonthError';
                elem.setAttribute('class', 'blankDegreeMonthError');
                elem.textContent = 'Please enter Degree Month ';
                elem.style = 'color:#ff0000; clear:both;';
                element.insertBefore(elem, element.nextSibling);
            }else{
                this.template.querySelectorAll('.blankDegreeMonthError').forEach(element => element.remove());
            }
        }
        if(this.template.querySelector('.degreeMonthPicklist').value !== null || this.template.querySelector('.degreeYear').value !=null){
            let degMonth = this.template.querySelector('.degreeMonthPicklist').value;
            let degYear = this.template.querySelector('.degreeYear').value;
            this.degreeYearVar = degYear;
            this.degreeMonthVar = degMonth;
            tempdate = degYear +'-'+degMonth+'-'+'01';
            degreeIssueDateVar = new Date(tempdate);
        }
        //end Degree date
        if(this.template.querySelector('.monthPicklist') !== null){
            monthPicklistVar = this.template.querySelector('.monthPicklist').value;
            this.gradMonth = monthPicklistVar;
            this.template.querySelectorAll('.blankGradMonthError').forEach(element => element.remove());
            if(monthPicklistVar === '' || monthPicklistVar === null || monthPicklistVar === undefined){
                let element = this.template.querySelector('.gradMonthWrapper');
                element.classList.add('slds-has-error');
                allowSave = false;
                let elem = document.createElement("div");
                elem.id = 'blankGradMonthError';
                elem.setAttribute('class', 'blankGradMonthError');
                elem.textContent = 'Please enter a month';
                elem.style = 'color:#ff0000; clear:both;';
                element.insertBefore(elem, element.nextSibling);
            }else{
                this.template.querySelectorAll('.blankGradMonthError').forEach(element => element.remove());
            }
        }
        if(this.template.querySelector('.gradYear') !== null){
            gradYearVar = this.template.querySelector('.gradYear').value;
            this.template.querySelectorAll('.blankGradYearError').forEach(element => element.remove());
            if(gradYearVar === '' || gradYearVar === null || gradYearVar === undefined){
                let element = this.template.querySelector('.gradYearWrapper');
                element.classList.add('slds-has-error');
                allowSave = false;
                let elem = document.createElement("div");
                elem.id = 'blankGradYearError';
                elem.setAttribute('class', 'blankGradYearError');
                elem.textContent = 'Please enter a year';
                elem.style = 'color:#ff0000; clear:both;';
                element.insertBefore(elem, element.nextSibling);
            }else{
                this.template.querySelectorAll('.blankGradYearError').forEach(element => element.remove());
                this.validGradYear = this.checkValidNumber(gradYearVar, 'blankGradYearError', '.gradYearWrapper');
            }
        }
        if(this.template.querySelector('.monthPicklist').value !== null || this.template.querySelector('.gradYear').value !=null){
            let gradMonth = this.template.querySelector('.monthPicklist').value;
            let gradYear = this.template.querySelector('.gradYear').value;
            tempdate = gradYear +'-'+gradMonth+'-'+'01';
            graduationDateVar = new Date(tempdate);
        }
        if(this.template.querySelector('.numOfYearsAttended') !== null){
            numOfYearsAttendedVar = this.template.querySelector('.numOfYearsAttended').value;
            this.template.querySelectorAll('.blankNumOfYearsError').forEach(element => element.remove());
            if(numOfYearsAttendedVar === '' || numOfYearsAttendedVar === null || numOfYearsAttendedVar === undefined || numOfYearsAttendedVar === '0'){
                let element = this.template.querySelector('.numOfYearsAttendedWrapper');
                element.classList.add('slds-has-error');
                allowSave = false;
                let elem = document.createElement("div");
                elem.id = 'blankNumOfYearsError';
                elem.setAttribute('class', 'blankNumOfYearsError');
                elem.textContent = 'Please enter the number of years attended';
                elem.style = 'color:#ff0000; clear:both;';
                element.insertBefore(elem, element.nextSibling);
            }else{
                this.template.querySelectorAll('.blankNumOfYearsError').forEach(element => element.remove());
            }
        }
        if(this.template.querySelector('.verificationStatusPicklist') !== null){
            verificationStatusPicklistVar = this.template.querySelector('.verificationStatusPicklist').value;
        }
        if(this.template.querySelector('.verificationStatusDate') !== null){
            verificationStatusDateVar = this.template.querySelector('.verificationStatusDate').value;
            this.template.querySelectorAll('.blankDateError').forEach(element => element.remove());
            if(verificationStatusDateVar === '' || verificationStatusDateVar === null || verificationStatusDateVar === undefined){
                let element = this.template.querySelector('.verificationStatusDate');
                element.classList.add('slds-has-error');
                allowSave = false;
                let elem = document.createElement("div");
                elem.id = 'blankDateError';
                elem.setAttribute('class', 'blankDateError');
                elem.textContent = 'Please enter a date';
                elem.style = 'color:#ff0000; clear:both;';
                element.insertBefore(elem, element.nextSibling);
            }else{
                this.template.querySelectorAll('.blankDateError').forEach(element => element.remove());
            }
        }
        if(this.template.querySelector('.verificationStatusMonthPicklist') !== null){
            verificationStatusDateMonthVar = this.template.querySelector('.verificationStatusMonthPicklist').value;
            this.template.querySelectorAll('.blankMonthError').forEach(element => element.remove());
            if(verificationStatusDateMonthVar === '' || verificationStatusDateMonthVar === null || verificationStatusDateMonthVar === undefined) {
                let element = this.template.querySelector('.monthSelectContainer');
                element.classList.add('slds-has-error');
                allowSave = false;
                let elem = document.createElement("div");
                elem.id = 'blankMonthError';
                elem.setAttribute('class', 'blankMonthError');
                elem.textContent = 'Please enter a month';
                elem.style = 'color:#ff0000; clear:both;';
                element.insertBefore(elem, element.nextSibling);
            }else{
                this.template.querySelectorAll('.blankMonthError').forEach(element => element.remove());
            }
        }
        if(this.template.querySelector('.verificationStatusYear') !== null){
            verificationStatusDateYearVar = this.template.querySelector('.verificationStatusYear').value;
            this.template.querySelectorAll('.blankYearError').forEach(element => element.remove());
            if(verificationStatusDateYearVar === '' || verificationStatusDateYearVar === null || verificationStatusDateYearVar === undefined){
                let element = this.template.querySelector('.verificationStatusYear');
                element.classList.add('slds-has-error');
                allowSave = false;
                let elem = document.createElement("div");
                elem.id = 'blankYearError';
                elem.setAttribute('class', 'blankYearError');
                elem.textContent = 'Please enter a year';
                elem.style = 'color:#ff0000; clear:both;';
                element.insertBefore(elem, element.nextSibling);
            }else{
                this.template.querySelectorAll('.blankYearError').forEach(element => element.remove());
                this.checkValidNumber(verificationStatusDateYearVar, 'blankYearError', '.verificationStatusYear');
            }
        }
        if(this.template.querySelector('.passedBasicScience') !== null){
            passedBasicScienceVar = this.template.querySelector('.passedBasicScience').value;
            this.template.querySelectorAll('.blankBasicScienceCompletedError').forEach(element => element.remove());
            if(passedBasicScienceVar === '' || passedBasicScienceVar === null || passedBasicScienceVar === undefined){
                let element = this.template.querySelector('.passedBasicScience');
                element.classList.add('slds-has-error');
                allowSave = false;
                let elem = document.createElement("div");
                elem.id = 'blankBasicScienceCompletedError';
                elem.setAttribute('class', 'blankBasicScienceCompletedError');
                elem.textContent = 'Please select a value';
                elem.style = 'color:#ff0000; clear:both;';
                element.insertBefore(elem, element.nextSibling);
            }else{
                this.template.querySelectorAll('.blankBasicScienceCompletedError').forEach(element => element.remove());
            }
        }
        allValidDate = this.validateDate(this.attendanceStartDateVar, this.attendanceEndDateVar, degreeIssueDateVar, graduationDateVar );
        let valuesToSave = {
            caseId: this.selectedCaseId,
            gradMonth: monthPicklistVar,
            gradYear: gradYearVar,
            degreeIssueDate: degreeIssueDateVar,
            numOfYearsAttended: numOfYearsAttendedVar,
            verificationStatus: verificationStatusPicklistVar,
            verificationStatusDate: verificationStatusDateVar,
            verificationStatusDateMonth: verificationStatusDateMonthVar,
            verificationStatusDateYear: verificationStatusDateYearVar,
            passedBasicScience: passedBasicScienceVar,
            attendanceStartMonth: this.attendanceStartMonthVar,
            attendanceStartYear: this.attendanceStartYearVar,
            attendanceEndMonth: this.attendanceEndMonthVar,
            attendanceEndYear: this.attendanceEndYearVar,
            degreeMonth: this.degreeMonthVar,
            degreeYear: this.degreeYearVar
        }
        if(allowSave && allValidDate && this.validYearInput){
            this.renderedOnce = false;
             saveApplicantDetails({
                    applicantDetails: JSON.stringify(valuesToSave)
                })
                .then(saveresult => {
                    this.spinner = false;
                    if(saveresult === 'true'){
                        this.template.querySelector('.successModal').show();
                    }
                })
                .catch(error => {
                    window.console.log('Error: ' + JSON.stringify(error));
                });
        }else{
            this.spinner = false;
        }
    }
    handleOkClick(){
        const submitEvent = new CustomEvent('submitevent', {
            detail: {
                updatedEV: true
            }
        });
        this.dispatchEvent(submitEvent);
    }
    validateYearInput(event){
        this.template.querySelectorAll('.blankYearError').forEach(element => element.remove());
        if(event.target.classList.contains('slds-has-error')){
            event.target.classList.remove('slds-has-error');
        }
        // prevent letter e which is considered as exponential in number field, minus symbol, hyphen and decimal
        if(event.which === 69 || event.which === 109 || event.which === 189 || event.which === 110){
            event.preventDefault();
        }
        // prevent more than 4 characters but allow backspace/tab
        if(event.target.value.length === 4 && event.which !== 8 && event.which !== 9){
            event.preventDefault();
        }
    }
    removeErrorText(event){
        this.template.querySelectorAll('.blankDateError').forEach(element => element.remove());
        this.template.querySelectorAll('.blankMonthError').forEach(element => element.remove());
        if(event.target.classList.contains('slds-has-error')){
            event.target.classList.remove('slds-has-error');
        }
        if(event.target.parentNode.classList.contains('slds-has-error')){
            event.target.parentNode.classList.remove('slds-has-error');
        }
    }
    backButton(event){
        event.preventDefault();
        const backEvent = new CustomEvent('backevent', {
            detail: {
                updatedEV: true
            }
        });
        this.dispatchEvent(backEvent);
    }
    submitButton(event){
        event.preventDefault();
        this.saveCaseDetails();
    }
    clearDateError(){
        this.template.querySelectorAll('.blankAttendanceEndDateError').forEach(element => element.remove());
        this.template.querySelectorAll('.blankDegreeError').forEach(element => element.remove());
        this.template.querySelectorAll('.blankAttendanceStartDateError').forEach(element => element.remove());
        this.template.querySelectorAll('.blankAttendanceStartYearError').forEach(element => element.remove());
        this.template.querySelectorAll('.blankAttendanceStartMonthError').forEach(element => element.remove());
        this.template.querySelectorAll('.blankAttendanceEndYearError').forEach(element => element.remove());
        this.template.querySelectorAll('.blankAttendanceEndMonthError').forEach(element => element.remove());
        this.template.querySelectorAll('.blankDegreeMonthError').forEach(element => element.remove());
        this.template.querySelectorAll('.blankDegreeYearError').forEach(element => element.remove());
        this.template.querySelectorAll('.blankGradError').forEach(element => element.remove());
        this.template.querySelectorAll('.blankEndDateDegreeError').forEach(element => element.remove());
    }
    validateDate(attStartDate, attEndDate, degreeDate, gradDate){
        let validDate = true;
        if(attStartDate > new Date() && this.validAttStartYear ){
            let element = this.template.querySelector('.attendanceMonthWrapper');
            let element1 = this.template.querySelector('.attendanceStartYearWrapper');
            let element2 = this.template.querySelector('.attendanceStartDateMessage');
            element.classList.add('slds-has-error');
            element1.classList.add('slds-has-error');
            validDate = false;
            let elem = document.createElement("div");
            elem.id = 'blankAttendanceStartDateError';
            elem.setAttribute('class', 'blankAttendanceStartDateError');
            elem.textContent = ' Start Date should not be in future';
            elem.style = 'color:#ff0000; clear:both;';
            element2.insertBefore(elem, element2.nextSibling);
        }else{
            this.template.querySelectorAll('.blankAttendanceStartDateError').forEach(element => element.remove());

        }
        if((attStartDate >=  attEndDate ) &&
                (this.template.querySelector('.attendanceStartYear').value !=null && this.template.querySelector('.attendanceStartYear').value !='') &&
                (this.template.querySelector('.attendanceStartMonthPicklist').value !== null && this.template.querySelector('.attendanceStartMonthPicklist').value !== '')
                && this.validAttStartYear &&this.validattEndYear){
            let element = this.template.querySelector('.attendanceEndMonthWrapper');
            let element1 = this.template.querySelector('.attendanceEndYearWrapper');
            let element2 = this.template.querySelector('.attendanceEndDateMessage');
            element.classList.add('slds-has-error');
            element1.classList.add('slds-has-error');
            validDate = false;
            let elem = document.createElement("div");
            elem.id = 'blankAttendanceEndDateError';
            elem.setAttribute('class', 'blankAttendanceEndDateError');
            elem.textContent = ' Attendance Start date cannot be greater than Attendance End date';
            elem.style = 'color:#ff0000; clear:both;';
            element2.insertBefore(elem, element2.nextSibling);
        }else{
            this.template.querySelectorAll('.blankAttendanceEndDateError').forEach(element => element.remove());
        }
        if(attStartDate > degreeDate && this.validAttStartYear && this.validDegreeYear){
            let element = this.template.querySelector('.degreeMonthWrapper');
            let element1 = this.template.querySelector('.degreeYearWrapper');
            let element2 = this.template.querySelector('.degreeErrorMessage');
            element.classList.add('slds-has-error');
            element1.classList.add('slds-has-error');
            validDate = false;
            let elem = document.createElement("div");
            elem.id = 'blankAttendanceEndDateError';
            elem.setAttribute('class', 'blankDegreeError');
            elem.textContent = ' Attendance Start date cannot be greater than Degree date';
            elem.style = 'color:#ff0000; clear:both;';
            element2.insertBefore(elem, element2.nextSibling);
        }else{
            this.template.querySelectorAll('.blankDegreeError').forEach(element => element.remove());
        }
        //check degree with enddate
        if(attEndDate > degreeDate && this.validattEndYear && this.validDegreeYear){
            let element = this.template.querySelector('.degreeMonthWrapper');
            let element1 = this.template.querySelector('.degreeYearWrapper');
            let element2 = this.template.querySelector('.degreeErrorMessage');
            element.classList.add('slds-has-error');
            element1.classList.add('slds-has-error');
            validDate = false;
            let elem = document.createElement("div");
            elem.id = 'blankEndDateDegreeError';
            elem.setAttribute('class', 'blankEndDateDegreeError');
            elem.textContent = 'Degree Issue Month and Degree Issue Year must be later than Attendance End Month and Attendance End Year';
            elem.style = 'color:#ff0000; clear:both;';
            element2.insertBefore(elem, element2.nextSibling);
        }else{
            this.template.querySelectorAll('.blankEndDateDegreeError').forEach(element => element.remove());
        }
        //check graduation date with enddate
        if(attEndDate > gradDate && this.validattEndYear && this.validGradYear){
            let element = this.template.querySelector('.gradMonthWrapper');
            let element1 = this.template.querySelector('.gradYearWrapper');
            let element2 = this.template.querySelector('.graduationDateErrorMessage');
            element.classList.add('slds-has-error');
            element1.classList.add('slds-has-error');
            validDate = false;
            let elem = document.createElement("div");
            elem.id = 'blankGraduationDateError';
            elem.setAttribute('class', 'blankGradError');
            elem.textContent = 'Graduation Month and Graduation Year must be later than Attendance End Month and Attendance End Year';
            elem.style = 'color:#ff0000; clear:both;';
            element2.insertBefore(elem, element2.nextSibling);
        }else{
            this.template.querySelectorAll('.blankGradError').forEach(element => element.remove());
        }
        return validDate;
    }
}