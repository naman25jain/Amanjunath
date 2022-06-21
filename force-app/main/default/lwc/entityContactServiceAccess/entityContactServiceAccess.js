import { LightningElement, track,api } from 'lwc';

import getAvailableServicesForEntity from '@salesforce/apex/EntityServiceRequestController.getAvailableServicesForEntity';
import createEntityUserRequest from '@salesforce/apex/EntityServiceRequestController.createEntityUserRequest';

const columns = [{
        label: 'Service Name',
        fieldName: 'serviceName',
        hideDefaultActions: true
    },
    {
        label: 'Does my entity currently participate?',
        fieldName: 'isEnrolled',
        hideDefaultActions: true
    },
    {
        label: 'Do I have access?',
        fieldName: 'hasAccess',
        hideDefaultActions: true
    },
    {
        type: 'button',
        hideDefaultActions: true,
        typeAttributes: {
            label: 'Request Access',
            variant: 'brand',
            name: 'Request Access',
            class: { fieldName: 'hideRequestAccessButton'},
            disabled: { fieldName: 'disableRequestAccess'},
        }
    }
];


export default class EntityContactServiceAccess extends LightningElement {
    @track entityServiceList = [];
    @track columns = columns;
    @track showServiceAccess = false;
    @track showServiceAccessError = false;
    @track spinner = false;
    @track errorMessagesText;
    @track selectedService;

    @track instructionsContent = ''+
    '<body>'+
    '<b>Alert</b>'+
    '<br><br>'+
    'You are about to confirm your request for access to a service. '+
    'By confirming, you agree to share your information with the Coordinator of that service at '+
    'your entity, if your entity already participates.'+

    ''+
    '</body>';

    @api
    get currentEntity() {
    return this._currentEnt;
    }
    set currentEntity(value) {
    this.setAttribute('currentEntity', value);
    this._currentEnt = value;
    this.setup();
    }

    @track _currentEnt;

    connectedCallback(){

    }

    setup() {
        this.spinner = true;
        this.entityServiceList =[];

        getAvailableServicesForEntity({currentEntityId : this._currentEnt})
        .then(result => {
            if(result.length > 0) {
                for(let key in result) {
                    if(result.hasOwnProperty(key)) {
                        let tempRecord = {
                            serviceName : result[key].serviceName,
                            isEnrolled : result[key].isEnrolled,
                            hasAccess : result[key].hasAccess,
                            hideRequestAccess : result[key].hideRequestAccess,
                            disableRequestAccess : result[key].disableRequestAccess
                        };
                        if(tempRecord.hideRequestAccess) {
                            tempRecord.hideRequestAccessButton = 'slds-hidden';
                        }
                        if(this.entityServiceList.length > 0 ){
                            this.entityServiceList = [...this.entityServiceList,tempRecord];
                        } else {
                            this.entityServiceList = [tempRecord];
                        }
                    }
                }
                this.showServiceAccess = true;
            }
            else {
                this.showServiceAccessError = true;
                this.errorMessagesText = 'Your entity does not have access to any service.';
            }
            this.spinner = false;
        })
        .catch(error => {
            this.spinner = false;
            window.console.log('Error: ' + JSON.stringify(error));
        });
    }
    displayModalClass( event ){
        this.selectedService = event.detail.row.serviceName;
        this.template.querySelector('c-modal-component').show();
    }
    handleConfirm() {
        this.spinner = true;
        createEntityUserRequest({
            selServiceName : this.selectedService,
            currentEntityId : this._currentEnt
        })
        .then(()=> {
            let data = [...this.entityServiceList];
            for (let key in data) {
                if (data.hasOwnProperty(key)) {
                   if(data[key].serviceName === this.selectedService) {
                    data[key] = {...data[key], disableRequestAccess : true};
                   }
                }
             }
            this.entityServiceList = data;
            this.spinner = false;
        })
        .catch(error => {
            this.spinner = false;
            window.console.log('Error: ' + JSON.stringify(error));
        });
    }
}