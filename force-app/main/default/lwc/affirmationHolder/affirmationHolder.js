import { LightningElement, api, track } from 'lwc';

export default class AffirmationHolder extends LightningElement {
    @api mdtRecords;
    @api childAndParentData;
    @api selectedAFDataVales;
    @api populateValues;
    @api mapAPIKeyAndRecord;
}