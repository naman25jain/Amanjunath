import { LightningElement, api} from 'lwc';

// Importing Aapex class
import codeCoverageAnalysis from '@salesforce/apex/CodeCoverageExportController.exportClassCoverage'; 
import getSeeAllDataTestClasses from '@salesforce/apex/CodeCoverageExportController.getSeeAllDataTestClasses'; 
import getTestQueueData from '@salesforce/apex/CodeCoverageExportController.getTestQueueData'; 
import readCsvDataFromFile from '@salesforce/apex/CodeCoverageExportController.readCsvDataFromFile'; 
import sentEmails from '@salesforce/apex/CodeCoverageExportController.sentEmails'; 
import getApexTestResults from '@salesforce/apex/CodeCoverageExportController.getApexTestResults';
import runAllTestClasses from '@salesforce/apex/CodeCoverageExportController.runAllTestClasses';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    {type: 'button-icon',initialWidth: 80,typeAttributes:{ iconName: 'action:preview', name: 'preview',}},
    {label: 'Name', sortable: "true",fieldName: 'ApexClassOrTrigger',type:"String",cellAttributes: { class: { fieldName: 'covrageLowCSSClass' }},},
    {label: 'Total Lines', fieldName: 'TotalLines'}, 
    {label: 'NumLinesCovered',fieldName: 'CoveredLinesCount'}, 
    {label: 'NumLinesUncovered',fieldName: 'UncoveredLinesCount'}, 
    {label: 'Percentage Covered',fieldName: 'PercentageCovered',sortable: "true",cellAttributes: { class: { fieldName: 'covrageLowCSSClass' }}}
];

const csvcolumns = [
    {label: 'Name', fieldName: 'ApexClassOrTrigger',type:"String"},
    {label: 'Old Percentage',fieldName: 'OldPercentage'},
    {label: 'New Percentage',fieldName: 'NewPercentage'},
    {label: 'Percentage Change',fieldName: 'PercentageChange'}
];

const allDatacolumns = [
    {label: 'Name', fieldName: 'ApexURL', type: 'url',
    typeAttributes: {label: {fieldName: 'Name'},target : '_blank'}},
    {label: 'Status',fieldName: 'Status'},
];

const testrescolumns = [
    {label: 'Name', fieldName: 'ApexClassOrTrigger',type:"String", wrapText: true},
    {label: 'Method Name',fieldName: 'MethodName', wrapText: true},
    {label: 'Message',fieldName: 'Message', wrapText: true},
    {label: 'StackTrace',fieldName: 'StackTrace', wrapText: true}
];

export default class CodeCoverageExport extends LightningElement {

// reactive variables
     columns = columns;
     csvcolumns = csvcolumns;
     testrescolumns = testrescolumns;
     allDatacolumns = allDatacolumns;
     csvdata = [];
     data;
     allData = [];
     testResdata = [];
     selectedCmpRecords = [];
     selectedTestRecords = [];
     seeAllDataTestClasses = [];
     sltdSeeAllDataTestClasses = [];
     orgTotalApexLines;
     OrgTotalCodeCoverage;
     OrgTotalCoveredLines;
     sortDirection;
     sortBy;
     isSpinner = false;
     isOpen = false;
     csvString = '';

    // Modal attributes
    isModalSpinner = false;
     modalTitle = '';
     modalMessage = '';
     showclosebtn = true;
     modalSize = '';
     modalEmailTitle = '';
     @api isCompareModal = false;
     @api isModalOpen = false;
     @api isEmailModalOpen = false;
     @api isTestResModal = false;
     @api isSeeAllModal = false;
     emailsToSend = '';
     selectedbtn = '';

     offSetValue = 20;
     isLoaded = false;
     enableInfiniteLoad = false;

    connectedCallback() {
        this.codeAnalysis();
    }

    codeAnalysis() {
        this.isSpinner = true;
        codeCoverageAnalysis()
        .then(result => {
            this.processRecords(result.records);
            this.isSpinner = false;
        })
        .catch(error => {
            this.isSpinner = false;
            this.error = error;
            console.log('error => ', error);
            this.toastmessage('Error', error.message);
        });
    }

    handleSearch(event) {
        this.enableInfiniteLoad = false;
        this.data = null;
        if(event.target.value) {
            let filterData = [...this.filtered(this.allData, 'ApexClassOrTrigger', event.target.value)];
            this.data = [...filterData];
            console.log('Data ',filterData);
            this.enableInfiniteLoad = filterData.length > this.offSetValue ? true : false;
        }
        else {
            let recordsClone = [...this.allData];
            this.data = recordsClone.splice(0, this.offSetValue);
            this.enableInfiniteLoad = true;
        }
    }

    filtered(list, key, value){
        let filtered = [], i = list.length;
        let reg = new RegExp("(.*)(" + value.toLowerCase() + ")(.*)");
        while (i--) {
            if (reg.test(list[i][key].toLowerCase())) {
                filtered.push(list[i]);
            }
        }
        return filtered;
    };

    processRecords(records) {
        let rows = [];
        let orgTotalLines = 0;
        let totalCoveredLines = 0;
        let totalCountLines = 0;

        records.forEach((key) => {
            let row = {...key}
            
            // Total apex lines in org
            orgTotalLines = orgTotalLines + totalCountLines;
            
            // Total lines of current apex class
            totalCountLines = Number(row.NumLinesCovered) + Number(row.NumLinesUncovered);

            // Covered lines of Apex class
            totalCoveredLines = totalCoveredLines + Number(row.NumLinesCovered);
            let percentage = Math.round(Number(row.NumLinesCovered) / totalCountLines * 100).toString() + '%';
            // Percentage covered for current apex class
            row.PercentageCovered = (percentage == 'NaN%' ? '0%' : percentage);
       
            // Showing different color in column based on percentage covered
            if(Math.round(Number(row.NumLinesCovered) / totalCountLines * 100) < 75) {
                row.covrageLowCSSClass = 'slds-text-color_error';
            }
            else {
                row.covrageLowCSSClass = 'slds-text-color_success';
            }

            row.TotalLines = totalCountLines.toString();
            if(row.ApexClassOrTrigger) {
                row['ApexClassOrTrigger'] = row.ApexClassOrTrigger.Name;
            }

            if(row) {
                row.CoveredLinesCount = row.NumLinesCovered.toString();
                row.UncoveredLinesCount = row.NumLinesUncovered.toString();
            }
            
            if(Number(row.PercentageCovered.replace('%', '')) < 75 && Number(row.TotalLines.replace('%', '')) > 0) {
                rows.push(row);
                this.allData.push(row);
            }
        }); 

        this.OrgTotalCodeCoverage = Math.round(totalCoveredLines/orgTotalLines * 100);
        this.orgTotalApexLines = orgTotalLines;
        this.OrgTotalCoveredLines = totalCoveredLines;
    
        this.data = rows.splice(0, this.offSetValue);
        this.isLoaded = true;
        this.enableInfiniteLoad = true;
    }

    handleSeeAllDataClasses() {
        this.isSeeAllModal = false;
        this.isModalOpen = false;
        this.modalTitle = '';
        this.isModalSpinner = true;
        getSeeAllDataTestClasses().then(res => {
            
            this.modalTitle = 'See All Data Classes';
            this.isModalSpinner = false;
            if(res) {
                this.isSeeAllModal = true;
                let allres = [];
                res.forEach(rec => {
                    let obj = {...rec};
                    obj['ApexURL'] = '/lightning/setup/ApexClasses/page?address=/' + obj['Id'];
                    allres.push(obj);
                });
                this.seeAllDataTestClasses = allres;
            }
            else {
                this.isModalOpen = true;
                this.modalTitle = 'Info!';
               this.modalMessage = 'No Test Classes are found with SeeAllData=True.';
            }
        }).catch(error => {
            this.isModalSpinner = false;
            console.log('errror => ', error);
            this.toastmessage('Error', error.message);
        })
    }

    selectedCompareRecords(event) {
        this.selectedCmpRecords = [];
        event.detail.selectedRows.forEach(rec => this.selectedCmpRecords.push(rec));
    }

    selectedTesrResRecords(event) {
        this.selectedTestRecords = [];
        event.detail.selectedRows.forEach(rec => this.selectedTestRecords.push(rec));
    }

    selectedSeeAllCls(event) {
        this.sltdSeeAllDataTestClasses = [];
        event.detail.selectedRows.forEach(rec => this.sltdSeeAllDataTestClasses.push(rec));
    }

    handleRowAction(event) { 
        window.open('/lightning/setup/ApexClasses/page?address=/' + event.detail.row.ApexClassOrTriggerId, '_blank');
    }

    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = [...this.data];
        // Return the value stored in the field
        let keyValue = (a) => {return a[fieldname];};
        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data 
        parseData.sort((x, y) => {
            let xvalue = keyValue(x).includes('%') ? Number(keyValue(x).replace('%', '')) : keyValue(x);
            let yvalue = keyValue(y).includes('%') ? Number(keyValue(y).replace('%', '')) : keyValue(y);

            x = xvalue ? xvalue : ''; // handling null values
            y = yvalue ? yvalue : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        // set the sorted data to data table data
        this.data = [...parseData];
    }

    handleLoadMore() {
        this.pushMoreData();
    }

    pushMoreData() {
        console.log('Invoked pushmore data');
        const offset = this.data.length;
        let additionalData = [];

        for(let i = offset;i <= offset + 20; i++) {
            if(this.allData[i]) {
                additionalData.push(this.allData[i]);
            }
        }

        this.data = [...this.data, ...additionalData];
        if(this.data.length >= this.allData.length){
            this.isLoaded = false;
            this.enableInfiniteLoad = false;
        }
    }

    exportCsvFile(event) {
        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        this.csvString = '';
        if(event.target.title == 'Test Res') {
            // CSV File Name
            downloadElement.download = 'Apex Test Class Results.csv';
            this.createTestResCSV();
        }
        else if(event.target.title == 'CompareBtn') {
            // CSV File Name
            downloadElement.download = 'Code Compare Result.csv';
            this.createCmpareResCSV();
        }
        else if(event.target.title == 'seealldata') {
            // CSV File Name
            downloadElement.download = 'SeeAllData(True) Class.csv';
            this.createSeeAllDataCSV();
        }
        else {
            // CSV File Name
            downloadElement.download = 'Code Coverage Data.csv';
            this.createCSVData();
        }
        
        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(this.csvString);
        downloadElement.target = '_self';
   
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
    }

    createTestResCSV() {
        let rowEnd = '\n';
        let rowData = new Set();
        rowData.add('ApexClassOrTrigger');
        rowData.add('MethodName');
        rowData.add('Message');
        rowData.add('StackTrace');
        rowData = Array.from(rowData);
        this.csvString += rowData.join(',');
        this.csvString += rowEnd;
        for(let i=0; i < this.testResdata.length; i++){
            let colValue = 0;
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    let rowKey = rowData[key];
                    if(colValue > 0){
                        this.csvString += ',';
                    }
                    let value = this.testResdata[i][rowKey] === undefined ? '' : this.testResdata[i][rowKey];
                    this.csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            this.csvString += rowEnd;
        }
        return this.csvString;
    }

    createCmpareResCSV() {
        let rowEnd = '\n';
        let rowData = new Set();
        rowData.add('ApexClassOrTrigger');
        rowData.add('OldPercentage');
        rowData.add('NewPercentage');
        rowData.add('PercentageChange');
        rowData = Array.from(rowData);
        this.csvString += rowData.join(',');
        this.csvString += rowEnd;
        for(let i=0; i < this.csvdata.length; i++){
            let colValue = 0;
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    let rowKey = rowData[key];
                    if(colValue > 0){
                        this.csvString += ',';
                    }
                    let value = this.csvdata[i][rowKey] === undefined ? '' : this.csvdata[i][rowKey];
                    this.csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            this.csvString += rowEnd;
        }
        return this.csvString;
    }

    createSeeAllDataCSV() {
        let rowEnd = '\n';
        let rowData = new Set();
        rowData.add('Name');
        rowData.add('Status');
        rowData = Array.from(rowData);
        this.csvString += rowData.join(',');
        this.csvString += rowEnd;
        for(let i=0; i < this.seeAllDataTestClasses.length; i++){
            let colValue = 0;
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    let rowKey = rowData[key];
                    if(colValue > 0){
                        this.csvString += ',';
                    }
                    let value = this.seeAllDataTestClasses[i][rowKey] === undefined ? '' : this.seeAllDataTestClasses[i][rowKey];
                    this.csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            this.csvString += rowEnd;
        }
        return this.csvString;
    }

    createCSVData() {
        let rowEnd = '\n';
        
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();
        rowData.add('ApexClassOrTrigger');
        rowData.add('PercentageCovered');

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        
        // splitting using ','
        this.csvString += rowData.join(',');
        this.csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < this.allData.length; i++){
            let colValue = 0;

            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        this.csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.allData[i][rowKey] === undefined ? '' : this.allData[i][rowKey];
                    this.csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            this.csvString += rowEnd;
        }

        return this.csvString;
    }

    compareTestData() {
        this.isModalOpen = false;
        this.isCompareModal = false;
        this.isEmailModalOpen = false;
        this.isModalSpinner = true;

        getTestQueueData().then(res => {
            if(res == 'true') {
                this.isModalOpen = true;
                this.isCompareModal = false;
               this.modalTitle = 'Info!';
               this.modalMessage = 'Apex test classes are RUNNING in background, please check after those classes are completed.';
            }
            else {
                this.isModalOpen = false;
                this.readDataFromCSV();
                this.modalTitle = 'Test Code Coverage Compare';
            }

            this.isModalSpinner = false;
        }).catch(error => { 
            console.log('error => ', error);
            this.toastmessage('Error', error.message);
            this.isModalSpinner = false;
        });
    }

    handleCancelModal(event) {
        this.selectedbtn = event.target.title; 
        if(this.selectedbtn == 'TestResBtn') {
            if(this.selectedTestRecords.length == 0) {
                this.toastmessage('Info','Please select atleast one record to sent email');
                return;
            }
        }
        else if(this.selectedbtn == 'CompareBtn') {
            if(this.selectedCmpRecords.length == 0) {
                this.toastmessage('Info','Please select atleast one record to sent email');
                return;
            }
        }
        else if(this.selectedbtn == 'seealldata') {
            if(this.sltdSeeAllDataTestClasses.length == 0) {
                this.toastmessage('Info','Please select atleast one record to sent email');
                return;
            }
        }
        this.isEmailModalOpen = false;
        this.modalEmailTitle = 'Add Emails';
        this.isEmailModalOpen = true;
    }

    handleEmailsChange(event) {
        this.emailsToSend = event.target.value;
    }

    handleEmailClose() {
        this.isEmailModalOpen = false;
    }

    emailsAdded(event) {
        if(!this.emailsToSend) {
            this.toastmessage('Info','Please enter at least one email to sent!');
            return;
        }

        let selectedRecords;
        if(this.selectedbtn == 'TestResBtn') {
            selectedRecords = [...this.selectedTestRecords];
        }
        else if(this.selectedbtn == 'CompareBtn') {
            selectedRecords = [...this.selectedCmpRecords];
        }
        else if(this.selectedbtn == 'seealldata') {
            selectedRecords = [...this.sltdSeeAllDataTestClasses];
        }

        sentEmails({ lstRecords : selectedRecords, toAddress : this.emailsToSend, strType : this.selectedbtn}).then(res => {
            this.toastmessage('success','Email Sent Successfully!!');
            this.emailsToSend = '';
        }).catch(error => { 
            console.log('error => ', error);
            this.toastmessage('Error', error.message);
        })
        this.isEmailModalOpen = false;
        this.isCompareModal = false;
    }

    handleClose() {
        this.isCompareModal = false;
        this.isEmailModalOpen = false;
        this.isTestResModal = false;
        this.isSeeAllModal = false;

        this.selectedCmpRecords = [];
        this.selectedTestRecords = [];
        this.sltdSeeAllDataTestClasses = [];
    }

    readDataFromCSV() {
        readCsvDataFromFile().then(res => {
            this.isCompareModal = true;
            if(res.length > 0) {
                let csvMap = new Map(res.map(i => [i.ApexClassOrTrigger.replaceAll('"', ''), i.PercentageCovered.replaceAll('"', '')]));
                let allCSVMap = new Map(this.allData.map(i => [i.ApexClassOrTrigger.replaceAll('"', ''), i.PercentageCovered.replaceAll('"', '')]));
                let differenceData = [];
                for (const [key, value] of allCSVMap.entries()) {
                    let obj = {};
                    if(csvMap.has(key)) {
                        let percntChange = 0;
                        let oldValue = Number(csvMap.get(key).replace('%', ''));
                        let newvalue = Number(value.replace('%', ''));
                        if((newvalue < oldValue && newvalue < 75)  || oldValue == 0 || newvalue == 0) {
                            obj.ApexClassOrTrigger = key;
                            obj.OldPercentage = oldValue + '%';
                            obj.NewPercentage = newvalue + '%';
                            percntChange = newvalue - oldValue;
                            obj.PercentageChange = percntChange + '%';
                            differenceData.push(obj);
                        }
                    }
                }
                this.csvdata = [...differenceData];
            }else {
                this.isModalOpen = true;
                this.isCompareModal = false;
                this.modalTitle = 'Info!';
                this.modalMessage = 'No Data found to compare.';
            }
        }).catch(error => { 
            console.log('error => ', error);
            this.isCompareModal = false;
            this.toastmessage('Error', error.message);
        })
    }

    handleTestResult() {
        this.isModalOpen = false;
        this.isTestResModal = false;
        this.modalTitle = '';
        this.isModalSpinner = true;
        getApexTestResults().then(res => {
            this.isModalSpinner = false;
            if(res && res != null) {
                let currentData = [];
                this.isTestResModal = true;
                this.modalTitle = 'Apex Test Results';
                res.forEach(rec => {
                    let obj = {};
                    obj.ApexClassOrTrigger = rec.ApexClass.Name;
                    obj.MethodName = rec.MethodName;
                    obj.Message = rec.Message;
                    obj.StackTrace = rec.StackTrace;
                    currentData.push(obj);
                });

                this.testResdata = currentData;
            }
            else {
                this.isModalOpen = true;
                this.modalTitle = 'Info!';
               this.modalMessage = 'No Test Classes are Failed.';
            }
        }).catch(error => {
            this.isTestResModal = false; 
            console.log('error => ', error);
            this.toastmessage('Error', error.message);
        });

    }

    runTestClasses() {
        this.isSpinner = true;
        runAllTestClasses().then(res => {
            this.isSpinner = false;
            if(res == 'Success') {
                this.toastmessage('SUCCESS', 'Test Classes run successfully, Please check apex test execution page.');
            }
            else {
                this.toastmessage('ERROR', res);
            }
        }).catch(error => {
            this.isSpinner = false;
              this.toastmessage('ERROR', JSON.stringify(error));
              console.log('error => ', error);
        })
    }

    toastmessage(varient, message) {
        const event = new ShowToastEvent({
            title: varient,
            message: message,
            variant: varient,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}