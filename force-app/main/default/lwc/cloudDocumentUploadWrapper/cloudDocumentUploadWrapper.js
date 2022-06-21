import {LightningElement,api,track} from "lwc";
import {bytesToSize,base64ToArrayBuffer,showMessage,assetToType} from "c/common";
import {saveDocument} from "c/cloudStorageSave";
import fileNameGenerator from '@salesforce/apex/CloudStorageController.fileNameGenerator';
import getFileUrlWithSAS from '@salesforce/apex/CloudStorageUtils.getFileUrlWithSAS';
import getAzureUrlFromAsset from '@salesforce/apex/CloudStorageController.getAzureUrlFromAsset';
import markAssetForDeletion from '@salesforce/apex/CloudStorageController.markAssetsForDeletion';
import CloudUploadWrapperStyle from '@salesforce/resourceUrl/CloudUploadWrapperStyle';
import {loadStyle} from 'lightning/platformResourceLoader';
export default class CloudDocumentUploadWrapper extends LightningElement{
  constructor(){
    super();
    let stylePath = CloudUploadWrapperStyle;
    loadStyle(this, stylePath);
  }
  header;
  document;
  @api assetType = "";
  // Public properties exposed as Design Parameters
  @api showCredSummScreen = false;
  @api maxAllowedFileSize;
  @api acceptedFileFormats = "";
  @api enableRedaction = false;
  @api enableAnnotation = false;
  @api showDeleteButton = false;
  @api hideUpload = false;
  @api warningMessage = 'Please note that you can only upload one file for this document. Uploading another file will replace the existing file. The file must be in JPG/JPEG/PDF file format and 10 MB or less. After you upload your document, and it appears in the viewer, you can use the tools to rotate the image, if necessary. You must click save to complete the upload process.';
  @track urlWithoutSasToken;
  @track assetExists = false;
  @track spinner = false;
  url = '';
  modalHeader = '';
  thumbnailNotLoaded = true;
  pdfContent = false;
  pdfContentThumbnail = false;
  uploadedFileName;
  @api payLoad = "{\"assetCreationRequired\":\"null\",\"assetId\":\"null\",\"assetRecordType\":\"null\",\"assetStatus\":\"null\",\"contactId\":\"null\",\"createOrReplace\":\"null\",\"documentType\":\"null\"}";
  @track fileUniqueName;
  @api azureDocUrl = null;
  @api merge = null;
  @track showMerge = false;
  @track mergePayload;
  @track uploadedBlob;
  @track uploadedBase64;
  @track mergedUrl;
  connectedCallback(){
    if(this.payLoad !== null && this.payLoad !== undefined && this.payLoad !== ''){
      let parameters = JSON.parse(this.payLoad);
      if(parameters.createFromPB !== 'true' || parameters.createFromPB === undefined){
        if(parameters.assetId !== '' && parameters.assetId !== null){
          getAzureUrlFromAsset({
            assetId: parameters.assetId
          }).then(val =>{
            if(val){
              this.updateThumbnail(val, parameters.documentType);
              this.urlWithoutSasToken = val;              
            }
          });
        }else{
          this.auraThumbnailLoaderAzureURL();
        }
      }else{
        this.auraThumbnailLoaderAzureURL();
      }
    }
  }
  @api auraThumbnailLoader(){
    let parameters = JSON.parse(this.payLoad);
    if(this.thumbnailNotLoaded){
      if(parameters.assetId !== '' && parameters.assetId !== null){
        getAzureUrlFromAsset({
          assetId: parameters.assetId
        }).then(val =>{
          if(val){
            this.updateThumbnail(val, parameters.documentType);
            this.urlWithoutSasToken = val;
            this.thumbnailNotLoaded = false;
            if(this.get_url_extension(this.urlWithoutSasToken) === 'pdf'){
              this.pdfContentThumbnail = true;
            }else{
              this.pdfContentThumbnail = false;
            }
          }
        });
      }else{
        this.assetExists = false;
      }
    }
  }
  @api auraThumbnailLoaderAzureURL(){
    let parameters = JSON.parse(this.payLoad);
    let cloudAzureUrl = (parameters.azureUrl !== '' && parameters.azureUrl !== null && parameters.azureUrl !== undefined) ? parameters.azureUrl : this.azureDocUrl;
    if(cloudAzureUrl){
      this.updateThumbnail(cloudAzureUrl, parameters.documentType);
      this.urlWithoutSasToken = cloudAzureUrl;
    }else{
      this.assetExists = false;
    }
  }
  updateThumbnail(fileNameUrlParam, headerText){
    let fileNameUrl = fileNameUrlParam;
    let splitParams = fileNameUrl.split("/");
    this.modalHeader = headerText;
    if(splitParams.length > 0){
      let tempFileName = splitParams[splitParams.length - 1];
      this.spinner = true;
      getFileUrlWithSAS({
        fileName: tempFileName
      }).then(result =>{
        this.spinner = false;
        if(this.get_url_extension(result) === 'pdf'){
          this.pdfContentThumbnail = true;
        }else{
          this.pdfContentThumbnail = false;
        }
        this.assetExists = true;
        this.url = result + "#view=Fit&toolbar=0&statusbar=0&messages=0&navpanes=0&scrollbar=0";
        const updateThumbnailEvent = new CustomEvent('thumbnailupdated', {});
        this.dispatchEvent(updateThumbnailEvent);
      })
    }
  }
  get_url_extension(url){
    return url.split(/[#?]/)[0].split('.').pop().trim();
  }
  updateThumbnailOnClick(fileNameUrlParam, headerText){
    let fileNameUrl = fileNameUrlParam;
    let splitParams = fileNameUrl.split("/");
    this.modalHeader = headerText;
    if(splitParams.length > 0){
      let tempFileName = splitParams[splitParams.length - 1];
      getFileUrlWithSAS({
        fileName: tempFileName
      }).then(result =>{
        this.assetExists = true;
        this.url = result + "#view=Fit&toolbar=0&statusbar=0&messages=0&navpanes=0&scrollbar=0";
        if(this.get_url_extension(this.url) === 'pdf'){
          this.pdfContent = true;
        }else{
          this.pdfContent = false;
          this.uploadedFileName = tempFileName.substr(tempFileName.indexOf('_') + 1, tempFileName.length - 1).trim();
        }
        this.openModal();
      })
    }
  }
  handleClick(){
    this.updateThumbnailOnClick(this.urlWithoutSasToken, JSON.parse(this.payLoad).documentType);
  }
  openModal(){
    this.template.querySelector(".thumbnailModal").show()
  }
  handleCloseThumbnailModal(){
    this.template.querySelector(".thumbnailModal").hide();
  }
  // Event to convert modified document from base64 -> blob -> file and add it to the data-table
  handleSaveDocument(event){
    let tempPayload = JSON.parse(this.payLoad);
    tempPayload.sourceDocument = 'true';
    this.payLoad = JSON.stringify(tempPayload);
    this.spinner = true;
    try{
      // base64 string document
      let strBase64Data = event.detail.doc;
      // covert base64 to binary (blob)
      let blob = new Blob([base64ToArrayBuffer(strBase64Data)],{
        encoding: "UTF-8",
        type: assetToType(this.assetType)
      });

      //Set the image size parameter for payload
      if(!JSON.parse(this.payLoad.hasOwnProperty('size'))){
        let tempPayload = JSON.parse(this.payLoad);
        tempPayload.size = blob.size;
        this.payLoad = JSON.stringify(tempPayload);
      }
      
      this.uploadedBlob = blob;
      this.uploadedBase64 = strBase64Data;
      if(this.merge){
        this.showMerge = true;
      }else{
        this.saveUploadedFile();
      }
      //hide modal window
      this.template.querySelector(".documentViewerModal").hide();
    }catch(err){
      showMessage(
        err,
        "Error Saving",
        "An error occurred while saving document.",
        "error"
      );
    }
  }
  saveUploadedFile(){
    let blob = this.uploadedBlob;
    let parameters = JSON.parse(this.payLoad);
    fileNameGenerator({
      contactId: parameters.contactId,
      documentType: parameters.documentType,
      azureDocUrl: this.azureDocUrl,
      createOrReplace: parameters.createOrReplace,
      assetId: parameters.assetId
    }).then(data=>{
      this.fileUniqueName = data + '.' + blob.type.substr(blob.type.lastIndexOf("/") + 1, blob.type.length);
      let fileName = this.fileUniqueName;
      let newfile = new File([blob], fileName, {
        lastModified: Date.now(),
        type: blob.type
      });
      this.saveDocument(newfile);
    })
  }
  handleMergeComplete(event){
    this.showMerge = false;
    this.mergedUrl = event.detail.url;
    let tempPayload = JSON.parse(this.payLoad);
    tempPayload.parentUrl = this.mergedUrl;
    this.payLoad = JSON.stringify(tempPayload);
    this.saveUploadedFile();
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
        file: event.detail.document
      };
      //show modal window
      this.header = this.document.name;
      this.template.querySelector(".documentViewerModal").show();
    } catch(err){
      showMessage(
        err,
        "Error Uploading",
        "An error occurred while uploading document.",
        "error"
      );
    }
  }
  // Event to show document
  handleMainDocument(){
    this.template.querySelector("c-document-viewer").viewDocument();
  }
  // Save document to cloud
  async saveDocument(document){
    try{
      let parameters = JSON.parse(this.payLoad);
      this.document = document;
     console.log('Before Cloud storage');
      let url = await saveDocument(this.document, parameters);
      console.log('After Cloud storage');

      this.urlWithoutSasToken = url;
      this.spinner = false;
      if(url){
        let urlObj = {url: url}
        const selectEvent = new CustomEvent('uploadcompleted', {detail : urlObj});
        console.log('Before upload despatch');
        this.dispatchEvent(selectEvent);
        console.log('After upload despatch');

        const selectEvent1 = new CustomEvent('generatedurl', {detail : urlObj});
        this.dispatchEvent(selectEvent1);
        //show success message
        showMessage(
          null,
          "Success",
          "Your file has been successfully uploaded",
          "success"
        );
        this.assetExists = false;
        this.updateThumbnail(url, JSON.parse(this.payLoad).documentType);
      }
    }catch(err){
      console.log('Inside catch:'+err);
      this.spinner = false;
      showMessage(
        err,
        "Error Saving",
        "An error occurred while saving document to Cloud.",
        "error"
      );
    }
  }
  handleCloseModal(){
    this.document = null;
  }
  markForDeletion(){
    try{
      markAssetForDeletion({
        azureUrl: this.urlWithoutSasToken
      }).then(val =>{
        if(val){
          this.assetExists = false;
          const delEvent = new CustomEvent('afterdelete', {});
          this.dispatchEvent(delEvent);
        }
      });
    }catch(err){
      showMessage(
        err,
        "Error Deleting",
        "An error occurred while deleting document.",
        "error"
      );
    }      
  }
}