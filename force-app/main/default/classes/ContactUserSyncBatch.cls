/*******************************************************************************************************************************
Name : ContactUserSyncBatch
Author : Thejasvi Venkataneni
Created Date : 05/09/2019
Description: This is the Batch Class to update the User Records when there are changes to the Contact First Name and Last Name

*********************************************************************************************************************************/
global class ContactUserSyncBatch implements Database.Batchable<sObject> {
    
    //Query the Contact records that have Name change Flag checked to true
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        String query = 'SELECT FirstName, Id, LastName, MailingAddress, MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet, Name, Name_ChangedDate__c, Name_Change__c FROM Contact WHERE Name_Change__c = true';
        
        return Database.getQueryLocator(query);
    }
    
    //Update the related User records based on the changes made to Contact First Name and Last Name
    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        List<User> usersToUpdate = new List<User>();
        List<Contact> contactList= new List<Contact>();
        Map<Id, Contact> contactMap= new Map<Id, Contact>();
        String sourceName = 'ContactUserSyncBatch';
        String logMessage = '';
        for(Contact cont : scope) {
            contactMap.put(cont.Id, cont);
        }
        if(contactMap != null) {
            List<User> userList = [SELECT Id,FirstName, LastName, Name, IsActive, CommunityNickname, ContactId, State 
                                   FROM User where ContactId in :contactMap.keySet() AND isActive = true]; 
            for(User currentUser : userList) {
                if(contactMap.containsKey(currentUser.contactId)){
                    Contact cont = contactMap.get(currentUser.ContactId);
                    currentUser.FirstName = cont.FirstName;
                    currentUser.LastName = cont.LastName;
                    currentUser.CommunityNickName = currentUser.Id + currentUser.LastName.toLowerCase();
                    currentUser.Alias = String.valueOf(currentUser.Id).substring(9,14) + currentUser.LastName.substring(0,2).toLowerCase();
                    currentUser.City = cont.MailingCity;
                    currentUser.State = cont.MailingState;
                    currentUser.Country = cont.MailingCountry;
                    currentUser.PostalCode = cont.MailingPostalCode;
                    currentUser.Street = cont.MailingStreet;
                    cont.Name_Change__c = false;
                    usersToUpdate.add(currentUser);
                    contactList.add(cont);
                }
            }
            
            // Update the List of User records  
            if(!usersToUpdate.isEmpty()){
                Database.SaveResult[] saveList = Database.update(usersToUpdate);
                for (Database.SaveResult sl : saveList) {
                    if (!sl.isSuccess()) {
                        // Operation failed, so get all error Messages             
                        for(Database.Error e : sl.getErrors()) {
                            logMessage += e.getMessage() + '$$$$$$';
                        }
                    }
                }
            }
            if(String.isNotBlank(logMessage)){
                Log_Message__c logMsg = new Log_Message__c();
                logMsg.Exception__c	= logMessage;
                logMsg.Source__c = sourceName;
                logMsg.Date_Time_Logged__c = DateTime.now();
                insert logMsg;
            }
            // Update the List of Contact Records  
            if(!contactList.isEmpty()){
                Database.update(contactList);
            }
        }
    }
    
    global void finish(Database.BatchableContext info) {
    }
    
}