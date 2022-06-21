import { LightningElement, track, wire } from 'lwc';
import getECFMGCertificateInfo from "@salesforce/apex/ECFMGCertificateDetails.getECFMGCertificateInfo";
import A360_efmgCertificateDetailsMessage from '@salesforce/label/c.A360_efmgCertificateDetailsMessage';

export default class EcfmgCertificateDetails extends LightningElement{
    @track certificationData =[];
    @track showDetails = false;
    @track showData = false;
    @track showMessage = false;

    label = {
        A360_efmgCertificateDetailsMessage
    };

    connectedCallback(){
        this.getData();
    }

    getData(){
        getECFMGCertificateInfo()
        .then(result => {
            this.certificationData = result;
            console.log("The result is:::"+JSON.stringify(result));
            let currentCaseStatus = this.certificationData.caseStatus;
            if(currentCaseStatus === 'Pending Review' || currentCaseStatus === 'In Review' || currentCaseStatus === 'Incomplete' || currentCaseStatus === 'Pending Applicant Action - Resubmit Documents'){
                this.showData = true;
                this.showMessage = true;
                this.showDetails = false;
            }else if(currentCaseStatus === 'Final QA Complete' || currentCaseStatus === 'Pending Address Review' || currentCaseStatus === 'Pending Print' || currentCaseStatus === 'Sent'){
                this.showData = true;
                this.showMessage = false;
                this.showDetails = true;
            }else{
                this.showData = false;
                this.showMessage = false;
                this.showDetails = false;
            }
        })
        .catch(error => {
            this.error = error;
            console.error("The error is:::"+JSON.stringify(error));
        });
    }


}