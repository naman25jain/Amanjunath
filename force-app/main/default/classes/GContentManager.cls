public with sharing class GContentManager{
    @auraEnabled
    public Static String getContent(String uniqueName){
        String displayContent='';  
        try{
            if(uniqueName!=null){
                List<Content_Manager__c> contRecord = [SELECT Id, Content__c FROM Content_Manager__c where Unique_Name__c=:uniqueName WITH SECURITY_ENFORCED];
                if(!contRecord.isEmpty()){
                    displayContent = contRecord[0].Content__c;
                }
                else{
                    displayContent = 'No Content Available';
                }              
            }
            else{
                displayContent ='No Content Available';  
            }
            return displayContent;
        }catch(Exception e){
            displayContent = 'Error while fetching content. Please contact administrator.';
            return displayContent;
        }
    }
   @AuraEnabled
    public static map<String, String> getContentValues(list<String> lstUniqueNames){
        map<String, String> mapValues = new map<String, String>();
        try{
        if(lstUniqueNames != null && !lstUniqueNames.isEmpty()){
            for(Content_Manager__c iterator : [SELECT Id, Unique_Name__c, Content__c FROM Content_Manager__c where Unique_Name__c IN:lstUniqueNames WITH SECURITY_ENFORCED]) {
                mapValues.put(iterator.Unique_Name__c, iterator.Content__c);
            }
        } 

        if(mapValues != null && !mapValues.isEmpty()) {
            return mapValues;
        }
        else {
            return null;
        }
      }
      catch(Exception e){
            System.debug('Error while fetching content. Please contact administrator.'+e.getMessage());
            return null;
        }
        
    }
}