import { LightningElement,track } from 'lwc';
import getAvailableServicesForEntity from '@salesforce/apex/EntitySelectionController.getEntity';
import checkEntityServiceAccess from '@salesforce/apex/EntitySelectionController.checkEntityServiceAccess';
export default class EntitySelectionMyServices extends LightningElement{
    @track accountName;
    @track showTabs = false;
    @track isCoordinator = false;
    @track selectedCoordinatorTab;
    @track selectedUserTab;
    @track showEPICPortal = false;
    @track showERAS = false;
    @track showCVSRequests = false;
    connectedCallback(){
        this.loadPrimaryDetails();          
    }
    loadPrimaryDetails(){
        getAvailableServicesForEntity()
        .then(result=>{        
            if (result !== undefined){                
                this.accountName = '';
                if (result.length > 0){                    
                    this.contactName = result[0].conName;                        
                    let tempVal = [];
                    let dataList = result[0].accName;
                    for(let i=0;i<dataList.length;i++){                              
                        let tempTcRecord = {value: dataList[i].accId,label: dataList[i].accName}               
                        tempVal.push(tempTcRecord);
                    }   
                    this.accountName = dataList[0].accId;                    
                    this.entityOptions = tempVal;
                    this.checkEntity();
                }
            }
        })
    } 
    checkEntity(){
        const servicesToCheck = ["Volume Report Recipients", "ERAS", "CVS"];
        checkEntityServiceAccess({
            serviceList: servicesToCheck,
            accId: this.accountName
        })
        .then((result)=>{
            if(result.includes('Volume Report Recipients')){
                this.showEPICPortal = true;
            }else{
                this.showEPICPortal = false;
            }
            if(result.includes('ERAS')){
                this.showERAS = true;
            }else{
                this.showERAS = false;
            }
            if(result.includes('CVS')){
                this.showCVSRequests = true;
            }else{
                this.showCVSRequests = false;
            }
            this.error = undefined;
        })
        .catch((error)=>{
            this.error = error;
        });
    }
    tabselectCoordinator(evt){
        this.selectedCoordinatorTab = evt.target.label;
        if(evt.target.label == 'Enrollment Verification'){
            this.template.querySelector('c-ev-entity').refreshSetup();
        }else if(this.selectedCoordinatorTab == 'Performance Data'){
            this.template.querySelector('c-entity-performance-data').refreshDataOnTabSwitch();
        }else if(this.selectedCoordinatorTab == 'Credential Verification'){
            this.template.querySelector('c-credential-verification-data').refreshDataOnTabSwitch();
        }else if(this.selectedCoordinatorTab == 'ERAS Services'){
            this.template.querySelector('c-entity-eras-services').refreshDataOnTabSwitch();
        }else if(this.selectedCoordinatorTab == 'EPIC Portal'){
           this.template.querySelector('c-entity-E-P-I-C-Portal').refreshSetup();
        }else if(this.selectedCoordinatorTab == 'CVS Requests'){
            this.template.querySelector('c-entity-c-v-s-requests').refreshSetup();
         }
    }
    changeHandler(event){
        const field = event.target.name;
        if(field === 'optionSelect'){
            this.accountName = event.target.value;
            this.checkEntity();
        }
    }
}