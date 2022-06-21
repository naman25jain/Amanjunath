import {
    LightningElement,
    track,
    wire
} from 'lwc';
import getAvailableServicesForEntity from '@salesforce/apex/EntitySelectionController.getEntity';
import getServices from '@salesforce/apex/EntitySelectionController.getServices';
import {
    refreshApex
} from '@salesforce/apex';
import getMessage from '@salesforce/apex/RestrictedMessage.getMessage';
export default class EntitySelection extends LightningElement {

    @track accountName;
    @track showTabs = false;
    @track isCoordinator = false;
    @track selectedCoordinatorTab;
    @track selectedUserTab;
    contactId;
    @track tempJson ={
        accountId: '',
        contactId: '',
        service: ''
    };
    @track jsonWrap;
    connectedCallback() {
        this.loadPrimaryDetails();

        if (this._getRecordResponse.data !== undefined) {
            refreshApex(this._getRecordResponse);

        }
    }
    loadPrimaryDetails(){
        getAvailableServicesForEntity()
            .then(result =>{
                if (result !== undefined){
                    this.accountName = '';
                    if (result.length > 0){
                        this.contactName = result[0].conName;
                        let tempVal = [];
                        let dataList = result[0].accName;
                        for (let i = 0; i < dataList.length; i++){
                            let tempTcRecord ={
                                value: dataList[i].accId,
                                label: dataList[i].accName
                            }
                            tempVal.push(tempTcRecord);
                        }
                        this.accountName = dataList[0].accId;
                        this.acctdetail = dataList[0].accId;
                        this.entityOptions = tempVal;
                        this.contactId = result[0].conId;
                        this.tempJson ={
                            accountId: this.acctdetail,
                            contactId: this.contactId,
                            service: 'Administrative Access - Internal and External'
                        };
                        this.jsonWrap = JSON.stringify(this.tempJson); 
                    }
                }
            })
    }

    acctdetail = '';

    _getRecordResponse;
    @wire(getServices, {
        accId: '$acctdetail'
    })
    serviceCheckWire(responsecom){
        this._getRecordResponse = responsecom;
        let data = responsecom.data;
        if (data){
            this.isCoordinator = true;
        } else {
            this.isCoordinator = false;
        }
    }
    @wire(getMessage,{
        jsonInput : '$jsonWrap'
    })
    getErrorMessage(response){
        this.showTabs = false;
        let data = response.data;
        if(data === 'There is an active restriction on this record.'){
            this.showTabs = false;
        }else{
            this.showTabs = true;
        }
    }
    tabselectCoordinator(evt) {
        this.selectedCoordinatorTab =  evt.target.label;
        if(evt.target.label === 'Manage Users'){
            this.template.querySelector('c-manage-users').refreshDataOnTabSwitch();
        }
        else if (evt.target.label === 'My Requests') {
            this.template.querySelector('.coordinatorRequests').setup();
        }
        else if(this.selectedCoordinatorTab === 'Manage Requests'){
            this.template.querySelector('c-entity-manage-requests').refreshSetup();
        }
    }

    tabselectUser(evt) {
        this.selectedUserTab =  evt.target.label;
        if(evt.target.label === 'Manage Users'){
            this.template.querySelector('c-manage-users').refreshDataOnTabSwitch();
        }
        else if (evt.target.label === 'My Requests') {
            this.template.querySelector('.userRequests').setup();
        }
    }
    changeHandler(event) {
        const field = event.target.name;
        if (field === 'optionSelect') {
            this.accountName = event.target.value;
            this.acctdetail = this.accountName;
            this.tempJson ={
                accountId: this.acctdetail,
                contactId: this.contactId,
                service: 'Administrative Access - Internal and External'
            };
            this.jsonWrap = JSON.stringify(this.tempJson); 
        }
    }
}