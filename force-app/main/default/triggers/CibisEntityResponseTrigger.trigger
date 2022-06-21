trigger CibisEntityResponseTrigger on Cibis_Entity_Search_Response_Event__e(after insert){        
  CibisResponseUtilityHandler.handleResponse(Trigger.New);
}