trigger TranscriptAnnotationTrigger on Transcript_Anotation__c (After Insert,After Update) {
    if(Trigger.isInsert && Trigger.isAfter){
        TranscriptAnnotationTriggerHandler.afterTriggerHandler(Trigger.NewMap);
    }   
}