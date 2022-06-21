import { LightningElement, track, wire, api} from 'lwc';
import createCredTermsRec from '@salesforce/apex/EpicCredVerController.createCredTermsRec';
import getCredAllTC from '@salesforce/apex/EpicCredVerController.getCredAllTC';
import getAllConstants from '@salesforce/apex/AppForCertController.getAllConstants';
import termsTitle from '@salesforce/label/c.App_For_Cert_Legal_Terms_Title';
export default class CredIntakeLegalLang extends LightningElement{
    @track recordsList = [];
    @track showError = false;
    @track errorMessagesText = '';
    @track checkedcount = 0;
    @track spinner = false;
    @track btnNotDisabled = false;
    @track credLegalVar;
    @api caseRecordId;
    @wire(getAllConstants) 
    allConstants({error, data}){
        if(data){
            this.credLegalVar = data.LWC_PRODUCT_NAME_CRED_INTAKE_LEGAL_TERMS;
        }else{
            this.error = error;
        }
    }
    label = {
        termsTitle
    };
    @wire(getCredAllTC) objectValues({
        error,
        data
    }){
        if(data){        
            for(let key in data){                              
                if(data.hasOwnProperty(key)){
                    let tempRecord = {
                        termsId : data[key].termsId,
                        termsContent : data[key].termsContent,
                        termsCheckboxCont : data[key].termsCheckboxContent
                    };                    
                    if(this.recordsList.length > 0){
                        this.recordsList = [...this.recordsList,tempRecord];
                    }else{
                        this.recordsList = [tempRecord];
                    }                    
                }
            } 
        }else if(error){
            this.recordsList = [{
                termsId : '',
                termsContent : '',
                termsCheckboxCont : ''
            }];
        }
    }
    prevButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent("previousevent", {detail:{caserecordid:this.caseRecordId}});
        this.dispatchEvent(selectEvent);
    }    
    handleClick(){
        this.showError = false;
        this.spinner = true;
        this.errorMessagesText = '';
        if(this.recordsList.length===this.checkedcount){
            createCredTermsRec({
                credLegalVar : this.credLegalVar
            })
            .then(saveresult => {
                this.spinner = false;
                this.nextButton();
            }
            )
            .catch(error => {
                window.console.log('Error: ' + JSON.stringify(error));
            });
        }else{
            this.showError = true;
            this.spinner = false;
        }        
    }
    handleChangeCheckBox(event){
        this.btnNotDisabled = false;
        if(event.target.checked){
            this.checkedcount = this.checkedcount+1;
        }else{
            this.checkedcount = this.checkedcount-1;
        }
        if(this.recordsList.length===this.checkedcount){
            this.btnNotDisabled = true;
        }
    }    
    cancelButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent("cancelevent", {});
        this.dispatchEvent(selectEvent);
    }
    nextButton(){
        const selectEvent = new CustomEvent("nextevent", {});
        this.dispatchEvent(selectEvent);
    }
    cancelButtonToOpen(){
        this.template.querySelector('[data-id="newModalAlert"]').show();
    }
    closeModal(){
        this.template.querySelector('[data-id="newModalAlert"]').hide();
    }
}