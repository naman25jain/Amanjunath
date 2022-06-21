import { LightningElement } from "lwc";
import getOnlineNotaryTransaction from "@salesforce/apex/OnlineNotaryTransactionController.getOnlineNotaryTransaction";
import getConstants from "@salesforce/apex/OnlineNotaryConfirmationController.getConstants";
import { showMessage } from "c/common";

export default class OnlineNotarySessionLinks extends LightningElement {
  initiateNotarySession;
  notarySessionLink;
  constants;

  // Case Details
  caseId;
  //////////////////////////////////////////////////////////////////////////////////////
  /**
   * * load start-up data
   */
  connectedCallback() {
    try {
      // Set Constants
      this.setConstants();

      // Set Case Id
      this.setCaseId();
    } catch (err) {
      showMessage(
        err,
        "Error",
        "An error occurred loading start-up data.",
        "error"
      );
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  async setConstants() {
    try {
      this.constants = await getConstants();
    } catch (err) {
      throw "An error occured loading constants";
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  async setCaseId() {
    try {
      // get case from query string
      this.caseId = new URL(window.location.href).searchParams.get("id");
    } catch (err) {
      throw "An error occured loading case id";
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  async handleNotarySession() {
    try {
      // Get online notary transaction session link
      let onlineNotaryTransaction = await getOnlineNotaryTransaction({
        caseId: this.caseId,
        caseStatus: this.constants
          .LWC_CASE_STATUS_ONLINE_NOTARY_SESSION_CREATED,
      });

      // bind the session link
      this.notarySessionLink = onlineNotaryTransaction.Signing_Session_Url__c;
      // Show modal popup
      this.initiateNotarySession = true;
    } catch (err) {
      showMessage(
        err,
        "Error",
        "An error occured displaying notary session links.",
        "error"
      );
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  handleProceed() {
    try {
      //Redirect to live notary session
      window.open(this.notarySessionLink, "_self");
    } catch (err) {
      showMessage(
        err,
        "Error",
        "An error occured redirecting to live notary session.",
        "error"
      );
    }
  }
  //////////////////////////////////////////////////////////////////////////////////////
  handleBack() {
    //Close modal
    this.initiateNotarySession = false;
  }
  //////////////////////////////////////////////////////////////////////////////////////
}