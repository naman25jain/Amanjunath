/** @name: ContactAssociationTypeService
*   @description: Define business logic
**/
public with sharing class ContactAssociationTypeService {

/**
* @name updateApplication
* @description: update information on contact based on Contact Association Type record
* @param List<Contact_Association_Type__c> objectList
* @return void
**/
    public static void updateApplication(List<Contact_Association_Type__c> objectList) {

        Map<Id, Id> contactToaccountIdMap = new Map<Id, Id>();
        List<Contact> contactList = new List<Contact>();

        try {
// loop through the case attribute records to get the account id and other details
// assuming one to one mapping b/w verification request, case, case attribute (LINKED_ENTITY_ID) and contact
            for (Contact_Association_Type__c itr : objectList) {
                contactToaccountIdMap.put(itr.Contact__c, itr.Account__c);
            }

//query medschool code of account associated with contact via contact association type child relationship
            Map<Id, Account> medschoolAcctMap = new Map<Id, Account>([
                    Select Id, Medschool_Code__c
                    FROM Account
                    WHERE Id = :contactToaccountIdMap.values()
                    AND Medschool_Code__c != null
            ]);
            if (medschoolAcctMap <> null && medschoolAcctMap.size() > 0) {
//populate the Mdeschool Code on Contact from the account having medschool code
                for (String itr : contactToaccountIdMap.keyset()) {
                    contactList.add(new Contact(Id = itr, Medschool_Code__c = medschoolAcctMap.get(contactToaccountIdMap.get(itr)).Medschool_Code__c, dupcheck__dc3DisableDuplicateCheck__c = true));
                }

// update Medschool Code on contacts
                update contactList;
            }

        } catch (Exception exp) {
            throw new ServiceException(Label.SystemError + ' ' + exp);
        }
    }

    public static List<Contact_Association_Type__c>  getContatAssocTypesByCaseId(Id caseId){
        List <Contact_Association_Type__c> lstContatAssocTypes = [SELECT Id 
                                                                 FROM Contact_Association_Type__c
                                                                 WHERE case__c =: caseId]; 
        return   lstContatAssocTypes;                                                       
    }

}