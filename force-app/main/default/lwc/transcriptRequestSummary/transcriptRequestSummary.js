import {LightningElement, track, api} from 'lwc';
// import required apex methods
import getTrascriptDetails from '@salesforce/apex/TranscriptRequestController.getTrascriptDetails';
export default class TranscriptRequestSummary extends LightningElement{
    @track transcriptRequestRecordList = [];
    @track showCourierFees = false;
    @api linkSource;
    get options() {
        return [{
                label: 'Yes',
                value: 'Yes'
            },
            {
                label: 'No',
                value: 'No'
            },
        ];
    }
    connectedCallback(){
        this.getTranscriptDetailRecords();
    }
    getTranscriptDetailRecords(){
        getTrascriptDetails({linkSource: this.linkSource})
            .then(results=>{
                if (results) {
                    let count = 0;
                    for(let key in results){
                        let tempRecord = {
                            sno: ++count,
                            case: results[key].Case__c,
                            city: results[key].City__c,
                            contact: results[key].Contact__c,
                            country: results[key].Country__c,
                            courierRequired: results[key].Courier__c ? 'Yes' : 'No',
                            nameOfRecipient: results[key].Name_of_Recipient__c,
                            organization: results[key].Organization__c,
                            parentTranscriptRequest: results[key].Parent_Transcript_Request__c,
                            sendToSameAddress: results[key].Send_to_Same_Address__c,
                            sendToSameAddressText: results[key].Send_to_Same_Address__c ? 'Yes' : 'No',
                            sendToSelf: results[key].Send_to_Self__c ? 'Yes' : 'No',
                            state: results[key].State__c,
                            street: results[key].Street__c,
                            showSendToSameAddress: results[key].Parent_Transcript_Request__c !== null && count !== 1,
                            telephone: results[key].Telephone_Number__c,
                            showTelephone: results[key].Courier__c,
                            zipcode: results[key].Zip_Postal_Code__c,
                            secondTranscriptToSameAddress: results[key].Number_of_Copies__c === 2
                        }
                        this.showCourierFees = this.showCourierFees || results[key].Courier__c;
                        if(this.transcriptRequestRecordList.length > 0){
                            this.transcriptRequestRecordList = [...this.transcriptRequestRecordList, tempRecord];
                        }else{
                            this.transcriptRequestRecordList = [tempRecord];
                        }
                    }
                }
            })
            .catch(error=>{
                window.console.error('System Error: getTrascriptDetails error : ' + JSON.stringify(error));
            });
    }
    prevButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('previousevent', {});
        this.dispatchEvent(selectEvent);
    }

    nextButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent("nextevent", {});
        this.dispatchEvent(selectEvent);
    }
    cancelButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }
    cancelButtonToOpen(){
        this.template.querySelector('[data-id="newModalAlert"]').show();
    }
    closeModal(){
        this.template.querySelector('[data-id="newModalAlert"]').hide();
    }
}