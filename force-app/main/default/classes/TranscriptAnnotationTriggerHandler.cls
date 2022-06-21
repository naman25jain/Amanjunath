public class TranscriptAnnotationTriggerHandler {
    
    Public static void afterTriggerHandler(map<Id,Transcript_Anotation__c> tranAnntNewMap){
        if(tranAnntNewMap!=null){  
            Set<Id> invesConId = new Set<Id>();
            Map<Id,String> caseIdIrgComments=new map<Id,String>();
            For(Transcript_Anotation__c tra:tranAnntNewMap.values()){
                invesConId.add(tra.Contact__c);
                if(tra.Transcript_Case__c!=null && tra.Cibis_Transcript_Status__c==Constants.APP_IRREGULAR){
                    if(caseIdIrgComments.containskey(tra.Transcript_Case__c)){
                        caseIdIrgComments.put(tra.Transcript_Case__c,caseIdIrgComments.get(tra.Transcript_Case__c)+','+tra.SHORT_TEXT__c);  
                    }
                    else{
                        caseIdIrgComments.put(tra.Transcript_Case__c,tra.SHORT_TEXT__c);
                    }
                    
                }
            }
            if(!caseIdIrgComments.isEmpty()){  
                list<Transcript_Anotation__c> transcriptAnnotations=new list<Transcript_Anotation__c>();
                For(Transcript_Anotation__c traAnt:[Select id,ANNOTATION_TEXT__c,Transcript_Case__c from Transcript_Anotation__c Where Cibis_Transcript_Status__c='USMLE' AND 
                                                    Transcript_Case__c IN:caseIdIrgComments.keySet() AND ID NOT IN:tranAnntNewMap.keyset()]){
                                                        
                                                        if(caseIdIrgComments.containskey(traAnt.Transcript_Case__c)){
                                                            String annotationText=string.valueOf(traAnt.ANNOTATION_TEXT__c); 
                                                            transcriptAnnotations.add(new Transcript_Anotation__c(Id=traAnt.Id,ANNOTATION_TEXT__c=annotationText.replace('[!DESCRIPTORS]','<b>'+caseIdIrgComments.get(traAnt.Transcript_Case__c)+'</b>')));
                                                        }
                                                        
                                                    }
                if(!transcriptAnnotations.isEmpty() && transcriptAnnotations.size()>0){   
                    update transcriptAnnotations;
                }
            }
            Id profileId = [SELECT id FROM Profile WHERE name =: Constants.Applicant_360_USER_PROFILE LIMIT 1].id;
            List<Id> userIdsList = new List<Id>();
            for(User userIns: [SELECT Id FROM User WHERE IsActive = true AND ProfileId =:profileId AND ContactId IN: invesConId]){
                userIdsList.add(userIns.Id);
            }
            system.debug('userIdsList : '+userIdsList);
            List<Transcript_Anotation__Share> transShareList = new List<Transcript_Anotation__Share>();
            for(Transcript_Anotation__c tra:tranAnntNewMap.values()){
                for(Id userId : userIdsList){
                    Transcript_Anotation__Share tranShareIns = new Transcript_Anotation__Share();
                    tranShareIns.AccessLevel = 'Read';
                    tranShareIns.UserOrGroupId = userId;
                    tranShareIns.ParentID = tra.Id;
                    tranShareIns.RowCause = Schema.CaseShare.RowCause.Manual;
                    transShareList.add(tranShareIns);   
                }
            }
            if(!transShareList.isEmpty() && Transcript_Anotation__Share.SObjectType.getDescribe().isCreateable()){
                INSERT transShareList;
            }
        }
    }
}