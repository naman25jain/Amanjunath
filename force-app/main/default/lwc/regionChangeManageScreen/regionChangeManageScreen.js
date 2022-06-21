import { LightningElement, track } from 'lwc';

//import required apex methods
import getRegionChangeExams from "@salesforce/apex/RegionChangeController.getRegionChangeExams";
import manageRegionChangeRequest from "@salesforce/apex/RegionChangeController.manageRegionChangeRequest";
import checkingExistingRegionChange from "@salesforce/apex/RegionChangeController.checkingExistingRegionChange";

//Custom Labels
import Blank_Testing_Region_Error_Message from '@salesforce/label/c.Blank_Testing_Region_Error_Message'; 
import Blank_Exam_Type from "@salesforce/label/c.Change_Reg_Req_Blank_Exam_Type";
import RegionExist from "@salesforce/label/c.RegionExist";
export default class RegionChangeManageScreen extends LightningElement{
    //track variables
    @track examRegistrationsList = [];
    @track showExamRegList = false;
    @track erSurchargeLists = [];
    @track btnDisabled = false;
    @track showError = false;
    @track spinner = false;
    @track showRegionError;
    @track regionChange=0;
    connectedCallback(){
        this.getRegionChangeExamRecords();
    }
    getRegionChangeExamRecords(){
        getRegionChangeExams()
            .then(value =>{
                if (value){                    
                    if (value.length > 0){
                        this.showExamRegList = true;
                        this.examRegistrationsList = [];
                        for (let key in value){
                            if (value.hasOwnProperty(key)){
                                let tempRecordValues = {
                                    recordIdVal: value[key].recordIdVal,
                                    caseIdVal: value[key].caseId,
                                    examType: value[key].examType,
                                    eligibilityPeriod: value[key].eligibilityPeriod,
                                    surcharge: value[key].surcharge,
                                    testingRegion: value[key].regionName,
                                    testingRegionId: value[key].regionId,
                                    testAccomodations: value[key].testAccommodNeeded,
                                    isRequestedRegionChange: value[key].isRequestedRegionChange,
                                    surchargeLists : value[key].regionSurchargeWrapperList
                                };
                                this.examRegistrationsList.push(tempRecordValues);
                            }
                        }
                    }
                    else {
                        this.examRegistrationsList = [];
                        this.showExamRegList = false;
                    }
                }
            })
            .catch(error => {
                window.console.error('Error Console: ' + JSON.stringify(error));
            });
    }

    showSurchargeRegionSectionClick(event){
        event.preventDefault();
        // Clear the main error messages
        this.template.querySelector('.regionmainerrormsg').innerHTML = '';
        let targetExamRegId = event.target.value;
        if(event.target.checked == true) {
            // If Checkbox is checked, Surcharge section will be shown
            this.template.querySelectorAll('.examregloop').forEach(element => {
                let dataExamRegId = element.getAttribute('data-examregid');
                if(targetExamRegId == dataExamRegId) {
                    checkingExistingRegionChange({
                        examId: targetExamRegId
                    })
                    .then(saveresult => {
                        if(saveresult === "true") {
                            this.regionChange=this.regionChange+1;
                            this.showRegionError=true;
                        }
                        else{
                            this.regionChange=this.regionChange;
                            this.showRegionError=false;
                            element.querySelector('.surchargeregionsection').style.display = 'block';
                        }
                    })
                    .catch(error => {
                        window.console.error('Error Console: ' + JSON.stringify(error));
                    });
                }                
            });                     
        }
        if(event.target.checked == false){
            this.regionChange=this.regionChange;
            this.template.querySelectorAll('.examregloop').forEach(element => {
                if(!element.querySelector('.examtypecheckbox').checked) {
                    let dataExamRegId = element.getAttribute('data-examregid');
                    if(targetExamRegId == dataExamRegId) {
                        checkingExistingRegionChange({
                            examId: targetExamRegId
                        })
                        .then(saveresult => {
                            if(saveresult === "true") {
                                this.regionChange=this.regionChange-1;
                                if(this.regionChange == 0){
                                    this.showRegionError=false;
                                }
                                else{
                                    this.showRegionError=true;
                                }
                            }
                            else{
                                this.regionChange=this.regionChange;
                                if(this.regionChange == 0){
                                    this.showRegionError=false;
                                }
                                else{
                                    this.showRegionError=true;
                                }
                            }
                        }).catch(error => {
                            window.console.error('Error Console: ' + JSON.stringify(error));
                        });

                        element.querySelector('.surchargeregionsection').style.display = 'none';
                        element.querySelector('.regionerrormsg').innerHTML = '';
                    }
                    // If radio buttons checked, uncheck all the values
                    element.querySelectorAll('.regionradio').forEach(elem1 => {
                        elem1.checked = false;
                    });
                }
            });
        }       
    }

    openModal(){
        this.template.querySelector('c-modal-component').show();
    } 


    nextButton(event){
        event.preventDefault();
    }

    prevButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('previousevent', {});
        this.dispatchEvent(selectEvent);
    }

    cancelButton(event){
        event.preventDefault();        
        const selectEvent = new CustomEvent("cancelevent", {});
        this.dispatchEvent(selectEvent);
    }

    handleSubmit(event){
        event.preventDefault(); // stop the form from submitting
        this.formsubmit = true;
        this.spinner = true;
        if (this.formsubmit){
            let dataExamTypeMainCheckbox = false;
            let checkboxCheckedCount = 0;
            let radioCheckedCount = 0;

            // Validation - checking as atleast anyone checkbox is checked
            this.template.querySelectorAll('.examregloop').forEach(element => {
                if(element.querySelector('.examtypecheckbox').checked){
                    dataExamTypeMainCheckbox    =   true;
                    checkboxCheckedCount        =   checkboxCheckedCount + 1;
                    let showSurchargeFlag       =   false;

                    element.querySelectorAll('.regionradio').forEach(elem1 => {
                        if (elem1.checked){                                
                            showSurchargeFlag   =   true;
                            radioCheckedCount   =   radioCheckedCount + 1;                           
                        }                       
                    });     
                    // Clear the error messages
                    element.querySelector('.regionerrormsg').innerHTML = '';
                    // Show error messages
                    if(showSurchargeFlag === false){                       
                        let elemvals = document.createElement("div");
                        elemvals.id = 'regionradioError';
                        elemvals.textContent = Blank_Testing_Region_Error_Message;
                        elemvals.style = 'color:#ff0000; clear:both;';
                        element.querySelector('.regionerrormsg').classList.add('slds-has-error');
                        element.querySelector('.regionerrormsg').appendChild(elemvals);
                        this.spinner = false;
                    }
                }                
                
            });

            if(dataExamTypeMainCheckbox === false){
                // Clear the error messages
                this.template.querySelector('.regionmainerrormsg').innerHTML = '';
                // Show error messages                 
                let elemvals = document.createElement("div");
                elemvals.id = 'regionmainradioError';
                elemvals.textContent = Blank_Exam_Type;
                elemvals.style = 'color:#ff0000; clear:both;';
                this.template.querySelector('.regionmainerrormsg').classList.add('slds-has-error');
                this.template.querySelector('.regionmainerrormsg').appendChild(elemvals);
                this.spinner = false;
            } else {
                if(checkboxCheckedCount == radioCheckedCount){
                    let allWrapper = this.template.querySelectorAll(".examregloop");
                    let recordValuesToSave = [];
                    allWrapper.forEach(elementv => {
                        let dataCaseId                  =   elementv.getAttribute('data-caseidval');
                        let dataSurchargeId             =   '';
                        let dataSurchargeValue          =   '';
                        let isRequestedRegionChange     =   false;
                        let dataSurchargeRegionName     = '';
                        let dataSurchargeRegionId     = '';

                        elementv.querySelectorAll('.regionradio').forEach(elem1 => {
                            if (elem1.checked) {
                                dataSurchargeId         =   elem1.getAttribute('data-surchargeid');
                                dataSurchargeValue      =   elem1.getAttribute('data-surchargevalue');
                                dataSurchargeRegionName =   elem1.getAttribute('data-surchargeregion');
                                dataSurchargeRegionId =   elem1.getAttribute('data-regionid');
                            }   
                        }); 
                        
                        if(dataSurchargeId != '') {
                            isRequestedRegionChange = true;
                        }                        

                        // manage array of items
                        let tempChangeRegionRecords = {
                            Id : dataCaseId,
                            Product_Detail__c : dataSurchargeId,
                            Surcharge__c : dataSurchargeValue,
                            Is_Requested_Region_Change__c : isRequestedRegionChange,
                            Exam_region__c : dataSurchargeRegionId           
                        }
                        recordValuesToSave.push(tempChangeRegionRecords);
                    });
                    // Save Records
                    manageRegionChangeRequest({
                        jsonString: JSON.stringify(recordValuesToSave)
                    })
                    .then(saveresult => {
                        if(saveresult != ''){
                            this.spinner = false;
                            const selectEvent = new CustomEvent('nextevent', {detail:{caserecordidregionchange:saveresult}});
                            this.dispatchEvent(selectEvent);
                        }               
                    })
                    .catch(error => {
                        this.spinner = false;
                        window.console.error('Error: ' + JSON.stringify(error));
                    });                   
                }    
            }
        }
    }

}