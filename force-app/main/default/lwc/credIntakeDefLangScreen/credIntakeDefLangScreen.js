import {LightningElement,api,track} from 'lwc';
import getCredIntakeDefLang from '@salesforce/apex/CredIntakeDefScreenController.getCredIntakeDefLang';
import getIncompleteAssets from '@salesforce/apex/CredIntakeDefScreenController.getIncompleteAssets';
export default class CredIntakeDefLangScreen extends LightningElement{
    @api caseId;
    @track rejLang = [];
    payloads = [];
    @track spinner = false;
    loadDefLanguages(){
        this.spinner = true;
        getCredIntakeDefLang({
            caseId : this.caseId
        }).then(rejectedListLang=>{           
            this.rejLang = rejectedListLang;
            this.spinner = false;
        })
    }
    showIncompleteAssets(){
        getIncompleteAssets({caseId:this.caseId})
        .then(result=>{
        result.forEach(assetRec =>{
                this.payloads.push({
                    id : assetRec.Id,
                    name : assetRec.assetName,
                    type : assetRec.documentType,
                    attendanceEndDate : assetRec.attendanceEndDate,
                    attendanceStartDate : assetRec.attendanceStartDate,
                    degreeIssueDate : assetRec.degreeIssueDate,
                    degreeTitle : assetRec.degreeTitle,
                    graduationYear : assetRec.graduationYear,
                    degreeExpectedToBeIssuedMonth : assetRec.degreeExpectedToBeIssuedMonth,
                    degreeExpectedToBeIssuedYear : assetRec.degreeExpectedToBeIssuedYear,
                    expirationDate : assetRec.expirationDate,
                    issueDate : assetRec.issueDate,
                    programEndDate : assetRec.programEndDate,
                    programStartDate : assetRec.programStartDate,
                    title : assetRec.title,
                    deansLetterDate : assetRec.deansLetterDate,
                    startMonth : assetRec.startMonth,
                    endMonth : assetRec.endMonth,
                    startYear : assetRec.startYear,
                    endYear : assetRec.endYear,
                    showADMSattr : (assetRec.documentType == 'Advanced Degree in the Medical Sciences'),
                    showAGDattr : (assetRec.documentType == 'Alternate Graduation Document'),
                    showCGSattr : (assetRec.documentType == 'Certificate of Good Standing'),
                    showFMDattr : (assetRec.documentType == 'Final Medical Diploma'),
                    showFMSTattr : (assetRec.documentType == 'Final Medical School Transcript'),
                    showMRCattr : (assetRec.documentType == 'Medical Registration Certificate/License to Practice Medicine'),
                    showPostTCattr : (assetRec.documentType == 'Postgraduate Training Credential'),
                    showPreICattr : (assetRec.documentType == 'Pregraduate Internship Certificate'),
                    showSMSTattr : (assetRec.documentType == 'Student Medical School Transcript'),
                    showSQattr : (assetRec.documentType == 'Specialist Qualification'),
                    showTranDocDetails : (assetRec.documentType == 'Translation'),
                    showTCTattr : (assetRec.documentType == 'Transcript to Document Transfer Credits'),
                    showTCTECFMGAttr : (assetRec.documentType == 'Transfer Credit Transcript'),
                    showLetterFromDeanAttr : (assetRec.documentType == 'Letter from Dean'),
                    showPreMedAttr : (assetRec.documentType == 'Pre-Med Letter'),
                    assetPayload : JSON.stringify(assetRec)
                });                
            });

            this.payloads.reverse();
        })        
    }
    connectedCallback(){       
        this.loadDefLanguages();
        this.showIncompleteAssets();
    }
    @api
    get caseIdFromFlow(){
        return this.caseId;
    }
    set caseIdFromFlow(val){
        this.caseId = val;
    }
}