public with sharing virtual class GRecordPrePopValues{
 //Method is used to get RecordTypeId based on Record Type Developer Name
 @AuraEnabled
 public static String getRecTypeId(String tObjName, String sObjName, String bName){
     // return Variable declaration
     String recordTypeId ='';
     
     try {
         // retrive Prepopulate Record Value Custom Metadata record & Record Type Id information
         Prepopulate_Record_Values__mdt preRecVal = new Prepopulate_Record_Values__mdt();

         if(bName!=null){
           preRecVal = [Select sourceObject__c,targetObject__c,recordType__c from Prepopulate_Record_Values__mdt where buttonName__c=:bName WITH SECURITY_ENFORCED];
         }
         else{
           preRecVal = [Select sourceObject__c,targetObject__c,recordType__c from Prepopulate_Record_Values__mdt where sourceObject__c=:sObjName and targetObject__c=:tObjName and buttonName__c=null WITH SECURITY_ENFORCED];
         }
         
         if(preRecVal.recordType__c!=null){
             recordTypeId = Schema.getGlobalDescribe().get(preRecVal.targetObject__c).getDescribe().getRecordTypeInfosByName().get(preRecVal.recordType__c).getRecordTypeId();
             system.debug('recordTypeId'+recordTypeId);
         }
          
     } 
     catch (Exception e) {
         System.debug('Exception'+e);
        
     }
     return recordTypeId;

 }
 
 // Method is used to get Prepopulated record values based on existing record
 @auraEnabled
 public Static String getDefData(Id recordId, String tObjName, String sObjName, String bName){
     
     // return Variable declaration
     String prePopValuesStr='';  
     try{
         
         // Verify input Parameters are not null
         if(recordId!=null){
           Prepopulate_Record_Values__mdt preRecVal = new Prepopulate_Record_Values__mdt();
           if(bName!=null){
            preRecVal = [Select defaultValues__c,sourceObject__c,buttonName__c,objectWrapper__c,targetObject__c,apexClass__c,recordType__c,AdditionalObjects__c from Prepopulate_Record_Values__mdt where buttonName__c=:bName WITH SECURITY_ENFORCED];
           }     
           else{
            preRecVal = [Select defaultValues__c,sourceObject__c,buttonName__c,objectWrapper__c,targetObject__c,apexClass__c,recordType__c,AdditionalObjects__c from Prepopulate_Record_Values__mdt where sourceObject__c=:sObjName and targetObject__c=:tObjName and buttonName__c=null WITH SECURITY_ENFORCED];
           }    
             
        if(preRecVal.apexClass__c==null || preRecVal.apexClass__c==''){ 
                prePopValuesStr = defaultGetDefData(recordId,preRecVal); 
        }
        else{
                prePopValuesStr = customGetDefData(recordId,preRecVal);  
             }

         // Verify default Values exist in Custom Metadata Configuration
         if(preRecVal.defaultValues__c!=null && preRecVal.defaultValues__c.length()>2){
            prePopValuesStr = prePopValuesStr + preRecVal.defaultValues__c;
         }
            
         }
         else{
             prePopValuesStr ='ERROR: Invalid Configuration';  
         } 
         
     }catch(Exception e){
         system.debug('error'+e);  
         prePopValuesStr = 'ERROR: System Exception';
         return prePopValuesStr;
     }
     system.debug('prePopValuesStr::'+prePopValuesStr);
     return String.Valueof(prePopValuesStr);
 }
 
 // This method execute default generic functionality
 public Static String defaultGetDefData(Id recordId, Prepopulate_Record_Values__mdt preRecVal){
   // Variable declaration
    String prePopValuesStr='';
    SObject targetObjRec;
    SObject sourceObjRec;

    try{
       // deserialize object Wrapper  
       ObjectWrapper objWrap = (ObjectWrapper)JSON.deserialize(preRecVal.objectWrapper__c, ObjectWrapper.class);
                 
       // Initialize call Non Static utility Methods
       GRecordPrePopValues recPrePop = new GRecordPrePopValues();
       
       // Get Source Object record Passing parameters to Utility Method
       sourceObjRec = recPrePop.getSourceObj(recordId,objWrap,null); 
       
       // Construct Target Object record Passing parameters to Utility Method
       if(sourceObjRec!=null){
          targetObjRec = recPrePop.constructTargetObj(sourceObjRec,null,objWrap.fMap,preRecVal.targetObject__c);
       }
        
       // Construct Prepopulated Values String passing parameters to Utility Method 
       if(targetObjRec!=null){
        if(prePopValuesStr!=null && prePopValuesStr.length()>2){
            prePopValuesStr = prePopValuesStr+','+recPrePop.constructPrePopValuesStr(targetObjRec,objWrap.fMap.Values());
        }
        else{
            prePopValuesStr = recPrePop.constructPrePopValuesStr(targetObjRec,objWrap.fMap.Values());  
        }   
       }
    }
    catch(Exception e){
        system.debug('Exception at defaultGetDefData'+e.getMessage());
        throw new ControllerException(e.getMessage());
    } 
    return prePopValuesStr;         
 }

 // This method execute Custom functionality
 public Static String customGetDefData(Id recordId, Prepopulate_Record_Values__mdt preRecVal){
   // Variable declaration
   String prePopValuesStr='';
    try{

       // Invoke Custom Apex Class 
       Type t = Type.forName(preRecVal.apexClass__c);
       // Instantiate Apex class using interface
       GRecordPrePopValuesInterface recPre =(GRecordPrePopValuesInterface)t.newInstance();
       // Retrieve Prepopulated String as return value
       if(prePopValuesStr!=null && prePopValuesStr.length()>2){
          prePopValuesStr = prePopValuesStr+','+recPre.process(recordId, preRecVal);
       }   
       else{
         prePopValuesStr = recPre.process(recordId, preRecVal);
       } 
         
    }
    Catch(Exception e){
        system.debug('Exception at customGetDefData'+e.getMessage());
        throw new ControllerException(e.getMessage());
    }
   return prePopValuesStr;
 }

 // This method accept recordId(required), Object Wrapper(Optional when Query String Exist), Querry string (Optional When Object Wrapper Exist) as parameters to retrieve Source Object    
 public Virtual SObject getSourceObj(Id recordId,ObjectWrapper oWrap, String queryStr){
    // Variable declaraiton
     String qString='';
     SObject sourceObj; 
     system.debug('queryStr :'+queryStr);
    try{
         // Construct Query string based on Object Wrapper if we receive Querry String parameter as null
         if(queryStr==null)
         {
           if(!oWrap.fMap.isEmpty()){
           qString = 'Select '+String.join((Iterable<String>)oWrap.fMap.keySet(),',')+' From '+oWrap.objectName+' '+oWrap.whereclause;
           }
         }       
         else{
           qString = queryStr;
         }
             
         if(String.IsNotEmpty(qString)){
             sourceObj = Database.query(String.escapeSingleQuotes(qString));
             system.debug('sourceObj'+sourceObj);
         }
         
     }
     catch(Exception e) {
         system.debug('Exception at getSourceObj'+e.getMessage());
         throw new ControllerException(e.getMessage());
     }
     return sourceObj;
 }
 
 // This method accept Source Object(Required), Target Object (Optional), Field Mapping (Required), Target Object Name (Required) as parameters and Construct Target Object
 public Virtual SObject constructTargetObj(SObject sourceObj, SObject targetObj, Map<String,String> fMap, String targetObjName){
  
   try{      
       // Construct Target object based on Source Object and/or Target object with Field Mapping
       if(sourceObj!=null){
           if(targetObj == null){
            targetObj = Schema.getGlobalDescribe().get(targetObjName).newSObject();
           }
           for(String sourceObjFldApiName:fMap.keySet()){
                targetObj.put(fMap.get(sourceObjFldApiName), getValue(sourceObj,sourceObjFldApiName));
           }     
           system.debug('targetObj'+targetObj);     
       }
 
   }
   catch(Exception e) {
       system.debug('Exception at constructTargetObj'+e.getMessage());
       throw new ControllerException(e.getMessage());
   }
   return targetObj;     
 }
 
 // This method required Target Object (required), List of Target Object Field Api names (required) as parameters and construct Field & Value String
 public Virtual String constructPrePopValuesStr(SObject targetObj,List<String> tobjFApiNames){
    // Variable declaraiton
    String prePopValuesStr=''; 
    try{
         // Construct Prepopulated String based on Target Object based on Field Mapping
         for(String targetObjFldApiName: tobjFApiNames)
         {
             if(prePopValuesStr.length()>1){
                prePopValuesStr = prePopValuesStr+','+targetObjFldApiName+'='+(targetObj.get(targetObjFldApiName)!=null?String.Valueof(targetObj.get(targetObjFldApiName)):'');
             }      
             else{
                prePopValuesStr = targetObjFldApiName+'='+(targetObj.get(targetObjFldApiName)!=null?String.Valueof(targetObj.get(targetObjFldApiName)):'');
             }
             system.debug('prePopValuesStr'+prePopValuesStr);
         }
         
         
     }
     catch(Exception e) {
         system.debug('Exception at constructPrePopValueStr'+e.getMessage());
         throw new ControllerException(e.getMessage());
     }
     return prePopValuesStr;
 }
 
 // This method required Sobject(required), Sobject Field Api name as parameters and return value of the Field from SObject
 public virtual object getValue(SObject sourceObj, String sourceFldApiName) {
    //Variable declaration 
    SObject temp = sourceObj;
    String[] parts = new List<String>();
     try {
         
         sourceFldApiName = sourceFldApiName.deleteWhitespace();
         parts = sourceFldApiName.split('\\.');
         while(parts.size() > 1) {
             temp = temp.getSObject(parts.remove(0));
         }
     } catch(Exception e) {
        system.debug('Exception at getValue'+e.getMessage());
        throw new ControllerException(e.getMessage());
     }
     return temp.get(parts[0]);
 }
 
 // Wrapper class is used to capture conditions to retrive Source Object data 
 public class ObjectWrapper{
     public String objectName;
     public Map<String, String> fMap;
     public String whereclause;
 }

}