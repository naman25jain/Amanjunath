import {LightningElement,api,track} from "lwc";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {bytesToSize,base64ToArrayBuffer,showMessage,assetToType} from "c/common";
import {saveDocument} from "c/cloudStorageSave";
import getContactId from '@salesforce/apex/CloudStorageController.getContactId';
import checkReadOnly from '@salesforce/apex/CloudStorageController.checkReadOnly';
import getCaseStatus from '@salesforce/apex/CloudStorageController.getCaseStatus';
import createPayload from '@salesforce/apex/CloudStorageController.createPayload';
import fileNameGenerator from '@salesforce/apex/CloudStorageController.fileNameGenerator';
import getRecordsList from '@salesforce/apex/CloudStorageController.getRecordsList';
import getFileUrlWithSAS from '@salesforce/apex/CloudStorageUtils.getFileUrlWithSAS';
import getRelatedEntities from '@salesforce/apex/CloudStorageController.getRelatedEntities';
import checkEntityHasService from '@salesforce/apex/CloudStorageController.checkEntityHasService';
import checkAssetExists from '@salesforce/apex/CloudStorageController.checkAssetExists';
import linkAssetToVPMethod from '@salesforce/apex/CloudStorageController.linkAssetToVPMethod';
import getRequestHeaders from "@salesforce/apex/CloudStorageController.getRequestHeaders";
import getCaseDocType from '@salesforce/apex/CloudStorageController.getCaseDocType';
export default class InternalCloudDocumentWrapper extends LightningElement{
  constructor(){
    super();
  }
  header;
  document;
  assetType = ""; //set as PHOTO or PASSPORT to save the file as JPEG image; otherwise it will be saved as PDF (default)
  // Public properties exposed as Design Parameters
  @api maxAllowedFileSize;
  @api acceptedFileFormats = "";
  @api enableRedaction = false;
  @api enableAnnotation = false;
  @track enableSaving = true;
  @api showbuilder = false;
  @track runRecursive = false;
  // Example payload
  @api payLoad;
  @track selectedType;
  @track selectedCatId = null;
  @track nameOnDocument;
  @track showViewer = true;
  @api recordId;
  @api contactId;
  @track spinner = false;
  @api recordType;
  @track recordStatus;
  @track recordDocType;
  @track caseNumberValue;
  @track recordService;
  @track readOnly = true;
  @track existingAssetId;
  actions = [{
    label: 'Open Asset in Viewer',
    name: 'show_details'
  }];
  // acceptable type values: text, Currency, phone, url
  @api columns = [{
    label: 'Asset Name',
    fieldName: 'Name',
    type: 'button',
    sortable: true,
    typeAttributes:{
      title: 'Asset Name',
      rowActions: this.actions,
      label:{
        fieldName: 'Name'
      }
    }
  },
  {
    label: 'Asset Type',
    fieldName: 'Type__c',
    type: 'text',
    sortable: true,
    wrapText: true
  },
  {
    label: 'Case Number',
    fieldName: 'Case_Number__c',
    type: 'text',
    sortable: true,
    wrapText: true
  }];
  @api queryStringParam;
  @track showNameOnDocument = false;
  @track entityHasService = false;
  @track modalTitle = 'Asset already exists!';
  @track modalContent = 'A document already exists on the case with the attributes you have indicated. You can replace the existing document with this new document by clicking Replace.';
  redactionApplied = false;
  // temporary hardcoded values; to be retrieved dynamically according to user story requirement
  get docTypeOptions(){
    if(this.recordType === 'IdVerification'){
      if(this.recordStatus === 'ID Verification'){
        return [{
          label: 'Redacted ID Form',
          value: 'Redacted ID Form'
        }];
      } else{
        return [{
            label: 'Passport',
            value: 'Passport'
          },
          {
            label: 'Passport Expiration Page',
            value: 'Passport Expiration Page'
          },
          {
            label: 'Passport Translation Page',
            value: 'Passport Translation Page'
          },
          {
            label: 'Photo',
            value: 'Photo'
          }
        ];
      }
    }
    if(this.recordType === 'appForCert'){
      return [{
          label: 'Final Medical Diploma',
          value: 'Final Medical Diploma'
        },
        {
          label: 'Final Diploma Name Document',
          value: 'Final Diploma Name Document'
        },
        {
          label: 'Final Diploma Translation',
          value: 'Final Diploma Translation'
        },
        {
          label: 'Final Medical School Transcript',
          value: 'Final Medical School Transcript'
        },
        {
          label: 'Final Transcript Name Document',
          value: 'Final Transcript Name Document'
        },
        {
          label: 'Final Transcript Translation',
          value: 'Final Transcript Translation'
        },
        {
          label: 'Letter from Dean',
          value: 'Letter from Dean'
        },
        {
          label: 'Letter from Dean Name Document',
          value: 'Letter from Dean Name Document'
        },
        {
          label: 'Letter from Dean Translation',
          value: 'Letter from Dean Translation'
        },
        {
          label: 'Pre-Med Letter',
          value: 'Pre-Med Letter'
        },
        {
          label: 'Pre-Med Letter Name Document',
          value: 'Pre-Med Letter Name Document'
        },
        {
          label: 'Pre-Med Letter Translation',
          value: 'Pre-Med Letter Translation'
        },
        {
          label: 'TCT Name Document',
          value: 'TCT Name Document'
        },
        {
          label: 'TCT Translation',
          value: 'TCT Translation'
        },
        {
          label: 'Transfer Credit Transcript',
          value: 'Transfer Credit Transcript'
        },
      ];
    }
    if(this.recordType === 'ExamRegistration'){
      return [{
        label: 'Visa Exception Documentation',
        value: 'Visa Exception Documentation'
      }];
    }
    if(this.recordType === 'applicantBiographicChange'){
      if(this.recordStatus === 'Pending Review' || this.recordStatus === 'In Review'){
        return [{
            label: 'Birth Certificate',
            value: 'Birth Certificate'
          },
          {
            label: 'Marriage Certificate',
            value: 'Marriage Certificate'
          },
          {
            label: 'Official Court Order',
            value: 'Official Court Order'
          },
          {
            label: 'Passport',
            value: 'Passport'
          },
          {
            label: 'Passport Expiration Page',
            value: 'Passport Expiration Page'
          },
          {
            label: 'Passport Translation Page',
            value: 'Passport Translation Page'
          },
          {
            label: 'Photo',
            value: 'Photo'
          },
          {
            label: 'U.S. Naturalization Certificate',
            value: 'U.S. Naturalization Certificate'
          },
          {
            label: 'U.S. Passport Card',
            value: 'U.S. Passport Card'
          },
          {
            label: 'U.S. Resident Alien Card',
            value: 'U.S. Resident Alien Card'
          }
        ];
      } else if(this.recordStatus === 'Resubmitted-Pending ID Review' || this.recordStatus === 'ID Review'){
        return [{
            label: 'Passport',
            value: 'Passport'
          },
          {
            label: 'Passport Expiration Page',
            value: 'Passport Expiration Page'
          },
          {
            label: 'Passport Translation Page',
            value: 'Passport Translation Page'
          },
          {
            label: 'Photo',
            value: 'Photo'
          }
        ];
      } else if(this.recordStatus === 'ID Verification'){
        return [{
          label: 'Redacted ID Form',
          value: 'Redacted ID Form'
        }];
      }
    }
    if(this.recordType === 'paperEVCase'){
      return [{
        label: 'Returned Enrollment Verification',
        value: 'Returned Enrollment Verification'
      }];
    }
    if(this.recordType === 'paperERVCase'){
      return [{
        label: 'Returned Enrollment Re-verification',
        value: 'Returned Enrollment Re-verification'
      }];
    }
    if(this.recordType === 'EntityUserReqSignatureForm'){
      if (this.entityHasService){
        return [{
          label: 'Signed Signature Form',
          value: 'Signed Signature Form'
        }];
      } else{
        return [{
            label: 'Signed PIA',
            value: 'Signed PIA'
          },
          {
            label: 'Signed Service Form',
            value: 'Signed Service Form'
          }
        ];
      }
    }
    if(this.recordType === 'IfomCaseRequest'){
      return [{
        label: 'Returned Enrollment Verification',
        value: 'Returned Enrollment Verification'
      }];
    }
    if((this.recordType === 'Credential_Verification' && this.recordStatus !== 'Verification In Review at ECFMG') || this.recordType === 'Extraction_Sub_case'){
      return [{
        label: 'Verified Asset',
        value: 'Verified Credential'
      },
      {
        label: 'Source Document',
        value: 'Source Document'
      },
      {
        label: 'Supporting Documents',
        value: 'Supporting Documents'
      },
      {
        label: 'Accepted Verification Form',
        value: 'Verification Form'
      },
      {
        label: 'Translation',
        value: 'Translation'
      }];
    }
    if(this.recordType === 'Credential_Verification' && this.recordStatus === 'Verification In Review at ECFMG'){
      return [{
        label: 'Returned Verification Form',
        value: 'Returned Verification Form'
      },
      {
        label: 'Returned Credential',
        value: 'Returned Credential'
      },
      {
        label: 'Returned Supporting Documents',
        value: 'Returned Supporting Documents'
      },
      {
        label: 'Returned Envelope',
        value: 'Returned Envelope'
      }];
    }
    if(this.recordType === 'Medical_Education_Form'){
      return [{
          label: 'Medical Education Form',
          value: 'Medical Education Form'
        },
      ];
    }
    return [{
        label: 'Name Document',
        value: 'Name Document'
      },
      {
        label: 'TCT Translation',
        value: 'TCT Translation'
      },
      {
        label: 'Transfer Credit Transcript',
        value: 'Transfer Credit Transcript'
      },
    ];
  }
  @track error;
  @track recordsList;
  @track defaultSortDirection = 'asc';
  @track sortDirection = 'asc';
  @track sortedBy;
  @track docTypeVal;
  @track entityVal;
  @track entityOptions = [];
  @track gradOrStudent;
  @track base64Doc;
  @track linkButtonVisibility = false;
  @track selectedAssetID;
  @track selectedAssetURL;
  @track credVerfDocType = null;
  @track selectedAssetType = null;
  @track selectedDocTypeLabel = null;
  @track tempPayloadCredVerif = {
    documentType: null,
    assetRecordType: null,
    createOrReplace: 'Create',
    assetStatus: 'Accepted',
    assetCreationRequired: 'true',
    assetName: null,
    assetId: null,
    caseId: null,
    createFromPB: 'true',
    contactId : null
  };
  assetIdsList = [];
  showEntitySelect = false;  
  connectedCallback(){
    getCaseStatus({
      caseId: this.recordId
    }).then(caseStatus=>{
      this.recordStatus = caseStatus.split(':')[0];
      this.credVerfDocType = caseStatus.split(':')[1];
      this.caseNumberValue = caseStatus.split(':')[2];
      this.recordService = caseStatus.split(':')[3];
      if((this.recordType === 'Credential_Verification' && (this.recordStatus !== 'Verification In Review at ECFMG' ||this.recordStatus !== 'Pending Verification Review')) || this.recordType === 'Extraction_Sub_case' || (this.recordType === 'Medical_Education_Form' && (this.recordStatus === 'New' || this.recordStatus === 'In Progress')) || this.recordType === 'ECFMG_Certification'){
        this.linkButtonVisibility = true;
      }
    });
    // Added for bug 19515
    getCaseDocType({
      caseId: this.recordId
    }).then(caseDocType=>{
      this.recordDocType = caseDocType;
    });
    this.onLoadMethods();
  }
  getDetailMethods(){
    getRecordsList({
      queryString: this.queryStringParam
    }).then(result=>{
      if(result){
        this.recordsList = result;
        for(let key in this.recordsList){
          this.assetIdsList.push(this.recordsList[key].Id);
        }
        if(this.recordType === 'appForCert' && this.recordType){
          getRelatedEntities({
            assetIdsList: this.assetIdsList
          }).then(entitiesResult=>{
            for (let resultKey in entitiesResult){
              let tempOption = {
                label: entitiesResult[resultKey][Object.keys(entitiesResult[resultKey])[0]],
                value: Object.keys(entitiesResult[resultKey])[0]
              }
              this.entityOptions.push(tempOption);
            }
            this.showEntitySelect = true;
          });
        }
      }
    });
  }
  getQuery(){
    getContactId({
      caseId: this.recordId
    }).then((result)=>{
      this.contactId = result.split(':')[0];
      this.gradOrStudent = result.split(':')[1];  
      if(this.contactId && ((this.recordType === 'Credential_Verification' && (this.recordStatus !== 'Verification In Review at ECFMG'||this.recordStatus !== 'Pending Verification Review')) || this.recordType === 'Extraction_Sub_case') && this.recordType){
        this.queryStringParam = "SELECT Id, Name, Azure_Storage_URL__c, Type__c, Case_Number__c  FROM Asset WHERE (ContactId = '" + this.contactId + "' AND Status = 'Accepted') OR (case__c ='"+ this.recordId +"' AND Status = 'In Progress') ORDER BY CreatedDate ASC"; 
      }
      if(this.contactId && this.recordType && this.recordType === 'Credential_Verification' && (this.recordStatus === 'Verification In Review at ECFMG'|| this.recordStatus === 'Pending Verification Review')){
        this.queryStringParam = "SELECT Id, Name, Azure_Storage_URL__c, Type__c, Case_Number__c FROM Asset WHERE Case__c = '" + this.recordId + "' AND (Name LIKE 'Returned%' OR Type__c = 'Returned Credential' OR Name = 'Entity Supporting Documents' OR Type__c = 'Envelope' OR Type__c = 'Email' OR Type__c = 'Translation' OR Type__c = 'Name Document' OR Type__c = 'DOB Document' OR Name = 'Credential Request') ORDER BY CreatedDate ASC"; 
      }
      if(this.contactId && this.recordType && this.recordType === 'Medical_Education_Form'){
        this.queryStringParam = "SELECT Id, Name, Azure_Storage_URL__c, Type__c, Case_Number__c  FROM Asset WHERE ContactId = '" + this.contactId + "' AND Status = 'Accepted' ORDER BY CreatedDate ASC"; //
      }
      if(this.contactId && this.recordType && this.recordType === 'ECFMG_Certification'){
        this.queryStringParam = "SELECT Id, Name, Azure_Storage_URL__c, Type__c, Case_Number__c  FROM Asset WHERE ContactId = '" + this.contactId + "' AND (Status = 'Accepted' OR Status = 'Verified') AND (Name = 'Final Medical Diploma' OR Name = 'Verified Final Medical Diploma' OR Name = 'Final Diploma Translation' OR Name = 'Final Medical School Transcript' OR Type__c = 'Verified Final Transcript Credential' OR Name = 'Final Transcript Translation' OR Name = 'Transfer Credit Transcript' OR Type__c = 'Verified Transfer Credit Transcript' OR Name = 'TCT Translation' OR Name = 'Name Document' OR Name = 'DOB Document' OR Name = 'Returned Verification Form' OR Name = 'Accepted Verification Form' OR Name = 'Returned Envelope' OR Name = 'Verified Verification Form' OR Name = 'Verified Transcript to Document Transfer Credits' OR Name = 'Verified Final Medical School Transcript') ORDER BY CreatedDate ASC"; //
      }
      //Added for US 7491
      if(this.contactId && this.recordType === 'Credential_Verification' && (this.recordService === 'FCVS' || this.recordService === 'EICS') && this.recordStatus === 'Duplicate Check'){
        this.queryStringParam = "SELECT Id, Name, Azure_Storage_URL__c, Type__c, Case_Number__c FROM Asset WHERE ContactId = '" + this.contactId + "' AND (Status = 'Accepted' OR Status = 'In Progress' OR Status = 'Verified') ORDER BY CreatedDate ASC"; 
      }
      if(this.contactId && this.recordType && this.recordType === 'CVS_Report_Case'){
        this.queryStringParam = "SELECT Id, Name, Azure_Storage_URL__c, Type__c, Case_Number__c  FROM Asset WHERE Case__c  = '" + this.recordId + "' AND (Status = 'New' OR Status = 'Sent' OR Status = 'Outdated') AND (Type__c = 'Status Report' OR Type__c = 'Confirmation Report') ORDER BY CreatedDate ASC"; //
      }
      if(!this.queryStringParam){
        this.queryStringParam = "SELECT Id, Name, Azure_Storage_URL__c, Type__c, Case_Number__c FROM Asset WHERE Case__c = '" + this.recordId + "' AND Status = 'In Progress' ORDER BY CreatedDate ASC"; // Type__c = 'Name Document' AND
      }
      this.getDetailMethods();   
    });
  }
  onLoadMethods(){
    getCaseStatus({
      caseId: this.recordId
    }).then(caseStatus=>{
      this.recordStatus = caseStatus.split(':')[0];
      this.credVerfDocType = caseStatus.split(':')[1];
      this.caseNumberValue = caseStatus.split(':')[2];
      this.recordService = caseStatus.split(':')[3]; // Added for US 7491
      this.getQuery();
    });
    // Added for bug 19515
    getCaseDocType({
      caseId: this.recordId
    }).then(caseDocType=>{
      this.recordDocType = caseDocType;
    });
    checkReadOnly({
      caseId: this.recordId
    }).then((result)=>{
      this.readOnly = result;
    });
    checkEntityHasService({
        recordId: this.recordId
      })
      .then(result=>{
        if(result){
          this.entityHasService = true;
        }
      })
  }
  // Used to sort the columns
  sortBy(field, reverse, primer){
    const key = primer ?
      function (x){
        return primer(x[field]);
      } :
      function (x){
        return x[field];
      };
    return function (a, b){
      a = key(a) ? key(a).toLowerCase() : '';
      b = key(b) ? key(b).toLowerCase() : '';
      return reverse * ((a > b) - (b > a));
    };
  }
  onHandleSort(event){
    const{
      fieldName: sortedBy,
      sortDirection
    } = event.detail;
    const cloneData = [...this.recordsList];
    if(sortedBy === ''){
      cloneData.sort(this.sortBy('recordAvailableDate', sortDirection === 'asc' ? 1 : -1));
    } else{
      cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
    }
    this.recordsList = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }
  handleRowActions(event){
    let row = event.detail.row;
    let azureUrl = row.Azure_Storage_URL__c;
    let splitParams = azureUrl.split("/");
    this.selectedAssetID = row.Id;
    this.selectedAssetType = row.Type__c;
    this.selectedAssetURL = row.Azure_Storage_URL__c;
    if(splitParams.length > 0){
      let tempFileName = splitParams[splitParams.length - 1];
      getFileUrlWithSAS({
        fileName: tempFileName
      }).then(result=>{
        if(!this.showbuilder){
          this.redactionApplied = false;
        }
        if(this.template.querySelector('c-document-viewer')){
          this.template.querySelector('c-document-viewer').viewUrl(result);
        }
      });
    }
  }
  handleDocumentTypeChange(event){
    if(this.template.querySelectorAll('.typeError') !== null){
      this.template.querySelectorAll('.typeError').forEach(element=>element.remove());
    }
    this.selectedType = null;
    this.selectedDocTypeLabel = null;
    this.selectedType = event.detail.value;
    this.selectedDocTypeLabel = event.target.options.find(opt=>opt.value === event.detail.value).label;
    if(this.selectedType === 'Final Medical Diploma' || this.selectedType === 'Final Medical School Transcript' || this.selectedType === 'Letter from Dean' || this.selectedType === 'Pre-Med Letter' || this.selectedType === 'Transfer Credit Transcript'){
      this.showNameOnDocument = true;
    } else{
      this.showNameOnDocument = false;
    }
  }
  handleEntityChange(event){
    if(this.template.querySelectorAll('.catError') !== null){
      this.template.querySelectorAll('.catError').forEach(element=>element.remove());
    }
    this.selectedCatId = event.detail.value;
  }
  handleRedactionApplied(event){
    this.redactionApplied = event.detail.redactionApplied;
  }
  // Event to convert modified document from base64 -> blob -> file and add it to the data-table
  handleSaveDocument(event){
    if(!this.runRecursive){
      try{
        if(this.selectedType && this.selectedCatId){
          this.createFileNameAndPayload(event);
        }else if(this.recordType === 'Medical_Education_Form' && this.selectedType){
          this.createFileNameAndPayload(event);
        } else if(this.recordType !== 'appForCert' && this.selectedType){
          //Added for bug 19515
          if(this.recordType === 'Extraction_Sub_case' && this.recordDocType === null){
            const errorEventDocType = new ShowToastEvent({
              title: "Error",
              message: 'You have not finished the Credential Details. Please finish the Credential and then proceed with Document Editing.',
              variant: "error"
            });
            this.dispatchEvent(errorEventDocType);
          }
          else if(this.recordType !== 'applicantBiographicChange' && this.recordType !== 'IdVerification'){
            this.createFileNameAndPayload(event);
          } else if((this.recordType === 'applicantBiographicChange' || this.recordType === 'IdVerification') && this.recordStatus !== 'ID Verification'){
            this.createFileNameAndPayload(event);
          } else if((this.recordType === 'applicantBiographicChange' || this.recordType === 'IdVerification') && this.recordStatus === 'ID Verification'){
            if(this.redactionApplied){
              this.createFileNameAndPayload(event);
            } else{
              const errorEvent = new ShowToastEvent({
                title: "Error",
                message: 'You have not redacted the passport on the identity form yet.  Please redact the passport and then click the Save button again.',
                variant: "error"
              });
              this.dispatchEvent(errorEvent);
            }
          }
        } else{
          if(!this.selectedType){
            if(this.template.querySelectorAll('.typeError') !== null){
              this.template.querySelectorAll('.typeError').forEach(element=>element.remove());
            }
            this.template.querySelectorAll('.documentType').forEach(element=>{
              let elem = document.createElement("div");
              elem.id = 'typeError';
              elem.setAttribute('class', 'typeError');
              elem.textContent = 'Please select document type';
              elem.style = 'color:#ff0000; clear:both;';
              element.classList.add('slds-has-error');
              element.parentNode.insertBefore(elem, element.nextSibling);
            });
          }
          if(this.recordType !== 'applicantBiographicChange'){
            if(!this.selectedCatId){
              if(this.template.querySelectorAll('.catError') !== null){
                this.template.querySelectorAll('.catError').forEach(element=>element.remove());
              }
              this.template.querySelectorAll('.cats').forEach(element=>{
                let elem1 = document.createElement("div");
                elem1.id = 'catError';
                elem1.setAttribute('class', 'catError');
                elem1.textContent = 'Please select staging record';
                elem1.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                element.parentNode.insertBefore(elem1, element.nextSibling);
              });
            }
          }
        }
      } catch (err){
        showMessage(
          err,
          "Error Saving",
          "An error occurred while saving document.",
          "error"
        );
      }
    }    
  }
  showDocumentBuilder(){
    this.enableSaving = false;
    this.showViewer = false;
    this.showbuilder = true;
    this.redactionApplied = false;    
  }
  hideBuilder(){
    this.enableSaving = true;
    this.showViewer = true;
    this.showbuilder = false;
    this.redactionApplied = false;
  }
  createFileNameAndPayload(event){
    this.spinner = true;   
    this.runRecursive = true; 
    this.base64Doc = event.detail.doc;
    if(((this.recordType === 'Credential_Verification' && (this.recordStatus !== 'Verification In Review at ECFMG'|| this.recordStatus !== 'Pending Verification Review')) || this.recordType === 'Extraction_Sub_case') && this.selectedType === 'Source Document'){
      this.selectedType = 'Verified Credential';
    }
    checkAssetExists({
      caseId: this.recordId,
      catId: this.selectedCatId,
      type: this.selectedType
    }).then(result=>{
      if(result){
        this.spinner = false;
        this.existingAssetId = result;
        this.runRecursive = false;
        this.template.querySelector('c-modal-component').show();
      } else{
        // base64 string document
        let strBase64Data = event.detail.doc;
        // covert base64 to binary (blob)
        let blob = new Blob([base64ToArrayBuffer(strBase64Data)], {
          encoding: "UTF-8",
          type: assetToType(this.assetType),
        });
        // convert to file
        fileNameGenerator({
          contactId: this.contactId,
          documentType: this.selectedType,
          azureDocUrl: null,
          createOrReplace: 'Create',
          assetId: null
        }).then(data=>{
          let fileName = data + '.' + blob.type.substr(blob.type.lastIndexOf("/") + 1, blob.type.length);
          let newfile = new File([blob], fileName, {
            lastModified: Date.now(),
            type: blob.type,
          });
          if(this.recordType === 'Credential_Verification' || this.recordType === 'Extraction_Sub_case' || this.recordType === 'Medical_Education_Form'){
            this.createPayLoadRefactoredCredVer(newfile);
          }else{
            createPayload({
              caseId: this.recordId,
              contactId: this.contactId,
              type: this.selectedType
            }).then((payLoadData)=>{
              this.payLoad = payLoadData;
              this.saveDocument(newfile);
            });
          }
        });
      }
    });
  }
  createPayLoadRefactoredCredVer(file){
    this.tempPayloadCredVerif.caseId = this.recordId; 
    this.tempPayloadCredVerif.contactId = this.contactId;
    if(this.selectedType === 'Verified Credential'){
      this.tempPayloadCredVerif.assetRecordType = 'Credential';
      if(this.recordType === 'Extraction_Sub_case'){
        this.tempPayloadCredVerif.assetName = 'Verified '+this.credVerfDocType;
        this.tempPayloadCredVerif.type = this.credVerfDocType;
      }else{
        this.tempPayloadCredVerif.assetName = 'Verified '+this.credVerfDocType;
      }
      this.tempPayloadCredVerif.documentType = this.selectedType;
    }else if(this.selectedType === 'Verification Form'){
      this.tempPayloadCredVerif.assetRecordType = 'Verification';
      this.tempPayloadCredVerif.assetName = 'Accepted Verification Form';
      this.tempPayloadCredVerif.documentType = this.selectedType;
      this.tempPayloadCredVerif.assetStatus = 'Verified';
    }else if(this.selectedType === 'Supporting Documents'){
      this.tempPayloadCredVerif.assetRecordType = 'Supporting_Documents';
      this.tempPayloadCredVerif.assetName = 'Supporting Documents';
      this.tempPayloadCredVerif.documentType = this.selectedType;
    }
    if(this.selectedType === 'Returned Verification Form'){
      this.tempPayloadCredVerif.assetRecordType = 'Verification';
      this.tempPayloadCredVerif.assetName = this.selectedType;
      this.tempPayloadCredVerif.type = 'Verification Form';
      this.tempPayloadCredVerif.documentType = 'Verification Form';
      this.tempPayloadCredVerif.assetStatus ='Submitted';
    }
    if(this.selectedType === 'Returned Credential'){
      this.tempPayloadCredVerif.assetRecordType = 'Credential';
      this.tempPayloadCredVerif.assetName = 'Returned '+this.credVerfDocType;
      this.tempPayloadCredVerif.type = this.credVerfDocType;
      this.tempPayloadCredVerif.documentType = this.credVerfDocType;
      this.tempPayloadCredVerif.assetStatus ='Submitted';
    }
    if(this.selectedType === 'Returned Supporting Documents'){
      this.tempPayloadCredVerif.assetRecordType = 'Supporting_Documents';
      this.tempPayloadCredVerif.assetName = this.selectedType;
      this.tempPayloadCredVerif.type = 'Supporting Documents';
      this.tempPayloadCredVerif.documentType = 'Supporting Documents';
      this.tempPayloadCredVerif.assetStatus ='Submitted';
    }  
    if(this.selectedType === 'Returned Envelope'){
      this.tempPayloadCredVerif.assetRecordType = 'Verification';
      this.tempPayloadCredVerif.assetName = this.selectedType;
      this.tempPayloadCredVerif.type = 'Envelope';
      this.tempPayloadCredVerif.documentType = 'Envelope';
      this.tempPayloadCredVerif.assetStatus ='Submitted';
    }
    if(this.recordType === 'Medical_Education_Form' && this.selectedType === 'Medical Education Form'){
      this.tempPayloadCredVerif.assetRecordType = 'Medical_Education_Form';
      this.tempPayloadCredVerif.assetName = 'Accepted Medical Education Form';
      this.tempPayloadCredVerif.type = this.selectedType;
      this.tempPayloadCredVerif.documentType = this.selectedType;
      this.tempPayloadCredVerif.assetStatus ='Accepted';
    }
    if(this.selectedType === 'Translation' && this.recordType === 'Extraction_Sub_case'){
      this.tempPayloadCredVerif.assetRecordType = 'Credential';
      this.tempPayloadCredVerif.assetName = this.selectedAssetType+' - Translation';
      this.tempPayloadCredVerif.type = this.selectedType;
      this.tempPayloadCredVerif.documentType = this.selectedType;
      this.tempPayloadCredVerif.assetStatus ='Accepted';
      this.tempPayloadCredVerif.sourceDocument ='true';
      this.tempPayloadCredVerif.parentAsset = this.selectedAssetID;
    }   
    this.payLoad = this.tempPayloadCredVerif;
    this.saveDocCredVer(file);    
  }
  // refactored, created this method
  async saveDocCredVer(file){
    try{
      this.payLoad.catId = this.selectedCatId;
      this.payLoad.nameOnDocument = this.nameOnDocument;
      this.payLoad.documentType = this.selectedType;
      let fullfileUrl;
      getRequestHeaders({documentAccessLevel:'CREATE_UPDATE',fileName:file.name,fileExt:'',payLoad:''}).then(result=>{
        if(result){
          fullfileUrl = JSON.parse(result).FileUrl;
          this.selectedAssetURL = fullfileUrl;
          if(this.recordType === 'Credential_Verification'){
            this.selectedAssetID = this.existingAssetId;
          }else{
            this.selectedAssetID = undefined;
          }
          //this.linkAssetToVP(); 
          if(this.recordType === 'Credential_Verification' || this.recordType === 'Medical_Education_Form' || this.recordType === 'Extraction_Sub_case'){
            this.linkAssetToVP(); 
          }
        }
      });   
      await saveDocument(file, this.payLoad); 
      this.spinner = false;
    }catch (err){
      showMessage(
        err,
        "Error Saving",
        "An error occurred while saving document to Cloud.",
        "error"
      );
    }
  }
  resetVariables(){
    this.header = null;
    this.document = null;
    this.assetType = "";
    this.payLoad = null;
    this.selectedType = null;
    this.selectedCatId = null;
    this.nameOnDocument = null;
    this.contactId = null;
    this.recordStatus = null;
    this.existingAssetId = null;
    this.showNameOnDocument = false;
    this.entityHasService = false;
    this.redactionApplied = false;
    this.recordsList = null;
    this.entityOptions = [];
    this.gradOrStudent = null;
    this.base64Doc = null;
    this.assetIdsList = [];
    this.showEntitySelect = false;
    this.selectedAssetURL = null;
    this.selectedAssetID = null;
    this.selectedAssetType = null;
  }
  // Save document to cloud
  async saveDocument(file){
    try{
      this.payLoad.catId = this.selectedCatId;
      this.payLoad.nameOnDocument = this.nameOnDocument;
      this.payLoad.documentType = this.selectedType;
      this.payLoad.isUploadLocation = 'DocumentEditingTab';
      this.payLoad.caseNumber = '';
      let url = await saveDocument(file, this.payLoad);
      console.log('url',url);
      this.spinner = false;
      if(url != null){
        showMessage(
          null,
          "Success",
          "File uploaded successfully.",
          "success"
        );        
        this.readOnly = !this.readOnly;
        this.resetVariables();
        this.onLoadMethods();
        if(this.showViewer){
          this.showViewer = false;
          let that = this;
          setTimeout(function(){
            that.showViewer = true;
          },250);
        }else{
          this.hideBuilder();
        }
        this.runRecursive = false;
        window.location.reload();
      }
    }catch (err){
      showMessage(
        err,
        "Error Saving",
        "An error occurred while saving document to Cloud.",
        "error"
      );
    }
  }
  handleNameChange(event){
    this.nameOnDocument = event.target.value;
  }
  // Event to show uploaded document in viewer
  handleFileUploaded(event){
    try{
      // set global
      this.document = {
        id: Date.now(),
        name: event.detail.document.name,
        size: bytesToSize(event.detail.document.size),
        type: event.detail.document.type,
        file: event.detail.document,
      };
      this.header = this.document.name;
      this.template.querySelector("c-document-viewer").viewDoc(this.document);
    } catch (err){
      showMessage(
        err,
        "Error Uploading",
        "An error occurred while uploading document.",
        "error"
      );
    }
  }
  handleReplace(){
    this.spinner = true;
    // base64 string document
    let strBase64Data = this.base64Doc;
    // covert base64 to binary (blob)
    let blob = new Blob([base64ToArrayBuffer(strBase64Data)], {
      encoding: "UTF-8",
      type: assetToType(this.assetType),
    });
    // convert to file
    fileNameGenerator({
      contactId: this.contactId,
      documentType: this.selectedType,
      azureDocUrl: null,
      createOrReplace: 'ReplaceInternal',
      assetId: this.existingAssetId
    }).then(data=>{
      let fileName = data + '.' + blob.type.substr(blob.type.lastIndexOf("/") + 1, blob.type.length);
      let newfile = new File([blob], fileName, {
        lastModified: Date.now(),
        type: blob.type,
      });
      if(this.recordType === 'Credential_Verification'){            
        this.createPayLoadRefactoredCredVer(newfile);
      }else{
        createPayload({
          caseId: this.recordId,
          contactId: this.contactId,
          type: this.selectedType
        }).then((payLoadData)=>{
          this.payLoad = payLoadData;
          this.saveDocument(newfile);
        });
      }
    });
  }
  linkAssetToVP(){
    if(!this.spinner){
      this.spinner = true;
    }
    if(!this.selectedType || !this.selectedDocTypeLabel){
      this.spinner = false;
      showMessage(
        null,
        "Error Uploading",
        "Please select a document type to link the asset to verification packet.",
        "error"
      );
    }
    else if(!this.selectedAssetURL || this.selectedAssetURL == null){
      this.spinner = false;
      showMessage(
        null,
        "Error Uploading",
        "Please select an asset to link the asset to verification packet.",
        "error"
      );
    }else{
      let docTypeValueSelected = null;
      docTypeValueSelected = this.documentTypReturn();
      linkAssetToVPMethod({
        caseId: this.recordId,
        assetId: this.selectedAssetID,
        type: docTypeValueSelected,
        azureURL: this.selectedAssetURL
      }).then((result)=>{
        var setToast = null;
        if(!result.outcome){
          setToast = "Error";
        }else{          
          setToast = "Success";          
        } 
        showMessage(
        null,
        setToast,
        result.message,
        setToast
        );
        let that = this;
        setTimeout(function(){
          that.readOnly = !that.readOnly;
          that.resetVariables();
          that.onLoadMethods();           
          if(that.showViewer){
            that.showViewer = false;
            setTimeout(function(){
              that.showViewer = true;
            },250);
          } else{
            that.hideBuilder();
          }
          that.selectedAssetURL = undefined;
          that.selectedDocTypeLabel = undefined;
          that.spinner = false;
          that.runRecursive = false;
        },2500);
      });
    }    
  }  
  // Refactored method to set the document type for Asset2Verification record - used in linkAsset2Vp methdo above
  documentTypReturn(){
    let tempValSelected = null;
    if(this.selectedDocTypeLabel === 'Supporting Documents'|| this.selectedDocTypeLabel === 'Translation'){
      tempValSelected = 'Supporting document';
    }else if(this.selectedDocTypeLabel === 'Verified Asset'){
      tempValSelected = 'Verified';
    }else if(this.selectedDocTypeLabel === 'Accepted Verification Form'){
      tempValSelected = 'Accepted Verification form';
    }else if(this.selectedDocTypeLabel === 'Source Document'){
      tempValSelected = 'Source';
    }else if(this.selectedDocTypeLabel === 'Returned Verification Form' || this.selectedDocTypeLabel === 'Returned Credential'){
      tempValSelected = this.selectedDocTypeLabel;
    }else if(this.selectedDocTypeLabel === 'Returned Supporting Documents'){
      tempValSelected = 'Returned Supporting Document';
    }else if(this.selectedDocTypeLabel === 'Returned Envelope'){
      tempValSelected = 'Returned Envelope';
    }else if(this.selectedDocTypeLabel === 'Medical Education Form'){
      tempValSelected = 'Medical Education Form';
    }
    return tempValSelected;
  }
}