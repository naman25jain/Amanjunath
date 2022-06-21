import { LightningElement, api, wire } from 'lwc';

export default class AffirmationRender extends LightningElement {
    @api renderData;
    @api childAndParentData;
    @api affrimationRecord;
    @api allfiledsinscreen;
    isChildRecords;
    isChild;
    objToParent = {};
    @api populateValues;
    @api mapAPIKeyAndRecord;
    objFieldsToParent = [];

    @api
    get initialChildKey() {
        return this.isChildRecords;
    };

    set initialChildKey(value) {
        if (value) {
            this.isChildRecords = this.childRecordsBasedOnParentKey(value);
            if (this.isChildRecords) {
                this.isChild = true;
            }
            else {
                this.isChild = false;
            }
        }
    }

    renderedCallback() {
        if (this.objFieldsToParent) {
            this.dispatchEvent(new CustomEvent('fieldtocapture', { bubbles: true, composed: true, detail: this.objFieldsToParent }));
        }
    }

    processMetadatarecords(lstRecords) {
        let objData = [];
        if (lstRecords) {
            lstRecords.forEach(res => {
                let obj = Object.assign({}, res);
                let objOptions = [];

                if (obj.Affirmation_Field_Type__c) {
                    if (obj.Affirmation_Field_Type__c === 'Picklist') {
                        objOptions.push({
                            label: '-None-', value: '-None-'
                        });
                        obj.isPicklist = true;
                    }
                    else if (obj.Affirmation_Field_Type__c === 'Checkbox') {
                        obj.isCheckbox = true;

                        obj.isChecked = this.checkValue(obj.Affirmation_Field_API_Name__c, 'true', obj.Affirmation_Field_Type__c, obj);
                        if (!this.populateValues.hasOwnProperty(obj.Affirmation_Field_API_Name__c)) {
                            this.populateValues[obj.Affirmation_Field_API_Name__c] = 'false';
                        }
                    }
                    else if (obj.Affirmation_Field_Type__c === 'Radio') {
                        obj.isRadio = true;
                    }
                    else if (obj.Affirmation_Field_Type__c === 'Text') {
                        obj.isTextarea = true;
                        this.checkValue(obj.Affirmation_Field_API_Name__c, 'Text', obj.Affirmation_Field_Type__c, obj);
                    }
                    else if (obj.Affirmation_Field_Type__c === 'Date') {
                        obj.isDate = true;
                        this.checkValue(obj.Affirmation_Field_API_Name__c, 'Date', obj.Affirmation_Field_Type__c, obj);
                    }
                }

                if (obj.Affirmation_List_of_Field_Values__c) {
                    obj.Affirmation_List_of_Field_Values__c.split('@~').forEach(val => {
                        let isChecked = this.checkValue(obj.Affirmation_Field_API_Name__c, val, obj.Affirmation_Field_Type__c, obj)
                        objOptions.push({
                            label: val.trim(),
                            value: val.trim(),
                            checked: isChecked
                        });
                        if (isChecked) {
                            if (obj.Affirmation_Static_Values__c) {
                                let mapStaticValues = new Map(Object.entries(JSON.parse(obj.Affirmation_Static_Values__c)));
                                obj.isStaticValue = mapStaticValues && mapStaticValues.has(val.trim()) ? mapStaticValues.get(val.trim()) : '';
                            }
                        }
                    });
                }

                if (objOptions) {
                    obj.Affirmation_List_of_Field_Values__c = objOptions;
                }

                this.objToParent = obj.Affirmation_Field_API_Name__c;
                this.objFieldsToParent.push(obj.Affirmation_Field_API_Name__c);
                
                objData.push(obj);

            });
        }

        return objData;
    }

    childRecordsBasedOnParentKey(key) {
        if (this.childAndParentData && this.childAndParentData.mapChildRecords && key) {
            const newMap = new Map(Object.entries(this.childAndParentData.mapChildRecords));
            if (newMap.has(key)) {
                return [...this.processMetadatarecords(newMap.get(key))];
            }
        }
        else {
            return null;
        }
    }

    handleChange(event) {
        let value = '';
        if (event.target.type == 'checkbox') {
            value = event.target.checked;
        }
        else if ((event.target.name == 'textarea' && event.target.value.trim() == '') || event.target.value == '-None-') {
            value = 'blank'
        }
        else {
            value = event.target.value;
        }

        if ((event.target.dataset.id || event.currentTarget.dataset.id) && value.toString()) {
            this.parentKey = (event.currentTarget.dataset.id ? event.currentTarget.dataset.id : event.target.dataset.id) + '@~' + value;

            const fieldName = (event.currentTarget.dataset.id ? event.currentTarget.dataset.id : event.target.dataset.id);
            let finalMap = {
                fieldType: fieldName, fieldvalue: (value == 'blank' ? '' : value), type: event.target.type
            };

            this.affrimationRecord = finalMap;
        }



        if (event.target.type && event.target.type == 'radio') {
            let targets = this.template.querySelectorAll(`[data-id="${event.currentTarget.dataset.id}"]`);
            if (targets) {
                targets.forEach(tg => tg.checked = event.target.value === tg.value);
            }
        }

        if (this.childAndParentData && this.childAndParentData.mapChildRecords && this.parentKey) {
            this.isChildRecords = this.childRecordsBasedOnParentKey(this.parentKey);
            if (this.isChildRecords) {
                this.isChild = true;
            }
            
            let renderToChange = Object.assign({}, this.renderData);
            let fieldAPIName = (event.target.dataset.id ? event.target.dataset.id : event.currentTarget.dataset.id);
            let allDataInfo;
            if(this.mapAPIKeyAndRecord) {
               allDataInfo = new Map(Object.entries(this.mapAPIKeyAndRecord));
            }
            
            if (allDataInfo && allDataInfo.has(fieldAPIName)) {
                if (allDataInfo.get(fieldAPIName).Affirmation_Static_Values__c) {
                    let mapStaticValues = new Map(Object.entries(JSON.parse(allDataInfo.get(fieldAPIName).Affirmation_Static_Values__c)));
                    renderToChange['isStaticValue'] = mapStaticValues && mapStaticValues.has(value.toString().trim()) ? mapStaticValues.get(value.toString().trim()) : '';
                    this.renderData = renderToChange;
                }
            }
        }

        const dataToparent = this.affrimationRecord;
        this.dispatchEvent(new CustomEvent('selectedvalues', { bubbles: true, composed: true, detail: { dataToparent } }));

    }

    checkValue(fieldType, value, type, obj) {
        if (this.populateValues && fieldType && value.toString() && type) {
            let newMap = new Map(Object.entries(this.populateValues));
            if (type === 'Text') {
                if (newMap.has(fieldType)) {
                    obj.TextareaValue = newMap.get(fieldType);
                }
            }else if (type === 'Date') {
                if (newMap.has(fieldType)) {
                    obj.dateValue = newMap.get(fieldType);
                }
            }else if (newMap.has(fieldType)) {
                this.parentKey = fieldType + '@~' + value;
                if (newMap.get(fieldType).trim() == value.trim()) {
                    if (this.childAndParentData && this.childAndParentData.mapChildRecords && this.parentKey) {
                        obj.childKey = this.parentKey;
                    }
                    return true;
                }
            }
            else {
                return false;
            }
        }
        else {
            return false;
        }

    }
}