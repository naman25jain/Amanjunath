@isTest
public with sharing class GResendPrePopValuesTest {
    public static final String BILLING_COUNTRY = 'India';
    @isTest
    static void testMethod1() {
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Id credVerCaseRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        List<Account> acctList = new List<Account>();
        List<Case> caseList = new List<case>();        
        List<Verification_Packet__c> verPack = new List<Verification_Packet__c>();
        Account acct = new Account(Name='Test Account1',RecordTypeId=idAccountTypeId,School__c=true,BillingCountry=BILLING_COUNTRY);
        INSERT acct;
        acctList.add(acct);           
        List<Contact> contactList = new List<Contact>();
        Contact c1 = new Contact(Firstname='firstname1',Lastname='lastname1',email='email@test1.com',AccountId = acct.Id);
        INSERT c1;
        contactList.add(c1);     
        Case credVerCase = new Case();
        credVerCase.RecordTypeId = credVerCaseRecordtypeId;
        credVerCase.ContactId = c1.Id;
        credVerCase.Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION;
        credVerCase.Internal_Status__c = Constants.CASE_STATUS_SENT_FOR_VERIFICATION;
        credVerCase.Send_Method__c = 'Paper';
        credVerCase.Entity__c = acct.Id; 
        credVerCase.Document_Type__c = 'Final Medical Diploma';
        INSERT credVerCase;
        caseList.add(credVerCase);
        Verification_Packet__c vp = new Verification_Packet__c();
        vp.Case__c = credVerCase.Id;
        vp.Contact__c = c1.Id;
        vp.Is_Active__c = true;
        vp.Case__c = credVerCase.Id;
        verPack.add(vp);
        INSERT vp; 
        Service__c newSer = new Service__c();
        newSer.Name = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION;
        Insert newSer;
        List<Account2Service__c> acc2SerList = new List<Account2Service__c>();
        Account2Service__c acctServ = new Account2Service__c();
        acctServ.active__c = true;
        acctServ.Account__c = acct.Id;
        acctServ.Service__c = newSer.Id;
        INSERT acctServ;
        acc2SerList.add(acctServ);
        List<CONTACT2ACCTSERVICE__c> con2AccserList = new List<CONTACT2ACCTSERVICE__c>();
        CONTACT2ACCTSERVICE__c conAccServiceObj = new CONTACT2ACCTSERVICE__c();
        conAccServiceObj.Role__c = 'User';
        conAccServiceObj.Preferred_mode_of_communication__c = 'Paper';
        conAccServiceObj.Physical_Address__c = 'Test Address';
        conAccServiceObj.List_of_emails__c = '';
        conAccServiceObj.Verification_Website_URL__c = '';
        conAccServiceObj.Credential_Type__c = 'Final Medical Diploma';
        conAccServiceObj.Account_Service__c = acctServ.Id;
        conAccServiceObj.Service_Contact__c = c1.Id;
        conAccServiceObj.Active__c = true;
        conAccServiceObj.City__c = 'New York';
        conAccServiceObj.State__c = 'New York';
        conAccServiceObj.Street__c = 'New York';
        conAccServiceObj.Postal_Code__c = '680567';
        conAccServiceObj.Country__c = 'United States';
        Insert conAccServiceObj;
        con2AccserList.add(conAccServiceObj);
        Send_Request__c srObj = new Send_Request__c();
        srObj.Verification_Packet__c = vp.Id;
        srObj.Is_Deleted__c = false;
        srObj.Current_Send_Date__c = Date.Today();
        srObj.Send_Method__c = 'Paper';
        srObj.Request_sent_via_courier__c = TRUE;        
        insert srObj;    
        String qString='';
        SObject sourceObjRec;
        Id recordId = credVerCase.Id;        
        Prepopulate_Record_Values__mdt preRecVal = new Prepopulate_Record_Values__mdt();
        preRecVal = [SELECT defaultValues__c,sourceObject__c,buttonName__c,objectWrapper__c,
                    targetObject__c, apexClass__c,recordType__c,AdditionalObjects__c 
                    FROM Prepopulate_Record_Values__mdt 
                    WHERE buttonName__c= 'Resend'];
        GRecordPrePopValues.ObjectWrapper oWrap = (GRecordPrePopValues.ObjectWrapper)JSON.deserialize(preRecVal.objectWrapper__c, GRecordPrePopValues.ObjectWrapper.class);
        if(!oWrap.fMap.isEmpty()){
            qString = 'Select '+String.join((Iterable<String>)oWrap.fMap.keySet(),',')+' From '+oWrap.objectName+' '+oWrap.whereclause;
        }        
        if(String.IsNotEmpty(qString)){
            sourceObjRec = Database.query(String.escapeSingleQuotes(qString));
        }
        sourceObjRec.put('State__c','');
        sourceObjRec.put('Street__c','');
        sourceObjRec.put('City__c','');
        sourceObjRec.put('Country__c','');
        sourceObjRec.put('Postal_Code__c','');
        Test.startTest();
        // Invoke Custom Apex Class 
        Type t = Type.forName(preRecVal.apexClass__c);
        GRecordPrePopValuesInterface recPre =(GRecordPrePopValuesInterface)t.newInstance();
        recPre.process(recordId, preRecVal);        
        GResendPrePopValuesUtility.processGetPrePopAddressValues(sourceObjRec);
        GRecordPrePopValues.getRecTypeId(preRecVal.targetObject__c, preRecVal.sourceObject__c, preRecVal.buttonName__c);
        GRecordPrePopValues.getRecTypeId(preRecVal.targetObject__c, preRecVal.sourceObject__c, null);
        GRecordPrePopValues.getDefData(recordId, preRecVal.targetObject__c, preRecVal.sourceObject__c, preRecVal.buttonName__c);
        GRecordPrePopValues.getDefData(recordId, preRecVal.targetObject__c, preRecVal.sourceObject__c, null);
        GRecordPrePopValues.defaultGetDefData(recordId, preRecVal);
        System.assert(sourceObjRec.get('Country__c') != NULL, 'Country is null!!!');
        Test.stopTest();
    }
}