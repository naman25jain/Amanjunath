import { LightningElement, track, api } from 'lwc';
export default class EvEntity extends LightningElement {
  @track showListView = true;
  @track casDetValue;
  @track conDetValue;
  @track curEnt;
  @track refreshList = false;
  @api
  get curEntity() {
    return this.curEnt;
  }
  set curEntity(value) {
    this.setAttribute('curEntity', value);
    this.curEnt = value;
  }
  showEVFormPage(event) {
    this.showListView = false;
    this.casDetValue = event.detail.cas;
    this.conDetValue = event.detail.con;
  }
  showEVCasesList(event) {
    if (event.detail.updatedEV) {
      this.refreshList = true;
    }
    this.showListView = true; 
  }
  @api refreshSetup(){
    this.template.querySelector('c-ev-entity-list-views').refreshSetup();
  }
}