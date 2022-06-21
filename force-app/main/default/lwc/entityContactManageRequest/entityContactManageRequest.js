import { LightningElement, track, api} from 'lwc';
import {
    ShowToastEvent
  } from "lightning/platformShowToastEvent";
// Controller
import getCaseManageRequestDetail from '@salesforce/apex/EntityServiceRequestController.getCaseManageRequestDetail';
import manageServiceRequestsSignature from '@salesforce/apex/EntityServiceRequestController.manageServiceRequestsSignature';
import checkSignatureAssetExist from '@salesforce/apex/EntityServiceRequestController.checkSignatureAssetExist';
import deleteSignedSignForm from '@salesforce/apex/EntityServiceRequestController.deleteSignedSignForm';
import getSignedSignFormId from '@salesforce/apex/EntityServiceRequestController.getSignedSignFormId';
import getIncompleteSignFormId from '@salesforce/apex/EntityServiceRequestController.getIncompleteSignFormId';
// Custom Label
import entityContactSignatureOptionsErrorText from '@salesforce/label/c.Entity_Contact_Signature_Option_Error';
import exceptionDocUploadMissingError from '@salesforce/label/c.Entity_Contact_Signature_Upload_Missing_Error';
import entityContactLanguageSignatureLine1 from '@salesforce/label/c.Entity_Contact_Language_Signature_Line_1';
import entityContactLanguageSignatureLine2 from '@salesforce/label/c.Entity_Contact_Language_Signature_Line_2';
import entityContactLanguageSignatureIncompleteLine1 from '@salesforce/label/c.Entity_Contact_Language_Signature_Incomplete_Line_1';
import entityContactLanguageSignatureIncompleteLine2 from '@salesforce/label/c.Entity_Contact_Language_Signature_Incomplete_Line_2';
import entityContactLanguageLinkText from '@salesforce/label/c.Entity_Contact_Language_Link_Text';
import entityContactBackButtonWarningMessage from '@salesforce/label/c.Entity_Contact_Signature_Upload_Warning_Message';
import entityContactIncompleteMessage from '@salesforce/label/c.Entity_Contact_Signature_Form_Incomplete_Language';
import entityContactSubmitButtonSuccessMessage from '@salesforce/label/c.Entity_Contact_Signature_Upload_Submit_Message';
// Constants
import getAllConstants from '@salesforce/apex/AppForCertController.getAllConstants';

export default class EntityContactManageRequest extends LightningElement {
    @track spinner = false;
    @track formsubmit = false;
    @track showError = false;   
    @track singnatureLanguage1 = entityContactLanguageSignatureLine1;
    @track singnatureLanguage2 = entityContactLanguageSignatureLine2;
    @track singnatureLinkText = entityContactLanguageLinkText;
    @track maxsize = 10;
    @track tempSignFormPayload = {
        documentType: 'Signed Signature Form',
        assetRecordType: 'Entity_Document',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        createFromPB: 'true'
    };
    @track signFormPayload;
    @track hideUpload = true;
    @track showUpload = false;
    @track caseId
    @track contactId;
    @track entityName;
    @track entityLastName;
    @track entityFirstName;
    @track entityLegalNameConsists;
    @track entityGenerationalSuffix;
    @track entityEmail;
    @track entityPhone;
    @track entityDepartment;
    @track entityJobTitle;
    @track entityServiceRequest;
    @track entitySignatureRequired;
    @track entityStatus;
    @track entityDeficiencyReason;
    @track selectedSignatureOption;   
    @track caseStatus;
    @track assetInserted = false;
    @track contentDocumentId = '';    
    @track showCheckedLegalName = false;
    @track showSignatureSection = false;
    @track signatureUploadSection  = false;
    @track showIncomplete = false;
    @track incompleteLanguage = entityContactIncompleteMessage;
    @track caseStatusApproved;
    @track caseStatusPendingUserAccess;
    @track caseStatusPendingReview;
    @track caseStatusPendingSignatureUpload;
    @track caseRadioButtonSelected;
    @track caseStatusIncomplete;
    @track assetStatusInProgress;
    @track enableElement  = false;
    @track disableElement = false;
    @track showSubmitButton = false;
    @track assetSignatureForm=false;
    @track entityAssetFileData;
    @track entityAssetFileType;
    @track entityAssetFileName;
    @track incomplete =false;
    @track entityAssetFileURL;
    @api selectedApplicantId;
    @api selectedCaseId;
    @track signUrl = null;
    @track signOldUrl = null;
    @track signFormIncomPayload;
    get options(){
        return [{
            label: 'Yes',
            value: 'Yes'
        },
        {
            label: 'No',
            value: 'No'
        },
        ];
    }
    connectedCallback(){
        this.caseId  =  this.selectedCaseId;
        this.loadConstants();
        // Manage Requests - Case Detail
        getCaseManageRequestDetail({
            caseId: this.caseId
        })
        .then(caseInfo=>{
            if(caseInfo){
                this.caseId = caseInfo.Case__c;
                this.contactId = caseInfo.ContactId;
                this.entityStatus = caseInfo.Status;
                this.tempSignFormPayload.contactId = caseInfo.ContactId;
                this.tempSignFormPayload.caseId = caseInfo.Case__c;
                this.signFormPayload = JSON.stringify(this.tempSignFormPayload);
                if(this.entityStatus === 'Pending Coordinator Approval'){
                    this.showUpload = true;
                    this.enableElement = true;
                }
                if(this.entityStatus === 'Incomplete' || this.entityStatus === 'In Review'){
                    this.disableElement = true;
                    this.caseRadioButtonSelected = 'Yes';
                    this.selectedSignatureOption = 'Yes'
                    if(this.entityStatus === 'Incomplete'){
                        this.incomplete = true;
                    }
                }
                this.entityName = caseInfo.Entity__c;
                this.entityLastName = caseInfo.LastName;
                this.entityFirstName = caseInfo.FirstName;
                this.entityLegalNameConsists = caseInfo.legal_name_consists_of_one_name_only__c;
                this.entityGenerationalSuffix = caseInfo.Generational_Suffix__c;
                this.entityEmail = caseInfo.Email;
                this.entityPhone = caseInfo.Phone;
                this.entityDepartment = caseInfo.Department;
                this.entityJobTitle = caseInfo.JobTitle;
                this.entityServiceRequest = caseInfo.ServiceName;
                this.entitySignatureRequired = caseInfo.Signature_Required__c;
                this.entityDeficiencyReason = caseInfo.DeficiencyReason;
                deleteSignedSignForm({
                    caseId : this.caseId,
                    status : this.entityStatus
                });
                getSignedSignFormId({caseId : this.caseId}).then(assetUrl=>{
                    if(this.entityStatus !== 'Pending Coordinator Approval' && this.entityStatus !== 'Incomplete'){
                        this.signUrl = assetUrl;
                        this.hideUpload =true;
                    }
                    this.showUpload = true;
                });
                getIncompleteSignFormId({caseId : this.caseId}).then(asstUrl=>{
                    if(this.entityStatus == 'Incomplete'){
                        this.showIncomplete = false;
                        this.signOldUrl = asstUrl;
                        this.signFormIncomPayload = JSON.stringify(this.tempSignFormPayload);
                        this.showIncomplete = true;
                    }
                });
                if(this.entityLegalNameConsists == 'true'){
                    this.showCheckedLegalName = true;
                }
                if(this.entityStatus == this.caseStatusPendingReview){
                    this.caseRadioButtonSelected = 'Yes';
                    this.selectedSignatureOption = 'Yes'
                    this.disableElement = true;
                    this.showSubmitButton = false;
                    this.showSignatureSection = true;
                    this.signatureUploadSection = true;
                    this.assetSignatureForm = true;
                }
                if(this.entityStatus == this.caseStatusIncomplete){
                    this.incomplete = true;
                    this.showUpload = false;
                    this.tempSignFormPayload.assetId = null;
                    this.signUrl = null;
                    this.signFormNewPayload = JSON.stringify(this.tempSignFormPayload); 
                    this.caseRadioButtonSelected = 'Yes';
                    this.selectedSignatureOption = 'Yes'
                    this.disableElement = true;
                    this.showSubmitButton = false;
                    this.showSignatureSection = true;
                    this.signatureUploadSection = true;
                    this.singnatureLanguage1 = entityContactLanguageSignatureIncompleteLine1;
                    this.singnatureLanguage2 = entityContactLanguageSignatureIncompleteLine2;
                    this.singnatureLinkText = entityContactLanguageLinkText;                   
                }else{
                    this.incomplete = false;
                }
            }
        })
        .catch(error=>{
            window.console.log('Error: ' + JSON.stringify(error));
        });
    }
    loadConstants(){
        getAllConstants().then(data=>{
            if(data !== undefined){                
                this.caseStatusPendingUserAccess = data.LWC_CASE_STATUS_PENDING_USER_ACCESS;
                this.caseStatusPendingReview = data.LWC_CASE_STATUS_PENDING_REVIEW;
                this.caseStatusPendingSignatureUpload = data.LWC_CASE_STATUS_PENDING_SIGNATURE_UPLOAD;
                this.caseStatusIncomplete = data.LWC_CASE_STATUS_INCOMPLETE;
                this.assetStatusInProgress = data.LWC_ASSET_STATUS_INPROGRESS;
            }
        }).catch();
    }    
    handleSelect(event){
        this.selectedSignatureOption = event.target.value;
        // eslint-disable-next-line eqeqeq
        if(this.selectedSignatureOption == 'Yes'){            
            if(this.entitySignatureRequired == 'true'){   
                this.hideUpload = false;          
                // Method to check as Asset exist for Signature Contact
                checkSignatureAssetExist({
                    contactId : this.contactId
                })
                .then(assetResult=>{
                    if(assetResult == true){
                        this.caseStatus = this.caseStatusPendingUserAccess;
                        this.showSubmitButton = true;
                        this.showSignatureSection = false;
                        this.signatureUploadSection = false; 
                    }else{
                        this.showSubmitButton = false;
                        this.showSignatureSection = true;
                        this.signatureUploadSection = true;   
                    }
                })
                .catch(error=>{
                    window.console.log('Error: ' + JSON.stringify(error));
                });
            }else{
                this.showSubmitButton = true;
                this.showSignatureSection = false;
                this.signatureUploadSection = false;
                this.caseStatus = this.caseStatusPendingUserAccess;
            }
        }else{
            this.tempSignFormPayload.assetId = null;
            this.signUrl = null;
            this.signFormPayload = JSON.stringify(this.tempSignFormPayload);
            this.showSubmitButton = true;
            this.showSignatureSection = false;
            this.signatureUploadSection = false;
            this.assetInserted = false;
            // Delete If Asset exists Entity Contact Signature
            deleteSignedSignForm({
                caseId : this.caseId,
                status : this.entityStatus
            });          
        }
        // Clear the errors....
        if(this.template.querySelectorAll('#fileUploadMissingError') !== null){
            this.template.querySelectorAll('#fileUploadMissingError').forEach(element=>element.remove());
        }
        this.template.querySelector('.entityCheckboxField').classList.remove('slds-has-error');
        if(this.template.querySelectorAll('#entityContactSignatureOptionError') !== null){
            this.template.querySelectorAll('#entityContactSignatureOptionError').forEach(element=>element.remove());
        }
    }
    prevButton(event){
        event.preventDefault();
        this.template.querySelector('.warningModal').title = 'Alert!';
        this.template.querySelector('.warningModal').message = entityContactBackButtonWarningMessage;
        this.template.querySelector('.warningModal').show();
    }
    handleConfirmClick(){
        if(this.assetInserted == true){
            deleteSignedSignForm({
                caseId : this.caseId,
                status : this.entityStatus
            });
        }
        const backEvent = new CustomEvent('backevent', {});
        this.dispatchEvent(backEvent);
    }
    handleCancelClick(){
        this.template.querySelector('.warningModal').hide();
    }
    handleSubmit(event){
        event.preventDefault(); // stop the form from submitting
        const fieldvals = event.detail.fields;
        this.formsubmit = true;
        this.spinner = true;
        if(this.selectedSignatureOption == "" || this.selectedSignatureOption == undefined){
            this.showError = true;
            this.formsubmit = false;
            this.spinner = false;
            if(this.template.querySelector('#entityContactSignatureOptionError') === null){
                let elem = document.createElement("span");
                elem.id = 'entityContactSignatureOptionError';
                elem.textContent = entityContactSignatureOptionsErrorText;
                elem.style = 'color:#ff0000; clear:both;';
                this.template.querySelector('.entityCheckboxField').appendChild(elem);
                this.template.querySelector('.entityCheckboxField').classList.add('slds-has-error');
            }
        }else{
            this.template.querySelector('.entityCheckboxField').classList.remove('slds-has-error');
            if(this.template.querySelectorAll('#entityContactSignatureOptionError') !== null){
                this.template.querySelectorAll('#entityContactSignatureOptionError').forEach(element=>element.remove());
            }
        }     
        if(this.showSignatureSection == true){
            // documentation uploaded check
            if(this.assetInserted == false){
                this.showError = true;
                this.formsubmit = false;
                this.spinner = false;
                if(this.template.querySelectorAll('#fileUploadMissingError') !== null){
                    this.template.querySelectorAll('#fileUploadMissingError').forEach(element=>element.remove());
                }
                if(this.template.querySelector('.fileUploadSection') !== null){
                    let elem = document.createElement("div");
                    elem.id = 'fileUploadMissingError';
                    elem.textContent = exceptionDocUploadMissingError;
                    elem.style = 'color:#ff0000; clear:both;';
                    this.template.querySelector('.fileUploadSection').appendChild(elem);
                }
            }else{
                if(this.template.querySelectorAll('#fileUploadMissingError') !== null){
                    this.template.querySelectorAll('#fileUploadMissingError').forEach(element=>element.remove());
                }
            }
        }       
        if(this.formsubmit){            
            fieldvals.caseId                =   this.caseId; 
            fieldvals.contactId             =   this.contactId;           
            fieldvals.signatureUploadStatus =   this.selectedSignatureOption;
            fieldvals.caseStatus            =   this.caseStatus;
            fieldvals.contentDocumentId     =   this.contentDocumentId;
            manageServiceRequestsSignature({
                fieldvals: JSON.stringify(fieldvals)
            })
            .then(saveresult=>{
                this.spinner = false;
                if(saveresult){
                    this.showError = true;
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: entityContactSubmitButtonSuccessMessage,
                        variant: "success"
                    });
                    this.dispatchEvent(evt);

                    const submitEvent = new CustomEvent('submitevent', {});
                    this.dispatchEvent(submitEvent);
                }
            })
            .catch(error=>{
                this.spinner = false;
                window.console.log('Error: ' + JSON.stringify(error));
            });
        }
    }
    handleOnAssetInserted(event){
        this.assetInserted = true;
        this.showUpload = false;
        this.caseStatus =  this.caseStatusPendingReview;
        this.showSubmitButton = true;
        this.signUrl = event.detail.url;
        this.showUpload = true;
        // Clear the errors....
        if(this.template.querySelectorAll('#fileUploadMissingError') !== null){
            this.template.querySelectorAll('#fileUploadMissingError').forEach(element=>element.remove());
        }
    }
    handleAssetOnUpload(event){
        this.signUrl = event.detail.url;
        this.assetInserted = true;
        this.incomplete = false;
        this.caseStatus =  this.caseStatusPendingReview;
        this.showSubmitButton = true;
        this.incomplete = true;
        // Clear the errors....
        if(this.template.querySelectorAll('#fileUploadMissingError')){
            this.template.querySelectorAll('#fileUploadMissingError').forEach(element=>element.remove());
        }
    }
}