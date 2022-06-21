import { LightningElement, api } from 'lwc';

const CSS_CLASS = 'modal-hidden';

export default class ModalComponent extends LightningElement {
    showModal = false;
    @api messageColor;
    @api showPrimaryButton;
    @api primaryButtonText;
    @api showSecondaryButton;
    @api secondaryButtonText;

    showPrimaryButtonPrivate;
    showSecondaryButtonPrivate;

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
        const primarybuttonclick = new CustomEvent('primarybuttonclick');
        this.dispatchEvent(primarybuttonclick);
        this.hide();
    }
}