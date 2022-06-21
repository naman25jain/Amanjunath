import { LightningElement, api } from 'lwc';

import changeRole from '@salesforce/apex/EntityContactServiceController.changeRole';

const CSS_CLASS = 'modal-hidden';
const COORDINATOR = 'Coordinator';

export default class RoleModalComponent extends LightningElement {
    showModal = false;
    @api messageColor;
    @api showPrimaryButton;
    @api primaryButtonText;
    @api showSecondaryButton;
    @api secondaryButtonText;

    @api serviceId;
    @api serviceDtl;
    @api roleVal;
    @api allRoles = [];
    @api accountDtl;
    @api showErrorDetails;
    
    showPrimaryButtonPrivate;
    showSecondaryButtonPrivate;
    get monthoptions() {
        return [{
            label: 'User',
            value: 'User'
        },
        {
            label: 'Coordinator',
            value: 'Coordinator'
        }
        ];
    }

    @api
    set title(value) {
        this.hasHeaderString = value !== '';
        this._headerPrivate = value;
    }
    get title() {
        return this._headerPrivate;
    }

    hasHeaderString = false;
    _headerPrivate;

    @api
    set message(value) {
        this.hasMessageString = value !== '';
        this._messagePrivate = value;
    }
    get message() {
        return this._messagePrivate;
    }

    hasMessageString = false;
    _messagePrivate;

    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }

    connectedCallback() {
        this.showErrorDetails = false;
        if (this.messageColor === '') {
            this.messageColor = black;
        }
    }
    
    renderedCallback() {
       
        if (this.template.querySelector(".message") != null) {
            this.template.querySelector(".message").style.color = this.messageColor;
        }
     
        if (this.showPrimaryButton === 'true' && this.primaryButtonText !== '') {
            this.showPrimaryButtonPrivate = true;
            if (this.template.querySelector('footer') != null) {
                this.handleSlotFooterChange();
            }
        }

        if (this.showSecondaryButton === 'true' && this.secondaryButtonText !== '') {
            this.showSecondaryButtonPrivate = true;
        }
    }

    handleDialogClose() {
        //Let parent know that dialog is closed (mainly by that cross button) so it can set proper variables if needed
        const closedialog = new CustomEvent('closedialog');
        this.dispatchEvent(closedialog);
        this.hide();
    }

    handleSlotTaglineChange() {
        const taglineEl = this.template.querySelector('p');
        taglineEl.classList.remove(CSS_CLASS);
    }

    handleSlotFooterChange() {
        const footerEl = this.template.querySelector('footer');
        footerEl.classList.remove(CSS_CLASS);
    }

    handlePrimaryButtonClick() {
        //Let parent know that primary button is clicked so it can set proper variables if needed
        if(this.showErrorDetails === false){
            const primarybuttonclick = new CustomEvent('primarybuttonclick');
            this.dispatchEvent(primarybuttonclick);
            this.hide();
        }
    }
    changeHandlerRole(event) {
        this.showErrorDetails = false;
        if(this.roleVal === COORDINATOR){
        
            changeRole({
                accId : this.accountDtl,serName : this.serviceDtl
            })
            .then(result=> {
                        
                if(result){
                
                    this.showErrorDetails = false;
                }else{
                    this.showErrorDetails = true;
                
                }
                
            })
            .catch(error => {     
                            
                window.console.log('Error: ' + JSON.stringify(error));
            }); 
        }
        if(this.showErrorDetails === false){
            this.roleVal = event.target.value;
        }
        
          
        }


}