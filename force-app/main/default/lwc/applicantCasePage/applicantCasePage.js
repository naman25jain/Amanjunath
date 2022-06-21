import { LightningElement,track } from 'lwc';
//import required apex methods

import getApplicantCaseData from '@salesforce/apex/ApplicantCaseRecord.getApplicantRequestData';

const column = [
    {
    label: 'Case Number',
    fieldName: 'nameUrl',
    sortable: true,
    type: "url",  
    typeAttributes: { label: { fieldName: 'caseNumber' }, target: '_self' }  
   },
   {
    label: 'Case Type',
    fieldName: 'recType',
    sortable: true   
   },
{
    label: 'Case Status',
    fieldName: 'caseStatus',
    sortable: true
},
{
    label: 'Date Opened',
    fieldName: 'createdDate',
    sortable: true
},
{
    label: 'Last Modified Date',
    fieldName: 'modifiedDate',
    sortable: true
},
{
    label: 'Action Required',
   fieldName: 'iconUrl',
    sortable: true,
    type: 'url',
    typeAttributes: { label: { fieldName: 'actionReqd' }, target: '_self', class: {fieldName: 'classVal'}}  
    //typeAttributes: {linkify: true}  
},
{
    label: 'Restriction Applied',
    fieldName: 'restricted',
    sortable: true
}

];

export default class applicantCasePage extends LightningElement{    
        @track columns = column;
        @track data = [];
        @track defaultSortDirection = 'asc';
        @track sortDirection = 'asc';
        @track sortedBy;
        @track isCaseReqFound = false;     
        // Used to sort the columns
        sortBy(field, reverse, primer){
            const key = primer ?
                function (x) {
                    return primer(x[field]);
                } :
                function (x) {
                    return x[field];
                };    
                if(field === "actionReqd"){    
                    return function (a, b) {
                        a = key(a) ? key(a).toLowerCase() : '';
                        b = key(b) ? key(b).toLowerCase() : '';
                        return reverse * ((a > b) - (b > a));
                    };
                }
                else{
                    return function (a, b) {
                        a = key(a)?key(a):'';
                        b = key(b)?key(b):'';
                        return reverse * ((a > b) - (b > a));
                    };
                }
        }    
        onHandleSort(event){
            const {
                fieldName: sortedBy,
                sortDirection
            } = event.detail;
            const cloneData = [...this.data];
    
            if(sortedBy === 'iconUrl'){
                cloneData.sort(this.sortBy('actionReqd', sortDirection === 'asc' ? 1 : -1));        
            }
            else{
                cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));    
            }
            this.data = cloneData;
            this.sortDirection = sortDirection;
            this.sortedBy = sortedBy;
        }
       connectedCallback(){
            this.setup();
        }        
        setup(){
            this.data = [];
            this.isCaseReqFound = false;
            getApplicantCaseData().then(prData => {
                if (prData) {
                    for (let key in prData) {
                        if (prData.hasOwnProperty(key)) {
                            this.isCaseReqFound = true;
                            let tempRecord = {
                                caseId:prData[key]['caseId'],
                                nameUrl:prData[key]['nameUrl'],
                                caseNumber:prData[key]['caseNumber'],
                                recType: prData[key]['recType'],
                                caseStatus: prData[key]['caseStatus'],
                                modifiedDate: prData[key]['modifiedDate'],
                                createdDate:  prData[key]['createdDate'],
                                actionReqd: prData[key]['actionReqd'],
                                restricted: prData[key]['restricted']
                            };
                            if(tempRecord.restricted == 'Yes'){
                                tempRecord.iconUrl = 'javascript: void(0)';
                            }
                            else if(tempRecord.actionReqd == 'Yes'){
                                tempRecord.iconUrl = prData[key]['iconUrl'];    
                            }
                            else if(tempRecord.actionReqd == 'No'){
                                //tempRecord.iconUrl = ' ';
                                tempRecord.iconUrl = 'javascript: void(0)';
                            }
                            else if(tempRecord.actionReqd != undefined){
                                tempRecord.iconUrl = prData[key]['iconUrl'];
                            }
                            else{
                                tempRecord.iconUrl = null;
                            }
                            if (this.data.length > 0) {
                                this.data = [...this.data, tempRecord];
                            } else {
                                this.data = [tempRecord];
                            }
                        }
                    }
                }
            })
            .catch(error => {
                window.console.log('get Error: ' + JSON.stringify(error));
            })
        }
        handleRowActions(event){    
            let row = event.detail.row;
            let caseId = row.caseId;
            this.showDetail(caseId);
        }
        showDetail(caseId){            
            let caseInfo    =   {caseId:caseId};
            const selectEvent = new CustomEvent("nextevent", {
                detail:caseInfo
            });
            this.dispatchEvent(selectEvent);
        }
    }