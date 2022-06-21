/**
 *   Sampath Karnati
 * * Community Applicant Confirmation/Affirmation for Online Notary
 */
import { LightningElement } from "lwc";
import { showMessage } from "c/common";
import getTermsAndConditions from "@salesforce/apex/TermsAndConditionsController.getTermsAndConditions";
import getAssetByCaseContact from "@salesforce/apex/AssetsController.getAssetByCaseContact";
import getAzureUrl from "@salesforce/apex/OnlineNotaryConfirmationController.getAzureUrl";
import getConstants from "@salesforce/apex/OnlineNotaryConfirmationController.getConstants";
import publishNotaryTransactionRequestEvent from "@salesforce/apex/OnlineNotaryConfirmationController.publishNotaryTransactionRequestEvent";

//Constants
const READ_ACCESS_LEVEL = "READ";

export default class OnlineNotaryConfirmation extends LightningElement {
  // Constants Class
  constants;

  // Terms and conditions
  termsAndConditions;

  // Disabled on load
  disableSave = true;

  // Document Viewer Properties
  header;
  documentUrl;
  enableRedaction = false;
  enableAnnotation = false;

  // Platform Events
  notaryTransactionEventPublished;

  // Case Details
  caseId;

  // Id Form Asset
  idFormAsset;

  isLoading = false;
  //////////////////////////////////////////////////////////////////////////////////////
  /**
   * * load start-up data
   */
  connectedCallback() {
    try {
      this.isLoading = true; //turn on spinner

      this.loadStartupData();
    } catch (err) {
      showMessage(
        err,
        "Error",
        "An error occurred loading start-up data.",
        "error"
      );
    } finally {
      this.isLoading = false; // turn off spinner
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  async loadStartupData() {
    try {
      // Set Constants
      await this.setConstants();

      // Set Case Id
      await this.setCaseId();

      //Set Id Form Asset
      await this.setIdFormAsset();

      //Set Terms and Conditions
      await this.setTermsAndConditions();
    } catch (err) {
      console.err(err);
      throw err;
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  async setConstants() {
    try {
      this.constants = await getConstants();
    } catch (err) {
      console.err(err);
      throw err;
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  async setCaseId() {
    try {
      // get case from query string
      this.caseId = new URL(window.location.href).searchParams.get("id");
    } catch (err) {
      console.err(err);
      throw err;
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  async setIdFormAsset() {
    try {
      this.idFormAsset = await getAssetByCaseContact({
        caseId: this.caseId,
        name: this.constants.LWC_ASSET_NAME_ID_FORM_TEMPLATE,
        status: this.constants.LWC_ASSET_STATUS_INPROGRESS,
      });
    } catch (err) {
      console.err(err);
      throw err;
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  async setTermsAndConditions() {
    try {
      this.termsAndConditions = await getTermsAndConditions({
        name: this.constants.TERMS_AND_COND_NAME_ONLINE_NOTARY_CONFIRMATION,
        productName: this.constants
          .PRODUCT_NAME_ONLINE_NOTARY_CONFIRMATION_LEGAL_TERMS,
      });
    } catch (err) {
      console.err(err);
      throw err;
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  handleAffirmation(event) {
    try {
      this.disableSave = !event.target.checked;
    } catch (err) {
      showMessage(
        err,
        "Error",
        "An error occurred while handling affirmation.",
        "error"
      );
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  async handleSave() {
    try {
      this.isLoading = true; //turn on spinner

      // publish Notary Transaction Request Event
      this.notaryTransactionEventPublished = await publishNotaryTransactionRequestEvent(
        {
          caseId: this.caseId,
          termsAndCondition: this.termsAndConditions,
          assetId: this.idFormAsset.Id,
        }
      );
    } catch (err) {
      showMessage(err, "Error", "An error occurred while saving.", "error");
    } finally {
      this.isLoading = false; // turn off spinner
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  handleCancel() {
    try {
      //Redirect to Home
      window.open("/s/", "_top");
    } catch (err) {
      showMessage(
        err,
        "Error",
        "An error occurred redirecting to home.",
        "error"
      );
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  handleIDFormPreview(){
    getAzureUrl({caseId: this.caseId})
      .then(url => {
        window.open(url, "_blank");
      });
  }
  //////////////////////////////////////////////////////////////////////////////////////
  handleShowDocument() {
    this.template.querySelector("c-document-viewer").viewUrl(this.documentUrl);
  }
  //////////////////////////////////////////////////////////////////////////////////////
  handleCloseModal() {
    // Do any cleanup here related to Document Viewer
    this.header = null;
    this.documentUrl = null;
  }
  //////////////////////////////////////////////////////////////////////////////////////
  handleOK() {
    //Redirect to Home
    window.open("/s/", "_top");
  }
  //////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////
}