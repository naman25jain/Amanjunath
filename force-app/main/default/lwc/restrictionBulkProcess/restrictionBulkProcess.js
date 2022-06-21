import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { reduceErrors } from 'c/lwcUtilities';
import searchRecords from '@salesforce/apex/RestrictionBulkProcessController.SearchRecords';
import getDataFromReport from '@salesforce/apex/RestrictionBulkProcessController.getDataFromReport';
import getExstingRowsData from '@salesforce/apex/RestrictionBulkProcessController.getExstingRowsData';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

export default class RestrictionBulkProcess extends LightningElement {
    @api records;
    @api recordId;
    showFilter = false;
    columns = [];
    selectedValue;
    enableTable = false;
    @api isBulkProcessReady = false;
    isBtnDisabled = false;

    contactPreSelectedArray = [];
    accountPreSelectedArray = [];
    reportId;
    isAccounts = false;
    isContacts = false;
    isSpinner = false;
    searchInput = '';
    @api hasRendered = false;

    get options() {
        return [
            { label: 'Account', value: 'Account' },
            { label: 'Contact', value: 'Contact' },
        ];
    }

    @wire(getRecord, { recordId: '$recordId', fields: ['Restriction_Request__c.Name', 'Restriction_Request__c.Entity_ID_List__c', 'Restriction_Request__c.Applicant_ID_List__c', 'Restriction_Request__c.RestrictionStatus__c', 'Restriction_Request__c.Restriction_Level__c'] })
    resReqRecord;

    openRecord(event) {
        window.open(
            '/' + event.currentTarget.dataset.id,
            '_blank'
        );
    }

    handleInputSearch(event) {
        this.searchInput = event.target.value;
    }

    async connectedCallback() {
        await this.recordId;
        await this.resReqRecord;
        this.isSpinner = true;
        setTimeout(() => {
            if (this.resReqRecord && this.resReqRecord.data && this.resReqRecord.data.fields && this.resReqRecord.data.fields.Restriction_Level__c !== null) {
                if (this.resReqRecord.data.fields.Restriction_Level__c.value === 'Entity') {
                    this.selectedValue = 'Account';
                } else if (this.resReqRecord.data.fields.Restriction_Level__c.value === 'Applicant') {
                    this.selectedValue = 'Contact';
                }
            }
            this.getOnloadData();
            if (this.recordId && this.resReqRecord && this.resReqRecord.data && this.resReqRecord.data.fields && this.resReqRecord.data.fields.RestrictionStatus__c && this.resReqRecord.data.fields.RestrictionStatus__c.value == 'Draft') {
                this.isBulkProcessReady = true;
            }
            else {
                this.isBulkProcessReady = false;
            }
        }, 1000);
    }


    getOnloadData() {
        getExstingRowsData({ strRecordId: this.recordId })
            .then(result => {
                this.columns = [];
                if (result) {
                    if (result.accountRecords) {
                        result.accountRecords.forEach(val => {
                            val.checked = true;
                        });
                        this.accountPreSelectedArray = result.accountRecords;
                    }

                    if (result.contactRecords) {
                        result.contactRecords.forEach(val => {
                            val.checked = true;
                        });

                        this.contactPreSelectedArray = result.contactRecords;
                    }
                }

                if (result.accountRecords && this.selectedValue && this.selectedValue == 'Account') {
                    this.records = result.accountRecords;
                    this.enableTable = true;
                    this.isAccounts = true;
                    this.isContacts = false;
                }
                else if (result.contactRecords && this.selectedValue == 'Contact') {
                    this.records = result.contactRecords;
                    this.enableTable = true;
                    this.isAccounts = false;
                    this.isContacts = true;
                }
                this.isSpinner = false;
            })
            .catch(error => {
                this.showToastMessage('error', (reduceErrors(error) ? reduceErrors(error)[0] : ''), 'Error!');
                //this.processErrorMessage(error);
                this.isSpinner = false;
            })
    }

    getSelectedRow(event) {
        if (this.selectedValue === 'Account') {
            let accMap;
            if (this.accountPreSelectedArray) {
                accMap = new Map(this.accountPreSelectedArray.map(obj => [obj.Id, obj]));
            }
            else {
                accMap = new Map();
            }

            let selectedRows = [];
            selectedRows = this.records.filter((ele) => {
                if (ele.Id == event.currentTarget.dataset.id) {
                    if (accMap.has(ele.Id) && accMap.get(ele.Id).checked && !event.target.checked) {
                        accMap.delete(ele.Id);
                    }
                    if (event.target.checked) {
                        ele.checked = true;
                        return ele;
                    }
                }
            });

            if (this.accountPreSelectedArray) {
                this.accountPreSelectedArray = accMap.values();
            }

            this.accountPreSelectedArray = [...this.accountPreSelectedArray, ...selectedRows];

        } else if (this.selectedValue === 'Contact') {
            let conMap;
            if (this.contactPreSelectedArray) {
                conMap = new Map(this.contactPreSelectedArray.map(obj => [obj.Id, obj]));
            }
            else {
                conMap = new Map();
            }

            let selectedRows = [];
            selectedRows = this.records.filter((ele) => {
                if (ele.Id == event.currentTarget.dataset.id) {
                    if (conMap.has(ele.Id) && conMap.get(ele.Id).checked && !event.target.checked) {
                        conMap.delete(ele.Id);
                    }
                    if (event.target.checked) {
                        ele.checked = true;
                        return ele;
                    }
                }
            });

            if (this.contactPreSelectedArray) {
                this.contactPreSelectedArray = conMap.values();
            }

            this.contactPreSelectedArray = [...this.contactPreSelectedArray, ...selectedRows];
        }
    }

    handleKeyUp(event) {
        if (this.searchInput) {
            this.isSpinner = true;
            searchRecords({ keyWord: this.searchInput, strObjName: this.selectedValue })
                .then(result => {
                    console.log('result => ', result);
                    if (this.selectedValue === 'Account') {
                        if (this.accountPreSelectedArray) {
                            this.accountPreSelectedArray.forEach(rec => {
                                result.accountRecords.forEach(val => {
                                    if (rec.Id == val.Id && rec.checked) {
                                        val.checked = true;
                                        return;
                                    }
                                })
                            })
                        }

                        this.records = result.accountRecords;
                        this.enableTable = true;
                        this.isAccounts = true;
                        this.isContacts = false;
                    }
                    else if (this.selectedValue === 'Contact') {
                        if (this.contactPreSelectedArray) {
                            this.contactPreSelectedArray.forEach(rec => {
                                result.contactRecords.forEach(val => {
                                    if (rec.Id == val.Id && rec.checked) {
                                        val.checked = true;
                                        return;
                                    }
                                })
                            })
                        }
                        this.records = result.contactRecords;
                        this.enableTable = true;
                        this.isAccounts = false;
                        this.isContacts = true;
                    }

                    this.isSpinner = false;
                })
                .catch(error => {
                    console.log('error => ', error);
                    this.showToastMessage('error', (reduceErrors(error) ? reduceErrors(error)[0] : ''), 'Error!');
                    //this.processErrorMessage(error);
                    this.isSpinner = false;
                })
        }
        else {
            this.showToastMessage('info', 'Please enter the keyword to search.', 'INFO');
        }
    }

    handleAccountContactSelect(event) {
        this.selectedValue = event.target.value;
        this.enableTable = false;
        // this.template.querySelector('.searchinput').value = '';
        // this.searchInput = '';
        if (this.selectedValue === 'Contact') {
            this.records = this.contactPreSelectedArray;
            this.isAccounts = false;
            this.isContacts = true;
            this.enableTable = true;
        }
        else if (this.selectedValue === 'Account') {
            this.records = this.accountPreSelectedArray;
            this.isAccounts = true;
            this.isContacts = false;
            this.enableTable = true;
        }
    }

    handleShowFilter(event) {
        this.showFilter = event.target.checked ? true : false;
    }

    handleReprId(event) {
        this.reportId = event.target.value;
    }

    async handleRunReport() {
        if (this.showFilter) {
            if (!this.reportId) {
                this.processErrorMessage('Please enter valid report Id to process.');
                return;
            }
            this.isSpinner = true;
            getDataFromReport({ strReportId: this.reportId, restrictionLevel: this.selectedValue })
                .then(result => {
                    if (result) {
                        let accountValues = [];
                        let contactValues = [];
                        if (result.accountRecords) {
                            result.accountRecords.forEach(val => {
                                accountValues.push(val.Id);
                                accountValues = [...new Set(accountValues)];
                            });
                        }

                        if (result.contactRecords) {
                            result.contactRecords.forEach(val => {
                                contactValues.push(val.Id);
                                contactValues = [...new Set(contactValues)];
                            });
                        }

                        if (this.resReqRecord.data.fields.Entity_ID_List__c.value) {
                            this.resReqRecord.data.fields.Entity_ID_List__c.value.slice(1, -1).split(',').forEach(val => {
                                accountValues.push(val.replace(/['"]+/g, ''));
                            });
                        }


                        if (this.resReqRecord.data.fields.Applicant_ID_List__c.value && this.resReqRecord.data.fields.Applicant_ID_List__c.value != '[]') {
                            this.resReqRecord.data.fields.Applicant_ID_List__c.value.slice(1, -1).split(',').forEach(val => {
                                contactValues.push(val.replace(/['"]+/g, ''));
                            });
                        }

                        accountValues = [...new Set(accountValues)];
                        contactValues = [...new Set(contactValues)];

                        const fields = {};
                        fields['Id'] = this.recordId;
                        fields['Applicant_ID_List__c'] = (contactValues.length > 0 ? JSON.stringify(contactValues) : '');
                        fields['Entity_ID_List__c'] = (accountValues.length > 0 ? JSON.stringify(accountValues) : '');

                        this.updateResReqRecord(fields);
                        this.isSpinner = false;
                    }
                })
                .catch(error => {
                    this.isSpinner = false;
                    this.showToastMessage('error', (reduceErrors(error) ? reduceErrors(error)[0] : ''), 'Error!');
                    //this.processErrorMessage(error);
                })
        }
        else {

            let consIds = [];
            let accsIds = [];
            if (this.contactPreSelectedArray) {
                this.contactPreSelectedArray.forEach(val => {
                    consIds.push(val.Id)
                })
            }

            if (this.accountPreSelectedArray) {
                this.accountPreSelectedArray.forEach(val => {
                    accsIds.push(val.Id)
                })
            }

            const fields = {};
            fields['Id'] = this.recordId;
            fields['Applicant_ID_List__c'] = (consIds.length > 0 ? JSON.stringify(consIds) : '');
            fields['Entity_ID_List__c'] = (accsIds.length > 0 ? JSON.stringify(accsIds) : '');
            this.isSpinner = true;
            this.updateResReqRecord(fields);
            this.isSpinner = false;
        }

    }

    updateResReqRecord(fields) {
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.showToastMessage('success', 'Entities/Applicants are successfully added/removed!!', 'SUCCESS');
                this.closeAction();
                // Display fresh data in the form
                return refreshApex(this.resReqRecord);
            })
            .catch(error => {
                this.showToastMessage('error', (reduceErrors(error) ? reduceErrors(error)[0] : ''), 'Error!');
               // this.processErrorMessage(error);
                this.closeAction();
            })
    }

    processErrorMessage(message) {
        let errorMsg = '';
        if (message) {
            if (message.body) {
                if (Array.isArray(message.body)) {
                    errorMsg = message.body.map(e => e.message).join(', ');
                } else if (typeof message.body.message === 'string') {
                    errorMsg = message.body.message;
                }
            }
            else {
                errorMsg = message;
            }
        }
        this.showToastMessage('error', errorMsg, 'Error!');
    }

    showToastMessage(variant, message, title) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    // renderedCallback() {
    //     if (!this.isBulkProcessReady) {
    //         return;
    //     }
    //     this.isBulkProcessReady = true;
    //     refreshApex(this.resReqRecord);
    //     console.log('Rendered callback invoked');
    // }
}