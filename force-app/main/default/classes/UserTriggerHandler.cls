public with sharing class UserTriggerHandler{
    public static void handleInsert(List<User> newList){
        Set<Id> userContactToTrue = new Set<Id>();
		Set<Id> userContactToFalse = new Set<Id>();
        for(User u : newList){
            //Profile is set depending on contact record type. User Story#8085
            if(u.IsActive == TRUE && (u.Profile_Name__c == Constants.Applicant_360_USER_PROFILE || u.Profile_Name__c == Constants.Entity_360_USER_PROFILE)){
                userContactToTrue.add(u.ContactId);
            }
            else if(u.IsActive == FALSE || u.Profile_Name__c != Constants.Applicant_360_USER_PROFILE || u.Profile_Name__c != Constants.Entity_360_USER_PROFILE){
                userContactToFalse.add(u.ContactId);
            }
        }
        if(userContactToTrue.size() > 0){
            List<Contact> contacts = [select Id, Active_Entity_Portal_User__c from Contact where Id in :userContactToTrue];
			for(Contact loopVar : contacts){
				loopVar.Active_Entity_Portal_User__c = TRUE;
			}
			update contacts;
        }
		if(userContactToFalse.size() > 0){
            List<Contact> contacts = [select Id, Active_Entity_Portal_User__c from Contact where Id in :userContactToFalse];
			for(Contact loopVar : contacts){
				loopVar.Active_Entity_Portal_User__c = FALSE;
			}
			update contacts;
        }
    }
    public static void handleUpdate(List<User> newList, Map<Id, User> oldMap){
        Set<Id> userContactToTrue = new Set<Id>();
        Set<Id> userContactToFalse = new Set<Id>(); 
        for(User u : newList){
            if(u.IsActive != oldMap.get(u.Id).IsActive || u.Profile_Name__c != oldMap.get(u.Id).Profile_Name__c){
                /* if(u.IsActive == TRUE && u.Profile_Name__c == profileName){
                    userContactToTrue.add(u.ContactId);
                }
                else if(u.IsActive == FALSE || u.Profile_Name__c != profileName){
                    userContactToFalse.add(u.ContactId);
                } */
                if(u.IsActive == TRUE && (u.Profile_Name__c == Constants.Applicant_360_USER_PROFILE || u.Profile_Name__c == Constants.Entity_360_USER_PROFILE)){
                    userContactToTrue.add(u.ContactId);
                }
                else if(u.IsActive == FALSE || u.Profile_Name__c != Constants.Applicant_360_USER_PROFILE || u.Profile_Name__c != Constants.Entity_360_USER_PROFILE){
                    userContactToFalse.add(u.ContactId);
                }
            }
        }
		if(userContactToTrue.size() > 0){
            updateContactRecs(userContactToTrue, true);
        }
		if(userContactToFalse.size() > 0){
            updateContactRecs(userContactToFalse, false);
        }        
	}
    
    @future
    public static void updateContactRecs(Set<Id> conId, Boolean valToUpdate){
        List<Contact> conList = new List<Contact>();
        for(Contact con : [select Id, Active_Entity_Portal_User__c from Contact where Id in :conId]){
            Contact newCon = new Contact();
            newCon.Active_Entity_Portal_User__c = valToUpdate;
            newCon.Id = con.Id;
            conList.add(newCon);
        }
        if(conList.size() > 0){
            update conList;
        }
    }
}