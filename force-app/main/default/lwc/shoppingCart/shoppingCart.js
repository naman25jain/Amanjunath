/* eslint-disable @lwc/lwc/no-api-reassignments */
import { api, LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getCases from "@salesforce/apex/ShoppingCartController.getCases";
import getCaseLines from "@salesforce/apex/ShoppingCartController.getCaseLines";
import getCredits from "@salesforce/apex/ShoppingCartController.getCredits";
import getUnpaidBalances from "@salesforce/apex/ShoppingCartController.getUnpaidBalances";
import getCurrentUsersContactId from "@salesforce/apex/ShoppingCartController.getCurrentUsersContactId";
import createChargentOrder from "@salesforce/apex/ShoppingCartController.createChargentOrder";
import ChargentOrders__ChargentOrder__c from '@salesforce/schema/ChargentOrders__ChargentOrder__c';

const columnsConst = [
	{ label: "Product", fieldName: "Product", type: "text" },
	{ label: "Total", fieldName: "Total", type: "currency" },
];

export default class shoppingCart extends NavigationMixin(LightningElement) {
	// Variables
	// ________________________________________________________________________
	columns = columnsConst;
	processPaymentLabel = 'Proceed';
	unpaidBalance = 0.0;
	credit = 0.0;
	appliedCredit = 0.0;
	subtotal = 0.0;
	total = 0.0;
	stringCaseNumbers = '';

	@track data = [];
	@track caseIdsList = [];
	@track caseNumbersList = [];

	@api caseRecordId;
	@api
	get totalAmount() {
		return this.total;
	}
	set totalAmount(value) {
		this.total = value;
		this.processPaymentLabel = value > 0.0 ? 'Proceed to Payment' : 'Proceed';
	}

	// Flags
	// ________________________
	hasRendered = false;
	spinner = true;
	showCredit = false;
	applyCredit = false;
	singleCase = false;
	hasUnpaidBalance = false;
	unpaidBalanceLoaded = false;
	caseLinesLoaded = false;
	everythingLoaded = false;


	renderedCallback() {
		if (this.hasRendered) {
			return;
		}
		this.hasRendered = true;

		if (this.caseRecordId == null || this.caseRecordId === '') {
			this.showToastSticky(
				'Case record Id not received!',
				'This process cannot continue because the component did not receive a case record Id. This is a required field in order for the rest of the process to work.',
				'error'
			)
			this.caseLinesLoaded = true;
			return;
		}

		this.caseRecordId = this.caseRecordId.replace(' ', '');
		this.caseIdsList = this.caseRecordId.split(',');
		this.singleCase = this.caseIdsList.length === 1;
		this.getCases();
	}

	// Methods
	// _________________________________________________________________
	// Getting the credits
	@wire(getCredits)
	wireCredits({ data, error }) {
		if (data != null) {
			console.log('Credits: ' + data);
			this.credit = data;
			if (data != 0.0) {
				this.showCredit = true;
			}
			this.creditLoaded = true;
			this.calculateTotal();
		} else if (error) {
			console.log("Error getting credits: " + JSON.stringify(error));
			this.creditLoaded = true;
		}
	}

	// Getting the unpaid balances
	@wire(getUnpaidBalances)
	wireUnpaidBalances({ data, error }) {
		if (data != null) {
			console.log('Unpaid Balance: ' + data);
			this.unpaidBalance = Math.abs(data);
			if (data != 0.0) {
				this.hasUnpaidBalance = true;
			}
			this.unpaidBalanceLoaded = true;
			this.calculateTotal();
		} else if (error) {
			console.log("Error getting unpaid balances: " + JSON.stringify(error));
			this.unpaidBalanceLoaded = true;
		}
	}

	// _________________________________________________________________
	// Methods
	// _________________________________________________________________
	// Apply Credits button handler
	applyCredits() {
		this.applyCredit = true;
		this.showCredit = false;
		if (this.totalAmount < this.credit) {
			this.appliedCredit = this.totalAmount;
		} else {
			this.appliedCredit = this.credit;
		}
		this.calculateTotal();
		this.showToast(
			"Credits Applied!",
			"A credit with the amount of $" + this.appliedCredit + " has been applied to your total.",
			"success"
		);
	}

	calculateTotal() {
		var total = 0.0;
		var subtotal = 0.0;
		if (this.data != null) {
			for (let i = 0; i < this.data.length; i++) {
				const element = this.data[i];
				if (element.Total) {
					subtotal += element.Total;
					total += element.Total;
				}
			}
		}

		if (this.hasUnpaidBalance) {
			total += this.unpaidBalance;
		}

		if (this.applyCredit) {
			total -= this.appliedCredit;
		}

		this.subtotal = subtotal;
		this.totalAmount = total;

		this.checkEverythingLoaded();
	}

	checkEverythingLoaded() {
		if (this.caseLinesLoaded && this.unpaidBalanceLoaded && this.hasRendered) {
			if (this.totalAmount == 0.0) {
				// This will cause the cart to exit and continue to the confirmation page, since no payment is needed.
				this.processPaymentAsync();
			}
			this.everythingLoaded = true;
			this.spinner = false;
		}
	}

	async getCases() {
		await getCases({
			caseRecordIds: this.caseIdsList
		})
			.then(result => {
				console.log('GetCases result: ');
				console.log(result);
				if (result) {
					this.caseNumbersList = [];
					for (let i = 0; i < result.length; i++) {
						let element = result[i];
						this.caseNumbersList.push(element.CaseNumber);
					}
					this.stringCaseNumbers = this.caseNumbersList.toString().replace(',', ', ');
					this.loadCaseLines();
				} else {
					this.showToastSticky(
						'No Cases found for given Ids!',
						'This process cannot continue because the component did not receive a correct case record Id. This is a required field in order for the rest of the process to work.',
						'error'
					)
					this.spinner = false;
				}
			})
			.catch(error => {
				console.log('An error occurred while getting your information: ' + JSON.stringify(error));
				this.caseLinesLoaded = true;
			})

	}

	async loadCaseLines() {
		await getCaseLines({
			caseRecordIds: this.caseIdsList
		})
			.then(result => {
				console.log(result);
				if (result) {
					this.data = [];
					for (let i = 0; i < result.length; i++) {
						const element = result[i];
						this.data.push({ Product: element.Product__c, Total: element.Total__c });
					}
				}
				this.caseLinesLoaded = true;
				this.calculateTotal();
			})
			.catch(error => {
				console.log('An error occurred while getting your information: ' + JSON.stringify(error));
				this.caseLinesLoaded = true;
			})
	}

	navigateToFinancialAccount() {
		getCurrentUsersContactId()
			.then(contactRecordId => {
				if (contactRecordId) {
					this[NavigationMixin.Navigate]({
						type: 'standard__recordPage',
						attributes: {
							recordId: contactRecordId,
							objectApiName: 'Contact',
							actionName: 'view'
						}
					}).then((url) => {
						window.open(url, "_blank").focus();
					});
				}
			})
			.catch(error => {
				const errorMessage = JSON.stringify(error.body.message);
				this.showToast(
					'Error',
					'An error occurred while trying to process your payment: ' + errorMessage,
					'error'
				);
			})
	}

	previousEvent(event) {
		event.preventDefault();
		const selectEvent = new CustomEvent("previousevent", {});
		this.dispatchEvent(selectEvent);
	}

	async processPaymentAsync() {
		await createChargentOrder({
			chargeAmount: this.totalAmount,
			caseRecordIds: this.caseIdsList,
			caseNumbers: this.stringCaseNumbers,
			singleCase: this.singleCase
		})
			.then(orderRecordId => {
				if (orderRecordId) {
					this[NavigationMixin.Navigate]({
						type: 'standard__recordPage',
						attributes: {
							recordId: orderRecordId,
							objectApiName: ChargentOrders__ChargentOrder__c.objectApiName,
							actionName: 'view'
						}
					});
				}
				this.spinner = false;
			})
			.catch(error => {
				const errorMessage = JSON.stringify(error.body.message);
				this.showToast(
					'Error',
					'An error occurred while trying to process your payment: ' + errorMessage,
					'error'
				);
				this.spinner = false;
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

	showToastSticky(title, message, variant) {
		const toastEvent = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: "sticky"
		});
		this.dispatchEvent(toastEvent);
	}
}