import {track,LightningElement,api,wire} from 'lwc';
import getServices from '@salesforce/apex/EntityContactServiceController.getServicesOfEntity';
import getServicesOfEntity from '@salesforce/apex/EntityManageAccountServiceController.getServicesOfEntity';
import deleteActiveAccount from '@salesforce/apex/EntityManageAccountServiceController.deleteActiveAccount';
import createAccountService from '@salesforce/apex/EntityManageAccountServiceController.createAccountService';
import updateAccountService from '@salesforce/apex/EntityManageAccountServiceController.updateAccountService';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import MODE_OF_COMMUNICATION from '@salesforce/schema/Account2Service__c.Mode_of_communication__c';
import ACCOUNT_2_SERVICE from '@salesforce/schema/Account2Service__c';
import {refreshApex} from '@salesforce/apex';
export default class EntityManageAccountServiceForm extends LightningElement{
    @api recordId;
    @track serviceList = [];
    @track showServices = false;
    @track serviceToDel;
    @track spinner = false;
    @track isModalOpen = false;
    @track isPhysicalAddress = false;
    @track isEmail = false;
    @track physicalAddress;
    @track emailList;
    @track modeOptions = [];
    @track selectedMode = '';
    @track serviceOptions = [];
    @track serviceVal = '';
    @track errorService = false;
    @track errorMode = false;
    @track accToServiceToEdit = '';
    @track isModalOpenEdit = false;
    @track isPhysicalAddressEdit = false;
    @track isEmailEdit = false;
    @track physicalAddressEdit;
    @track emailListEdit;
    @track selectedModeEdit = '';
    @track serviceValEdit = '';
    @track errorServiceEdit = false;
    @track errorModeEdit = false;
    connectedCallback(){        
        this.acctdetail = this.recordId;
        this.serviceToDel = '';
        this.isModalOpen = false;
        this.isModalOpenEdit = false;
        this.accToServiceToEdit = '';
        this.serviceOptions = [];
        if(this._getRecordResponse.data !== undefined){
            refreshApex(this._getRecordResponse);      
        }
        getServices({accountId: this.recordId})
        .then(resultData =>{
            if(resultData){                
                let tempArr = [];
                let tem = {value: '--None--', label: '--None--'}
                this.serviceVal = '';
                tempArr.push(tem);
                for(let i=0; i<resultData.length; i++){                              
                    let tempTcRec = {value: resultData[i].Id , label: resultData[i].Name}               
                    tempArr.push(tempTcRec);
                }   
                this.serviceOptions = tempArr;                
            }
        })       
    }
    @wire(getObjectInfo,{objectApiName:ACCOUNT_2_SERVICE})
    objectInfo;
    @wire(getPicklistValues,{recordTypeId:'$objectInfo.data.defaultRecordTypeId',fieldApiName: MODE_OF_COMMUNICATION})
    ModePicklistValues({
        error,
        data
    }){
        if(data){
            let tempVal = [];
            let dataList = data.values;
            if(dataList.length > 0){
                let tmp = {value: '--None--', label: '--None--'}
                this.selectedMode = '';
                tempVal.push(tmp);
            }
            for(let i=0; i<dataList.length; i++){
                let tempTcRecord = {value: dataList[i].value , label: dataList[i].label}               
                tempVal.push(tempTcRecord);
            }   
            this.modeOptions = tempVal;
        }else if(error){
            window.console.log('Error: ' + JSON.stringify(error));
        }
    }
    modeChangeHandler(event){
        this.selectedMode = event.target.value; 
        this.errorMode = false;        
        if(this.selectedMode === 'Paper'){
            this.isPhysicalAddress = true;
            this.isEmail = false;
        }
        else if(this.selectedMode === 'Email'){
            this.isPhysicalAddress = false;
            this.isEmail = true;
        }else if(this.selectedMode === '--None--'){
            this.isPhysicalAddress = false;
            this.isEmail = false;
        }
    }
    serviceChangeHandler(event){
        this.serviceVal = event.target.value;
        this.errorService = false;
    }
    handleChangeForPhysicalAddress(event){
        this.physicalAddress = event.target.value; 
        this.emailList = '';        
    }
    handleChangeForEmailList(event){
        this.emailList = event.target.value; 
        this.physicalAddress = '';       
    }
    closeModal(){
        this.errorService = false;
        this.errorMode = false;
        this.isModalOpen = false;
        this.selectedMode = '';
        this.isPhysicalAddress = false;
        this.isEmail = false;
        this.emailList = ''; 
        this.physicalAddress = '';
    }
    submitDetails(){ 
        this.errorService = false;
        this.errorMode = false;
        if((this.serviceVal !== undefined && this.serviceVal !== '' && this.serviceVal !== null && this.serviceVal !== '--None--')&&
        (this.selectedMode !== undefined && this.selectedMode !== '' && this.selectedMode !== null && this.selectedMode !== '--None--')){
            this.isModalOpen = false;
            this.spinner = true;
            createAccountService({acc:this.recordId,emailList: this.emailList ,physicalAddress: this.physicalAddress ,serviceVal: this.serviceVal ,selectedMode: this.selectedMode})
            .then(resultData => {
                if(resultData){ 
                this.loadServiceDetails();
                this.selectedMode = '';
                this.serviceVal = '';
                this.isPhysicalAddress = false;
                this.isEmail = false; 
                this.physicalAddress='';
                this.emailList='';
                this.spinner = false; 
                }
            })
        }
        else{
            if(this.serviceVal === undefined || this.serviceVal === '' || this.serviceVal === null|| this.serviceVal === '--None--' ){
            this.template.querySelector('.service').classList.add('slds-has-error');
            this.errorService = true;                
            }
            if(this.selectedMode === undefined || this.selectedMode === '' || this.selectedMode === null || this.selectedMode === '--None--'){
            this.template.querySelector('.mode').classList.add('slds-has-error');
            this.errorMode = true;
            }          
        }
    }
    loadServiceDetails(){       
        if(this._getRecordResponse.data !== undefined){
            refreshApex(this._getRecordResponse);            
            if(this.serviceList.length > 0){
                this.showServices = true;
            }else{
                this.showServices = false;
            }
        }
    }
    acctdetail = '';
    _getRecordResponse;
    @wire(getServicesOfEntity, {accId: '$acctdetail'}) 
    ServiceListWire(responsecom){        
        this.showServices = false;
        this._getRecordResponse = responsecom;
        let error = responsecom.error;
        let data = responsecom.data;
        this.serviceList = [];        
        if(data){
            if(data.length > 0 ){
                this.serviceList = data;
                this.showServices = true;                
            }
            else{
                this.serviceList = [];                   
                this.showServices = false;
            }               
            this.error = undefined;
        }else if(error){
            this.error = error;
            this.serviceList = undefined;        
        }
    }
    deleteService(event){                    
        let serviceId = event.target.dataset.serviceId;
        this.serviceToDel = serviceId;
        this.isModalOpen = false; 
        this.isModalOpenEdit = false;   
        this.template.querySelector('c-modal-component').show(); 
    }
    handleDelete(){
        this.spinner = true;
        deleteActiveAccount({
            accToSerId : this.serviceToDel
        })
        .then(result=>{                 
            if(result){      
                this.serviceToDel = '';
                this.loadServiceDetails();                 
                this.spinner = false;                             
            }
        })
        .catch(error=>{      
            this.spinner = false;                        
            window.console.log('Error in del ' + JSON.stringify(error));
        });       
    }
    addNewService(){
        this.isModalOpen = true;        
    }
    editService(event){
        this.accToServiceToEdit = '';
        let serviceId = event.target.dataset.serviceId;
        let accserviceId = event.target.dataset.accserviceId;
        let mode = event.target.dataset.mode;
        let physicalAddr = event.target.dataset.physicalAddr;
        let email = event.target.dataset.email;
        this.isModalOpen = false;  
        this.isModalOpenEdit = true; 
        this.accToServiceToEdit = accserviceId;
        this.serviceValEdit = serviceId;
        this.selectedModeEdit =  mode;
        this.physicalAddressEdit =physicalAddr;
        this.emailListEdit =email;
        if(this.selectedModeEdit === 'Paper'){
            this.isPhysicalAddressEdit = true;
            this.isEmailEdit = false;
        }
        else if(this.selectedModeEdit === 'Email'){
            this.isPhysicalAddressEdit = false;
            this.isEmailEdit = true;
        }else if(this.selectedModeEdit === '--None--'){
            this.isPhysicalAddressEdit = false;
            this.isEmailEdit = false;
        }
        if(this.physicalAddressEdit === undefined){
            this.physicalAddressEdit ='';
        }
        if(this.emailListEdit === undefined){
            this.emailListEdit ='';
        }
    }
    modeChangeHandlerEdit(event){
        this.selectedModeEdit = event.target.value; 
        this.errorModeEdit = false;        
        if(this.selectedModeEdit === 'Paper'){
            this.isPhysicalAddressEdit = true;
            this.isEmailEdit = false;
        }
        else if(this.selectedModeEdit === 'Email'){
            this.isPhysicalAddressEdit = false;
            this.isEmailEdit = true;
        }else if(this.selectedModeEdit === '--None--'){
            this.isPhysicalAddressEdit = false;
            this.isEmailEdit = false;
        }
    }
    serviceChangeHandlerEdit(event){
        this.serviceValEdit = event.target.value;
        this.errorServiceEdit = false;
    }
    handleChangeForPhysicalAddressEdit(event){
        this.physicalAddressEdit = event.target.value; 
        this.emailListEdit = '';        
    }
    handleChangeForEmailListEdit(event){
        this.emailListEdit = event.target.value; 
        this.physicalAddressEdit = '';       
    }
    closeModalEdit(){
        this.errorServiceEdit = false;
        this.errorModeEdit = false;
        this.isModalOpenEdit = false;
        this.selectedModeEdit = '';
        this.isPhysicalAddressEdit = false;
        this.isEmailEdit = false;
        this.emailListEdit = ''; 
        this.physicalAddressEdit = '';
    }
    submitDetailsEdit(){ 
        this.errorServiceEdit = false;
        this.errorModeEdit = false;
        if((this.serviceValEdit !== undefined && this.serviceValEdit !== '' && this.serviceValEdit !== null && this.serviceValEdit !== '--None--')&&
        (this.selectedModeEdit !== undefined && this.selectedModeEdit !== '' && this.selectedModeEdit !== null && this.selectedModeEdit !== '--None--')){
            this.isModalOpenEdit = false;
            this.spinner = true;            
            updateAccountService({accToSerId:this.accToServiceToEdit,acc:this.recordId,emailList: this.emailListEdit ,physicalAddress: this.physicalAddressEdit ,serviceVal: this.serviceValEdit ,selectedMode: this.selectedModeEdit})
            .then(resultData => {
                if(resultData){ 
                this.loadServiceDetails();
                this.accToServiceToEdit = '';
                this.selectedModeEdit = '';
                this.serviceValEdit = '';
                this.isPhysicalAddressEdit = false;
                this.isEmailEdit = false; 
                this.physicalAddressEdit='';
                this.emailListEdit='';
                this.spinner = false; 
                }
            })
        }
        else{
            if(this.serviceValEdit === undefined || this.serviceValEdit === '' || this.serviceValEdit === null){
            this.template.querySelector('.serviceEdit').classList.add('slds-has-error');
            this.errorServiceEdit = true;                
            }
            if(this.selectedModeEdit === undefined || this.selectedModeEdit === '' || this.selectedModeEdit === null || this.selectedModeEdit === '--None--'){
            this.template.querySelector('.modeEdit').classList.add('slds-has-error');
            this.errorModeEdit = true;
            }          
        }
    }
    preventBackslash(event){
        if(event.which === 8 || event.which === 46){
            event.preventDefault();
        }
    }
}