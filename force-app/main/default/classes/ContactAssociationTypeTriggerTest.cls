/** @name: ContactAssociationTypeTriggerTest
 *  @description: test class
**/
@isTest
public class ContactAssociationTypeTriggerTest {
/*
Creates test data for other tests.
*/
   @testSetup
   static void setup() {
       
        Account acct = new Account(
            Name = 'Test Entity Account',
            BillingCountry ='Bhutan',
            RecordTypeId = RecordTypeUtility.getRecordTypeIdByName('Account', Constants.ACCOUNT_RECORD_TYPE_ENTITY),
            Medschool_Code__c = 'MED001'
        );
       insert acct;
       
       Contact con = new Contact(
           FirstName = 'Mike',
           LastName = 'Testing',
           Medschool_Code__c = '12345',
           Gender__c = 'Male',
           Email = 'test_ECFMG@test.ecfmg.com'
        );
        insert con;
       
       Contact_Association_Type__c conAscType = new Contact_Association_Type__c(Account__c=acct.Id, Contact__c=con.Id, 
                                                                                	RecordTypeId=RecordTypeUtility.getRecordTypeIdByName('Contact_Association_Type__c', Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MED_SCHOOL), 
                                                                                	Degree_Issue_Date__c=Date.parse('1/1/2000'), 
                                                                                	Type__c=Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL);
       insert conAscType;

    }
    
    /*
        This method tests if the method throws an exception if a non-valid case id is passed to method.
    */
    @isTest
    static void testContactAssociationTypeCreation() {
        


        List<Account> accounts = [select Id, Name, Medschool_Code__c from Account];

        System.assert(accounts != null, 'accounts should not be null');
       
        List<Contact> contacts = [select Id, Name, Medschool_Code__c from Contact];
       
        System.assert(contacts != null, 'contacts should not be null');
        System.assert(contacts.size() == 1, 'size of contacts should be 1');
        
        List<Contact_Association_Type__c> conAscList = [SELECT Account__c, Contact__c, RecordTypeId, Degree_Issue_Date__c, Type__c
                                                        	FROM Contact_Association_Type__c
                                                        	WHERE Account__c=:accounts[0].Id
                                                        	AND Contact__c=:contacts[0].Id];
        
		System.assert(conAscList != null, 'contact association type should not be null');
        System.assert(conAscList.size() == 1, 'size of contact association type should be 1');                                               
        System.assert(contacts[0].Medschool_Code__c == accounts[0].Medschool_Code__c, 'medscool on application is not mathcing with degree medschool associated with applicant');
    	List<Contact_Association_Type__c> tL = [Select Id FROM Contact_Association_Type__c];
    	Map<Id, SObject> oldmap = new Map<Id, SObject>();
    	ContactAssociationTypeHandler h = new ContactAssociationTypeHandler();
    	h.beforeUpdate(tL,oldmap);
    	h.afterUpdate(tL,oldmap);
    	h.beforeDelete(tL);
    	h.afterDelete(tL);
    	h.afterUndelete(tL);
    }   
}