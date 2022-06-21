import {api,LightningElement,track,wire} from 'lwc';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {refreshApex} from '@salesforce/apex';
import CONTACT_ASSOCIAION_TYPE_OBJECT from '@salesforce/schema/Contact_Association_Type__c';
import YEARS_OF_EDU_REQ_FIELD from '@salesforce/schema/Contact_Association_Type__c.Years_of_education_required__c';
import FROM_YEAR from '@salesforce/schema/Contact_Association_Type__c.Personal_Family_from_year__c';
import FROM_MONTH from '@salesforce/schema/Contact_Association_Type__c.Personal_Family_from_month__c';
import getMedEduCAT from '@salesforce/apex/MedEduController.getMedEduCAT';
import getRecTypeId from '@salesforce/apex/GenericUtilities.getRecordTypeIdByDevName';
import recTypeDevName from '@salesforce/label/c.CAT_Medical_Education_Questionnaire_Record_Type';
import {updateScreenNumer} from 'c/util';
const dateMY = ["FromMonth","FromYear","ToMonth","ToYear"];
const changeToBoolean = ["Academic_remediation_reason_approved__c","Financial_reason_approved__c","Health_reason_approved__c"
,"Joint_degree_program_approved__c","Non_degree_research_reason_approved__c","Non_research_special_study_approved__c"
,"Other_reason_approved__c","Personal_Family_Reason_Approved__c","Transfer_Credit_to_Degree_School__c"];
const resetFields = {"personalFamily":["personalFamilyFromMonth","personalFamilyFromYear","personalFamilyToMonth","personalFamilyToYear","personalFamilyApproved"],
"academicRemediation":["academicRemediationFromMonth","academicRemediationFromYear","academicRemediationToMonth","academicRemediationToYear","academicRemediationApproved"],
"health":["healthFromMonth","healthFromYear","healthToMonth","healthToYear","healthApproved","healthApproved"],
"financial":["financialFromMonth","financialFromYear","financialToMonth","financialToYear","financialApproved"],
"jointDeg":["jointDegFromMonth","jointDegFromYear","jointDegToMonth","jointDegToYear","jointDegApproved"],
"nonReseach":["nonReseachFromMonth","nonReseachFromYear","nonReseachToMonth","nonReseachToYear","nonReseachApproved"],
"nonDegRes":["nonDegResFromMonth","nonDegResFromYear","nonDegResToMonth","nonDegResToYear","nonDegResApproved"],
"other":["otherFromMonth","otherFromYear","otherToMonth","otherToYear","otherReasonApproved","otherDetails"],
"academicProbation":["academicProbationFromMonth","academicProbationFromYear","academicProbationToMonth","academicProbationToYear"],
"unprofessionalProbation":["unprofessionalProbationFromMonth","unprofessionalProbationFromYear","unprofessionalProbationToMonth","unprofessionalProbationToYear"],
"probationOther":["probationOtherFromMonth","probationOtherFromYear","probationOtherToMonth","probationOtherToYear","probationOtherReason"],
"unprofessionalDisciplined":["unprofessionalDisciplinedDetail"],
"negativeReport":["negativeReportDetail"],
"limitationsImposed":["limitationSpecialRequ"],
"transferCredit":["institTransferCredit"]
}
const resetParentFields = {"interruptions":["personalFamily","academicRemediation","health","financial","jointDeg","nonReseach","nonDegRes","other"],
"onAcademicDiscProb":["academicProbation","unprofessionalProbation","probationOther"]
}
export default class MedEduQuestionnaire extends LightningElement{    
    @track
    fieldMap = { 
        "IndividualWasConferred": {"value":null,"apiName":"Individual_was_conferred_issued_degree__c"},
        "DegreeTitle": {"value":null,"apiName":"Degree_Title__c"},
        "DegreeIssueDate": {"value":null,"apiName":"Degree_Issue_Date__c"},
        "ReasonNotIssuesDegree": {"value":null,"apiName":"Reason_for_not_conferred_issued_degree__c"},
        "YearsEduReq": {"value":null,"apiName":"Years_of_education_required__c"},
        "CredentialDegreeAppicant": {"value":null,"apiName":"Credential_degree_presented_by_applicant__c"},
        "totalWeeksEdu": {"value":null,"apiName":"Total_weeks_of_medical_education__c"},
        "attendanceStart" : {"value":null,"apiName":"Attendance_Start_Date__c"},
        "attendanceEnd" : {"value":null,"apiName":"Attendance_End_Date__c"},
        "transferCredit" : {"value":null,"apiName":"Transfer_Credit_to_Degree_School__c"},
        "institTransferCredit" : {"value":null,"apiName":"Institution_s_credits_transferred_from__c"},
        "interruptions" : {"value":null,"apiName":"Interruptions_extensions__c"},
        "personalFamily" : {"value":false,"apiName":"Personal_Family__c"},
        "personalFamilyFromMonth" : {"value":null,"apiName":"Personal_Family_from_month__c"},
        "personalFamilyFromYear" : {"value":null,"apiName":"Personal_Family_from_year__c"},
        "personalFamilyToMonth" : {"value":null,"apiName":"Personal_Family_to_month__c"},
        "personalFamilyToYear" : {"value":null,"apiName":"Personal_Family_to_year__c"},
        "personalFamilyApproved" : {"value":'false',"apiName":"Personal_Family_Reason_Approved__c"},
        "academicRemediation" : {"value":false,"apiName":"Academic_remediation__c"},
        "academicRemediationFromMonth" : {"value":null,"apiName":"Academic_remediation_from_month__c"},
        "academicRemediationFromYear" : {"value":null,"apiName":"Academic_remediation_from_year__c"},
        "academicRemediationToMonth" : {"value":null,"apiName":"Academic_remediation_to_month__c"},
        "academicRemediationToYear" : {"value":null,"apiName":"Academic_remediation_to_year__c"},
        "academicRemediationApproved" : {"value":'false',"apiName":"Academic_remediation_reason_approved__c"},
        "health" : {"value":false,"apiName":"Health__c"},
        "healthFromMonth" : {"value":null,"apiName":"Health_from_month__c"},
        "healthFromYear" : {"value":null,"apiName":"Health_from_year__c"},
        "healthToMonth" : {"value":null,"apiName":"Health_to_month__c"},
        "healthToYear" : {"value":null,"apiName":"Health_to_year__c"},
        "healthApproved" : {"value":'false',"apiName":"Health_reason_approved__c"},
        "financial" : {"value":false,"apiName":"Financial__c"},
        "financialFromMonth" : {"value":null,"apiName":"Financial_from_month__c"},
        "financialFromYear" : {"value":null,"apiName":"Financial_from_year__c"},
        "financialToMonth" : {"value":null,"apiName":"Financial_to_month__c"},
        "financialToYear" : {"value":null,"apiName":"Financial_to_year__c"},
        "financialApproved" : {"value":'false',"apiName":"Financial_reason_approved__c"},        
        "jointDeg" : {"value":false,"apiName":"Joint_degree_program__c"},
        "jointDegFromMonth" : {"value":null,"apiName":"Joint_degree_program_from_month__c"},
        "jointDegFromYear" : {"value":null,"apiName":"Joint_degree_program_from_year__c"},
        "jointDegToMonth" : {"value":null,"apiName":"Joint_degree_program_to_month__c"},
        "jointDegToYear" : {"value":null,"apiName":"Joint_degree_program_to_year__c"},
        "jointDegApproved" : {"value":'false',"apiName":"Joint_degree_program_approved__c"},
        "nonReseach" : {"value":false,"apiName":"Non_research_special_study__c"},
        "nonReseachFromMonth" : {"value":null,"apiName":"Non_research_special_study_from_month__c"},
        "nonReseachFromYear" : {"value":null,"apiName":"Non_research_special_study_from_year__c"},
        "nonReseachToMonth" : {"value":null,"apiName":"Non_research_special_study_to_month__c"},
        "nonReseachToYear" : {"value":null,"apiName":"Non_research_special_study_to_year__c"},
        "nonReseachApproved" : {"value":'false',"apiName":"Non_research_special_study_approved__c"},
        "nonDegRes" : {"value":false,"apiName":"Non_degree_research__c"},
        "nonDegResFromMonth" : {"value":null,"apiName":"Non_degree_research_from_month__c"},
        "nonDegResFromYear" : {"value":null,"apiName":"Non_degree_research_from_year__c"},
        "nonDegResToMonth" : {"value":null,"apiName":"Non_degree_research_to_month__c"},
        "nonDegResToYear" : {"value":null,"apiName":"Non_degree_research_to_year__c"},
        "nonDegResApproved" : {"value":'false',"apiName":"Non_degree_research_reason_approved__c"},
        "other" : {"value":false,"apiName":"Other__c"},
        "otherFromMonth" : {"value":null,"apiName":"Other_from_month__c"},
        "otherFromYear" : {"value":null,"apiName":"Other_from_year__c"},
        "otherToMonth" : {"value":null,"apiName":"Other_to_month__c"},
        "otherToYear" : {"value":null,"apiName":"Other_to_year__c"},
        "otherReasonApproved" : {"value":'false',"apiName":"Other_reason_approved__c"},
        "otherDetails" : {"value":null,"apiName":"Other_Details__c"},
        "onAcademicDiscProb" : {"value":null,"apiName":"On_academic_or_disciplinary_probation__c"},
        "academicProbation" : {"value":false,"apiName":"Academic_probation__c"},
        "academicProbationFromMonth" : {"value":null,"apiName":"Academic_probation_from_month__c"},
        "academicProbationFromYear" : {"value":null,"apiName":"Academic_probation_from_year__c"},
        "academicProbationToMonth" : {"value":null,"apiName":"Academic_probation_to_month__c"},
        "academicProbationToYear" : {"value":null,"apiName":"Academic_probation_to_year__c"},
        "unprofessionalProbation" : {"value":false,"apiName":"Probation_for_unprofessional_conduct__c"},
        "unprofessionalProbationFromMonth" : {"value":null,"apiName":"Unprofessional_conduct_from_month__c"},
        "unprofessionalProbationFromYear" : {"value":null,"apiName":"Unprofessional_conduct_from_year__c"},
        "unprofessionalProbationToMonth" : {"value":null,"apiName":"Unprofessional_conduct_to_month__c"},
        "unprofessionalProbationToYear" : {"value":null,"apiName":"Unprofessional_conduct_to_year__c"},
        "probationOther" : {"value":false,"apiName":"Probation_for_other_reason__c"},        
        "probationOtherFromMonth" : {"value":null,"apiName":"Probation_for_other_reason_from_month__c"},
        "probationOtherFromYear" : {"value":null,"apiName":"Probation_for_other_reason_from_year__c"},
        "probationOtherToMonth" : {"value":null,"apiName":"Probation_for_other_reason_to_month__c"},
        "probationOtherToYear" : {"value":null,"apiName":"Probation_for_other_reason_to_year__c"},
        "probationOtherReason" : {"value":null,"apiName":"Probation_for_other_reason_details__c"},
        "unprofessionalDisciplined" : {"value":null,"apiName":"Disciplined_for_unprofessional_conduct__c"},
        "unprofessionalDisciplinedDetail" : {"value":null,"apiName":"Detail_of_unprofessional_conduct__c"},
        "negativeReport" : {"value":null,"apiName":"Negative_reports_or_an_investigation__c"},
        "negativeReportDetail" : {"value":null,"apiName":"Detail_of_negative_report_investigation__c"}, 
        "limitationsImposed" : {"value":null,"apiName":"Limitations_special_requirements_imposed__c"},        
        "limitationSpecialRequ" : {"value":null,"apiName":"Detail_of_limitation_special_requirement__c"},   
    };
    @track
    subFieldReq = {"interruptions":false,"onAcademicDiscProb":false}
    @track
    monthYearExceed = {"personalFamily":false,"academicRemediation":false,"health":false,"financial":false,"jointDeg":false,"nonReseach":false,"nonDegRes":false,"academicProbation":false,"other":false,"unprofessionalProbation":false,"probationOther":false}
    objectApiName = CONTACT_ASSOCIAION_TYPE_OBJECT;
    @api accountId;
    @api caseId;
    @api contactId;
    recordTypeDevName = recTypeDevName;
    recordTypeId;
    fetchedRecord;
    optionsYesNo = [
        {label: 'Yes', value: 'Yes'},
        {label: 'No', value: 'No'}
    ]
    optionsYesNoTrueFalse = [
        {label: 'Yes', value: 'true'},
        {label: 'No', value: 'false'}
    ]
    optionsApproved = [
        {label: 'Approved', value: 'true'},
        {label: 'Unapproved', value: 'false'}
    ]
    today = (new Date()).getFullYear()+'-'+((new Date()).getMonth()+1)+'-'+(new Date()).getDate();
    objectId;
    errorOccurred;
    errorMsgMedEduDate = false;
    @wire(getRecTypeId, {objectName: 'Contact_Association_Type__c', recordTypeDevName: '$recordTypeDevName'})
    getRecordTypeId(data,error){
        if(data){
            this.recordTypeId = data.data;
        }else if(error){
            window.console.error(error);
        }
    }
    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: FROM_YEAR})
    optionsYearsPickVal;
    get optionsYears(){
        if(this.optionsYearsPickVal.data){
            return this.optionsYearsPickVal.data.values;
        }
    }
    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: FROM_MONTH})
    optionsMonthsPickVal;
    get optionsMonths(){
        if(this.optionsMonthsPickVal.data){
            return this.optionsMonthsPickVal.data.values;
        }
    }
    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: YEARS_OF_EDU_REQ_FIELD})
    optionsYearPickVal;
    get optionsYear(){
        if(this.optionsYearPickVal.data){
            return this.optionsYearPickVal.data.values;
        }
    }
    @wire(getMedEduCAT, {caseId:'$caseId'})
    fetchCATRecord(value){
        this.fetchedRecord = value;
        const { data, error } = value;
        if(data){
            this.errorOccurred = false;
            this.objectId = data.Id;
            Object.entries(this.fieldMap).forEach(field=>{
                if(changeToBoolean.includes(field[1].apiName)){
                    field[1].value=(data[field[1].apiName])?'true':'false';
                }else{
                    field[1].value=data[field[1].apiName];
                }
            });
        }
        if(error){
            this.errorOccurred = true;
            window.console.error('Error ',error);
        }
        this.clearFields(resetParentFields);
        this.clearFields(resetFields);
        this.clearConferred();
    }
    get wasConferredOptionsInitial(){
        return [
            { label: 'Was conferred/issued a degree', value: 'Yes' },
            { label: 'Was not conferred/issued a degree', value: 'No' }
        ];
    }
    get wasConferredOptions(){
        return [
            { label: 'Was conferred/issued the degree of', value: 'Yes' },
            { label: 'Was not conferred/issued a degree', value: 'No' }
        ];
    }
    get wasNotConferredOptions(){
        return [
            { label: 'Was conferred/issued a degree', value: 'Yes' },
            { label: 'If this individual was not conferred/issued a degree by this medical school, please explain.', value: 'No' }
        ];
    }
    get wasnotConferred(){
        return this.fieldMap.IndividualWasConferred.value == 'Yes'?false:true;
    }
    get hasTrasferredCredit(){
        return this.fieldMap.transferCredit.value == 'true'?true:false;
    }
    get wasInterrupted(){
        return this.fieldMap.interruptions.value == 'Yes'?true:false;
    }
    get onAcademicDisc(){
        return this.fieldMap.onAcademicDiscProb.value == 'Yes'?true:false;
    }
    get wasDisciplined(){
        return this.fieldMap.unprofessionalDisciplined.value == 'Yes'?true:false;
    }
    get hasLimitiations(){
        return this.fieldMap.limitationsImposed.value == 'Yes'?true:false;
    }
    get hasNegative(){
        return this.fieldMap.negativeReport.value == 'Yes'?true:false;
    }
    connectedCallback(){
        updateScreenNumer(this.caseId,2);
    }
    handleSuccess(event){
        refreshApex(this.fetchedRecord);
        event.preventDefault();
        const selectEvent = new CustomEvent('showsummary');
        this.dispatchEvent(selectEvent);
    }
    handleSubmit(event){
        event.preventDefault(); // stop the form from submitting
        let subFieldValid = true;
        let myExceedValidaton = true;
        let allValidinput = ([...this.template.querySelectorAll('lightning-input')].concat([...this.template.querySelectorAll('lightning-radio-group')]).concat([...this.template.querySelectorAll('lightning-combobox')].concat([...this.template.querySelectorAll('lightning-textarea')])))
        .reduce((validSoFar,inputCmp)=>{
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        },true);
        Object.entries(resetParentFields).forEach(item=>{
            if(this.fieldMap[item[0]].value === 'Yes'){
                for(let subField of item[1]){
                    if(this.fieldMap[subField].value){
                        this.subFieldReq[item[0]] = false;
                        break;
                    }else{
                    this.subFieldReq[item[0]] = true;
                    }
                }
            }else{
                this.subFieldReq[item[0]] = false;
            }
        });
        subFieldValid = this.validateSubFieldMY(this.subFieldReq);
        myExceedValidaton = this.validateSubFieldMY(this.monthYearExceed);
        if(allValidinput && subFieldValid && myExceedValidaton && !this.errorMsgMedEduDate){
            let fields = this.populateValues();
            fields.Case__c = this.caseId;
            fields.Account__c = this.accountId;
            fields.Contact__c = this.contactId;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
     }
     validateSubFieldMY(fieldSet){
        let returnVal = true;
        Object.entries(fieldSet).forEach(item=>{
            if(item[1]){
                returnVal = false;
            }
        });
        return returnVal;
     }
    populateValues(){
        let fields = {};
        let fieldResetParent = this.getResetParentFeilds();        
        Object.entries(this.fieldMap).forEach(field=>{
            if(changeToBoolean.includes(field[1].apiName)){
                fields[field[1].apiName]=(field[1].value==='true' || field[1].value==='Yes')?true:false;
            }
            else if(fieldResetParent && fieldResetParent.includes(field[0])){
                fields[field[1].apiName]=field[1].value?true:false;
            }
            else{
                fields[field[1].apiName]=field[1].value;
            }
        });
        return fields;
    }
    handleOnChange(event){
        if(event.target.type != 'checkbox'){
            this.fieldMap[event.target.name].value = event.target.value;
            if(event.target.name=='IndividualWasConferred'){
                this.clearConferred();
            }
        }else{
            this.fieldMap[event.target.name].value = event.target.checked;            
        }
        if(resetFields[event.target.name]){
            this.clearValFields(resetFields[event.target.name],false);
        }else if(resetParentFields[event.target.name]){
            this.clearValFields(resetParentFields[event.target.name],true);
            (resetFields[event.target.name]).forEach(field=>{
                this.clearValFields(resetFields[field],false);
            });
        }
        else if((event.target.name=='attendanceStart' || event.target.name=='attendanceEnd') && ((this.fieldMap['attendanceStart']).value && (this.fieldMap['attendanceEnd']).value)){            
            if((Date.parse(this.fieldMap['attendanceStart'].value) > Date.parse(this.fieldMap['attendanceEnd'].value)) || this.fieldMap['attendanceStart'].value==this.fieldMap['attendanceEnd'].value){
                this.errorMsgMedEduDate = true;
            }else{
                this.errorMsgMedEduDate = false;
            }
        }
        else{
            this.dateMYField(event.target.name);
        }
    }
    clearConferred(){
        if(this.fieldMap['IndividualWasConferred'].value === 'Yes'){
            this.fieldMap['ReasonNotIssuesDegree'].value = null;
        }
        else if(this.fieldMap['IndividualWasConferred'].value === 'No'){
            this.fieldMap['DegreeTitle'].value = null;
            this.fieldMap['DegreeIssueDate'].value = null;
        }
        else{
            this.fieldMap['ReasonNotIssuesDegree'].value = null;
            this.fieldMap['DegreeTitle'].value = null;
            this.fieldMap['DegreeIssueDate'].value = null;
        }
    }
    clearFields(toResetFields){
        Object.entries(toResetFields).forEach(item=>{
            if(this.fieldMap[item[0]].value === false || this.fieldMap[item[0]].value === 'false' || this.fieldMap[item[0]].value === 'No' || this.fieldMap[item[0]].value == null){
                this.clearValFields(item[1],false);
            }
        });
    }
    clearValFields(fields,checkBox){
        fields.forEach(childItem=>{
            this.clearVal(childItem,checkBox);
        });
    }
    clearVal(field,checkBox){
        if(checkBox){
            this.fieldMap[field].value = false;
        }else{
            this.fieldMap[field].value = null;
        }
    }
    checkDateMY(fieldName){
        let fromMonth = this.fieldMap[fieldName+'FromMonth'].value;
        let fromYear = this.fieldMap[fieldName+'FromYear'].value;
        let toMonth = this.fieldMap[fieldName+'ToMonth'].value;
        let toYear = this.fieldMap[fieldName+'ToYear'].value;
        if(fromMonth && fromYear && toMonth && toYear){
            if((fromYear>toYear) || (fromYear === toYear && this.getMonthNum(fromMonth) > this.getMonthNum(toMonth)) || (toYear > new Date().getFullYear()) || (toYear == new Date().getFullYear() && this.getMonthNum(toMonth) > new Date().getMonth()+1)){
                this.monthYearExceed[fieldName] = true;
            }
            else{
                this.monthYearExceed[fieldName] = false;
            }
        }
    }
    getResetParentFeilds(){
        let fieldResetParent = [];
        Object.values(resetParentFields).forEach(item=>{
            fieldResetParent = fieldResetParent.concat(item);
        });
        return fieldResetParent;
    }
    dateMYField(fieldName){
        let extractedFieldName = '';
        for(let item of dateMY){
            if(fieldName.endsWith(item)){
                extractedFieldName = fieldName.replace(item,'');
                break;
            }
        }
        if(extractedFieldName){
            this.checkDateMY(extractedFieldName);
        }
    }
    getMonthNum(monthName){
        return new Date(Date.parse(monthName +" 1, "+ new Date().getFullYear())).getMonth()+1;
    }
    reviewDocuments(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('reviewdocuments');
        this.dispatchEvent(selectEvent);
    }
    returnCredRevList(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('showlist');
        this.dispatchEvent(selectEvent);
    }
}