public with sharing class FileEditorController {
        @AuraEnabled
        public static Blob getFileBlob() {
            ContentVersion v;
            try{
                v = [Select Id, VersionData FROM ContentVersion WHERE Id =: Constants.ECFMG_LOGO];            
            }
            catch(Exception ex){
                throw ex;
            }
            return v.VersionData;
        }
        
        @AuraEnabled
        public static List<String> getCaseFileIds(String caseId) {
            List<String> IDs = new List<String>();
            for(ContentDocumentLink l : [Select Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId  = :caseId ORDER BY SystemModstamp DESC]) {
                IDs.add(l.ContentDocumentId);
            }
            return IDs;
        }
}