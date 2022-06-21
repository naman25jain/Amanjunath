import { LightningElement } from 'lwc';
import getAccountBalance from '@salesforce/apex/ShoppingCartController.getAccountBalance';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class AccountBalance extends LightningElement {

	hasRendered = false;
	total = 0.0;
	showableTotal = 0.0;
	styleClass = '';

	renderedCallback() {
		if (this.hasRendered) {
			return;
		}
		this.hasRendered = true;
		this.getBalance();
	}

	async getBalance() {
		console.log('Getting Account Balance... V5');
		await getAccountBalance()
		.then(data => {
			if (data) {
				this.total = data;
				if (this.total > 0) {
					this.styleClass = 'red';
					this.total = this.total * -1;
				} else if (this.total < 0) {
					this.styleClass = 'green';
					this.total = this.total * -1;
				}
			}
		})
		.catch(error => {
			const errorMessage = JSON.stringify(error.body.message);
			this.showToast(
				"Info",
				"An error occurred while getting your information: " + errorMessage,
				"info"
			);
			console.log("Error getting account balance: ");
			console.log(errorMessage);
		})
	}

	showToast(title, message, variant) {
		const toastEvent = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant
		});
		this.dispatchEvent(toastEvent);
	}

}