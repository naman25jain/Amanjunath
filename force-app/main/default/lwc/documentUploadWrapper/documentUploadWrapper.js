import { LightningElement, api } from "lwc";
import {
  bytesToSize,
  base64ToArrayBuffer,
  showMessage,
  assetToType
} from "c/common";
import { saveDocument } from "c/cloudStorageSave";

//////////////////////////////////////////////////////////////////////////////////////
//Example to retrieve and view the document from Azure
//////////////////////////////////////////////////////////////////////////////////////
//import getRequestUrl from "@salesforce/apex/CloudStorageController.getRequestUrl";
//const readAccessLevel = "READ";
//let sampleUrl =
//  "https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/3ae1748a-a3c8-f432-4111-7dfaa6ec0b75.pdf";

/*     getRequestUrl({
      documentAccessLevel: readAccessLevel,
      fileName: sampleUrl.substring(sampleUrl.lastIndexOf("/") + 1, sampleUrl.length)
     })
    .then((requestUrl) => {
        this.template.querySelector("c-document-viewer").viewUrl(requestUrl);
       }
    ) */
//////////////////////////////////////////////////////////////////////////////////////

const actions = [
  { label: "View", name: "view" },
  { label: "Delete", name: "delete" },
  { label: "Save", name: "save" }
];

const columns = [
  { label: "Title", fieldName: "name" },
  { label: "Size", fieldName: "size" },
  {
    type: "button-icon",
    fixedWidth: 48,
    typeAttributes: {
      label: "View",
      name: "view",
      title: "View",
      disabled: false,
      value: "view",
      iconName: "utility:preview"
    }
  },
  {
    type: "button-icon",
    fixedWidth: 48,
    typeAttributes: {
      label: "Delete",
      name: "delete",
      title: "Delete",
      disabled: false,
      value: "delete",
      iconName: "utility:delete"
    }
  },
  {
    type: "button-icon",
    fixedWidth: 48,
    typeAttributes: {
      label: "Save",
      name: "save",
      title: "Save",
      disabled: false,
      value: "save",
      iconName: "utility:save"
    }
  },
  {
    type: "action",
    fixedWidth: 48,
    typeAttributes: { rowActions: actions }
  }
];

export default class DocumentUploadWrapper extends LightningElement {
  constructor() {
    super();
  }

  // Class declaration
  documents = [];
  columns = columns;
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
  // Event to convert modified document from base64 -> blob -> file and add it to the data-table
  handleSaveDocument(event) {
    try {
      // base64 string document
      let strBase64Data = event.detail.doc;

      // delete previous document
      this.deleteRow(this.findRowIndexById(event.detail.id));

      // covert base64 to binary (blob)
      let blob = new Blob([base64ToArrayBuffer(strBase64Data)], {
        encoding: "UTF-8",
        type: assetToType(this.assetType)
      });

      // convert to file
      let fileName =
        this.document.name.substr(0, this.document.name.lastIndexOf(".") + 1) + //parse file name
        blob.type.substr(blob.type.lastIndexOf("/") + 1, blob.type.length); //parse file extension

      let newfile = new File([blob], fileName, {
        lastModified: Date.now(),
        type: blob.type
      });

      //add document to data-table
      this.documents = [
        ...this.documents,
        {
          id: Date.now(),
          name: newfile.name,
          size: bytesToSize(newfile.size),
          type: newfile.type,
          file: newfile
        }
      ];

      //hide modal window
      this.template.querySelector("c-modal").hide();
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
  // Event to show uploaded document in viewer
  handleFileUploaded(event) {
    try {
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
      this.template.querySelector("c-modal").show();
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
  // Event to show document
  handleMainDocument() {
    this.template.querySelector("c-document-viewer").viewDocument();
  }

  //////////////////////////////////////////////////////////////////////////////////////
  // Event of an action taken on data-table
  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case "delete":
        this.deleteDocument(row);
        break;
      case "view":
        this.showDocument(row);
        break;
      case "save":
        this.saveDocument(row);
        break;
      default:
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////
  // Delete document from data-table by row
  deleteDocument(row) {
    const { id } = row;
    const index = this.findRowIndexById(id);
    this.deleteRow(index);
  }

  //////////////////////////////////////////////////////////////////////////////////////
  // Delete document from data-table by row index
  deleteRow(index) {
    if (index !== -1) {
      this.documents = this.documents
        .slice(0, index)
        .concat(this.documents.slice(index + 1));
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////
  // Get data-table row idex
  findRowIndexById(id) {
    let ret = -1;
    this.documents.some((row, index) => {
      if (row.id === id) {
        ret = index;
        return true;
      }
      return false;
    });
    return ret;
  }

  //////////////////////////////////////////////////////////////////////////////////////
  // Show selected document in viewer
  showDocument(row) {
    try {
      //get selected file
      this.document = this.documents.find((x) => x.id === row.id);

      //show modal window
      this.header = this.document.name;
      this.template.querySelector("c-modal").show();
    } catch (err) {
      showMessage(
        err,
        "Error Displaying",
        "An error occurred while displaying document.",
        "error"
      );
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////
  // Save document to cloud
  async saveDocument(row) {
    try {
      this.document = this.documents.find((x) => x.id === row.id).file;
      let url = await saveDocument(this.document, this.payLoad);

      if (url != null) {
        //show success message
        showMessage(
          null,
          "Success",
          "Your file has been successfully uploaded",
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
  handleCloseModal() {
    this.document = null;
  }
  //////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////
}