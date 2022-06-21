public with sharing class OFACSearchHandler implements IOFACSearchHandler{
    private static List<String> sIds = new List<String>();   

    public OFACSearchRequest.Party buildCase(Contact contact) {
        OFACSearchRequest.Party party = new OFACSearchRequest.Party();        
        party.name = contact.Name; //name is required
        If( String.IsNotBlank(contact.ECFMG_ID__c)) {                             
            party.localId = contact.ECFMG_ID__c;             
        } 
        If( String.IsNotBlank(String.ValueOf(contact.Birthdate))) {
            party.dob = String.ValueOf(contact.Birthdate);
        }
        If( String.IsNotBlank(contact.Current_Citizenship__c)) {
            party.citizenship = contact.Current_Citizenship__c;
        }
        If( String.IsNotBlank(contact.Gender__c)) {
            party.gender = contact.Gender__c;
        }
        If( String.IsNotBlank(String.ValueOf(contact.Phone))) {
            party.phoneNumber = String.ValueOf(contact.Phone).mid(0,10);                       
        }
        If( String.IsNotBlank(contact.National_ID_Country__c)) {
            party.nationality = contact.National_ID_Country__c;
        }
        If( String.IsNotBlank(String.ValueOf(contact.US_Social_Security__c))) {
            party.ssn = String.ValueOf(contact.US_Social_Security__c).replace('-','');           
        }

        OFACSearchRequest.Cls_Case_Attributes cAttributes = new OFACSearchRequest.Cls_Case_Attributes();        
        If( String.IsNotBlank(String.ValueOf(contact.Generational_Suffix__c))) {
            cAttributes.generationalSuffix = String.ValueOf(contact.Generational_Suffix__c);
        }
        If( String.IsNotBlank(contact.National_Identification__c)) {
            cAttributes.nationalId = contact.National_Identification__c;
        }
        
        OFACSearchRequest.Cls_passport p = new OFACSearchRequest.Cls_passport();          
        If( String.IsNotBlank(contact.Passport_Number__c)) {
           p.passportNumber = contact.Passport_Number__c;           
        }
        If( String.IsNotBlank(contact.Passport_Country__c)) {
            p.passportCountry = contact.Passport_Country__c;             
        }
            
        OFACSearchRequest.Cls_Address add = new OFACSearchRequest.Cls_Address(); 
        If( String.IsNotBlank(contact.mailingStreet)) {           
        add.address1  = contact.mailingStreet; 
        } 
        If( String.IsNotBlank(contact.mailingCity)) {                   
        add.city  = contact.mailingCity; 
        } 

        If( String.IsNotBlank(contact.mailingPostalCode)) {                   
        add.stateOrProvince = contact.mailingPostalCode;             
        } 
        If( String.IsNotBlank(contact.mailingCountry)) {                             
        add.country = contact.mailingCountry;             
        } 
        party.passport = p;
        party.address = add; 
        party.caseAttributes = cAttributes;

        return party;
    }

public OFACSearchRequest.Party buildAccountCase(Account account) {
    OFACSearchRequest.Party party = new OFACSearchRequest.Party();
    party.name = account.Name; //name is required  
        
    If( String.IsNotBlank(account.Phone)) {                             
        party.phoneNumber = account.Phone;             
    } 
    If( String.IsNotBlank(account.Entity_ID__c)) {                             
        party.localId = account.Entity_ID__c;             
    } 

    OFACSearchRequest.Cls_Case_Attributes cAttributes = new OFACSearchRequest.Cls_Case_Attributes(); 
    If( String.IsNotBlank(account.Medschool_Code__c)) {                             
        cAttributes.medicalSchoolCode = account.Medschool_Code__c;             
    }
    If( String.IsNotBlank(account.Institution_ID__c)) {                             
        cAttributes.institutionId = account.Institution_ID__c;             
    }
    List<String> lstAccType = new List<String>(); 

    If( String.IsNotBlank(account.Account_Type__c)) {    
        cAttributes.accountType =account.Account_Type__c.removeEnd(',');                            
    }    

    OFACSearchRequest.Cls_Address add = new OFACSearchRequest.Cls_Address(); 
    If( String.IsNotBlank(account.BillingStreet)) {           
        add.address1  = account.BillingStreet; 
    } 
    If( String.IsNotBlank(account.BillingCity)) {                   
        add.city  = account.BillingCity; 
    } 

    If( String.IsNotBlank(account.BillingPostalCode)) {                   
        add.stateOrProvince = account.BillingPostalCode;             
    } 
    If( String.IsNotBlank(account.BillingCountry)) {                             
        add.country = account.BillingCountry;             
    } 
    party.address = add;  
    party.caseAttributes = cAttributes; 
  
    return party;
}

public OFACSearchRequest.Party buildAkaCase(aka_Names__c akaName) {
    OFACSearchRequest.Party party = new OFACSearchRequest.Party();
    party.name = akaName.Name; //name is required   
    if( String.IsNotBlank(akaName.WDOMS_ID__c)) {
        party.localId = akaName.WDOMS_ID__c; 
    }
    return party;
}

    public static Boolean updateContacts (List<Contact> contacts){
        Database.SaveResult[] saveList = Database.update(contacts, false);
        for (Database.SaveResult sl : saveList) {
            if (!sl.isSuccess()) {
                String logMessage = '';
                // Operation failed, so get all error Messages             
                for(Database.Error e : sl.getErrors()) {
                    logMessage += e.getMessage() + '-->';
                    sIds.add(sl.getId());
                }
                logMessage(logMessage);
                return false;
            }
        }
        return true;
    }

public static Boolean updateAccounts (List<Account> accounts){
    Database.SaveResult[] saveList = Database.update(accounts, false);
    for (Database.SaveResult sl : saveList) {
        if (!sl.isSuccess()) {
            String logMessage = '';
            // Operation failed, so get all error Messages             
            for(Database.Error e : sl.getErrors()) {
                logMessage += e.getMessage() + '-->';
                sIds.add(sl.getId());
            }
            logMessage(logMessage);
            return false;
        }
    }
    return true;
}   

public static Boolean updateAkaNames (List<aka_Names__c> akaList){
    Database.SaveResult[] saveList = Database.update(akaList, false);
    for (Database.SaveResult sl : saveList) {
        if (!sl.isSuccess()) {
            String logMessage = '';
            // Operation failed, so get all error Messages             
            for(Database.Error e : sl.getErrors()) {
                logMessage += e.getMessage() + '-->';
                sIds.add(sl.getId());
            }
            logMessage(logMessage);
            return false;
        }
    }
    return true;
}  

public static Boolean logMessage(String message){
        if(String.isNotBlank(message)){
            Log_Message__c logMsg = new Log_Message__c();
            logMsg.Exception__c	= message;
            logMsg.Record_Id__c = String.valueOf(SIds);
            logMsg.Source__c = 'OFACSearchHandler';
            logMsg.Date_Time_Logged__c = DateTime.now();
            if(!Test.isRunningTest() && Log_Message__c.SObjectType.getDescribe().isCreateable()) {
                insert logMsg;
            }
            return true;
        }
        return false;
    }
}