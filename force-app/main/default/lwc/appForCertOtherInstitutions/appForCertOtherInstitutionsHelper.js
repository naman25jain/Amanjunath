import endDateGreaterThanStartDate from '@salesforce/label/c.End_date_always_greater_than_Start_date';
import startDateAndEndDateNotSame from '@salesforce/label/c.Start_date_and_End_date_should_not_be_same';
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
                while (--i >= 0 && matches.item(i) !== this){
                    //loop to check i value
                }
                return i > -1;
            };
    }
    // Get closest match
    for(; elem && elem !== document; elem = elem.parentNode){
        if(elem.matches(selector)) return elem;
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
// method to  hide the sections given the parent element and class name
export function hideSection(elem, clsName){
    let cls = '.' + clsName;
    elem.querySelectorAll(cls).forEach(element => {
        element.style.display = 'none';
    });
}
// method to  show the sections given the parent element and class name
export function showSection(elem, clsName){
    let cls = '.' + clsName;
    elem.querySelectorAll(cls).forEach(element => {
        element.style.display = 'block';
    });
}
//New code added by Shailaja. User Story#7601
export function showNewDateErrorFunc(temp){
    if(temp.querySelectorAll('.blankStartMonthError') !== null){
        temp.querySelectorAll('.blankStartMonthError').forEach(element => element.remove());
    }
    temp.querySelectorAll('.startMonth').forEach(element => {
        //code for start month validation
        if(element.value === '' || element.value === null){
            //create a div tag and display the error
            let elem = document.createElement("div");
            elem.id = 'blankStartMonthError';
            elem.setAttribute('class', 'blankStartMonthError');
            elem.textContent = 'Please enter a Start Month';
            elem.style = 'color:#ff0000; clear:both;';
            element.classList.add('slds-has-error');
            element.parentNode.insertBefore(elem, element.nextSibling);
        }
    });
    //Blank Start Year
    if(temp.querySelectorAll('.blankStartYearError') !== null){
        temp.querySelectorAll('.blankStartYearError').forEach(element => element.remove());
    }
    temp.querySelectorAll('.startYear').forEach(element => {
        if(element.value === '' || element.value === null){
            let elem = document.createElement("div");
            elem.id = 'blankStartYearError';
            elem.setAttribute('class', 'blankStartYearError');
            elem.textContent = 'Please enter a Start Year';
            elem.style = 'color:#ff0000; clear:both;';
            element.classList.add('slds-has-error');
            element.parentNode.insertBefore(elem, element.nextSibling);
        }
    });
    //Blank End Month
    if(temp.querySelectorAll('.blankEndMonthError') !== null){
        temp.querySelectorAll('.blankEndMonthError').forEach(element => element.remove());
    }
    temp.querySelectorAll('.endMonth').forEach(element => {
        if(element.value === '' || element.value === null){
            let elem = document.createElement("div");
            elem.id = 'blankEndMonthError';
            elem.setAttribute('class', 'blankEndMonthError');
            elem.textContent = 'Please enter a End Month';
            elem.style = 'color:#ff0000; clear:both;';
            element.classList.add('slds-has-error');
            element.parentNode.insertBefore(elem, element.nextSibling);
        }
    });
    //Blank End Year
    // Remove the Error Elements by Class Name
    if(temp.querySelectorAll('.blankEndYearError') !== null){
        temp.querySelectorAll('.blankEndYearError').forEach(element => element.remove());
    }
    temp.querySelectorAll('.endYear').forEach(element => {
        if(element.value === '' || element.value === null){
            let elem = document.createElement("div");
            elem.id = 'blankEndYearError';
            elem.setAttribute('class', 'blankEndYearError');
            elem.textContent = 'Please enter End Year';
            elem.style = 'color:#ff0000; clear:both;';
            element.classList.add('slds-has-error');
            element.parentNode.insertBefore(elem, element.nextSibling);
        }
    });
    //Check End Date against Current Date.
    let today = new Date();
    let tempEndMonthVal = '';
    let tempEndYearVal = '';
    let tempStrEDate = '';
    let tempNewEDate = new Date();
    // Remove the Error Elements by Class Name
    if(temp.querySelectorAll('.EndDateError') !== null){
        temp.querySelectorAll('.EndDateError').forEach(element => element.remove());
    }
    temp.querySelectorAll('.endMonth').forEach(element => {
        if(element.value !== '' || element.value !== null){
            //construct the dates
            tempEndMonthVal = element.value;
            tempEndYearVal = element.parentNode.parentNode.querySelector('.endYear').value;
            //Now that we have end year & end month. compare it with current date
            if(tempEndMonthVal !== '' && tempEndYearVal !=='' && tempEndMonthVal !== null && tempEndYearVal !==null){
                tempStrEDate = tempEndYearVal + '-'+ tempEndMonthVal +'-' + '01';
                tempNewEDate = new Date(tempStrEDate);
                if(Date.parse(tempNewEDate) >= Date.parse(today)){
                    let elem = document.createElement("div");
                    elem.id = 'EndDateError';
                    elem.setAttribute('class', 'EndDateError');
                    elem.textContent = 'Start and End dates for a graduate should not be in the future.';
                    elem.style = 'color:#ff0000; clear:both;';
                    element.classList.add('slds-has-error');
                    element.parentNode.insertBefore(elem, element.nextSibling);
                }
            }
        }
    });
    temp.querySelector('.slds-has-error').scrollIntoView();
}
//New Code added by Shailaja.
export function showStartEndErrorFunc(temp){
    let startMonthVal ='';
    let startYearVal ='';
    let endMonthVal ='';
    let endYearVal ='';
    let newEndDateStr ='';
    let newEndDate = new Date();
    let newStartDateStr ='';
    let newStartDate = new Date();
    // Remove the Error Elements by Class Name
    if(temp.querySelectorAll('.startEndDateError') !== null){
        temp.querySelectorAll('.startEndDateError').forEach(element => element.remove());
    }
    temp.querySelectorAll('.endMonth').forEach(element => {
        if(element.value !== '' || element.value !== null){
            endMonthVal = element.value;
            //get end year
            endYearVal = element.parentNode.parentNode.querySelector('.endYear').value;
            //start month & start year
            startMonthVal = element.parentNode.parentNode.parentNode.querySelector('.startMonth').value;
            startYearVal = element.parentNode.parentNode.parentNode.querySelector('.startYear').value;
            //construct end date
            if(endMonthVal !== '' && endMonthVal !== null && endYearVal !=='' && endYearVal !==null && startMonthVal !== '' && startMonthVal !== null && startYearVal !== '' && startYearVal !== null){
                newEndDateStr = endYearVal+ '-'+endMonthVal + '-' + '01';
                newEndDate = new Date (newEndDateStr);
                //start date
                newStartDateStr = startYearVal+ '-'+startMonthVal + '-' + '01';
                newStartDate = new Date(newStartDateStr);
                if(Date.parse(newEndDate) < Date.parse(newStartDate) ){
                    console.log('end date is less than start date ');
                    //add the code for tags
                    let elem = document.createElement("div");
                    elem.id = 'startEndDateError';
                    elem.setAttribute('class', 'startEndDateError');
                    elem.textContent = endDateGreaterThanStartDate;
                    elem.style = 'color:#ff0000; clear:both;';
                    element.classList.add('slds-has-error');
                    element.parentNode.insertBefore(elem, element.nextSibling);
                }
                if(Date.parse(newEndDate) === Date.parse(newStartDate)){
                    //dates are same
                    let elem = document.createElement("div");
                    elem.id = 'startEndDateError';
                    elem.setAttribute('class', 'startEndDateError');
                    elem.textContent = startDateAndEndDateNotSame;
                    elem.style = 'color:#ff0000; clear:both;';
                    element.classList.add('slds-has-error');
                    element.parentNode.insertBefore(elem, element.nextSibling);
                }
            }
        }
    });
    temp.querySelector('.slds-has-error').scrollIntoView();
}
export function showAttendedYearsFunc(temp){
    temp.querySelectorAll('.attendedYearsError').forEach(element => element.remove());
    temp.querySelectorAll('.attendedYears').forEach(element => {
        let decimalCount;
        if(element.value === '' || parseFloat(element.value) <= parseFloat('0') || parseFloat(element.value) > parseFloat('20')){
            let elem = document.createElement("div");
            elem.id = 'attendedYearsError';
            elem.setAttribute('class', 'attendedYearsError');
            elem.textContent = 'Please enter valid number of years attended';
            if(parseFloat(element.value) > parseFloat('20')){
                elem.textContent = 'Maximum number of years allowed is 20';
            }
            elem.style = 'color:#ff0000; clear:both;';
            element.classList.add('slds-has-error');
            element.parentNode.insertBefore(elem, element.nextSibling);
        }else{
            if((Math.floor(parseFloat(element.value)) === parseFloat(element.value))){
                decimalCount = 0;
            }else{
                decimalCount = element.value.split(".")[1].length;
            }
            if(decimalCount > 2){
                element.classList.add('slds-has-error');
            }
        }
    });
    temp.querySelector('.slds-has-error').scrollIntoView();
}
export function sectionsRendererHelper(thisTemp){
    thisTemp.template.querySelectorAll('.recordFieldsWrapper').forEach(element => {
        element.querySelectorAll('.tcMainSection').forEach(elem => {
            if(!elem.classList.contains('creditsDate')){
                elem.style.display = 'block';
            }else{
                elem.style.display = 'flex';
            }
        });
        element.querySelectorAll('.transferCreditSection').forEach(elem => {
            elem.style.display = 'none';
        });
        element.querySelectorAll('.preMedLetterSection').forEach(elem => {
            elem.style.display = 'none';
        });
        if(element.querySelector('.tctName').getAttribute('data-asset-url') !== '' &&
            element.querySelector('.tctName').getAttribute('data-asset-url') !== 'true' &&
            element.querySelector('.tctName').getAttribute('data-asset-url') !== null){
            element.querySelector(".cloudTransferCreditTranscript").auraThumbnailLoaderAzureURL();
            element.querySelectorAll('.tcNameSection').forEach(elem=>{
                elem.style.display = 'block';
            });
            element.querySelectorAll('.tcTranslationSection').forEach(elem=>{
                elem.style.display = 'block';
            });
        }
        if(element.querySelector('.tctNameDifferentCheckbox').checked){
            element.querySelectorAll('.tctNameDocumenatationSectionUpload').forEach(elem=>{
                elem.style.display = 'block';
            });
            if(element.querySelector('.tctNameDocumenatationSectionUploadId').getAttribute('data-asset-url') !== '' &&
            element.querySelector('.tctNameDocumenatationSectionUploadId').getAttribute('data-asset-url') !== 'true' &&
            element.querySelector('.tctNameDocumenatationSectionUploadId').getAttribute('data-asset-url') !== null){
                element.querySelector(".cloudTCTNameDocumentation").auraThumbnailLoaderAzureURL();
            }
        }
        if(element.querySelector('.isTranscriptInEnglishCheckbox').checked){
            element.querySelectorAll('.tcTranslationSectionUpload').forEach(elem=>{
                elem.style.display = 'block';
            });
            if(element.querySelector('.tctTranslationId').getAttribute('data-asset-url') !== '' &&
            element.querySelector('.tctTranslationId').getAttribute('data-asset-url') !== 'true' &&
            element.querySelector('.tctTranslationId').getAttribute('data-asset-url') !== null){
                element.querySelector(".cloudTCTTransDoc").auraThumbnailLoaderAzureURL();
            }
        }
        if(element.querySelector('.pmlName').getAttribute('data-asset-url') !== '' &&
            element.querySelector('.pmlName').getAttribute('data-asset-url') !== 'true' &&
            element.querySelector('.pmlName').getAttribute('data-asset-url') !== null){
            element.querySelector(".cloudPML").auraThumbnailLoaderAzureURL();
            element.querySelectorAll('.pmlNameSection').forEach(elem=>{
                elem.style.display = 'block';
            });
            element.querySelectorAll('.pmlTranslationSection').forEach(elem=>{
                elem.style.display = 'block';
            });
        }
        if(element.querySelector('.pmlNameDifferentCheckbox').checked){
            element.querySelectorAll('.pmlNameSectionUpload').forEach(elem=>{
                elem.style.display = 'block';
            });
            if(element.querySelector('.pmlNameSectionUploadId').getAttribute('data-asset-url') !== '' &&
            element.querySelector('.pmlNameSectionUploadId').getAttribute('data-asset-url') !== 'true' &&
            element.querySelector('.pmlNameSectionUploadId').getAttribute('data-asset-url') !== null){
                element.querySelector(".cloudPMLNameDocumentation").auraThumbnailLoaderAzureURL();
            }
        }
        if(element.querySelector('.isPreMedLetterInEnglishCheckbox').checked){
            element.querySelectorAll('.pmlTranslationSectionUpload').forEach(elem=>{
                elem.style.display = 'block';
            });
            if(element.querySelector('.pmlTranslationId').getAttribute('data-asset-url') !== '' &&
            element.querySelector('.pmlTranslationId').getAttribute('data-asset-url') !== 'true' &&
            element.querySelector('.pmlTranslationId').getAttribute('data-asset-url') !== null){
                element.querySelector(".cloudPMLTransDoc").auraThumbnailLoaderAzureURL();
            }
        }
    });
}
export function emptyRecordsListHelper(){
    let emptyRecordsList = [{
        sno: 1,
        recordIdVal: '',
        otherSchool: '',
        otherSchoolId: '',
        numberOfYearsAttended: '',
        fromDate: '',
        endDate: '',
        startMonth:'',
        startYear:'',
        endMonth:'',
        endYear:'',
        schoolProgram: '',
        transferCreditCourse: '',
        transferCreditGrade: '',
        courseOutcome: '',
        creditsEarnedMonth: '',
        creditsEarnedYear: '',
        showNameSection: false,
        showPmlNameSection: false,
        showTranslationSection: false,
        showTranslationNameSection: false,
        nameOnTranscriptCheckbox: '',
        nameOnPreMedLetterCheckbox: '',
        isTranscriptInEnglishCheckbox: '',
        isPreMedLetterInEnglishCheckbox: '',
        tctId: '',
		pmlId: '',
        pmlUrl: '',
        tctTranslationId: '',
        pmlTranslationId: '',
        tctName: '',
        pmlName: '',
        nameOnTranslationDocCheckbox: '',
        nameOnPmlTranslationCheckbox: '',
        tcWrapperList: [{
            tcId: '',
            transferCreditCourse: '',
            transferCreditGrade: '',
            courseOutcome: '',
            creditsEarnedMonth: '',
            creditsEarnedYear: ''
        }],
        tctAssetIdUpdated: true,
        tctTrnAssetIdUpdated: true,
        tctNameAssetIdUpdated: true,
        pmlAssetIdUpdated: true,
        pmlTrnAssetIdUpdated: true,
        pmlNameAssetIdUpdated: true
    }];
    return emptyRecordsList;
}
export function clearErrorMessage(thisele){
    thisele.template.querySelectorAll('.blankStartMonthError').forEach(element => element.remove());
    thisele.template.querySelectorAll('.blankStartYearError').forEach(element => element.remove());
    thisele.template.querySelectorAll('.blankEndMonthError').forEach(element => element.remove());
    thisele.template.querySelectorAll('.blankEndYearError').forEach(element => element.remove());
    thisele.template.querySelectorAll('.EndDateError').forEach(element => element.remove());
}
export function manageShowSection(thisele){
    if(thisele.template.querySelectorAll('.monthPicklist') !== null){
        thisele.template.querySelectorAll('.monthPicklist').forEach(element => {
            if(element.getAttribute('data-selected-month') !== '' &&
                element.getAttribute('data-selected-month') !== 'true' &&
                element.getAttribute('data-selected-month') !== null){
                element.value = element.getAttribute('data-selected-month');
            }
        });
    }
    if(thisele.template.querySelectorAll('.creditEarnedYearInput') !== null){
        thisele.template.querySelectorAll('.creditEarnedYearInput').forEach(element => {
            element.setAttribute("maxlength", "4");
        });
    }
    if(thisele.template.querySelectorAll('.transferCreditsCheckbox') !== null){
        thisele.template.querySelectorAll('.transferCreditsCheckbox').forEach(element => {
            if(element.checked){
                element.parentNode.querySelectorAll('.transferCreditSection').forEach(elem => {
                    elem.style.display = 'block';
                });
            }else{
                element.parentNode.querySelectorAll('.transferCreditSection').forEach(elem => {
                    elem.style.display = 'none';
                });
            }
        });
    }
    if(thisele.template.querySelectorAll('.tcTable') !== null){
        thisele.template.querySelectorAll('.tcTable').forEach(element => {
            if(element.querySelectorAll('.tcDetailsRow').length === 1){
                element.querySelectorAll('.delete-icon').forEach(elem => {
                    elem.style.display = 'none';
                });
            }else{
                element.querySelectorAll('.delete-icon').forEach(elem => {
                    elem.style.display = 'block';
                });
            }
        });
    }
}
export function tempTctPayloadHelper(contactId, parentCaseId, caseId){
    let tempTctPayloadVar = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'Transfer Credit Transcript',
        assetName: 'Transfer Credit Transcript',
        assetRecordType: 'Credential',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Transfer Credit Transcript',
        key: 'Transfer Credit Transcript Document',
        parentKey: '',
        createFromPB: 'true'
    };
    return tempTctPayloadVar;
}
export function tempTctNamePayloadHelper(contactId, parentCaseId, caseId){
    let tempTctNamePayloadVar = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'Name Document',
        assetName: 'Name Document',
        assetRecordType: 'Identity',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Name Document',
        key: 'Transfer Credit Transcript Name Document',
        parentKey: 'Transfer Credit Transcript Document',
        createFromPB: 'true'
    };
    return tempTctNamePayloadVar;
}
export function tempTctTrnPayloadHelper(contactId, parentCaseId, caseId){
    let tempTctTrnPayloadVar = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'TCT Translation',
        assetName: 'TCT Translation',
        assetRecordType: 'Credential',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Translation',
        key: 'Transfer Credit Transcript Translation Document',
        parentKey: 'Transfer Credit Transcript Document',
        createFromPB: 'true'
    };
    return tempTctTrnPayloadVar;
}
export function tempPmlPayloadHelper(contactId, parentCaseId, caseId){
    let tempPmlPayloadVar = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'Pre-Med Letter',
        assetName: 'Pre-Med Letter',
        assetRecordType: 'Credential',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Pre-Med Letter',
        key: 'Pre-Med Letter Document',
        parentKey: '',
        createFromPB: 'true'
    };
    return tempPmlPayloadVar;
}
export function tempPmlNamePayloadHelper(contactId, parentCaseId, caseId){
    let tempPmlNamePayloadVar = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'Name Document',
        assetName: 'Pre-Med Letter Name Document',
        assetRecordType: 'Identity',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Name Document',
        key: 'Pre-Med Letter Name Document',
        parentKey: 'Pre-Med Letter Document',
        createFromPB: 'true'
    };
    return tempPmlNamePayloadVar;
}
export function tempPmlTrnPayloadHelper(contactId, parentCaseId, caseId){
    let tempPmlTrnPayloadVar = {
        contactId: contactId,
        parentCaseId: parentCaseId,
        caseId: caseId,
        documentType: 'Pre-Med Letter Translation',
        assetName: 'Pre-Med Letter Translation',
        assetRecordType: 'Credential',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        type: 'Pre-Med Letter Translation',
        key: 'Pre-Med Letter Translation',
        parentKey: 'Pre-Med Letter Document',
        createFromPB: 'true'
    };
    return tempPmlTrnPayloadVar;
}