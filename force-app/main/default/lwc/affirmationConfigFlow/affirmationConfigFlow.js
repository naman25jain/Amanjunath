import { LightningElement, api, wire } from 'lwc';
import configs from '@salesforce/apex/AffirmationConfigController.getAffirmnationConfigs';
import createAFRecord from '@salesforce/apex/AffirmationConfigController.createAffirmationRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import TOASTMESSAGECSS from '@salesforce/resourceUrl/ToastMessageCSS';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationBackEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';
export default class AffirmationConfigFlow extends LightningElement{
    @api strScreenName;
    populateValues;
    @api recordId;
    @api strRecordId;
    @api parentKey;
    @api strAffirmationRecId;
    @api afRecordTypeDevName;
    @api isPrevious;
    @api isNext;
    @api isFinish;
    @api parentData = [];
    @api childAndParentData;
    @api mapAPIKeyAndRecord
    @api selectedAFDataVales;
    showButton = true;
    @api preLoadedValues = [];
    @api flowHeader;
    errorMessage;
    @api affirmationCurentId;
    isSpinner = false;
    showNavgButtons = false;
    @api savedAfRecord;
    @api fieldToCapture = [];
    @api affirmationRecord;
    @api strScreenInstructions;
    isCssLoaded = false;
    lstParentRecords;
    criteriaFields = new Map();
    caseFieldValues;
    @api flowVariables;
    affAllFieldValues;
    removedValues = [];
    @api fieldsToUpdate;
    @wire(CurrentPageReference) pageRef;
    renderedCallback() {
        if (this.isCssLoaded) return
        this.isCssLoaded = true;
        loadStyle(this, TOASTMESSAGECSS).then(() => {
            console.log('loaded');
        })
            .catch(error => {
                this.processErrorMessage(error);
            });
    }

    connectedCallback() {
        this.strRecordId;
        this.recordId;
        if (!this.strRecordId) {
            this.strRecordId = this.recordId;
        }
        this.getAFConfigs(this.strScreenName, this.strRecordId, this.affirmationCurentId, this.afRecordTypeDevName);
    }

    onNextButtonClick() {
        this.showNavgButtons = false;
        this.validateAFValues('Next');
    }

    onFinishButtonClick() {
        this.showNavgButtons = false;
        this.validateAFValues('Finish');
    }

    onPreviousButtonClick() {
        this.showNavgButtons = false;
        this.dispatchEvent(new FlowNavigationBackEvent());
        this.getAFConfigs(this.strScreenName, this.strRecordId, this.affirmationCurentId, this.afRecordTypeDevName);
    }

    getAFConfigs(strScreenName, caseId, affirmationId, afRecordTypeDevName){
        this.isSpinner = true;
        let mapFieldsToUpdate = this.fieldsToUpdate ? new Map(Object.entries(JSON.parse(this.fieldsToUpdate))): '';
        configs({
            strScreenName: strScreenName,
            parentRecordId: caseId,
            strAffirmationRecId: affirmationId,
            strAffirmationRecordType: afRecordTypeDevName,
            fieldToUpdate: Object.fromEntries(mapFieldsToUpdate)
        })
        .then(result=>{
            this.isSpinner = false;
            this.showNavgButtons = true;
            if(result){
                this.childAndParentData = result;
                if(result.mapFiledNameAndValues){
                    this.populateValues = result.mapFiledNameAndValues;
                    this.preLoadedValues = result.mapFiledNameAndValues;
                }
                if(result.mapAPIKeyAndRecord){
                    this.mapAPIKeyAndRecord = result.mapAPIKeyAndRecord;
                }
                if(result.strAffirmationId){
                    this.affirmationCurentId = result.strAffirmationId;
                }
                if(result.caseFieldValues){
                    this.caseFieldValues = result.caseFieldValues;
                }
                if(result.affAllFieldValues){
                    this.affAllFieldValues = result.affAllFieldValues;
                }
                this.lstParentRecords = result.lstParentRecords;
                this.parentData = [...this.processMetadatarecords(result.lstParentRecords)];
            }
        })
        .catch(error=>{ 
            this.processErrorMessage(error);
        });
    }
    fieldsToCheck(event) {
        if(event.detail) {
            this.fieldToCapture = [...new Set([...this.fieldToCapture, ...event.detail])];
        }
    }

    validateAFValues(eventType){
        if (this.fieldToCapture && this.preLoadedValues){
            this.errorMessage = '';
            let parentKeyAndChildKey = new Map();
            let getFieldInfos = this.preLoadedValues ? new Map(Object.entries(this.preLoadedValues)) : '';
            let allDataInfo = this.preLoadedValues ? new Map(Object.entries(this.mapAPIKeyAndRecord)) : '';
            let prAndChilds = this.childAndParentData.mapChildsWithKey ? new Map(Object.entries(this.childAndParentData.mapChildsWithKey)) : {};
            let mapFieldsToUpdate = this.fieldsToUpdate ? new Map(Object.entries(JSON.parse(this.fieldsToUpdate))): '';
            if(prAndChilds){
                for(let [key, value] of prAndChilds.entries()){
                    if(key.includes('@~')){
                        let dataTo = key.split('@~');
                        if(!parentKeyAndChildKey.has(dataTo[0])){
                            let newSetVales = new Set();
                            parentKeyAndChildKey.set(dataTo[0], newSetVales.add(dataTo[1].toString()));
                        }
                        else{
                            parentKeyAndChildKey.get(dataTo[0]).add(dataTo[1].toString());
                        }
                    }
                }
            }
            let fieldsToRemove = [];
            let fieldsToFinal = [...this.fieldToCapture];
            this.fieldToCapture.forEach(field=>{
                let fieldValue = '';
                if(getFieldInfos.has(field)){
                    fieldValue = getFieldInfos.get(field);
                }
                this.captureTheChildFields(parentKeyAndChildKey, field, fieldValue, prAndChilds, fieldsToRemove);
                if(fieldsToRemove){
                    for(let fieldToVerify of fieldsToRemove){
                        if(allDataInfo.has(fieldToVerify)){
                            let rec = allDataInfo.get(fieldToVerify);
                            if(rec && rec.Affirmation_Field_Type__c == 'Checkbox'){
                                getFieldInfos.set(fieldToVerify, 'false');
                            }
                            else{
                                getFieldInfos.set(fieldToVerify, null);
                            }
                        }
                        if(fieldsToFinal.includes(fieldToVerify)){
                            fieldsToFinal.splice(fieldsToFinal.indexOf(fieldToVerify), 1);
                        }
                    }
                }
            });
            let isValid = fieldsToFinal.every(field=>{
                let rec;
                if(allDataInfo.has(field)){
                    rec = allDataInfo.get(field);
                }
                if(getFieldInfos.has(field)){
                    if((rec.Affirmation_Field_Type__c == 'Checkbox' && rec.Required__c && getFieldInfos.get(field).toString() == 'false') || (!getFieldInfos.get(field).toString() && rec.Required__c)){
                        return false;
                    }
                    else{
                        return true;
                    }
                }
                else if(rec && !rec.Required__c){
                    return true;
                }
                else{
                    return false;
                }
            });
            if(mapFieldsToUpdate){
                for(let [key, value] of mapFieldsToUpdate){
                    getFieldInfos.set(key, value);
                }
            }
            if(!isValid){
                this.showtToastMessage('Error!', 'Please select/enter the affirmation values to process', 'error');
                this.isSpinner = false;
                this.showNavgButtons = true;
            }
            else{
                this.isSpinner = true;
                this.saveAfRecord(Object.fromEntries(getFieldInfos), eventType);
                this.errorMessage = '';
            }
        }
    }
    captureTheChildFields(parentKeyAndChildKey, field, fieldValue, prAndChilds, fieldsToRemove) {
        if (parentKeyAndChildKey && parentKeyAndChildKey.has(field)) {
            let allfieldValues = parentKeyAndChildKey.get(field);
            if (allfieldValues) {
                allfieldValues.forEach(val => {
                    let keyToCheck = field + '@~' + val;
                    if (fieldValue && val != fieldValue.toString() && prAndChilds.has(keyToCheck)) {
                        let fieldToCheck = prAndChilds.get(keyToCheck);
                        if (fieldToCheck) {
                            fieldToCheck.forEach(fieldTo => {
                                fieldsToRemove.push(fieldTo);
                                this.captureTheChildFields(parentKeyAndChildKey, fieldTo, fieldValue, prAndChilds, fieldsToRemove);
                            })
                        }
                    }
                    else {
                        return;
                    }
                });
            }
        }
    }
    selectedAFData(event){
        if(event.detail && event.detail.dataToparent && this.childAndParentData){
            if(this.fieldToCapture && !this.fieldToCapture.includes(event.detail.dataToparent.fieldType)){
                this.fieldToCapture.push(event.detail.dataToparent.fieldType);
            }
            let getFieldInfo = Object.assign({}, this.preLoadedValues);
            if(event.detail.dataToparent.type === 'checkbox'){
                getFieldInfo[event.detail.dataToparent.fieldType] = event.detail.dataToparent.fieldvalue.toString();
            }else{
                getFieldInfo[event.detail.dataToparent.fieldType] = event.detail.dataToparent.fieldvalue;
            }
            this.preLoadedValues = getFieldInfo;
            if(this.criteriaFields.has(event.detail.dataToparent.fieldType)){
                this.parentData = this.processMetadatarecords(this.lstParentRecords);
            }
        }
    }
    async saveAfRecord(fieldValues, eventType){
        await createAFRecord({strScreenName: this.strScreenName, strParentRecord: this.strRecordId, strObjectName: 'Affirmation__c', fieldValues: fieldValues, strAFrecordId: this.affirmationCurentId, strRecordTypeDevName: this.afRecordTypeDevName})
            .then(result=>{
                if(result){
                    this.savedAfRecord = result;
                    if(result.objAfRecord){
                        this.dispatchEvent(new FlowAttributeChangeEvent('affirmationRecord', JSON.parse(result.objAfRecord)));
                        if(eventType == 'Next'){
                            this.dispatchEvent(new FlowNavigationNextEvent());
                        }
                        else if(eventType == 'Finish'){
                            this.dispatchEvent(new FlowNavigationFinishEvent());
                        }
                        this.dispatchEvent(new CustomEvent('affirmationrecord', {bubbles: true, composed: true, detail: result.objAfRecord}));
                    }
                    else if(result.strError){
                        if(result.strError.includes('@')){
                            result.strError = result.strError.replaceAll('@', '\n');
                        }
                        this.showtToastMessage('Error!', result.strError, 'error');
                        this.showNavgButtons = true;
                    }
                    this.isSpinner = false;
                }
            })
            .catch(error=>{
                this.processErrorMessage(error);
                this.isSpinner = false;
            })
    }
    processMetadatarecords(lstRecords){
        let objData = [];
        if(lstRecords){
            lstRecords.forEach(res=>{
                let obj = Object.assign({}, res);
                let objOptions = [];
                let visible = true;
                if(obj.Visibility_Conditions__c){
                    visible = this.checkVisibilityConditions(obj);
                    this.updatePreLoadedValues(obj, visible);
                }
                if(obj.Affirmation_Field_Type__c){
                    if(obj.Affirmation_Field_Type__c === 'Picklist'){
                        obj.isPicklist = true;
                        objOptions.push({
                            label: '-None-',
                            value: '-None-'
                        });
                    }else if(obj.Affirmation_Field_Type__c === 'Checkbox'){
                        obj.isCheckbox = true;
                        obj.isChecked = this.checkValue(obj.Affirmation_Field_API_Name__c, 'true', obj.Affirmation_Field_Type__c, obj);
                        if(!this.populateValues.hasOwnProperty(obj.Affirmation_Field_API_Name__c)){
                            this.populateValues[obj.Affirmation_Field_API_Name__c] = 'false';
                        }
                    }else if(obj.Affirmation_Field_Type__c === 'Radio'){
                        obj.isRadio = true;
                    }else if(obj.Affirmation_Field_Type__c === 'Text'){
                        obj.isTextarea = true;
                        this.checkValue(obj.Affirmation_Field_API_Name__c, 'Text', obj.Affirmation_Field_Type__c, obj);
                    }else if(obj.Affirmation_Field_Type__c === 'Date'){
                        obj.isDate = true;
                        this.checkValue(obj.Affirmation_Field_API_Name__c, 'Date', obj.Affirmation_Field_Type__c, obj);
                    }
                }
                if(obj.Affirmation_List_of_Field_Values__c){
                    obj.Affirmation_List_of_Field_Values__c.split('@~').forEach(val=>{
                        let isChecked = this.checkValue(obj.Affirmation_Field_API_Name__c, val, obj.Affirmation_Field_Type__c, obj);
                        objOptions.push({
                            label: val.trim(),
                            value: val.trim(),
                            checked: isChecked
                        });
                        if(isChecked){
                            if(obj.Affirmation_Static_Values__c){
                                let mapStaticValues = new Map(Object.entries(JSON.parse(obj.Affirmation_Static_Values__c)));
                                obj.isStaticValue = mapStaticValues && mapStaticValues.has(val.trim()) ? mapStaticValues.get(val.trim()) : '';
                            }
                        }
                    });
                }
                if(objOptions){
                    obj.Affirmation_List_of_Field_Values__c = objOptions;
                }
                if(visible){
                    this.fieldToCapture.push(obj.Affirmation_Field_API_Name__c);
                    objData.push(obj);
                }
            });
        }     
        return objData;
    }
    updatePreLoadedValues(obj, visible){
        if(!visible){
            if(this.fieldToCapture.includes(obj.Affirmation_Field_API_Name__c)){
                this.fieldToCapture.splice(this.fieldToCapture.indexOf(obj.Affirmation_Field_API_Name__c), 1);
            }
            if(this.preLoadedValues[obj.Affirmation_Field_API_Name__c]){
                let getFieldInfo = Object.assign({}, this.preLoadedValues);
                this.removedValues[obj.Affirmation_Field_API_Name__c] = getFieldInfo[obj.Affirmation_Field_API_Name__c];
                if(obj.Affirmation_Field_Type__c == 'Checkbox'){
                    getFieldInfo[obj.Affirmation_Field_API_Name__c] = false;
                }else{
                    getFieldInfo[obj.Affirmation_Field_API_Name__c] = null;
                }
                this.preLoadedValues = getFieldInfo;
            }
        }else{
            if(!this.preLoadedValues[obj.Affirmation_Field_API_Name__c] && this.removedValues[obj.Affirmation_Field_API_Name__c]){
                let getFieldInfo = Object.assign({}, this.preLoadedValues);
                getFieldInfo[obj.Affirmation_Field_API_Name__c] = this.removedValues[obj.Affirmation_Field_API_Name__c];
                this.preLoadedValues = getFieldInfo;
            }
        }
    }
    checkValue(fieldType, value, type, obj){
        if (this.preLoadedValues && fieldType && value.toString() && type){
            let newMap = new Map(Object.entries(this.preLoadedValues));
            if (type === 'Text'){
                if(newMap.has(fieldType)){
                    obj.TextareaValue = newMap.get(fieldType);
                }
            }else if(type === 'Date'){
                if(newMap.has(fieldType)){
                    obj.dateValue = newMap.get(fieldType);
                }
            }else if(newMap.has(fieldType)){
                this.parentKey = fieldType + '@~' + value;
                let finalMap = {...this.selectedAFDataVales};
                let currentobj = {
                    [fieldType]: value
                };
                finalMap = {
                    ...finalMap,
                    ...currentobj
                };
                this.selectedAFDataVales = finalMap;
                if(newMap.get(fieldType) === value){
                    if(this.childAndParentData && this.childAndParentData.mapChildRecords && this.parentKey){
                        obj.childKey = this.parentKey;
                    }
                    return true;
                }
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
    showtToastMessage(title, message, varient) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: varient,
            // mode: 'sticky'
        }));
    }

    processErrorMessage(message) {
        let errorMsg = '';
        if (message) {
            if (message.body) {
                if (Array.isArray(message.body)) {
                    errorMsg = message.body.map(e => e.message).join(', ');
                } else if (typeof message.body.message === 'string') {
                    errorMsg = message.body.message;
                }
            }
            else {
                errorMsg = message;
            }

        }
        this.showtToastMessage('Error!', errorMsg, 'error');
    }
    checkVisibilityConditions(obj){
        let visExp = obj.Visibility_Conditions__c;
        let tempAnd;
        let tempOr;
        let temp = visExp.split('&&');
        let exp = '';
        if(visExp.includes('&&')){
            tempAnd = visExp.split('&&');
            exp = this.solveExpressions(obj, tempAnd, '&&');
        }else{
            exp = visExp;
        }
        if(exp.includes('||')){
            tempOr = exp.split('||');
            exp = this.solveExpressions(obj, tempOr, '||');
        }
        if(!visExp.includes('&&') && !visExp.includes('||')){
            exp = this.solveExpressions(obj, temp, '||');
        }
        return eval(exp);
    }
    solveExpressions(obj, exp, operator){
        let finalExp = '';
        exp.forEach(temp=>{
            let tempObj = []; 
            tempObj.temp1 = temp;
            tempObj.tempStart = '';
            tempObj.tempEnd = '';
            tempObj.tempExp = '';
            tempObj.temp2 = '';
            tempObj.end = true;
            tempObj.start = false;
            tempObj.expStart = '';
            tempObj.expEnd = '';
            tempObj.tempJoin = '';
            tempObj.outcome = false;
            tempObj.insideQuote = false;
            this.solveExpressionsRefactor(tempObj);
            if(tempObj.end){
                tempObj.tempEnd = tempObj.temp2;
            }else if(tempObj.start){
                tempObj.tempExp = tempObj.temp2;
            }else{
                tempObj.tempStart = tempObj.temp2;
            }
            tempObj.tempExpFinal = tempObj.tempExp.split('').reverse().join('');
            if(tempObj.tempStart){
                tempObj.expStart = tempObj.tempStart.split('').reverse().join('');
            }
            if(tempObj.tempEnd){
                tempObj.expEnd = tempObj.tempEnd.split('').reverse().join('');
            }
            if(tempObj.expStart){
                tempObj.tempJoin += tempObj.expStart;
            }
            if(tempObj.tempExpFinal && tempObj.tempExpFinal.substr(tempObj.tempExpFinal.length - 4) != 'true' && tempObj.tempExpFinal.substr(tempObj.tempExpFinal.length - 5) != 'false'){
                tempObj.outcome = this.checkFieldValues(obj, tempObj.tempExpFinal);
                tempObj.tempJoin += tempObj.outcome.toString();
            }else if(tempObj.tempExpFinal){
                tempObj.bool = tempObj.tempExpFinal;
                tempObj.tempJoin += tempObj.bool;
            }
            if(tempObj.expEnd){
                tempObj.tempJoin += tempObj.expEnd;
            }
            if(finalExp){
                finalExp += operator;
            }
            finalExp += tempObj.tempJoin;
        });
        return finalExp;
    }
    solveExpressionsRefactor(tempObj){
        const chars = [" ", ")", "(", "&", "|", "true", "false"];
        for (var i = tempObj.temp1.length-1; i >= 0; i--){
            if(tempObj.temp1[i] == '"'){
                tempObj.insideQuote = !(tempObj.insideQuote);
            }
            if(chars.includes(tempObj.temp1[i])){
                if(tempObj.start && !tempObj.insideQuote){
                    tempObj.tempExp = tempObj.temp2;
                    tempObj.temp2 = '';
                    tempObj.start = false;
                }
                tempObj.temp2 += tempObj.temp1[i];
            }else if(tempObj.end){
                tempObj.tempEnd = tempObj.temp2;
                tempObj.temp2 = tempObj.temp1[i];
                tempObj.end = false;
                tempObj.start = true;
            }else{
                tempObj.temp2 += tempObj.temp1[i];
            }
        }
    }
    checkFieldValues(obj, expr){
        let mapPreLoadedValues = new Map(Object.entries(this.preLoadedValues));
        let mapCaseFieldValues = this.caseFieldValues ? new Map(Object.entries(this.caseFieldValues)) : '';
        let mapFlowVariables = this.flowVariables ? new Map(Object.entries(JSON.parse(this.flowVariables))) : '';
        let mapFieldValues;
        let spitExpr;
        if(expr.includes('case.')){
            spitExpr = expr.split('.')[1];
            mapFieldValues = mapCaseFieldValues;
        }else if(expr.includes('$')){
            spitExpr = expr.split('$')[1];
            mapFieldValues = mapFlowVariables;
        }else{
            spitExpr = expr;
            mapFieldValues = mapPreLoadedValues;
        }
        return this.checkCondition(obj, spitExpr, mapFieldValues);
    }
    checkCondition(obj, expr, mapFieldValues){
        let mapAffAllFieldValues = this.affAllFieldValues ? new Map(Object.entries(this.affAllFieldValues)) : '';
        let outcome = false;
        if(expr.includes('==')){
            let spitExpr = expr.split('==');
            if(mapFieldValues && mapFieldValues.has(spitExpr[0])){
                if(mapFieldValues.get(spitExpr[0]) === spitExpr[1].replaceAll('"', '')){
                    outcome = true;
                }
            }else if(mapAffAllFieldValues && mapAffAllFieldValues.has(spitExpr[0]) && mapAffAllFieldValues.get(spitExpr[0]) === spitExpr[1].replaceAll('"', '')){
                outcome = true;
            }
            this.updateCriteriaFields(obj, spitExpr[0]);
        }else if(expr.includes('!=')){
            outcome = this.checkConditionNotEqual(expr, mapFieldValues, mapAffAllFieldValues, obj);
        }
        return outcome;
    }
    checkConditionNotEqual(expr, mapFieldValues, mapAffAllFieldValues, obj){
        let spitExpr = expr.split('!=');
        let outcome1 = false;
        if(mapFieldValues && mapFieldValues.has(spitExpr[0])){
            if(mapFieldValues.get(spitExpr[0]) !== spitExpr[1].replaceAll('"', '')){
                outcome1 = true;
            }
        }else if(mapAffAllFieldValues && mapAffAllFieldValues.has(spitExpr[0]) && mapAffAllFieldValues.get(spitExpr[0]) !== spitExpr[1].replaceAll('"', '')){
            outcome1 = true;
        }
        this.updateCriteriaFields(obj, spitExpr[0]);
        return outcome1; 
    }
    updateCriteriaFields(obj, field){
        if (!this.criteriaFields.has(field)){
            let newSetVales = new Set();
            this.criteriaFields.set(field, newSetVales.add(obj.Affirmation_Field_API_Name__c.toString()));
        }else{
            this.criteriaFields.get(field).add(obj.Affirmation_Field_API_Name__c.toString());
        }
    }
}