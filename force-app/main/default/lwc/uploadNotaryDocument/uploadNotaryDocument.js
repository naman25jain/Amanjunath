import { LightningElement, api } from "lwc";
import getContactId from "@salesforce/apex/CommunityIdentityVerificationController.getContactId";
import getCaseNumberByServiceAndRecordType from "@salesforce/apex/CommunityIdentityVerificationController.getCaseNumberByServiceAndRecordType";
import eifDownloadUrl from "@salesforce/label/c.EIF_Download_URL";
import { bytesToSize, base64ToArrayBuffer, showMessage, assetToType } from "c/common";
import { saveDocument } from "c/cloudStorageSave";

const actions = [
  { label: "View", name: "view" },
  { label: "Delete", name: "delete" },
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
      iconName: "utility:preview",
    },
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
      iconName: "utility:delete",
    },
  },
  {
    type: "action",
    fixedWidth: 48,
    typeAttributes: { rowActions: actions },
  },
];

export default class UploadNotaryDocument extends LightningElement {
  constructor() {
    super();
  }

  // Class declaration
  documents = [];
  columns = columns;
  header;
  document;
  disableSave = this.documents.length == 0;
  eifDownloadLink;
  payLoad = {};
  caseNumber;
  docSaved = false;
  assetType = "";
  
  // Public properties exposed as Design Parameters
  @api maxAllowedFileSize;
  @api acceptedFileFormats = "";
  @api enableRedaction = false;
  @api enableAnnotation = false;

  //////////////////////////////////////////////////////////////////////////////////////
  connectedCallback() {
    this.buildEifDownloadLink();
    this.buildPayload();
    this.setCaseNumber();
  }
  //////////////////////////////////////////////////////////////////////////////////////
  renderedCallback() {
    this.disableSave = this.documents.length == 0;
  }
  //////////////////////////////////////////////////////////////////////////////////////
  buildEifDownloadLink() {
    let parsedUrl = new URL(window.location.href);
    let splitUrl = parsedUrl.host.split("-");
    // Construct Download Link
    this.eifDownloadLink =
      "https://ecfmgb2--" +
      splitUrl[0] +
      "--c.documentforce.com/" +
      eifDownloadUrl;
  }
  //////////////////////////////////////////////////////////////////////////////////////
  setCaseNumber() {
    getCaseNumberByServiceAndRecordType({
      service: this.payLoad.service,
      recordType: "Identity Verification",
    }).then((result) => {
      if (result != null) {
        this.caseNumber = result;
        this.payLoad.casenumber = result;
      }
    });
  }
  //////////////////////////////////////////////////////////////////////////////////////
  buildPayload() {
    let parsedUrl = new URL(window.location.href);
    //service(EPIC, ECFMG...)
    let service = parsedUrl.searchParams.get("service");
    if (service != null) {
      this.payLoad.service = parsedUrl.searchParams.get("service");
    }
    // case id
    let caseid = parsedUrl.searchParams.get("id");
    if (caseid != null) {
      this.payLoad.caseid = parsedUrl.searchParams.get("id");
    }
    // case number

    // contact id
    getContactId().then((result) => {
      if (result !== "") {
        this.payLoad.contactid = result;
      }
    });
  }
  //////////////////////////////////////////////////////////////////////////////////////

  // Event to convert modified document from base64 -> blob -> file and add it to the data-table
  handleSaveDocument(event) {
    try {
      // base64 string document
      let strBase64Data = event.detail.doc;

      // delete all the documents (only 1 upload is allowed)
      this.documents = [];

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
          file: newfile,
        },
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
        file: event.detail.document,
      };

      //show modal window
      this.header = this.document.name;
      this.template.querySelector("c-modal").show(); //this will initialize loading of document viewer
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
  handleShowDocument() {
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
      this.template.querySelector("c-modal").show(); //this will initialize loading of document viewer
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
  async handleSave() {
    try {
      this.document = this.documents[0].file;

      let url = await saveDocument(this.document, this.payLoad);

      if (url != null) {
        //show success message
        this.docSaved = true;
      }
    } catch (err) {
      showMessage(
        err,
        "Error Saving",
        "An error occurred while saving notarized identification form.",
        "error"
      );
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  handleCancel() {
    //Redirect to Home
    window.open("/s/", "_top");
  }
  //////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////
}