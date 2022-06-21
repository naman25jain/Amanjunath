import { LightningElement, api } from 'lwc';

export default class CibisCompareRecords extends LightningElement {
    @api contactData;
    @api selectedCIBISDupCheckContact;

    columnNames = ['','Last Name', 'USMLE ID', 'BirthDate', 'Gender', 'MedSchool Code'];
    tableData = [];

    connectedCallback(){
        console.log('Received data '+this.contactData);
        console.log('Selected row data '+this.selectedCIBISDupCheckContact);
        this.tableData.push({'source':'CIBIS Record','LastName':this.selectedCIBISDupCheckContact.Cibis_Last_Name__c, 'USMLEId':this.selectedCIBISDupCheckContact.CIBIS_USMLE_ID__c,'BirthDate':this.selectedCIBISDupCheckContact.CibisBirthDate__c,'Gender':this.selectedCIBISDupCheckContact.CIBIS_GENDER_CODE__c,'MedSchoolCode':this.selectedCIBISDupCheckContact.CibisMedicalSchoolCode__c});
        this.tableData.push({'source':'ECFMG Contact','LastName':this.contactData.Contact.LastName, 'USMLEId':this.contactData.Contact.USMLE_ID__c,'BirthDate':this.contactData.Contact.Birthdate,'Gender':this.contactData.Contact.Gender__c === 'Male' ? 'M' : 'F' ,'MedSchoolCode':this.contactData.Contact.Medschool_Code__c});
    }
}