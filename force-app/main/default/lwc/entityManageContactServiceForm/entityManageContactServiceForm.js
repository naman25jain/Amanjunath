import { LightningElement,track,api,wire } from 'lwc';
import getAvailableServicesForEntity from '@salesforce/apex/EntityContactServiceController.getEntity';
import getServices from '@salesforce/apex/EntityContactServiceController.getServices';
import updateRole from '@salesforce/apex/EntityContactServiceController.updateRole';
import deleteRole from '@salesforce/apex/EntityContactServiceController.deleteRole';
import getServicesOfEntity from '@salesforce/apex/EntityContactServiceController.getServicesOfEntity';
import validateRecord from '@salesforce/apex/EntityContactServiceController.validateRecord';
import checkCVS from '@salesforce/apex/EntityContactServiceController.checkCVS';
import { refreshApex } from '@salesforce/apex';
const COORDINATOR = 'Coordinator';

export default class EntityManageContactServiceForm extends LightningElement {
    @api recordId;
    @track contactName = '';
    @track created = false;
    @track accountName = '';
    @track entityOptions ;
    @track showServices = false;
    @track showNewServButton = false;
    @track serviceList = [];
    @track selectedRole = '';
    @track serviceValue = '';
    @track roleValue = '';
    @track accountRoles =[];
    @track serviceToDel = '';
    @track spinner = false;
    @track isModalOpen = false;
    @track roleOptions;
    @track account;
    @track serviceOptions;
    @track serviceVal;
    @track roleVal;
    @track firstFlag = true;
    @track secondFlag = true;
    @track thirdFlag = true;
    @track fourthFlag = true;
    @track fifthFlag = true;
    @track sixthFlag = true;
    @track seventhFlag = true;
    @track eigthFlag = true;
    @track err = false;

    @track showErrorMsg = false;
    connectedCallback(){
        this.showErrorMsg = false;
        this.showServices = false;
        this.accountName= '';
        this.serviceToDel ='';
        this.contdetail = this.recordId;
        getAvailableServicesForEntity({ conId: this.recordId })
            .then(result => {
                if (result !== undefined) {
                    this.contactName ='';
                    this.accountName = '';
                    if (result.length > 0 ) {
                        this.contactName = result[0].conName;                        
                        let tempVal = [];
                        let dataList = result[0].accName;
                        for(let i=0; i<dataList.length; i++)  {                              
                            let tempTcRecord = {value: dataList[i].accId , label: dataList[i].accName}               
                            tempVal.push(tempTcRecord);
                        }
                        if(dataList.length > 0) {
                            this.accountName = dataList[0].accId;
							this.account = dataList[0].accId;
                        }
                        this.entityOptions = tempVal; 
                        this.acctdetail = this.accountName;
                        getServicesOfEntity({ accountId: this.account })
                        .then(resultData => {
                            if (resultData !== undefined) {
                                if (resultData.length > 0 ) {
                                    let tempArr = [];
                                    if(resultData.length > 0){
                                        let tem = {value: 0, label: '--None--'}
                                        this.serviceVal = 0;
                                        tempArr.push(tem);
                                    }
                                    for(let i=0; i<resultData.length; i++)  {                              
                                        let tempTcRec = {value: resultData[i].Id , label: resultData[i].Name}               
                                        tempArr.push(tempTcRec);
                                    }   
                                    this.serviceOptions = tempArr;
                                    
                                }
                            }
                        })
                    }
                }
            })
            
            if (this._getRecordResponse.data !== undefined) {
                refreshApex(this._getRecordResponse);
            }

    }
    acctdetail = '';
    contdetail = '';
    _getRecordResponse;
    @wire(getServices, {accId: '$acctdetail',conId : '$contdetail'}) 
    taskCompWrapperListWire(responsecom) {
       
        
        this._getRecordResponse = responsecom;
        let error = responsecom.error;
        let data = responsecom.data;
        if (data) {
             if (data.length > 0 ) {
                
                    let tempVal = [];
                    this.serviceList = [];
                    this.accountRoles = [];
                    let tempAccountRoles = [];
                    let dataList = data;
                    for(let i=0; i<dataList.length; i++)  {                              
                        let tempTcRecord = {serviceId: dataList[i].serviceId , serviceName: dataList[i].serviceName,role: dataList[i].role }               
                        tempVal.push(tempTcRecord);
                        tempAccountRoles.push(dataList[i].role);
                    }   
                    
                    this.serviceList = tempVal; 
                    this.accountRoles = tempAccountRoles;
                    
                    }
                    else{
                        this.serviceList = [];
                        this.accountRoles = [];
                        this.showServices = false;
                    }
                   
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.serviceList = undefined;
            
        }
    }
    loadServiceDetails(){
        
        
        if (this._getRecordResponse.data !== undefined) {
            refreshApex(this._getRecordResponse);
            if(this.serviceList.length > 0){
                this.showServices = true;
            }else{
                this.showServices = false;
            }
            
            this.showNewServButton = true;
        }
    }
  
    changeHandler(event) {
    const field = event.target.name;
    if (field === 'optionSelect') {
        this.accountName = event.target.value;
        this.acctdetail = this.accountName;        
        this.showServices = false;  
        this.showErrorMsg = false;
        this.account = this.accountName;
        this.created = false;
        } 
    }
 
    editService( event ){
        this.showErrorMsg = false;           
        let serviceId = event.target.dataset.serviceId;
        let selRole = event.target.dataset.roleId;
        let serviceDtl = event.target.dataset.serviceName;
        this.created = false;

        this.template.querySelector('c-role-modal-component').showErrorDetails = false;
        this.template.querySelector('c-role-modal-component').show();        
        this.template.querySelector('c-role-modal-component').serviceId = serviceId;
        this.template.querySelector('c-role-modal-component').serviceDtl = serviceDtl;
        this.template.querySelector('c-role-modal-component').roleVal= selRole;
        this.template.querySelector('c-role-modal-component').accountDtl = this.accountName;
                
        
        let tempAccRoles = [];
        this.accountRoles = [];
		for(let i=0; i<this.serviceList.length; i++)  { 
            
            if(this.serviceList[i].serviceName === serviceDtl){
                tempAccRoles = [...tempAccRoles, this.serviceList[i].role];              
            }

        }
              
        for(let i=0; i<tempAccRoles.length; i++)  {
                   
            if(tempAccRoles[i] === COORDINATOR){
                delete tempAccRoles[i];
                tempAccRoles.splice(i, 1);
                break;
            }
        }
        this.accountRoles = []  ;
        this.accountRoles.push(tempAccRoles);
        this.template.querySelector('c-role-modal-component').allRoles=this.accountRoles;
        
   }

   deleteService( event ){
    this.showErrorMsg = false;              
    let serviceId = event.target.dataset.serviceId;
    this.serviceToDel = serviceId;
    this.created = false;
    
    this.template.querySelector('c-modal-component').show(); 
   }

    handleConfirm() {
   
        let rl = this.template.querySelector('c-role-modal-component').roleVal;
        let sl = this.template.querySelector('c-role-modal-component').serviceId ; 
        this.spinner = true;
        updateRole({ serviceId: sl, roleValue:rl})
        .then(result => {
            if (result !== undefined) {              
              this.loadServiceDetails();
              this.spinner = false;
            }
        })
        .catch(error => {     
            this.spinner = false;               
            window.console.log('Error: ' + JSON.stringify(error));
        });
        
    }

    handleDelete() {
        
        this.spinner = true;
       
        deleteRole({
            serviceId : this.serviceToDel,accountId : this.accountName,conId : '$contdetail'
        })
        .then(result=> {
                 
            if(result){
                this.spinner = false;
                this.showErrorMsg = true;
            }else{
                this.showErrorMsg = false;
                let acctserviceList = this.serviceList;
          
                for(let i=0; i<acctserviceList.length; i++)  { 
                    
                    if(acctserviceList[i].serviceId === this.serviceToDel){
                            
                        delete acctserviceList[i];
                        acctserviceList.splice(i, 1);
                        break;
                    } 
                }
                this.serviceList = []  ;
                this.serviceList.push(acctserviceList);
                this.spinner = false;
                this.serviceToDel = '';
                this.loadServiceDetails();

            }
            
        })
        .catch(error => {     
            this.spinner = false;               
            window.console.log('Error: ' + JSON.stringify(error));
        }); 
    }

    serviceChangeHandler(event){
        this.serviceVal = event.target.value;
        this.created = false;
        checkCVS({serviceId: this.serviceVal}).then(result => {      
        let dataList = [];
        if (result !== undefined) {
            let tempVal = [];
            dataList = result;
            if(dataList.length > 0){
                let tmp = {value: 0, label: '--None--'}
                this.roleVal = 0;
                tempVal.push(tmp);
            }
            for(let i=0; i<dataList.length; i++)  {                              

                let tempTcRecord = {value: dataList[i].svalue , label: dataList[i].slabel}               
                tempVal.push(tempTcRecord);
            }   
            this.roleOptions = tempVal;       
        }
    })
  }

    addNewService(){
        this.isModalOpen = true;
        this.created = false;
    }
    closeModal(){
        this.isModalOpen = false;
    }
    
    submitDetails(){
        if(this.serviceVal == 0 || this.roleVal == 0){
            this.err = true;
        }
        else if(this.serviceVal != 0 && this.roleVal != 0){
            this.err = false;
        this.isModalOpen = false;
        this.spinner = true;
        validateRecord({ serviceId: this.serviceVal, role: this.roleVal, accountId: this.account, contactId: this.recordId})
        .then(result => {
            if (result !== undefined) {              
              this.firstFlag = result[0];
              this.secondFlag = result[1];
              this.thirdFlag = result[2];
              this.fourthFlag = result[3];
              this.fifthFlag = result[4];
              this.sixthFlag = result[5];
              this.seventhFlag = result[6];
              this.eigthFlag = result[7];
              if(this.firstFlag == false || this.secondFlag == false || this.thirdFlag == false || this.fourthFlag == false || this.fifthFlag == false || this.sixthFlag == false || this.seventhFlag == false || this.eigthFlag == false){
                this.created = false;
              }
              else{
                this.created = true;
              }
              refreshApex(this._getRecordResponse);
            }
            this.spinner = false;
        })
    }
    }
    roleChangeHandler(event){
        this.roleVal = event.target.value;
        this.created = false;
    }
  
}