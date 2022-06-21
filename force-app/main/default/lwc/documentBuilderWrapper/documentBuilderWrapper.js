import { LightningElement, api } from "lwc";
import {
  bytesToSize,
  base64ToArrayBuffer,
  showMessage,
  assetToType,
} from "c/common";
import { saveDocument } from "c/cloudStorageSave";

export default class DocumentBuilderWrapper extends LightningElement {
  constructor() {
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
  @api enableSaving = false;

  // Example payload
  @api payLoad = { recordId: "1234abcd" };

  //////////////////////////////////////////////////////////////////////////////////////
  handleDocViewerReady(event) {
    console.log("Document Viewer - Ready: ", event.detail.docviewerReady);
  }

  //////////////////////////////////////////////////////////////////////////////////////
  handleDocBuilderReady(event) {
    console.log("Document Builder - Ready: ", event.detail.docbuilderReady);
    // For testing only: opening document using URL -- delete me
    //this.template.querySelector("c-document-builder").viewUrl('https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg');
    //this.template.querySelector("c-document-builder").viewUrl('https://pdftron.s3.amazonaws.com/downloads/pl/demo-annotated.pdf');
  }

  //////////////////////////////////////////////////////////////////////////////////////
  // Event to convert modified document from base64 -> blob -> file and add it to the data-table
  handleSaveDocument(event) {
    try {
      console.log("Saving Document...");

      // base64 string document
      let strBase64Data = event.detail.doc;

      // covert base64 to binary (blob)
      let blob = new Blob([base64ToArrayBuffer(strBase64Data)], {
        encoding: "UTF-8",
        type: assetToType(this.assetType),
      });

      // convert to file
      let fileName =
        this.document.name.substr(0, this.document.name.lastIndexOf(".") + 1) + //parse file name
        blob.type.substr(blob.type.lastIndexOf("/") + 1, blob.type.length); //parse file extension

      let newfile = new File([blob], fileName, {
        lastModified: Date.now(),
        type: blob.type,
      });

      this.saveDocument(newfile);
    } catch (err) {
      showMessage(
        err,
        "Error Saving",
        "An error occurred while saving document.",
        "error"
      );
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  handleRedactionApplied(event) {
    console.log("Redaction Applied: ", event.detail.redactionApplied);
  }

  //////////////////////////////////////////////////////////////////////////////////////
  // Save document to cloud
  async saveDocument(file) {
    try {
      //this.document = file;
      let url = await saveDocument(file, this.payLoad);

      if (url != null) {
        //show success message
        showMessage(
          null,
          "Success",
          "File uploaded successfully. URL: " + url,
          "success"
        );
      }
    } catch (err) {
      showMessage(
        err,
        "Error Saving",
        "An error occurred while saving document to Cloud.",
        "error"
      );
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  // Event to show uploaded document in viewer
  handleFileUploaded(event) {
    try {
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
    } catch (err) {
      showMessage(
        err,
        "Error Uploading",
        "An error occurred while uploading document.",
        "error"
      );
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////
}