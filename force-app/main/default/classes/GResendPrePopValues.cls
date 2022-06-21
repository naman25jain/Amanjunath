public with sharing class GResendPrePopValues extends GRecordPrePopValues implements GRecordPrePopValuesInterface{
    public String process(Id recordId, Prepopulate_Record_Values__mdt preRecVal){
        String prePopValuesStr = '';
        SObject sourceObjRec;
        try{
            if(recordId!=null && preRecVal.objectWrapper__c!=null){               
                            
                ObjectWrapper objWrap = (ObjectWrapper)JSON.deserialize(preRecVal.objectWrapper__c, ObjectWrapper.class);                
                sourceObjRec = getSourceObj(recordId,objWrap,null);                
                if(sourceObjRec != null){         
                    prePopValuesStr = processGetPrePopValues(preRecVal.targetObject__c, objWrap, sourceObjRec);
                }else{
                    prePopValuesStr = 'ERROR: No Send Records';
                }
            }else{
                prePopValuesStr = 'ERROR: Invalid Button Configuration';  
            }        
            return prePopValuesStr;    
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    public string processGetPrePopValues(String tObjectName, ObjectWrapper objWrap, SObject sourceObjRec){
        String prePopValuesStr = '';
        SObject targetObjRec;
        if(sourceObjRec.get('Current_Send_Date__c') == null){
            prePopValuesStr = 'ERROR: Current Send record is not yet sent';  
        }else{
            sourceObjRec.put('Current_Send_Date__c',null);
            sourceObjRec.put('Request_sent_via_courier__c',false);
            sourceObjRec.put('Courier_fee_payable_by__c','');
            sourceObjRec.put('Courier_Account__c',null);
            sourceObjRec.put('ZK_Account__c',null);
            GResendPrePopValuesUtility.processGetPrePopAddressValues(sourceObjRec);            
            if(((Double) sourceObjRec.get('Current_Send_Count__c')) < 4.0){
                sourceObjRec.put('Current_Send_Count__c',((Double)sourceObjRec.get('Current_Send_Count__c'))+1);
            }else{
                sourceObjRec.put('Current_Send_Count__c',null);
            }
            targetObjRec = constructTargetObj(sourceObjRec,null,objWrap.fMap,tObjectName);                        
            if(targetObjRec != null){
                prePopValuesStr = constructPrePopValuesStr(targetObjRec,objWrap.fMap.Values());
            }               
        }
        return prePopValuesStr;
    }
}