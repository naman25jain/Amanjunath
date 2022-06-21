import { LightningElement,track,api } from 'lwc';
//import required apex methods

import getEntityRequestData from '@salesforce/apex/EntityCaseManageRequest.getEntityRequestData';
import getEntityCompletedRequestData from '@salesforce/apex/EntityCaseManageRequest.getEntityCompletedRequestData';

const columnsCom = [
    {
        label: 'Case Number',
        type: 'button',
        sortable: true,
        fieldName: 'casenumber',
        typeAttributes: {
            title: 'Case Number',
            variant: 'border-filled',
            disabled: false,
            class:'caseNumberTd',
            label: { fieldName: 'casenumber' },
            name: { fieldName: 'caseId' },
        }
    },
    {
        label: 'Contact',
        fieldName: 'contact',
        sortable: true 
    },
    {
        label: 'Subject',
        fieldName: 'subject',
        sortable: true
    },
    {
        label: 'Status',
        fieldName: 'status',
        sortable: true
    },
    {
        label: 'Priority',
        fieldName: 'priority',
        sortable: true
    },
    {
        label: 'DateTime Opened',
        fieldName: 'createddate',
        sortable: true
    },
    {
        label: 'Owner Name',
        fieldName: 'owner',
        sortable: true
    }
];

const columns = [
    {
        label: 'Case Number',
        type: 'button',
        sortable: true,
        fieldName: 'casenumber',
        typeAttributes: {
            title: 'Case Number',
            variant: 'border-filled',
            disabled: false,
            class:'caseNumberTd',
            label: { fieldName: 'casenumber' },
            name: { fieldName: 'caseId' },
        }
    },
    {
        label: 'Contact',
        fieldName: 'contact',
        sortable: true
    },
    {
        label: 'Subject',
        fieldName: 'subject',
        sortable: true
    },
    {
        label: 'Status',
        fieldName: 'status',
        sortable: true
    },
    {
        label: 'Priority',
        fieldName: 'priority',
        sortable: true
    },
    {
        label: 'DateTime Opened',
        fieldName: 'createddate',
        sortable: true
    },
    {
        label: 'Owner Name',
        fieldName: 'owner',
        sortable: true
    }
];
export default class EntityCaseManageRequest extends LightningElement {
    
        @track data = [];
        @track dataCom = [];
        @track columns = columns;
        @track columnsCom = columnsCom;
        @track defaultSortDirection = 'asc';
        @track sortDirection = 'asc';
        @track sortedBy;

        @track defaultSortDirectionCom = 'asc';
        @track sortDirectionCom = 'asc';
        @track sortedByCom;

        @track isActiveReqFound = false;
        @track isCompletedReqFound = false;

        @track activeRequests = [];
        @track recordsToDisplay = [];
        @track rowNumberOffset;

        @track completedRequests = [];
        @track recordsToDisplayCom = [];
        @track rowNumberOffsetCom;
        // Used to sort the columns
        sortBy(field, reverse, primer) {
            const key = primer ?
                function (x) {
                    return primer(x[field]);
                } :
                function (x) {
                    return x[field];
                };
    
            return function (a, b) {
                var a = key(a) ? key(a).toLowerCase() : '';
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a > b) - (b > a));
            };
        }
    
        onHandleSort(event) {
            const {
                fieldName: sortedBy,
                sortDirection
            } = event.detail;
            const cloneData = [...this.recordsToDisplay];

            cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
            this.recordsToDisplay = cloneData;
            this.sortDirection = sortDirection;
            this.sortedBy = sortedBy;
        }

        onHandleSortCompleted(event) {
            const {
                fieldName: sortedByCom,
                sortDirection
            } = event.detail;
            const cloneDataCom = [...this.recordsToDisplayCom];

            cloneDataCom.sort(this.sortBy(sortedByCom, sortDirection === 'asc' ? 1 : -1));
            this.recordsToDisplayCom = cloneDataCom;
            this.sortDirectionCom = sortDirection;
            this.sortedByCom = sortedByCom;
        }

        @api
            get currentEntity() {
            return this._currentEnt;
            }
            set currentEntity(value) {
            this.setAttribute('currentEntity', value);
            this._currentEnt = value;
            this.setup();
        }
        @track _currentEnt;
        setup() {
            this.sortDirection = '';
            this.sortedBy = '';
            this.sortDirectionCom = '';
            this.sortedByCom = '';
            this.data = [];
            this.activeRequests = [];
            this.recordsToDisplay = [];
            this.isActiveReqFound = false;
            getEntityRequestData({currentEntityId : this._currentEnt}).then(prData => {
                if (prData) {
                    let rowNum = 0;
                    for (let key in prData) {
                        if (prData.hasOwnProperty(key)) {
                            this.isActiveReqFound = true;
                            let tempRecord = {
                                caseId:prData[key]['caseId'],
                                casenumber:prData[key]['name'],
                                nameUrl:prData[key]['nameUrl'],
                                contact: prData[key]['Contact.Name'],
                                subject: prData[key]['Subject'],
                                status: prData[key]['Status'],
                                priority:  prData[key]['Priority'],
                                createddate:  prData[key]['CreatedDate'],
                                owner:  prData[key]['Owner.Name'],
                                }
                            
                            tempRecord.rowNumber = '' + (rowNum + 1);
                            if (this.data.length > 0) {
                                this.data = [...this.data, tempRecord];
                            } else {
                                this.data = [tempRecord];
                            }
                        }
                        rowNum = rowNum + 1;
                    }
                    this.activeRequests = this.data;
                    if (this.template.querySelector('.paginatorAR') !== null) {
                        this.template.querySelector('.paginatorAR').records = this.activeRequests;
                        this.template.querySelector('.paginatorAR').totalRecords = this.activeRequests.length;
                        this.template.querySelector('.paginatorAR').setRecordsPerPage();
                    }
                }
            })
            .catch(error => {
                window.console.log('get Error: ' + JSON.stringify(error));
            })

            this.dataCom = [];
            this.completedRequests = [];
            this.recordsToDisplayCom = [];
            this.isCompletedReqFound = false;
            getEntityCompletedRequestData({currentEntityId : this._currentEnt}).then(prData => {
                         if (prData) {
                            let rowNumCom = 0;
                             for (let key in prData) {
                                 if (prData.hasOwnProperty(key)) {
                                    this.isCompletedReqFound = true;
                                     let tempRecord = {
                                         caseId:prData[key]['caseId'],
                                         casenumber: prData[key]['CaseNumber'],
                                         contact: prData[key]['Contact.Name'],
                                         subject: prData[key]['Subject'],
                                         status: prData[key]['Status'],
                                         priority:  prData[key]['Priority'],
                                         createddate:  prData[key]['CreatedDate'],
                                         owner:  prData[key]['Owner.Name'],
                                         }
         
                                     tempRecord.rowNumber = '' + (rowNumCom + 1);
                                     if (this.dataCom.length > 0) {
                                         this.dataCom = [...this.dataCom, tempRecord];
                                     } else {
                                         this.dataCom = [tempRecord];
                                     }
                                     rowNumCom = rowNumCom + 1;
                                 }
                             }
                             this.completedRequests = this.dataCom;
                            if (this.template.querySelector('.paginatorCR') !== null) {
                                this.template.querySelector('.paginatorCR').records = this.completedRequests;
                                this.template.querySelector('.paginatorCR').totalRecords = this.completedRequests.length;
                                this.template.querySelector('.paginatorCR').setRecordsPerPage();
                            }
                         }
                     })
                     .catch(error => {
                         window.console.log('get Error: ' + JSON.stringify(error));
                     })
        }
        @api refreshSetup(){
            this.setup();
        }

        handleRowActions(event) {    
            let row = event.detail.row;
            let caseId = row.caseId;
            this.showDetail(caseId);
        }
        showDetail(caseId) {            
            let caseInfo    =   {caseId:caseId};
            const selectEvent = new CustomEvent("nextevent", {
                detail:caseInfo
            });
            this.dispatchEvent(selectEvent);
        }

        handleARPaginatorChange(event) {
            this.recordsToDisplay = event.detail;
            if (this.recordsToDisplay.length > 0) {
                this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
            }
        }

        handleCRPaginatorChange(event) {
            this.recordsToDisplayCom = event.detail;
            if (this.recordsToDisplayCom.length > 0) {
                this.rowNumberOffsetCom = this.recordsToDisplayCom[0].rowNumber - 1;
            }
        }
    }