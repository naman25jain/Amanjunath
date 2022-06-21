import { LightningElement,track,api } from 'lwc';
import getMyOrganizations from '@salesforce/apex/MyOrganizationsEntityListViewController.getMyOrganizations';
import getMyCases from '@salesforce/apex/MyOrganizationsEntityListViewController.getMyCases';
import Id from '@salesforce/user/Id';
import getContact from '@salesforce/apex/MyOrganizationsEntityListViewController.getContact';
export default class MyOrganizationsEntityListView extends LightningElement {
    userId=Id;    
    @track myOrgColumns = [{    
        label: 'Name',
        fieldName: 'orgName',        
        type: 'button',
        initialWidth: 300,
        sortable: true,
        typeAttributes: {
            title: 'Name',
            variant: 'border-filled',
            disabled: false,
            class:'recordTd',
            wrapText: true,  
            label: {fieldName: 'orgName'}          
        }      
    },
    {        
        label: 'Country',
        fieldName: 'orgCountry',
        initialWidth: 300,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Address',
        fieldName: 'orgAddress',
        initialWidth: 300,
        sortable: true,
        typeAttributes: {      
            wrapText: true
        }
    },
    {        
        label: 'Last Modified',
        fieldName: 'orgLastModifiedDate',
        initialWidth: 300,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },    
];  
@track myCasesColumns = [{    
    label: 'Case Number',
    fieldName: 'caseNumber',        
    type: 'button',
    initialWidth: 200,
    sortable: true,
    typeAttributes: {
        title: 'caseNumber',
        variant: 'border-filled',
        disabled: false,
        class:'recordTd',
        wrapText: true,  
        label: {fieldName: 'caseNumber'},
        target:'_self'          
    }      
},
{        
    label: 'Type',
    fieldName: 'caseType',
    initialWidth: 250,
    sortable: true,
    typeAttributes: {            
        wrapText: true
    }
},
{        
    label: 'Account Name',
    fieldName: 'caseEntityName',
    initialWidth: 250,
    sortable: true,
    typeAttributes: {            
        wrapText: true
    }
},
{        
    label: 'Case Status',
    fieldName: 'caseStatus',
    initialWidth: 250,
    sortable: true,
    typeAttributes: {            
        wrapText: true
    }
},
{        
    label: 'Date Opened',
    fieldName: 'caseDateOpened',
    initialWidth: 200,
    sortable: true,
    typeAttributes: {            
        wrapText: true
    }
}, 
{        
    label: 'Last Modified Date',
    fieldName: 'caseLastModifiedDate',
    initialWidth: 200,
    sortable: true,
    typeAttributes: {            
        wrapText: true
    }
}   
];
      
@track data = [];
@track dataMyCases = [];
@track defaultSortDirection = 'asc';
@track sortDirection = 'asc';
@track sortedBy;
@track defaultSortDirectionMyCases = 'asc';
@track sortDirectionMyCases = 'asc';
@track sortedByMyCases;
@track isMyOrgsFound = false;
@track isMyCasesFound = false;
@track myOrganizations = [];
@track recordsToDisplayMyOrg = [];
@track recordsToDisplayMyCases = [];
@track rowNumberOffset;
@track myCases = [];
@track rowNumberOffsetMyCases;  
@track attributesList = [];
    connectedCallback(){
        this.setup();
    }
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
            var x = key(a) ? key(a).toLowerCase() : '';
            var y = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((x > y) - (y > x));
        };
    }
    onHandleSort(event){
        const {
            fieldName: sortedBy,
            sortDirection
        } = event.detail;
        const cloneData = [...this.recordsToDisplayMyOrg];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.recordsToDisplayMyOrg = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    onHandleSortMyCases(event){
        const {
            fieldName: sortedByMyCases,
            sortDirection
        } = event.detail;
        const clonedataMyCases = [...this.recordsToDisplayMyCases];
        clonedataMyCases.sort(this.sortBy(sortedByMyCases, sortDirection === 'asc' ? 1 : -1));
        this.recordsToDisplayMyCases = clonedataMyCases;
        this.sortDirectionMyCases = sortDirection;
        this.sortedByMyCases = sortedByMyCases;
    }   
    @api setup(){
        this.sortDirection = '';
        this.sortedBy = '';
        this.sortDirectionMyCases = '';
        this.sortedByMyCases = '';
        // My Organizations
        this.data = [];
        this.recordsToDisplayMyOrg = [];
        this.myOrganizations = [];
        this.isMyOrgsFound = false;        
        //My Organizations
        getContact({
            userId: this.userId
        }).then(conResult => {               
        getMyOrganizations({ currentEntityContactId:conResult }).then(orgData => {
            if (orgData){
                let rowNum = 0;
                for (let key in orgData){
                    if (orgData.hasOwnProperty(key)){
                        this.isMyOrgsFound = true;
						this.isExptDataAvailable = true;
                        let tempRecord = {
                            conId: orgData[key]['conId'],
                            entityId: orgData[key]['entityId'],
                            orgName:orgData[key]['orgName'],
                            orgCountry:orgData[key]['orgCountry'],
                            orgAddress:orgData[key]['orgAddress'],
                            orgLastModifiedDate:orgData[key]['orgLastModifiedDate']                                       
                        };
                        tempRecord.rowNumber = '' + (rowNum + 1);
                        if (this.data.length > 0){
                            this.data = [...this.data, tempRecord];
                        }else{
                            this.data = [tempRecord];
                        }
                        this.attributesList = ['conId'];
                    }
                    rowNum = rowNum + 1;
                }
                this.myOrganizations = this.data;
                if(this.template.querySelector('.paginatorAR') !== null){
                    this.template.querySelector('.paginatorAR').records = this.myOrganizations;
                    this.template.querySelector('.paginatorAR').totalRecords = this.myOrganizations.length;
                    this.template.querySelector('.paginatorAR').setRecordsPerPage();
                }
            }
        })
        .catch(error => {
            window.console.error('get Error: ' + JSON.stringify(error));
        }); 
        //My Cases
        this.dataMyCases = [];
        this.myCases = [];
        this.recordsToDisplayMyCases = [];
        this.isMyCasesFound = false;
        getMyCases({currentEntityContactId:conResult}).then(caseData => {
            if (caseData){
                let rowNumMyCases = 0;
                for (let key in caseData){
                    if (caseData.hasOwnProperty(key)){
                        this.isMyCasesFound = true;
						this.isExptDataAvailable = true;
                        let tempRecord = {
                            caseId: caseData[key]['caseId'],
                            conId: caseData[key]['conId'],
                            caseNumber: caseData[key]['caseNumber'],
                            caseType: caseData[key]['caseType'],
                            caseEntityName: caseData[key]['caseEntityName'],
                            caseStatus: caseData[key]['caseStatus'],
                            caseDateOpened: caseData[key]['caseDateOpened'],
                            caseLastModifiedDate: caseData[key]['caseLastModifiedDate']                            
                        };
                        tempRecord.rowNumber = '' + (rowNumMyCases + 1);
                        if (this.dataMyCases.length > 0){
                            this.dataMyCases = [...this.dataMyCases, tempRecord];
                        }else{
                            this.dataMyCases = [tempRecord];
                        }
                        this.attributesList = ['caseId'];                  
                    }
                    rowNumMyCases = rowNumMyCases + 1;
                }
                this.myCases = this.dataMyCases;
                if (this.template.querySelector('.paginatorCR') !== null){
                    this.template.querySelector('.paginatorCR').records = this.myCases;
                    this.template.querySelector('.paginatorCR').totalRecords = this.myCases.length;
                    this.template.querySelector('.paginatorCR').setRecordsPerPage();
                }
            }
        })
        .catch(error => {
            window.console.error('get Error: ' + JSON.stringify(error));
        });    
        })      
    }              
    viewCaseRecord(event){        
        let row = event.detail.row;
        let caseId = row.caseId;        
        const action = event.detail.action;
        this.showCaseDetail(caseId);        
    }
	viewEntityRecord(event){    
        let row = event.detail.row;
        let entityId = row.entityId;
        this.showEntityDetail(entityId);
    }
    showEntityDetail(entityId){        
        let baseURL = window.location.origin;
        baseURL += '/entity360/s/account/' + entityId;
        window.open(baseURL,"_self");        
    }
    showCaseDetail(caseId){        
        let baseURL = window.location.origin;
        baseURL += '/entity360/s/case/' + caseId;
        window.open(baseURL,"_self");        
    }
    handleMyOrgPaginatorChange(event){
        this.recordsToDisplayMyOrg = event.detail;
        if (this.recordsToDisplayMyOrg.length > 0){
            this.rowNumberOffset = this.recordsToDisplayMyOrg[0].rowNumber - 1;
        }
    }
    handleMyCasesPaginatorChange(event){
        this.recordsToDisplayMyCases = event.detail;
        if (this.recordsToDisplayMyCases.length > 0){
            this.rowNumberOffsetMyCases = this.recordsToDisplayMyCases[0].rowNumber - 1;
        }
    }       
}