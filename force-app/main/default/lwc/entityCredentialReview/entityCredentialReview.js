import {LightningElement,track,api,wire} from 'lwc';
import getCredUploaded from '@salesforce/apex/EntityCredVerController.getCredUploaded';
import createEcfmgVerForm from '@salesforce/apex/EntityCredVerController.createEcfmgVerForm';
import updateAsset2VerDtl from '@salesforce/apex/EntityCredVerController.updateAsset2VerDtl';
import getEntitySeal from '@salesforce/apex/EntityCredVerController.getEntitySeal';
import fatchPickListValue from '@salesforce/apex/TranscriptRequestController.fatchPickListValue';
import getFileUrlWithSAS from '@salesforce/apex/CloudStorageUtils.getFileUrlWithSAS';
import{saveDocument} from "c/cloudStorageSave";
import fileNameGenerator from '@salesforce/apex/CloudStorageController.fileNameGenerator';
import getRequestHeaders from "@salesforce/apex/CloudStorageController.getRequestHeaders";
import linkAssetToVPMethod from '@salesforce/apex/CloudStorageController.linkAssetToVPMethod';
import checkReturnedAsstExist from '@salesforce/apex/EntityCredVerController.checkReturnedAsstExist';
import checkAssetExist from '@salesforce/apex/EntityCredVerController.checkAssetExist';
import checkAsstExist from '@salesforce/apex/EntityCredVerController.checkAsstExist';
import{base64ToArrayBuffer,showMessage,assetToType,} from "c/common";
import {updateScreenNumer} from 'c/util';
export default class EntityCredentialReview extends LightningElement{
    @api caseId;
    @track showCred = false;
    @track showTrans = false;    
    @track credAssType = '';
    @track transAssType = '';
    @track showCredSummScreen = true;
    @track selectedValue;
    @track credReasonNotCert;
    @track credComNotCert;
    @track showReason = false;
    @track reasonOptions;    
    @track showOtherCom = false;
    @track asset2VerSouId = '';
    @track showCertErr = false;
	@track showReasonErr = false;
	@track showComErr = false;
    @track allowSubmit = false;
    @api currentEntity;
    @track credTypeInserted ='';
    @track credAzureUrl = '';
    @track assContact;
    @api payLoad;
    @track showPayload = false;
    @track selectedAssetURL;
    @track selectedAssetID;
    @track spinner = false;
    @track showPayloadError = false;  
    @track fileUniqueName;
    @track stamped = false;  
    @track stampBlob = null;
    @track retuAsstChecker = false;
    @track tempPayloadCredVerif = {
        documentType: 'Returned Credential',
        assetRecordType: null,
        createOrReplace: 'Create',
        assetStatus: 'New',
        assetCreationRequired: 'true',
        assetName: null,
        assetId: null,
        caseId: null,
        createFromPB: 'true',
        contactId : null
      };
    get options(){
        return[
            {label: 'I Certify This Document',value: 'Certify'},
            {label: 'I Cannot Certify This Document',value: 'Cannot certify'}
        ];
    }
    handleChange(event){
        this.spinner = true;
        this.selectedValue = event.detail.value;
        this.showCertErr = false;
        this.showReasonErr = false;
        this.showComErr = false;
        this.credReasonNotCert = '';
        this.showOtherCom = false;
        this.showPayloadError = false;
        if(this.selectedValue === 'Certify'){
            clearTimeout(this.timeoutId); // no-op if invalid id
            this.timeoutId = setTimeout(this.handleLoadDocument.bind(this), 1500); // Adjust as necessary
            this.showPayload = true;
            this.showReason = false;
        }
        if(this.selectedValue === 'Cannot certify'){
            this.showReason = true;
            this.showPayload = false;
        }
        this.spinner = false;
    }
    handleChangeForReason(event){
        this.spinner = true;
        this.credReasonNotCert = event.detail.value;
        this.showReasonErr = false;
        this.showComErr = false;
        this.credComNotCert = '';
        if(this.credReasonNotCert === 'Other' || this.credReasonNotCert === 'Applicant action is required'){
            this.showOtherCom = true;
        }else{
            this.showOtherCom = false;
        }        
        this.spinner = false;
    }
    handleChangeForCom(event){
        this.credComNotCert  = event.target.value;
    }
    @wire(fatchPickListValue,{objInfo:{'sobjectType' : 'Case'},
    picklistFieldApi: 'Reason_for_not_Certifying__c'}) reasonValues(result){        
    let dataList = [];
    if(result.data !== undefined){
        let tempVal = [];
        dataList = result.data;
        for(let i = 0;i < dataList.length;i++){  
            let tempTcRecord = {value: dataList[i].svalue , label: dataList[i].slabel}               
            tempVal.push(tempTcRecord);
        }            
        this.reasonOptions = tempVal;             
        }
    }
    connectedCallback(){
        this.spinner = true; 
        getEntitySeal({entityId: this.currentEntity}).then(result=>{
            if(result){
                this.stampBlob = result;
            }
            this.loadCredentials();
            updateScreenNumer(this.caseId,3);
        })
    }
    loadCredentials(){   
        this.showCertErr = false;
	    this.showReasonErr = false;
	    this.showComErr = false; 
        this.showPayloadError = false;
        this.spinner = true;    
        getCredUploaded({caseId:this.caseId})
        .then(
        result=>{       
            if(result){                                
                let tempMainPayload={
                    contactId: null,
                    caseId: null,
                    catsId: null,
                    documentType: null,
                    assetRecordType: null,
                    createOrReplace: null,
                    assetStatus: null,
                    assetCreationRequired: null,
                    assetId: null
                };    
                let tempTransPayload={
                    contactId: null,
                    caseId: null,
                    catsId: null,
                    documentType: null,
                    assetRecordType: null,
                    createOrReplace: null,
                    assetStatus: null,
                    assetCreationRequired: null,
                    assetId: null
                };            
                for(let key in result){                 
                    if(result.hasOwnProperty(key)){                        
                        if(key === 'isSourceSoc'){
                            this.showCred = true;                                                                                   
                        } 
                        if(key === 'assTypeSoc'){
                            tempMainPayload.documentType = result[key];
                            this.credAssType = result[key];
                        } 
                        if(key === 'assIdSoc'){
                            tempMainPayload.assetId = result[key];
                        }     
                        if(key === 'isSupDoc'){
                            this.showTrans = true;
                        } 
                        if(key === 'assTypeSup'){
                            tempTransPayload.documentType = result[key];
                            this.transAssType = result[key];
                        } 
                        if(key === 'assIdSup'){
                            tempTransPayload.assetId = result[key];
                        }  
                        if(key === 'assDocCertifiedSoc'){
                            this.selectedValue = result[key]; 
                            if(this.selectedValue === 'Certify'){
                                clearTimeout(this.timeoutId); // no-op if invalid id
                                this.timeoutId = setTimeout(this.handleLoadDocument.bind(this), 1500); // Adjust as necessary
                                this.showReason = false;
                                this.showPayload = true;                                  
                            }
                            if(this.selectedValue === 'Cannot certify'){
                                this.showReason = true;
                                this.showPayload = false;
                            }                           
                        }   
                        if(key === 'assReasonNotCertSoc'){
                            this.credReasonNotCert = result[key]; 
                            if(this.credReasonNotCert === 'Other' || this.credReasonNotCert === 'Applicant action is required'){
                                this.showOtherCom = true;
                            }                         
                        } 
                        if(key === 'assComNotCertSoc'){
                            this.credComNotCert = result[key];                            
                        }  
                        if(key === 'credTypeInserted'){
                            this.credTypeInserted = result[key];                            
                        } 
                        if(key === 'asstVerIdSoc'){
                            this.asset2VerSouId = result[key];                            
                        } 
                        if(key === 'azureUrlSoc'){
                            this.credAzureUrl = result[key];                            
                        } 
                        if(key === 'assContactSoc'){
                            this.assContact = result[key];                            
                        }                         
                        if(key === 'assReturnedExst' && result[key]==='true'){    
                            this.retuAsstChecker = true;                     
                        }
                    }
                }
                if(this.showCred){
                    if(this.retuAsstChecker){
                        let retUrl = this.credAzureUrl;        
                        let splitParams = retUrl.split("/");  
                        if(splitParams.length > 0){
                            this.fileUniqueName = splitParams[splitParams.length - 1]; 
                        }
                    }
                    this.mainDocPayload = JSON.stringify(tempMainPayload); 
                    if(this.showPayload && this.credAzureUrl){                        
                        checkAsstExist({
                            azure: this.credAzureUrl
                        }).then(retAsst=>{                 
                            if(retAsst){
                                clearTimeout(this.timeoutId); // no-op if invalid id
                                this.timeoutId = setTimeout(this.handleLoadDocument.bind(this), 1500); // Adjust as necessary
                            }
                        });                       
                    }
                }
                if(this.showTrans){
                    this.transPayload = JSON.stringify(tempTransPayload);                            
                }
                this.spinner = false;                                      
            }
        });                
    }
    showCredRevLandPage(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('showscredintland',{});
        this.dispatchEvent(selectEvent);
    }
    showCredRevNextPage(event){         
        this.allowSubmit = true;
        this.showCertErr = false;
	    this.showReasonErr = false;
	    this.showComErr = false;
        this.showPayloadError = false;
        this.spinner = true;    
        let ret = 'Returned '+this.credTypeInserted;             
        if(!this.selectedValue){
            this.allowSubmit = false;
            this.showCertErr = true;
        }
        if(this.showReason && !this.credReasonNotCert){
            this.allowSubmit = false;
            this.showReasonErr = true;
        }
        if(this.showReason && (this.credReasonNotCert === 'Other' || this.credReasonNotCert === 'Applicant action is required') && !this.credComNotCert){
            this.allowSubmit = false;
            this.showComErr = true;
        }
        if(this.showPayload){
            checkReturnedAsstExist({
                caseId: this.caseId,
                retName: ret,
                azureURL: this.selectedAssetURL
            }).then(retAsst=>{                 
                if(retAsst){
                    this.saveAllData(event);                    
                }else{
                    this.showPayloadError = true;
                    this.spinner = false; 
                }                
            });
        }
        else{
            if(this.allowSubmit){
                this.saveAllData(event);
            } 
            else{
                this.spinner = false; 
            }
            if(this.showTrans && !this.showCred){                            
                event.preventDefault();
                const selectEvent = new CustomEvent('nextevent',{});
                this.dispatchEvent(selectEvent);
                this.spinner = false;
            } 
        }                   
    }
    saveAllData(event){        
        if(!this.spinner){
            this.spinner = true;
        }
        if(this.showCred){
            let assVerValues = {} 
            assVerValues.ass2VerId = this.asset2VerSouId;
            assVerValues.cert = this.selectedValue;
            if(this.showReason){
                assVerValues.reason = this.credReasonNotCert;
                if(this.credReasonNotCert === 'Other' || this.credReasonNotCert === 'Applicant action is required'){
                    assVerValues.com = this.credComNotCert;
                }else{
                    assVerValues.com = '';
                }                
            }else{
                assVerValues.reason = '';
                assVerValues.com = '';
            } 
            assVerValues.caseId = this.caseId;
            assVerValues.retName = 'Returned '+this.credTypeInserted;                  
            updateAsset2VerDtl({
            jsonString: JSON.stringify(assVerValues)})
            .then(result=>{
                if(result){
                    if(!this.spinner){
                        this.spinner = true;
                    }                      
                   createEcfmgVerForm({caseRecordId : this.caseId, selectedEntityId : this.currentEntity, certifiedValue : this.selectedValue}).then(resultForm=>{
                        if(resultForm){
                            event.preventDefault();
                            const selectEvent = new CustomEvent('nextevent', {detail : resultForm});
                            this.dispatchEvent(selectEvent);
                            this.spinner = false;
                        }
                    });
                }
            }).catch(error=>{
                window.console.log('Error'+JSON.stringify(error));
                this.spinner = false;
            });            
        }
        else{                
            event.preventDefault();
            const selectEvent = new CustomEvent('nextevent',{});
            this.dispatchEvent(selectEvent);
            this.spinner = false;
        } 
    }
    showCredRevPrevPage(event){
        event.preventDefault();
        const selectEvent = new CustomEvent("prevevent",{});
        this.dispatchEvent(selectEvent);
    } 
    redactionApplied = false;
    handleRedactionApplied(event){
        this.redactionApplied = event.detail.redactionApplied;
    }   
    handleSaveDocument(event){
        this.spinner = true;
        if(this.stampBlob){
            if(this.stamped){
                this.handleSaveSealedDocument(event)
            }else{
                alert("Entity seal is required to save the document");
                this.spinner = false;
            }
        }else{
            this.handleSaveSealedDocument(event)
        }
    } 
    assetType = this.credTypeInserted;
    handleSaveSealedDocument(event){    
        this.spinner = true;        
        let strBase64Data = event.detail.doc;
        // covert base64 to binary (blob)
        let blob = new Blob([base64ToArrayBuffer(strBase64Data)], {
          encoding: "UTF-8",
          type: assetToType(this.assetType),
        });		
       // convert to file       
        fileNameGenerator({
          contactId: this.assContact,
          documentType: this.credTypeInserted,
          azureDocUrl: null,
          createOrReplace: 'Create',
          assetId: null
        }).then(data=>{ 
            let fileName = data + '.' + blob.type.substr(blob.type.lastIndexOf("/") + 1, blob.type.length);
            if(this.fileUniqueName){
                fileName = this.fileUniqueName;
            }   
            else{
                this.fileUniqueName = fileName;
            }      
            let newfile = new File([blob], fileName, {
            lastModified: Date.now(),
            type: blob.type,
        });                    
            this.createPayLoadRefactoredCredVer(newfile);            
        });
    }
    createPayLoadRefactoredCredVer(file){
        this.showPayloadError = false;
        let returnName = 'Returned '+this.credTypeInserted; 
        this.tempPayloadCredVerif.caseId = this.caseId; 
        this.tempPayloadCredVerif.contactId = this.assContact;    
        this.tempPayloadCredVerif.assetRecordType = 'Credential';      
        this.tempPayloadCredVerif.assetName = returnName;           
        this.payLoad = this.tempPayloadCredVerif;               
        this.saveDocCredVer(file);       
    }
    // refactored, created this method
    async saveDocCredVer(file){
        try{
        let fullfileUrl;        
        getRequestHeaders({documentAccessLevel:'CREATE_UPDATE',fileName:file.name,fileExt:'',payLoad:''}).then(result=>{
            if(result){                
                fullfileUrl = JSON.parse(result).FileUrl;                
                this.selectedAssetURL = fullfileUrl;
                this.selectedAssetID = null;
                checkAssetExist({caseId:this.caseId,assetUrl:this.fullfileUrl,type:this.credAssType}).then(result=>{
                    this.selectedAsstId=result;
                });
                this.linkAssetToVP();             
            }
        });      
        await saveDocument(file, this.payLoad);             
        }catch (err){
        showMessage(
            err,
            "Error Saving",
            "An error occurred while saving document to Cloud.",
            "error"
        );
        }
    }
    linkAssetToVP(){     
        if(!this.spinner){
            this.spinner = true;
        } 
        linkAssetToVPMethod({
            caseId: this.caseId,
            assetId: this.selectedAssetID,
            type: 'Verified',
            azureURL: this.selectedAssetURL
        }).then(result=>{
            this.spinner = false;     
            this.showPayloadError = false;       
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
        });
    }
    handleLoadDocument(){                         
        let azureUrl = this.credAzureUrl;        
        let splitParams = azureUrl.split("/");        
        if(!this.spinner){
            this.spinner = true;
        }
        if(splitParams.length > 0){
            let tempFileName = splitParams[splitParams.length - 1]; 
            if(this.credAzureUrl){
                getFileUrlWithSAS({
                fileName: tempFileName
                })
                .then(result=>{
                    if(result && this.template.querySelector('c-document-viewer')){   
                        setTimeout(this.template.querySelector('c-document-viewer').viewUrl(result), 1500);
                        this.spinner = false;  
                    }
                }).catch(error=>{
                    window.console.log('Error: '+JSON.stringify(error));
                    this.spinner = false;                    
                }); 
            }
        }
    }
    handleStamping(event){
        this.stamped = event.detail.sealApplied;
    }
}