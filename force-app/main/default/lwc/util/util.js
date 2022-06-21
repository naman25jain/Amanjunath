/* eslint-disable no-useless-escape */
/* eslint-disable radix */
/* eslint-disable consistent-return */
/* eslint-disable no-console */

import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateStepNumber from '@salesforce/apex/EntityCredVerController.updateStep';
export default class Util extends LightningElement {

}

export function showMessage(component, {
    title,
    message,
    messageType,
    mode
}) {
    component.dispatchEvent(new ShowToastEvent({
        mode: mode,
        title: title,
        message: message,
        variant: messageType,
    }));
}


export function passDataToParent(eventName, isTrue, eventData, componentInstance) {
    const myEventWithPriority = new CustomEvent(eventName, {
        bubbles: true,
        cancelable: true,
        composed: true,
        detail: {
            flag: isTrue,
            data: eventData
        }
    });

    // Fire the event
    componentInstance.dispatchEvent(myEventWithPriority);
}

export function changeTabs(component, target) {
    let clickedItem = target;
    let newActiveTabId = clickedItem.getAttribute("id").split("__")[0];

    component.template.querySelector('.slds-is-active').classList.remove('slds-is-active');
    clickedItem.parentNode.classList.add('slds-is-active');

    component.template.querySelector('.slds-show').classList.add('slds-hide');
    component.template.querySelector('.slds-show').classList.remove('slds-show');


    this.changeTabWithId(component, newActiveTabId);

}

export function changeTabWithId(component, tabId) {
    component.template.querySelector('.' + tabId).classList.remove('slds-hide');
    component.template.querySelector('.' + tabId).classList.add('slds-show');
}

export function formatPhoneNumber(event, number) {
    let keyCode = event.which;
    if ((keyCode < 48 || keyCode > 57) || (number && number.length > 13)) {
        event.preventDefault();
        return number;
    } 
    return autoFormatNumber(number);

}

export function formatNumber(event, number) {
    let keyCode = event.which;
    if ((keyCode < 48 || keyCode > 57)) {
        event.preventDefault();
    }  return number;
}

export function formatString(event, value) {
    let keyCode = event.which;
    if ((keyCode >= 48 && keyCode <= 57)) {
        event.preventDefault();
        return value;
    }  return value;
}

export function formatZIP(event, number) {
    if (number && number.length > 5) {
        event.preventDefault();
    } return number;
}

export function formatNumberLength(event, number) {
    let keyCode = event.which;
    if ((keyCode < 48 || keyCode > 57) || (number && number.length > number)) {
        event.preventDefault();
    } 
    return number;
}

export function formatNumber11(event, number) {
    let keyCode = event.which;
    if ((keyCode < 48 || keyCode > 57) || (number && number.length > 9)) {
        event.preventDefault();
    } return number;
}

function autoFormatNumber(number) {
    number = number.replace(/[^\d]/g, '');
    if (number.length === 1) {
        number = number.replace(/(\d{1})/, "($1)");
    } else if (number.length === 2) {
        number = number.replace(/(\d{2})/, "($1)");
    } else if (number.length === 3) {
        number = number.replace(/(\d{3})/, "($1)");
    } else if (number.length === 4) {
        number = number.replace(/(\d{3})(\d{1})/, "($1) $2");
    } else if (number.length === 5) {
        number = number.replace(/(\d{3})(\d{2})/, "($1) $2");
    } else if (number.length === 6) {
        number = number.replace(/(\d{3})(\d{3})/, "($1) $2");
    } else if (number.length === 7) {
        number = number.replace(/(\d{3})(\d{3})(\d{1})/, "($1) $2-$3");
    } else if (number.length === 8) {
        number = number.replace(/(\d{3})(\d{3})(\d{2})/, "($1) $2-$3");
    } else if (number.length === 9) {
        number = number.replace(/(\d{3})(\d{3})(\d{3})/, "($1) $2-$3");
    } else if (number.length === 10) {
        number = number.replace(/(\d{3})(\d{3})(\d{4})/, "($1) $2-$3");
    }
    return number;
}

export function validatePhoneNumber(number) {
    let finalNumber = '';
    if (number) {
        [...number].forEach(element => {
            if (element !== ' ') {
                if (!isNaN(element) || (element !== '(' && element !== ')' && element !== '-')) {
                    finalNumber = finalNumber ? finalNumber + element : element;
                }
            }
        });
        if (finalNumber.length === 10) {
            return true;
        }
        return false;
    }

    return true;
}

export function validateEmail(email) {
    let regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

    if (email) {
        if (email.match(regExpEmailformat)) {
            return true;
        }
    }

    return false;
}

export function validateString(str) {
    let isString = true;
    if (str !== '') {
        [...str].forEach(element => {
            if (element !== ' ') {
                if (isString) {
                    if (!isNaN(element)) {
                        isString = false;
                    }
                }
            }
        });
    }
    return isString;
}

export function validateNumber(number) {
    let isNumber = true;
    if (number) {
        if (isNaN(number)) {
            isNumber = false;
        }
    } else {
        isNumber = false;
    }
    return isNumber;
}

export function calculateYears(date1) {
    let birthDate = new Date(date1);
    let otherDate = new Date();
    let years = (otherDate.getFullYear() - birthDate.getFullYear());
    if (otherDate.getMonth() < birthDate.getMonth() ||
        otherDate.getMonth() === birthDate.getMonth() && otherDate.getDate() < birthDate.getDate()) {
        years--;
    }
    // console.log('Years', years);
    return years;
}
export function updateScreenNumer(caseId,screenNumer){
    updateStepNumber({
        stepNumber:screenNumer,
        caseId:caseId
    }).catch(err=>window.console.error('Error: ',err));
}