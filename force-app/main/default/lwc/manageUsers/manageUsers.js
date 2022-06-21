import { LightningElement ,wire,track,api } from 'lwc';
import getAllRecs from '@salesforce/apex/ManageUsersController.getRecs';
import revealButton from '@salesforce/apex/ManageUsersController.revealButton';
import deactivateUser from '@salesforce/apex/ManageUsersController.deactivateUser';    
import manageUsersLabel from '@salesforce/label/c.E360_Manage_User';
import deactivateLabel from '@salesforce/label/c.E360_Deactivate_Modal';
import { refreshApex } from '@salesforce/apex';
export default class ManageUsers extends LightningElement {
    label={
        manageUsersLabel,
        deactivateLabel
    };
    @track columns = [{
        label: 'User Name',
        fieldName: 'userName',
        type: 'text',
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: 'Job Title',
        fieldName: 'jobTitle',
        type: 'text',
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: 'Service',
        fieldName: 'serviceName',
        type: 'text',
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: 'Role',
        fieldName: 'role',
        type: 'text',
        sortable: true,
        hideDefaultActions: true
    },
    {
        type: 'button',
        sortable: true,
        hideDefaultActions: true,
        typeAttributes:{
            label: 'Deactivate Service',
            title: 'Deactivate Service',
            name: 'deactivateService',
            value: 'deactivateService',
            variant: 'brand',
            disabled: {fieldName: 'isVisible'},
            class: {fieldName: 'className'}
        }
    }];
    @track error;
    @track dataRec=[];
    @track record;
    @track showModal = false;
    @track currentRecordId;
    @track toAddServiceClicked = false;
    @track toAddUserClicked = false;
    @track boolVal = false;
    @track spinner = false;
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy = 'userName';
    @track dataRecClone = [];
    @track showPaginator = false;
    @track showTable = false;
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
    @track attributesList = [];
    _currentEnt;
    @api
    get currentEntity() {
    return this._currentEnt;
    }
    set currentEntity(value) {
        this.setAttribute('currentEntity', value);
        this._currentEnt = value;
        refreshApex(this._getWiredRecordResponse);
    }
    wiredResults;
    @wire(getAllRecs,{currentEntityId : '$_currentEnt'})
    wiredOpps(resultRecords) {
        this.wiredResults = resultRecords;
        if(resultRecords.data) {
            this.dataRec = resultRecords.data;
            this.dataRecClone = this.dataRec;
            this.attributesList = ['idVal'];
            if(this.dataRec.length > 0) {
                this.showPaginator = true;
                this.showTable = true;
            } else {
                this.showPaginator = false;
                this.showTable = false;
            }
        }
    }
    @track recordsList;    
    @track wiredShowButtons;    
    _getWiredRecordResponse;   
    @wire(revealButton,{currentEntityId : '$_currentEnt'}) showButtons(result){
        this._getWiredRecordResponse = result;
        
        if(this._getWiredRecordResponse.data === 'Coordinator'){
            this.wiredShowButtons = true;
        }
        else{
            this.wiredShowButtons = false;
        }
    }    
    handleRowActions(event) {
        let actionName = event.detail.action.name;
        let row = event.detail.row;
        if(actionName == 'deactivateService'){
            this.deactivateUser(row);
        }
    }
    @api
    refreshDataOnTabSwitch(){
        refreshApex(this.wiredResults);
        this.dataRec = this.wiredResults.data;
        this.template.querySelector('lightning-datatable').sortedBy = 'userName';
        this.template.querySelector('lightning-datatable').sortDirection = 'asc';
	    this.template.querySelector('c-paginator').setRecordsPerPage();
    }
    deactivateUser(currentRow){
        this.template.querySelector('c-modal-component').show();
        this.record = currentRow;
        this.currentRecordId = currentRow.idVal;
    }
    closeModal(){
        this.template.querySelector('c-modal-component').hide();
    }
    confirmModal(){
        this.spinner = true;
        deactivateUser({
            contact2AddId: this.currentRecordId
        })
        .then( () => {
            refreshApex(this.wiredResults);
            this.spinner = false;
        });
    }
    addService() {
        this.toAddServiceClicked = true;
        this.boolVal = true;
    }
    addUser() {
        this.toAddUserClicked = true;
        this.boolVal = true;
    }
    cancelButton() {
        this.toAddServiceClicked = false;
        this.toAddUserClicked = false;
        this.boolVal = false;
    }   
    connectedCallback(){
        if (this._getWiredRecordResponse.data !== undefined) {
            refreshApex(this._getWiredRecordResponse);
        }  
    }
    initialized = false;
    renderedCallback() {
        if (this.initialized) {
            return;
        }
        this.initialized = true;        
        if (this._getWiredRecordResponse.data !== undefined) {
            refreshApex(this._getWiredRecordResponse);
        }
    }
    //Capture the event fired from the paginator component
    handlePaginatorChange(event) {
        this.dataRec = event.detail;
        if (this.dataRec.length > 0) {
            this.rowNumberOffset = this.dataRec[0].rowNumber - 1;
        }
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
                a = key(a) ? key(a).toLowerCase() : '';
                b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a > b) - (b > a));
        };
    }
    onHandleSort(event) {
        const {
            fieldName: sortedBy,
            sortDirection
        } = event.detail;
        const cloneData = [...this.dataRec];
        if(sortedBy === '') {
            cloneData.sort(this.sortBy('deactivateService', sortDirection === 'asc' ? 1 : -1));        
        } else {
            cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        }
        this.dataRec = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}