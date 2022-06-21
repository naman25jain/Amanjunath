/**
 * Get the closest matching element up the DOM tree.
 * @private
 * @param  {Element} elem     Starting element
 * @param  {String}  selector Selector to match against
 * @return {Boolean|Element}  Returns null if not match found
 */
 export function getClosest(elem, selector){
    // Element.matches() polyfill
    if(!Element.prototype.matches){
        Element.prototype.matches =
            Element.prototype.matchesSelector ||
            Element.prototype.mozMatchesSelector ||
            Element.prototype.msMatchesSelector ||
            Element.prototype.oMatchesSelector ||
            Element.prototype.webkitMatchesSelector ||
        function(s){
            var matches = (this.document || this.ownerDocument).querySelectorAll(s),
                i = matches.length;
            // eslint-disable-next-line no-empty
            while(--i >= 0 && matches.item(i) !== this){
                //loop to check i value
            }
            return i > -1;
        };
    }
    // Get closest match
    for(; elem && elem !== document; elem = elem.parentNode){
        if(elem.matches(selector)){
            return elem;
        }
    }
    return null;
}
/* Final Medical Diploma */
export function payloadFinalMedDiplomaHelper(contactId, parentCaseId, caseId){
    let payloadFinalMedDiploma = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'Final Medical Diploma',
        assetName: 'Final Medical Diploma',
        assetRecordType: 'Credential',
        createOrReplace: 'Replace',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Final Medical Diploma',
        key: 'DIPLOMA DOCUMENT',
        parentKey: '',
        createFromPB: 'true'
    };
    return payloadFinalMedDiploma;
}
/* Final Medical Diploma - Name Document */
export function payloadFMDNameDocHelper(contactId, parentCaseId, caseId){
    let payloadFMDNameDoc = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'Final Diploma Name Document',
        assetName: 'Name Document',
        assetRecordType: 'Identity',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Name Document',
        key: 'DIPLOMA NAME DOCUMENT',
        parentKey: 'DIPLOMA DOCUMENT',
        createFromPB: 'true'
    };
    return payloadFMDNameDoc;
}
/* Final Medical Diploma - Translation */
export function payloadFMDTransDocHelper(contactId, parentCaseId, caseId){
    let payloadFMDTransDoc = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'Final Diploma Translation',
        assetName: 'Final Diploma Translation',
        assetRecordType: 'Credential',
        createOrReplace: 'Replace',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Translation',
        key: 'DIPLOMA TRANSLATION DOCUMENT',
        parentKey: 'DIPLOMA DOCUMENT',
        createFromPB: 'true'
    };
    return payloadFMDTransDoc;
}
/* Final Medical School Transscript */
export function payloadFinalMedSchoolTranscriptHelper(contactId, parentCaseId, caseId){
    let payloadFinalMedSchoolTranscript = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'Final Medical School Transcript',
        assetName: 'Final Medical School Transcript',
        assetRecordType: 'Credential',
        createOrReplace: 'Replace',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Final Medical School Transcript',
        key: 'FINAL MEDICAL SCHOOL TRANSCRIPT DOCUMENT',
        parentKey: '',
        createFromPB: 'true'
    };
    return payloadFinalMedSchoolTranscript;
}
/* Final Medical School Transscript - Name Document */
export function payloadFMTranscriptNameDocHelper(contactId, parentCaseId, caseId){
    let payloadFMTranscriptNameDoc = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'Final Transcript Name Document',
        assetName: 'Final Transcript Name Document',
        assetRecordType: 'Credential',
        createOrReplace: 'Replace',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Name Document',
        key: 'FINAL MEDICAL SCHOOL TRANSCRIPT NAME DOCUMENT',
        parentKey: 'FINAL MEDICAL SCHOOL TRANSCRIPT DOCUMENT',
        createFromPB: 'true'
    };
    return payloadFMTranscriptNameDoc;
}
/* Final Medical School Transscript - Translation */
export function payloadFMTranscriptTransDocHelper(contactId, parentCaseId, caseId){
    let payloadFMTranscriptTransDoc = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'Final Transcript Translation',
        assetName: 'Final Transcript Translation',
        assetRecordType: 'Credential',
        createOrReplace: 'Replace',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Translation',
        key: 'FINAL MEDICAL SCHOOL TRANSCRIPT TRANSLATION DOCUMENT',
        parentKey: 'FINAL MEDICAL SCHOOL TRANSCRIPT DOCUMENT',
        createFromPB: 'true'
    };
    return payloadFMTranscriptTransDoc;
}
/* Dean Letter */
/* Dean Letter --- Letter from Dean */
export function payloadDeanLetterDocHelper(contactId, parentCaseId, caseId){
    let payloadDeanLetterDoc = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'Letter from Dean',
        assetName: 'Letter from Dean',
        assetRecordType: 'Credential',
        createOrReplace: 'Replace',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Letter from Dean',
        key: 'DEAN LETTER DOCUMENT',
        parentKey: '',
        createFromPB: 'true'
    };
    return payloadDeanLetterDoc;
}
/* Dean Letter --- Name Document */
export function payloadDeanLetterNameDiffDocHelper(contactId, parentCaseId, caseId){
    let payloadDeanLetterNameDiffDoc = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'Letter from Dean Name Document',
        assetName: 'Letter from Dean Name Document',
        assetRecordType: 'Credential',
        createOrReplace: 'Replace',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Name Document',
        key: 'DEAN LETTER NAME DOCUMENT',
        parentKey: 'DEAN LETTER DOCUMENT',
        createFromPB: 'true'
    };
    return payloadDeanLetterNameDiffDoc;
}
/* Dean Letter --- Letter from Dean Translation */
export function payloadDeanLetterEnglishDocHelper(contactId, parentCaseId, caseId){
    let payloadDeanLetterEnglishDoc = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'Letter from Dean Translation',
        assetName: 'Letter from Dean Translation',
        assetRecordType: 'Credential',
        createOrReplace: 'Replace',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Translation',
        key: 'DEAN LETTER TRANSLATION DOCUMENT',
        parentKey: 'DEAN LETTER DOCUMENT',
        createFromPB: 'true'
    };
    return payloadDeanLetterEnglishDoc;
}