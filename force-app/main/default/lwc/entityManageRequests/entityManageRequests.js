import {
  LightningElement,
  track,api
} from 'lwc';

export default class EntityManageRequests extends LightningElement {

  @track showListView = true;
  @track caseDetailId;
  @track contactDetailId;
  @track curEnt;

  @api
  get currentEntity() {
    return this._currentEnt;
  }
  set currentEntity(value) {
    this.setAttribute('currentEntity', value);
    this._currentEnt = value;
  }
  @track _currentEnt;

  showManageRequestPage(event) {
    this.showListView   = false;
    this.caseDetailId   = event.detail.caseId;
  }

  showManageRequestList(event){
    this.showListView = true;
  }
  @api refreshSetup(){
    this.template.querySelector('c-entity-case-manage-request').refreshSetup();
  }
}