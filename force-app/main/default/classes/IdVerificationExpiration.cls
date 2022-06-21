global with sharing class IdVerificationExpiration implements Database.Batchable<sObject>, Database.Stateful {

    global final string query;
    global Map<Id, Id> caseMap = new Map<Id, Id>();
    global Set<String> uniqueEmailIds = new Set<String>();
    global Set<Asset> uniqueCaseAssets = new Set<Asset>();


    global IdVerificationExpiration() {
        query = 'Select Id, Name, Status, InstallDate, Type__c, ContactId, Case__r.Internal_Status__c, Case__c From Asset WHERE Status !=\'' + 'Verified' + '\'' + 'AND Name =\'' + 'ID Form Template' + '\'' + 'AND (Case__r.Internal_Status__c =\'' + 'Pending Applicant Action-Notarize ID Form' + '\'' + ' OR Case__r.Internal_Status__c =\'' + 'Pending Applicant Action-Resubmit Notarized ID Form' + '\')';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        EIFMonth__c monthVar = EIFMonth__c.getValues('MonthsToExpiration');
        System.debug(monthVar.Months__c);
        List<Asset> allAssets = new List<Asset>();
        for (Asset a : (List<Asset>) scope) {
            System.debug(a);
            if (a.InstallDate != null) {
                if (a.InstallDate.addMonths(integer.valueof(monthVar.Months__c)) <= Date.Today()) {
                    a.Status = 'Expired';
                    allAssets.add(a);
                    caseMap.put(a.Id, a.Case__c);
                    uniqueEmailIds.add(a.ContactId);
                }
            }
        }

        // expire verified photo assets if associated with contacts related assets, which are related to in-scope cases
        for (Asset photoAssets : [Select id, Name, status, type__c, Case__c FROM Asset Where type__c = 'Photo' AND status = 'Verified' AND Case__r.ContactId in :uniqueEmailIds]) {
            System.debug(photoAssets);
            photoAssets.Status = 'Expired';
            uniqueCaseAssets.add(photoAssets);
            caseMap.put(photoAssets.Id, photoAssets.Case__c);
        }
        allAssets.addAll(uniqueCaseAssets);
        update allAssets;

        Map<Id, Case> casesToUpdate = new Map<Id, Case>();
        List<Case> allCases = new List<Case>();
        for (Case c : [select Id, Internal_Status__c, Action_Required__c from Case where Id in:caseMap.values()]) {
            c.Internal_Status__c = 'Pending Applicant Action-Resubmit ID Documents';
            c.Action_Required__c = true;
            casesToUpdate.put(c.Id, c);
            allCases.add(c);
        }
       update allCases;

        List<Affirmation__c> allAffirmations = new List<Affirmation__c>();
        for (Affirmation__c aff : [select Id, Status__c, Asset__c, Other__c  from Affirmation__c where Asset__c in:caseMap.keySet()]) {
            aff.Status__c = 'Rejected';
            aff.ID_Form_Expired_Picklist__c = 'yes';
            aff.Other__c = 'The ECFMG Identification Form (EIF) that was previously created for you is no longer valid because your notarized EIF was not received within 6 months of the date it was created.  Your previously accepted photograph has been invalidated as well.';
            allAffirmations.add(aff);
        }
        update allAffirmations;
    }

    global void finish(Database.BatchableContext BC) {
        Network netUrl = [select id,name from network where name = 'Applicant 360'];
        String commURL = Network.getLoginUrl(netUrl.Id);
        System.debug(uniqueEmailIds);
        List <Contact> c = [Select id, firstName, lastName, email From Contact Where id in:uniqueEmailIds];
        System.debug(c);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (c.size() > 0) {
            for (Contact emailsTheseContacts : c) {
                mail.setToAddresses(new String[]{emailsTheseContacts.Email});
                mail.setSenderDisplayName('ECFMG Portal');
                mail.setSubject('Status Update Available In ECFMG Portal');
                mail.setHTMLBody('Dear ' + emailsTheseContacts.FirstName + ' ' + emailsTheseContacts.LastName + ', <br><br>A status update is available for your account in the ECFMG Portal. Please log in at <a href='+commUrl+'>' + commURL + '</a> to view the update. <br><br>Sincerely,<br>ECFMG');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            }
        }
    } 
}