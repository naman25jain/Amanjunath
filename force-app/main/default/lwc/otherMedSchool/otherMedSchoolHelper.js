/**
 * Get the closest matching element up the DOM tree.
 * @private
 * @param  {Element} elem     Starting element
 * @param  {String}  selector Selector to match against
 * @return {Boolean|Element}  Returns null if not match found
 */
 import deleteUncheckedTCAndAsset from '@salesforce/apex/AppForCertHelper.deleteUncheckedTCAndAsset';
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
// method to get index of current other med school
export function getCurrentSchoolIndex(elem, recordsList){
    let closestElem = getClosest(elem, '.recordFieldsWrapper');
    let currentSchoolRecordIndex = parseInt(closestElem.getAttribute('data-record-index'), 10);
    let index = 0;
    for(let i in recordsList){
        if(recordsList[i].sno === currentSchoolRecordIndex){
            index = i;
            break;
        }
    }
    return index;
}
// method to check if two arrays are equal
export function arrayEquals(a, b){
    return Array.isArray(a) &&
        Array.isArray(b) &&
        a.length === b.length &&
        a.every((val, index) => val === b[index]);
}
export function emptyRecordsListHelper(){
    let emptyRecordsList = [{
        sno: 1,
        recordIdVal: '',
        otherSchool: '',
        otherSchoolId: '',
        schoolProgram: '',
        studentId: '',
        numberOfYearsAttended: '',
        Specialty: '',
        inputOtherSchoolId: '',
        valueListId: '',
        fromDate: '',
        endDate: '',
        startMonth: '',
        startYear: '',
        endMonth: '',
        endYear: '',
        transferCreditsCheckbox: '',
        inputCreditMonthId: 'inputCreditMonth',
        creditMonthValueListId: 'creditMonthValueList',
        tctName: '',
        tctTranslationName: '',
        tctAssetId: '',
        tctNameDocId: '',
        tctTranslationId: '',
        tctUrl: '',
        nameDocUrl: '',
        tctTransUrl: '',
        tcWrapperList: [{
            tcId: '',
            transferCreditCourse: '',
            transferCreditGrade: '',
            courseOutcome: '',
            creditsEarnedMonth: '',
            creditsEarnedYear: ''
        }],
        tctAssetIdUpdated: true,
        tctTranslationAssetIdUpdated: true,
        nameDocAssetIdUpdated: true,
        tctAssetIdUpdatedRej: false,
        tctNameAssetIdUpdatedRej: false,
        tctTrnAssetIdUpdatedRej: false
    }];
    return emptyRecordsList;
}
export function getNewRecordsLists(newsetRecordsList, newMedChangedSchools, recordsListExamRegLength){
    let newDataRecordsList = [];
    for(let i in newsetRecordsList){
        let incNum = parseInt(i)+parseInt(recordsListExamRegLength)+1;
        newsetRecordsList[i].otherSchool = newMedChangedSchools[newsetRecordsList[i].sno].schoolInput;
        newsetRecordsList[i].otherSchoolId = newMedChangedSchools[newsetRecordsList[i].sno].schoolId;
        newsetRecordsList[i].schoolProgram = newMedChangedSchools[newsetRecordsList[i].sno].schoolProgram;
        newsetRecordsList[i].studentId = newMedChangedSchools[newsetRecordsList[i].sno].studentId;
        newsetRecordsList[i].Specialty = newMedChangedSchools[newsetRecordsList[i].sno].Specialty;
        newsetRecordsList[i].startMonth = newMedChangedSchools[newsetRecordsList[i].sno].startMonth;
        newsetRecordsList[i].startYear = newMedChangedSchools[newsetRecordsList[i].sno].startYear;
        newsetRecordsList[i].endMonth = newMedChangedSchools[newsetRecordsList[i].sno].endMonth;
        newsetRecordsList[i].endYear = newMedChangedSchools[newsetRecordsList[i].sno].endYear;
        newsetRecordsList[i].numberOfYearsAttended = newMedChangedSchools[newsetRecordsList[i].sno].numberOfYearsAttended;
        newsetRecordsList[i].transferCreditsCheckbox = newMedChangedSchools[newsetRecordsList[i].sno].transferCreditsCheckbox;
        newsetRecordsList[i].tcWrapperList = newMedChangedSchools[newsetRecordsList[i].sno].tcWrapperList;
        newsetRecordsList[i].tctAssetIdUpdated = newMedChangedSchools[newsetRecordsList[i].sno].tctAssetIdUpdated;
        newsetRecordsList[i].tctName = newMedChangedSchools[newsetRecordsList[i].sno].tctName;
        newsetRecordsList[i].tctUrl = newMedChangedSchools[newsetRecordsList[i].sno].tctUrl;
        newsetRecordsList[i].tctAssetId = newMedChangedSchools[newsetRecordsList[i].sno].tctAssetId;
        newsetRecordsList[i].nameOnTranscriptCheckbox = newMedChangedSchools[newsetRecordsList[i].sno].nameOnTranscriptCheckbox;
        newsetRecordsList[i].nameDocAssetIdUpdated = newMedChangedSchools[newsetRecordsList[i].sno].nameDocAssetIdUpdated;
        newsetRecordsList[i].tctNameDocId = newMedChangedSchools[newsetRecordsList[i].sno].tctNameDocId;
        newsetRecordsList[i].nameDocUrl = newMedChangedSchools[newsetRecordsList[i].sno].nameDocUrl;
        newsetRecordsList[i].isTranscriptInEnglishCheckbox = newMedChangedSchools[newsetRecordsList[i].sno].isTranscriptInEnglishCheckbox;
        newsetRecordsList[i].tctTranslationAssetIdUpdated = newMedChangedSchools[newsetRecordsList[i].sno].tctTranslationAssetIdUpdated;
        newsetRecordsList[i].tctTransUrl = newMedChangedSchools[newsetRecordsList[i].sno].tctTransUrl;
        newsetRecordsList[i].tctTranslationId = newMedChangedSchools[newsetRecordsList[i].sno].tctTranslationId;
        newsetRecordsList[i].sno = incNum;
        newDataRecordsList.push(newsetRecordsList[i]);
    }
    return newDataRecordsList;
}
export function getNewChangedSchools(newsetRecordsList, newMedChangedSchools, recordsListExamRegLength){
    let newMedicalChangedSchools = {};
    for(let i in newsetRecordsList){
        let incNum = parseInt(i)+parseInt(recordsListExamRegLength)+1;
        newMedicalChangedSchools[incNum] = newMedChangedSchools[newsetRecordsList[i].sno];
        newMedicalChangedSchools[incNum].index = incNum;
    }
    return newMedicalChangedSchools;
}
export function updatedChangedSchools(elemTHis, currentSchoolRecordIndex, changedSchools){
    let medChangedSchoolsObj = changedSchools;
    if(elemTHis.template.querySelectorAll('.recordFieldsWrapper') !== null){
        let allWrapper = elemTHis.template.querySelectorAll(".recordFieldsWrapper");
        allWrapper.forEach(function(element){
            let loopRecordIndex = parseInt(element.getAttribute('data-record-index'), 10);
            if(medChangedSchoolsObj[loopRecordIndex] !== undefined && currentSchoolRecordIndex !== loopRecordIndex){
                medChangedSchoolsObj[loopRecordIndex].schoolProgram = element.querySelector(".schoolProgram").value;
                medChangedSchoolsObj[loopRecordIndex].studentId = element.querySelector(".studentId").value;
                medChangedSchoolsObj[loopRecordIndex].Specialty = element.querySelector(".speciality").value;
                medChangedSchoolsObj[loopRecordIndex].startMonth = element.querySelector(".startMonth").value;
                medChangedSchoolsObj[loopRecordIndex].startYear = element.querySelector(".startYear").value;
                medChangedSchoolsObj[loopRecordIndex].endMonth = element.querySelector(".endMonth").value;
                medChangedSchoolsObj[loopRecordIndex].endYear = element.querySelector(".endYear").value;
                medChangedSchoolsObj[loopRecordIndex].numberOfYearsAttended = element.querySelector(".attendedYears").value;
                if(element.querySelector(".transferCreditsCheckbox").checked){
                    let tcWrapperList = [];
                    let tcDetailsRow = element.querySelectorAll(".tcDetailsRow");
                    tcDetailsRow.forEach(function (elem){
                        let regex = /^(\d{0,2}\.?\d{0,2})/g; // regex to limit decimals to 2 digits and 2 decimals
                        let decimalCheckerRegex = /^\d*\.?\d+$/; // regex to check if value is of a decimal format
                        let normalizedGradeInput = 0;
                        if(decimalCheckerRegex.test(elem.querySelector(".transferCreditGradeInput").value)){
                            let decimalValue = parseFloat(elem.querySelector(".transferCreditGradeInput").value);
                            if(decimalValue > 0 && decimalValue < 100){
                                normalizedGradeInput = elem.querySelector(".transferCreditGradeInput").value.match(regex)[0];
                            }
                        }
                        elem.querySelector(".transferCreditGradeInput").setAttribute('data-normalizedGradeInput', normalizedGradeInput);
                        let tempTcRecord = {
                            tcId: elem.getAttribute('data-tcid'),
                            transferCreditCourse: elem.querySelector(".transferCreditCourseInput").value,
                            transferCreditGrade: normalizedGradeInput,
                            courseOutcome: elem.querySelector(".transferCreditCourseOutcomeInput").value,
                            creditsEarnedMonth: elem.querySelector(".monthPicklist").value,
                            creditsEarnedYear: elem.querySelector(".creditEarnedYearInput").value
                        }
                        tcWrapperList.push(tempTcRecord);
                    });
                    medChangedSchoolsObj[loopRecordIndex].transferCreditsCheckbox = true;
                    medChangedSchoolsObj[loopRecordIndex].tcWrapperList = tcWrapperList;
                    medChangedSchoolsObj[loopRecordIndex].tctAssetIdUpdated = true;
                    medChangedSchoolsObj[loopRecordIndex].tctName = element.querySelector(".tctName").value;
                    medChangedSchoolsObj[loopRecordIndex].tctUrl = element.querySelector(".tctName").getAttribute('data-asset-url');
                    medChangedSchoolsObj[loopRecordIndex].tctAssetId = element.querySelector(".tctName").getAttribute('data-asset-id');
                    medChangedSchoolsObj[loopRecordIndex].nameOnTranscriptCheckbox = element.querySelector(".nameOnTranscriptCheckbox").checked;
                    medChangedSchoolsObj[loopRecordIndex].nameDocAssetIdUpdated = true;
                    medChangedSchoolsObj[loopRecordIndex].tctNameDocId = element.querySelector(".tctNameDocumenatationSectionUploadId").getAttribute('data-asset-id');
                    medChangedSchoolsObj[loopRecordIndex].nameDocUrl = element.querySelector(".tctNameDocumenatationSectionUploadId").getAttribute('data-asset-url');
                    medChangedSchoolsObj[loopRecordIndex].isTranscriptInEnglishCheckbox = element.querySelector(".isTranscriptInEnglishCheckbox").checked;
                    medChangedSchoolsObj[loopRecordIndex].tctTranslationAssetIdUpdated = true;
                    medChangedSchoolsObj[loopRecordIndex].tctTransUrl = element.querySelector(".tctTranslationId").getAttribute('data-asset-url');
                    medChangedSchoolsObj[loopRecordIndex].tctTranslationId = element.querySelector(".tctTranslationId").getAttribute('data-asset-id');
                }else{
                    let tcWrapperList = [];
                    let tempTcRecord = {
                        tcId: '',
                        transferCreditCourse: '',
                        transferCreditGrade: '',
                        courseOutcome: '',
                        creditsEarnedMonth: '',
                        creditsEarnedYear: ''
                    }
                    tcWrapperList.push(tempTcRecord);
                    medChangedSchoolsObj[loopRecordIndex].transferCreditsCheckbox = false;
                    medChangedSchoolsObj[loopRecordIndex].tcWrapperList = tcWrapperList;
                    medChangedSchoolsObj[loopRecordIndex].tctAssetIdUpdated = true;
                    medChangedSchoolsObj[loopRecordIndex].tctName = '';
                    medChangedSchoolsObj[loopRecordIndex].tctUrl = '';
                    medChangedSchoolsObj[loopRecordIndex].tctAssetId = '';
                    medChangedSchoolsObj[loopRecordIndex].nameOnTranscriptCheckbox = false;
                    medChangedSchoolsObj[loopRecordIndex].nameDocAssetIdUpdated = true;
                    medChangedSchoolsObj[loopRecordIndex].tctNameDocId = '';
                    medChangedSchoolsObj[loopRecordIndex].nameDocUrl = '';
                    medChangedSchoolsObj[loopRecordIndex].isTranscriptInEnglishCheckbox = false;
                    medChangedSchoolsObj[loopRecordIndex].tctTranslationAssetIdUpdated = true;
                    medChangedSchoolsObj[loopRecordIndex].tctTransUrl = '';
                    medChangedSchoolsObj[loopRecordIndex].tctTranslationId = '';
                    medChangedSchoolsObj[loopRecordIndex].tctAssetIdUpdatedRej = false;
                    medChangedSchoolsObj[loopRecordIndex].tctNameAssetIdUpdatedRej = false;
                    medChangedSchoolsObj[loopRecordIndex].tctTrnAssetIdUpdatedRej = false;
                }
            }else{
                element.querySelector(".otherSchoolRecord").value = '';
                element.querySelector(".otherSchoolRecord").setAttribute("data-otherschool-id", '');
                element.querySelector(".schoolProgram").value = '';
                element.querySelector(".studentId").value = '';
                element.querySelector(".speciality").value = '';
                element.querySelector(".startMonth").value = '';
                element.querySelector(".startYear").value = '';
                element.querySelector(".endMonth").value = '';
                element.querySelector(".endYear").value = '';
                element.querySelector(".attendedYears").value = '';
                element.querySelector(".transferCreditsCheckbox").checked = false;
                clearTransferCreditsFields(element);
                medChangedSchoolsObj[loopRecordIndex].schoolInput = '';
                medChangedSchoolsObj[loopRecordIndex].schoolId = '';
                medChangedSchoolsObj[loopRecordIndex].schoolProgram = '';
                medChangedSchoolsObj[loopRecordIndex].studentId = '';
                medChangedSchoolsObj[loopRecordIndex].Specialty = '';
                medChangedSchoolsObj[loopRecordIndex].startMonth = '';
                medChangedSchoolsObj[loopRecordIndex].startYear = '';
                medChangedSchoolsObj[loopRecordIndex].endMonth = '';
                medChangedSchoolsObj[loopRecordIndex].endYear = '';
                medChangedSchoolsObj[loopRecordIndex].numberOfYearsAttended = '';
                let tcWrapperList = [];
                let tempTcRecord = {
                    tcId: '',
                    transferCreditCourse: '',
                    transferCreditGrade: '',
                    courseOutcome: '',
                    creditsEarnedMonth: '',
                    creditsEarnedYear: ''
                }
                tcWrapperList.push(tempTcRecord);
                medChangedSchoolsObj[loopRecordIndex].transferCreditsCheckbox = false;
                medChangedSchoolsObj[loopRecordIndex].tcWrapperList = tcWrapperList;
                medChangedSchoolsObj[loopRecordIndex].tctAssetIdUpdated = true;
                medChangedSchoolsObj[loopRecordIndex].tctName = '';
                medChangedSchoolsObj[loopRecordIndex].tctUrl = '';
                medChangedSchoolsObj[loopRecordIndex].tctAssetId = '';
                medChangedSchoolsObj[loopRecordIndex].nameOnTranscriptCheckbox = false;
                medChangedSchoolsObj[loopRecordIndex].nameDocAssetIdUpdated = true;
                medChangedSchoolsObj[loopRecordIndex].tctNameDocId = '';
                medChangedSchoolsObj[loopRecordIndex].nameDocUrl = '';
                medChangedSchoolsObj[loopRecordIndex].isTranscriptInEnglishCheckbox = false;
                medChangedSchoolsObj[loopRecordIndex].tctTranslationAssetIdUpdated = true;
                medChangedSchoolsObj[loopRecordIndex].tctTransUrl = '';
                medChangedSchoolsObj[loopRecordIndex].tctTranslationId = '';
                medChangedSchoolsObj[loopRecordIndex].tctAssetIdUpdatedRej = false;
                medChangedSchoolsObj[loopRecordIndex].tctNameAssetIdUpdatedRej = false;
                medChangedSchoolsObj[loopRecordIndex].tctTrnAssetIdUpdatedRej = false;
            }
        });
    }
    // Remove Error Messages
    elemTHis.template.querySelectorAll('.slds-has-error').forEach(element => element.classList.remove('slds-has-error'));
    elemTHis.template.querySelectorAll('.medSchoolNameError').forEach(elementsec => elementsec.remove());
    elemTHis.template.querySelectorAll('.blankNameError').forEach(elementsec => elementsec.remove());
    elemTHis.template.querySelectorAll('.blankStartMonthError').forEach(elementsec => elementsec.remove());
    elemTHis.template.querySelectorAll('.blankStartYearError').forEach(elementsec => elementsec.remove());
    elemTHis.template.querySelectorAll('.blankEndMonthError').forEach(elementSec => elementSec.remove());
    elemTHis.template.querySelectorAll('.blankEndYearError').forEach(elementSec => elementSec.remove());
    elemTHis.template.querySelectorAll('.attendedYearsError').forEach(elementSec => elementSec.remove());
    removeTransferCreditsErrors(elemTHis.template);
    return medChangedSchoolsObj;
}
export function markAssetsForDeletionWithUrlHelper(currentSchool){
    let assetsToBeUpdated = [];
    let tctUrl = currentSchool.querySelector(".tctName").getAttribute('data-asset-url');
    if(tctUrl){
        assetsToBeUpdated.push(tctUrl);
    }
    let nameDocUrl = currentSchool.querySelector(".tctNameDocId").getAttribute('data-asset-url');
    if(nameDocUrl){
        assetsToBeUpdated.push(nameDocUrl);
    }
    let transDocUrl = currentSchool.querySelector(".tctTranslationId").getAttribute('data-asset-url');
    if(transDocUrl){
        assetsToBeUpdated.push(transDocUrl);
    }
    return assetsToBeUpdated;
}
export function emptyMedChangeSchoolObj(thisRecordsList){
    let emptyMedChangeSchool = {
        index : thisRecordsList.sno,
        schoolInput : thisRecordsList.otherSchool,
        schoolId : thisRecordsList.otherSchoolId,
        schoolProgram : thisRecordsList.schoolProgram,
        studentId : thisRecordsList.studentId,
        Specialty : thisRecordsList.Specialty,
        startMonth : thisRecordsList.startMonth,
        startYear : thisRecordsList.startYear,
        endMonth : thisRecordsList.endMonth,
        endYear : thisRecordsList.endYear,
        numberOfYearsAttended : thisRecordsList.numberOfYearsAttended,
        transferCreditsCheckbox : thisRecordsList.transferCreditsCheckbox,
        tcWrapperList : thisRecordsList.tcWrapperList,
        tctAssetIdUpdated : true,
        tctName : thisRecordsList.tctName,
        tctUrl : thisRecordsList.tctUrl,
        tctAssetId : thisRecordsList.tctAssetId,
        nameOnTranscriptCheckbox : false,
        nameDocAssetIdUpdated : true,
        tctNameDocId : thisRecordsList.tctNameDocId,
        nameDocUrl : thisRecordsList.nameDocUrl,
        isTranscriptInEnglishCheckbox : false,
        tctTranslationAssetIdUpdated : true,
        tctTransUrl : thisRecordsList.tctTransUrl,
        tctTranslationId : thisRecordsList.tctTranslationId,
        tctAssetIdUpdatedRej : false,
        tctNameAssetIdUpdatedRej : false,
        tctTrnAssetIdUpdatedRej : false
    };
    return emptyMedChangeSchool;
}
export function removeTransferCreditsErrors(closestOtherMedSchool){
    // Removing Error texts
    closestOtherMedSchool.querySelectorAll('.slds-has-error').forEach(element => element.classList.remove('slds-has-error'));
    closestOtherMedSchool.querySelectorAll('.blankCourseError').forEach(element => element.remove());
    closestOtherMedSchool.querySelectorAll('.blankGradeError').forEach(element => element.remove());
    closestOtherMedSchool.querySelectorAll('.blankOutcomeError').forEach(element => element.remove());
    closestOtherMedSchool.querySelectorAll('.blankMonthError').forEach(element => element.remove());
    closestOtherMedSchool.querySelectorAll('.blankYearError').forEach(element => element.remove());
    closestOtherMedSchool.querySelectorAll('.futureYearError').forEach(element => element.remove());
    closestOtherMedSchool.querySelectorAll('.tctMissingError').forEach(element => element.remove());
    closestOtherMedSchool.querySelectorAll('.translationDocMissingError').forEach(element => element.remove());
    return null;
}
export function clearTransferCreditsFields(closestOtherMedSchool){
    // Clearing the Transfer Credits fields
    // TCT Name Document
    closestOtherMedSchool.querySelector(".tctName").value = '';
    closestOtherMedSchool.querySelector(".tctName").setAttribute('data-asset-id', ''); // tctAssetId
    closestOtherMedSchool.querySelector(".tctName").setAttribute('data-asset-url', ''); // tctUrl
    // Is Name on the Document different?
    closestOtherMedSchool.querySelector('.nameOnTranscriptCheckbox').checked = false;
    closestOtherMedSchool.querySelector('.nameOnTranscriptCheckbox').setAttribute('data-asset-id', ''); // tctNameDocId
    closestOtherMedSchool.querySelector('.nameOnTranscriptCheckbox').setAttribute('data-asset-url', ''); // nameDocUrl
    closestOtherMedSchool.querySelector(".tctNameDocumenatationSectionUploadId").setAttribute('data-asset-id', ''); // tctNameDocId
    closestOtherMedSchool.querySelector(".tctNameDocumenatationSectionUploadId").setAttribute('data-asset-url', ''); // nameDocUrl
    // TCT Translation
    closestOtherMedSchool.querySelector(".isTranscriptInEnglishCheckbox").checked = false;
    closestOtherMedSchool.querySelector('.isTranscriptInEnglishCheckbox').setAttribute('data-asset-id', ''); // tctTranslationId
    closestOtherMedSchool.querySelector('.isTranscriptInEnglishCheckbox').setAttribute('data-asset-url', ''); // tctTransUrl
    closestOtherMedSchool.querySelector(".tctTranslationId").setAttribute('data-asset-id', '');  // tctTranslationId
    closestOtherMedSchool.querySelector(".tctTranslationId").setAttribute('data-asset-url', ''); // tctTransUrl
    // TCT Details
    closestOtherMedSchool.querySelectorAll('.transferCreditCourseInput').forEach(element =>{element.value = ''});
    closestOtherMedSchool.querySelectorAll('.transferCreditGradeInput').forEach(element =>{element.value = ''});
    closestOtherMedSchool.querySelectorAll('.transferCreditCourseOutcomeInput').forEach(element =>{element.value = ''});
    closestOtherMedSchool.querySelectorAll('.monthPicklist').forEach(element =>{element.value = ''});
    closestOtherMedSchool.querySelectorAll('.creditEarnedYearInput').forEach(element =>{element.value = ''});
    return null;
}
export function updateRecordsListUncheckedTC(thisRecordsList){
    thisRecordsList.tctAssetIdUpdated = false;
    thisRecordsList.tctTranslationAssetIdUpdated = false;
    thisRecordsList.nameDocAssetIdUpdated = false;
    let tempTctPayload = JSON.parse(thisRecordsList.tctPayload);
    tempTctPayload.assetId = null;
    thisRecordsList.tctPayload = JSON.stringify(tempTctPayload);
    let tempNameDocPayload = JSON.parse(thisRecordsList.nameDocPayload);
    tempNameDocPayload.assetId = null;
    thisRecordsList.nameDocPayload = JSON.stringify(tempNameDocPayload);
    let tempTctTransPayload = JSON.parse(thisRecordsList.tctTranslationPayload);
    tempTctTransPayload.assetId = null;
    thisRecordsList.tctTranslationPayload = JSON.stringify(tempTctTransPayload);
    thisRecordsList.nameOnTranscriptCheckbox = false;
    thisRecordsList.isTranscriptInEnglishCheckbox = false;
    thisRecordsList.nameOnTranslationDocCheckbox = false;
    thisRecordsList.tctAssetId = '';
    thisRecordsList.tctName = '';
    thisRecordsList.tctUrl = '';
    thisRecordsList.tctNameDocId = '';
    thisRecordsList.nameDocUrl = '';
    thisRecordsList.tctTranslationId = '';
    thisRecordsList.tctTranslationName = '';
    thisRecordsList.tctTransUrl = '';
    thisRecordsList.tcWrapperList = [];
    thisRecordsList.assets = [];
    let tempTc = {
        tcId: '',
        transferCreditCourse: '',
        transferCreditGrade: '',
        courseOutcome: '',
        creditsEarnedMonth: '',
        creditsEarnedYear: ''
    }
    thisRecordsList.tcWrapperList.push(tempTc);
    return thisRecordsList;
}
export function hideTransferCreditSection(thisElem){
    if(thisElem.template.querySelectorAll('.transferCreditsCheckbox') !== null){
        thisElem.template.querySelectorAll('.transferCreditsCheckbox').forEach(element => {
            element.parentNode.querySelectorAll('.transferCreditSection').forEach(elem => {
                elem.style.display = 'none';
            });
        });
    }
}
export function sectionsRenderer(thisElem){
    if(thisElem.template.querySelectorAll('.transferCreditsCheckbox') !== null){
        thisElem.template.querySelectorAll('.transferCreditsCheckbox').forEach(element => {
            if(element.checked){
                element.parentNode.querySelectorAll('.tcMainSection').forEach(elem => {
                    if(!elem.classList.contains('creditsDate')){
                        elem.style.display = 'block';
                    }else{
                        elem.style.display = 'flex';
                    }
                });
                if(element.parentNode.querySelector('.tctName').getAttribute('data-asset-url') || element.parentNode.querySelector('.tctName').getAttribute('data-asset-id')){
                    element.parentNode.querySelector(".cloudTransferCreditTranscript").auraThumbnailLoaderAzureURL();
                    element.parentNode.querySelectorAll('.tcNameSection').forEach(elem => {
                        elem.style.display = 'block';
                    });
                    element.parentNode.querySelectorAll('.tcTranslationSection').forEach(elem => {
                        elem.style.display = 'block';
                    });
                }
                if(element.parentNode.querySelector('.tctName').getAttribute('data-asset-url') === 'undefined' || element.parentNode.querySelector('.tctName').getAttribute('data-asset-url') === ''){
                    element.parentNode.querySelectorAll('.tcNameSection').forEach(elem => {
                        elem.style.display = 'none';
                    });
                    element.parentNode.querySelectorAll('.tcTranslationSection').forEach(elem => {
                        elem.style.display = 'none';
                    });
                }
                if(element.parentNode.querySelector('.nameOnTranscriptCheckbox').checked){
                    element.parentNode.querySelector(".cloudTCTNameDocumentation").auraThumbnailLoaderAzureURL();
                    element.parentNode.querySelectorAll('.tcNameSectionUpload').forEach(elem => {
                        elem.style.display = 'block';
                    });
                }
                if(element.parentNode.querySelector('.isTranscriptInEnglishCheckbox').checked){
                    element.parentNode.querySelector(".cloudTCTTransDoc").auraThumbnailLoaderAzureURL();
                    element.parentNode.querySelectorAll('.tcTranslationSectionUpload').forEach(elem => {
                        elem.style.display = 'block';
                    });
                }
            }
        });
    }
    thisElem.template.querySelectorAll('.recordFieldsWrapper').forEach(element=>{
        element.style.display = '';
    });
}
export function tempTctPayloadHelper(contactId, parentCaseId, caseId){
    return {
        "contactId": contactId,
        "parentCaseId": parentCaseId,
        "caseId": caseId,
        "catsId": "",
        "documentType": "Transfer Credit Transcript",
        "assetName": "Transfer Credit Transcript",
        "assetRecordType": "Credential",
        "createOrReplace": "Create",
        "assetStatus": "In Progress",
        "assetCreationRequired": "true",
        "assetId": "null",
        "type": "Transfer Credit Transcript",
        "key": "Transfer Credit Transcript Document",
        "parentKey": "",
        "createFromPB": "true"
    };
}
export function tempTctTranslationPayloadHelper(contactId, parentCaseId, caseId){
    return {
        "contactId": contactId,
        "parentCaseId": parentCaseId,
        "caseId": caseId,
        "catsId": "",
        "documentType": "TCT Translation",
        "assetName": "TCT Translation",
        "assetRecordType": "Credential",
        "createOrReplace": "Create",
        "assetStatus": "In Progress",
        "assetCreationRequired": "true",
        "assetId": "null",
        "type": "Translation",
        "key": "Transfer Credit Transcript Translation Document",
        "parentKey": "Transfer Credit Transcript Document",
        "createFromPB": "true"
    };
}
export function tempNameDocPayloadHelper(contactId, parentCaseId, caseId){
    return {
        "contactId": contactId,
        "parentCaseId": parentCaseId,
        "caseId": caseId,
        "catsId": "",
        "documentType": "Name Document",
        "assetName": "Name Document",
        "assetRecordType": "Identity",
        "createOrReplace": "Create",
        "assetStatus": "In Progress",
        "assetCreationRequired": "true",
        "assetId": "null",
        "type": "Name Document",
        "key": "Transfer Credit Transcript Name Document",
        "parentKey": "Transfer Credit Transcript Document",
        "createFromPB": "true"
    };
}
export function deleteUncheckedTCAsset(thisElem){
    deleteUncheckedTCAndAsset({
        contactId: thisElem.contactId,
        caseId: thisElem.caseId
    }).then(delresult=>{                    
        if(delresult === 'true'){
            thisElem.deleteSchoolFlag = false;                           
        }else{
            window.console.error('Delete Error:', delresult);
        }
    }).catch(error=>{
        window.console.error('Error: ' + JSON.stringify(error));
    });
}
export function showOtherMedSchoolErrorFunc(thisElem){
    // Remove the Error Elements by Class Name
    thisElem.template.querySelectorAll('.medSchoolNameError').forEach(element => element.remove());
    thisElem.template.querySelectorAll('.otherSchoolRecord').forEach(element => {
        if(element.getAttribute('data-otherschool-id') === '' ||
            element.getAttribute('data-otherschool-id') === true ||
            !thisElem.validSchoolRecordIds.includes(element.getAttribute('data-otherschool-id'))){
            let elem = document.createElement("div");
            elem.id = 'medSchoolError';
            elem.setAttribute('class', 'medSchoolNameError');
            elem.textContent = 'Please enter a valid Medical School from the available options';
            elem.style = 'color:#ff0000; clear:both;';
            element.classList.add('slds-has-error');
            element.parentNode.insertBefore(elem, element.nextSibling);
        }
    });
    thisElem.template.querySelector('.slds-has-error').scrollIntoView();
}