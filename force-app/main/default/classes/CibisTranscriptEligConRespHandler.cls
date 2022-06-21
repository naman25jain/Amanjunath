/*
CIBIS Transcripts Eligibility Process response handler
*/
public class CibisTranscriptEligConRespHandler {
    
    // Variable declaration
    Public static list<Contact> contactsList=new list<Contact>();
    public static  Map<Id,Date> conSecrMap=new map<Id,Date>();
    Public static list<String> contentMgrs=new list<String>{Constants.CIBIS_NBME_POST_CHECK,Constants.CIBIS_NBME_PRE_CHECK,Constants.CIBIS_STEP3_PRE_CHECK,Constants.CIBIS_STEP3_POST_CHECK};
    Public static map<String,string> contentMgrMap=new map<String,String>();
    Public static map<Id,Id> conCaseId=new map<Id,Id>();
    public static list<Case> caseLst=new list<Case>();
    
    // Method to Handle Response Event from Platform Event Trigger routed from ResponseUtilityHandler
    public Static void handleResponse(List<String> lstPayloads){
        try{
            if(lstPayloads != null && !lstPayloads.isEmpty()) {
                
                contentMgrMap=ContentManagerRecords.FetchContentManagerRecords(contentMgrs);
                
                // Iterate each payload and construct process payload 
                for(String str:lstPayloads){
                    processPayload(str);
                } 
                
                //Utility method to Update Sobject - Update Case data based on the response status
                if(!caseLst.isEmpty()){                    
                    CibisUtility.updateSobjects(caseLst);
                }
                //Utility method to Update Sobject - Update Contact data based on the response status
                if(!contactsList.isEmpty()){                    
                    CibisUtility.updateSobjects(contactsList);
                }
                // Capture Secratary document date in Map
                if(conSecrMap!=null || conCaseId!=null){
                    checkSecrDocumentUpdatedDate(conSecrMap,conCaseId);
                }
            }
        }
        Catch(Exception e){
            System.debug('**CibisTranscriptEligConRespHandler**'+e.getMessage()); 
            System.debug('**CibisTranscriptEligConRespHandler** ===> '+e.getStackTraceString());
             System.debug('**CibisTranscriptEligConRespHandler** ==> '+e.getLineNumber());
            System.debug('**CibisTranscriptEligConRespHandler** ==> '+e.getCause());
        }
        
    }
    public static void processPayload(String strPayload) {
        CibisTranscriptEligResponseEventWrap responseEvent = (CibisTranscriptEligResponseEventWrap)JSON.deserialize(strPayload,CibisTranscriptEligResponseEventWrap.class);
        if( responseEvent.transactionId.split('-')[1]!=null){ 
            Id contactId=Id.ValueOf(responseEvent.transactionId.split('-')[1]);
            CibisTranscriptEligResponseEventWrap.Payload objPayload = responseEvent.payload;          
            if(responseEvent != null && responseEvent.responseStatus == 'SUCCESS' && responseEvent.transactionId != null){                          
                if(objPayload.IsNBMEMostRecentlyRegistered=='N' && objPayload.STEP3Exist=='N'){
                    if(responseEvent.transactionId.split('-')[0]!=null && responseEvent.transactionId.split('-')[0]==Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT && objPayload.SecretariatDocumentUpdateDTime!=null){
                        if(objPayload.SecretariatDocumentUpdateDTime!=null && objPayload.SecretariatDocumentUpdateDTime!=''){
                            conSecrMap.put(contactId,date.valueOf(objPayload.SecretariatDocumentUpdateDTime)); 
                        }
                        
                        conCaseId.put(contactId,responseEvent.transactionId.split('-')[2]);
                    }
                    else if(responseEvent.transactionId.split('-')[0]!=null && responseEvent.transactionId.split('-')[0]==Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT){
                        conCaseId.put(contactId,responseEvent.transactionId.split('-')[2]);
                    }
                    else if(responseEvent.transactionId.split('-')[0]!=null && responseEvent.transactionId.split('-')[0]==Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT){
                        contactsList.add(new Contact(USMLE_Transcript_Eligible__c=TRUE,Id=contactId,USMLE_Transcript_Eligibility_Message__c=''));    
                    }
                }
                else{
                    string inelgMsg='';
                    if(responseEvent.transactionId.split('-')[0]!=null && responseEvent.transactionId.split('-')[0]==Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT){
                        inelgMsg=objPayload.IsNBMEMostRecentlyRegistered=='Y' ? contentMgrMap?.get(Constants.CIBIS_NBME_PRE_CHECK) : contentMgrMap?.get(Constants.CIBIS_STEP3_PRE_CHECK);
                        contactsList.add(new Contact(USMLE_Transcript_Eligible__c=FALSE,Id=contactId,USMLE_Transcript_Eligibility_Message__c=inelgMsg));     
                    }
                    else if(responseEvent.transactionId.split('-')[0]!=null && responseEvent.transactionId.split('-')[0]==Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT){
                        inelgMsg= objPayload.IsNBMEMostRecentlyRegistered=='Y' ? contentMgrMap?.get(Constants.CIBIS_NBME_POST_CHECK) : contentMgrMap?.get(Constants.CIBIS_STEP3_POST_CHECK);
                        caseLst.add(new case(Id=responseEvent.transactionId.split('-')[2],Description=inelgMsg,Internal_Status__c=Constants.CASE_STATUS_REJECTED));
                    }
                    
                }
            }
            
            else if(responseEvent != null && responseEvent.responseStatus == 'FAILED' && responseEvent.transactionId != null){
                System.debug('**FAILED**'+responseEvent);     
                
            }            
        }        
    }
    
    // Publish next sequence event
    Public static void checkSecrDocumentUpdatedDate(map<Id,Date> conSecrMap,map<Id,Id> caseMap){
        Map<String,Set<Id>> cibisIdMap=new Map<String,Set<Id>>();
        if(!caseMap.isEmpty()){
            For(Contact con:[Select id,SecrDoc_Updated_Dtime__c from Contact where ID IN:caseMap.keyset()])  {
                if(conSecrMap.containskey(con.Id) && con.SecrDoc_Updated_Dtime__c!=date.valueOf(conSecrMap.get(con.Id))){
                    cibisIdMap.put(Constants.CIBIS_SECR_DOCURL_EVENT,new set<Id>{caseMap.get(con.Id)}); 
                }
                else{
                    cibisIdMap.put(Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT,new set<Id>{caseMap.get(con.Id)});  
                }
                
            }
            if(cibisIdMap!=null && !cibisIdMap.isEmpty()){
                CibisRequestUtilityHandler.cibisPlatformEventPublish(cibisIdMap);  
            } 
        }
        
    }
}