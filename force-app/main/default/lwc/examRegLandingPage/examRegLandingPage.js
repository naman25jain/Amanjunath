/* eslint-disable vars-on-top */
import { LightningElement, track, api } from 'lwc';
//import required apex methods
import getExamRegistrations from "@salesforce/apex/ExamRegistrationController.getExamRegistrations";
import deleteExamRegistration from '@salesforce/apex/ExamRegistrationController.deleteExamRegistration';
import getExamRegistrationCases from "@salesforce/apex/ExamRegistrationController.getExamRegistrationCases";
//import required custom labels
import examRegLandingPageHeader from "@salesforce/label/c.ExamRegLandingPageHeader";
import examRegNoExamMessage from "@salesforce/label/c.NoExamMessage";
import examRegTableHeader from "@salesforce/label/c.Exam_Reg_Table_Header1";
export default class ExamRegLandingPage extends LightningElement {
    //track variables
    @track examRegistrationsList = [];
    @track examRegCaseRecordIds = '';
    @track showExamRegList = false;
    @api showBackToSummary;
    @api examRegId;

    label = { examRegLandingPageHeader, examRegNoExamMessage, examRegTableHeader};

    connectedCallback() {
        this.getExamRegistrationsRecords();
    }

    getExamRegistrationsRecords(){
        getExamRegistrationCases()
        .then(result => {
            if(result){
                this.examRegCaseRecordIds = result;
            }
        })
        .catch(error => {
            window.console.log('Error: ' + JSON.stringify(error));
        });
        getExamRegistrations()
            .then(value => {
                if (value) {
                    if (value.length > 0) {
                        this.showExamRegList = true;
                        this.examRegistrationsList = [];
                        for (let key in value) {
                            if (value.hasOwnProperty(key)) {
                                let tempRecord = {
                                    recordIdVal: value[key].recordIdVal,
                                    examType: value[key].examType,
                                    eligibilityPeriod: value[key].eligibilityPeriod,
                                    testingRegion: value[key].testingRegion,
                                    testAccomodations: value[key].testAccomodations,
                                };
                                this.examRegistrationsList.push(tempRecord);
                            }
                        }
                    }
                    else {
                        this.examRegistrationsList = [];
                        this.showExamRegList = false;
                    }
                }
            })
            .catch(error => {
                window.console.log('Error: ' + JSON.stringify(error));
            });
    }
    showDeleteExamRegAlert(event){
        this.template.querySelector('[data-id="deleteExamRegModalAlert"]').show();
        event.preventDefault();
        //Get the current exam registration id
        let closestId = this.getClosest(event.target, '.exam-reg-id');
        let currentExamRegId = closestId.getAttribute('data-record-id');
        //Set the value in examRegId and this will be used in the delete exam event.
        this.examRegId = currentExamRegId;
    }

    closeDeleteExamRegAlert(event){
        this.template.querySelector('[data-id="deleteExamRegModalAlert"]').hide();
    }

    deleteExamReg(event) {
        event.preventDefault();
        deleteExamRegistration({ examRegId: this.examRegId })
            .then(result => {
                if (result === 'Success') {
                    this.getExamRegistrationsRecords();
                }
            });
    }

    editExamReg(event) {
        event.preventDefault();
        let closestId = this.getClosest(event.target, '.exam-reg-id');
        let currentExamRegId = closestId.getAttribute('data-record-id');
        this.examRegId = currentExamRegId;
        const selectEvent = new CustomEvent('editexamregevent', { detail: {examRegId: currentExamRegId, showBackToSummary: this.showBackToSummary} });
        this.dispatchEvent(selectEvent);
    }

    next(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('nextevent', {detail:{caserecordidexamreg:this.examRegCaseRecordIds}});
        this.dispatchEvent(selectEvent);
    }

    previous(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('previousevent', {});
        this.dispatchEvent(selectEvent);
    }
    backToSummary(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('backtosummary', {});
        this.dispatchEvent(selectEvent);
    }

    addExamReg(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('addevent', { detail: {examRegId: undefined, showBackToSummary: this.showBackToSummary }});
        this.dispatchEvent(selectEvent);
    }
    cancel(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent("cancelevent", {});
        this.dispatchEvent(selectEvent);
    }

    /**
     * Get the closest matching element up the DOM tree.
     * @private
     * @param  {Element} elem     Starting element
     * @param  {String}  selector Selector to match against
     * @return {Boolean|Element}  Returns null if not match found
     */
    getClosest(elem, selector) {

        // Element.matches() polyfill
        if (!Element.prototype.matches) {
            Element.prototype.matches =
                Element.prototype.matchesSelector ||
                Element.prototype.mozMatchesSelector ||
                Element.prototype.msMatchesSelector ||
                Element.prototype.oMatchesSelector ||
                Element.prototype.webkitMatchesSelector ||
                function (s) {
                    var matches = (this.document || this.ownerDocument).querySelectorAll(s),
                        i = matches.length;
                    // eslint-disable-next-line no-empty
                    while (--i >= 0 && matches.item(i) !== this) {
                        //loop to check i value
                    }
                    return i > -1;
                };
        }
        // Get closest match
        for (; elem && elem !== document; elem = elem.parentNode) {
            if (elem.matches(selector)) return elem;
        }
        return null;
    }
}