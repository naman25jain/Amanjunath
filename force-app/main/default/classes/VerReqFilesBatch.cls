/**
 *
 *  Links the files (Content Documents) from the Verification Request Files object to the associated case.
 *
 *
 *  Created by Matthew on 2019-07-17.
 */
global with sharing  class VerReqFilesBatch implements Database.Batchable<sObject>{
    public static final Integer MAX_BATCH_SIZE = 200;
    global Database.QueryLocator start(Database.BatchableContext bc){
        String vrStatus = Constants.VERIFICATION_REQUEST_STATUS_PROCESSED;
        String vrfStatus = Constants.VERIFICATION_REQUEST_FILE_STATUS_PENDING;
        String query = 'select Id, Status__c, Verification_Request__c, Verification_Request_Status__c from Verification_Request_File__c where Status__c = :vrfStatus and Verification_Request_Status__c = :vrStatus';
        return Database.getQueryLocator(query);
    }
    /*
    	************************************************************************
    	*********David's stub to remove SOQL from within for loops *************
    	************************************************************************
        It's kind of a pain to get from Verification_Request_File__c all the way to a Case to Content Document mapping.
        Here's the journey we must take:

            1. verificationRequestIdToContentDocumentIdsMap
            2. caseIdToVerificationRequestIdMap
            3. caseIdToContentDocumentIdsMap
	*/
	    global void execute(Database.BatchableContext bc, List<Verification_Request_File__c> scope){
	        List<ContentDocumentLink> caseCdls = new List<ContentDocumentLink>();
	        List<String> reqIds = new List<String>();
	        List<String> fileIds = new List<String>();
	        Map<String, String> fileToReqMap = new Map<String, String>();
	        Map<String, Set<String>> reqToFilesMap = new Map<String, Set<String>>();
			for(Verification_Request_File__c f : scope){
	            reqIds.add(f.Verification_Request__c);
	            fileIds.add(f.Id);
	            fileToReqMap.put(f.Id, f.Verification_Request__c);
	            if(!reqToFilesMap.containsKey(f.Verification_Request__c)){
	            	Set<String> newSet = new Set<String>();
	            	newSet.add(f.Id);
	            	reqToFilesMap.put(f.Verification_Request__c, newSet);
				}
				else{
	            	reqToFilesMap.get(f.Verification_Request__c).add(f.Id);
	            }
			}
			List<ContentDocumentLink> cdls = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId in :fileIds];
			Map<String, Set<String>> verificationRequestIdToContentDocumentIdsMap = new Map<String, Set<String>>();
	        for(ContentDocumentLink cdl : cdls){
	            String verificationRequestId = fileToReqMap.get(cdl.LinkedEntityId);
	            if(verificationRequestIdToContentDocumentIdsMap.get(verificationRequestId)==null){
	                verificationRequestIdToContentDocumentIdsMap.put(verificationRequestId, new Set<String>());
	            }
	            verificationRequestIdToContentDocumentIdsMap.get(verificationRequestId).add(cdl.ContentDocumentId);
	        }
	        List<Case> cases = [select Id, Verification_Request__c from Case where Verification_Request__c in : reqIds];
			Map<String, String> caseIdToVerificationRequestIdMap = new Map<String, String>();
			Map<String, String> verificationRequestIdToCaseIdMap = new Map<String, String>();
			for(Case cse : cases){
				caseIdToVerificationRequestIdMap.put(cse.Id, cse.Verification_Request__c);
				verificationRequestIdToCaseIdMap.put(cse.Verification_Request__c, cse.Id);
			}
			Map<String, Set<String>> caseIdToContentDocumentIdsMap = new Map<String, Set<String>>();
	        for(Verification_Request_File__c vrf : scope){
				String verificationRequestId = vrf.Verification_Request__c;
				Set<String> reqDocIds = verificationRequestIdToContentDocumentIdsMap.get(verificationRequestId);
				String caseId = verificationRequestIdToCaseIdMap.get(verificationRequestId);
				if(reqDocIds.isEmpty()){
	            	vrf.Status__c = Constants.VERIFICATION_REQUEST_FILE_STATUS_ERROR;
				} 
				else{
					for(String contentDocumentId : reqDocIds)
	                    caseCdls.add(new ContentDocumentLink(
	                            LinkedEntityId = caseId,
	                            ContentDocumentId = contentDocumentId,
	                            ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED,
	                            Visibility = Constants.CONTENT_DOCUMENT_LINK_VISIBILITY_ALL_USERS
	                    ));
				}
	            vrf.Status__c = Constants.VERIFICATION_REQUEST_FILE_STATUS_PROCESSED;
	        }
	        update scope;
	        insert caseCdls;
	    }
    global void finish(Database.BatchableContext info){}
}