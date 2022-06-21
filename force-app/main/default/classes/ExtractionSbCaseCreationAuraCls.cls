public with sharing class ExtractionSbCaseCreationAuraCls{
    @AuraEnabled
    public static void subcaseInsert(id recordId){
        try{
            List<Case> epicCaseList = new List<Case>();
            List<Case> insrtSubcsList = new List<Case>();
            epicCaseList = [SELECT Id ,Ownerid, Contact.Name FROM CASE WHERE Id =:recordId WITH SECURITY_ENFORCED];
            Id entityRecId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXTRACTION_SUB_CASE).getRecordTypeId();
            For(Case parcs : epicCaseList){
                Case cs = new Case();
                cs.ParentId = recordId;
                cs.Internal_Status__c = 'In Progress';
                cs.Service__c = 'EPIC';
                cs.ContactId = parcs.ContactId;
                cs.RecordTypeId = entityRecId;
                cs.Ownerid = parcs.Ownerid;
                cs.Origin = 'Web';
                insrtSubcsList.add(cs);
            }
            if(insrtSubcsList != NULL && Schema.sObjectType.Case.fields.Internal_Status__c.isCreateable()){
                INSERT insrtSubcsList;
            }
            List<Verification_Packet__c> listOfVerPack = new List<Verification_Packet__c>();
            for(Case  cs : [SELECT Id,ContactId FROM Case WHERE ID IN :insrtSubcsList]){
                Verification_Packet__c  verpck = new Verification_Packet__c();
                verpck.Case__c = cs.Id;
                verpck.Contact__c = cs.ContactId;
                verpck.Is_Active__c = True;
                listOfVerPack.add(verpck);
            }
            if(insrtSubcsList != NULL && Schema.sObjectType.Verification_Packet__c.fields.Case__c.isCreateable()){
                INSERT listOfVerPack;
            }
        }Catch(Exception e){
            throw e ;
        }
    }
}