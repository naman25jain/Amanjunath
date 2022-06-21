public  with sharing class CibisScoreReportRespHandler {
  Public static list<CibisScoreReportResponseEventWrap.cibisScoringInfo> scoreList;
      public static void handleResponse(List<String> lstPayloads){
        try{
            if(lstPayloads != null && !lstPayloads.isEmpty()) {
                scoreList=new list<CibisScoreReportResponseEventWrap.cibisScoringInfo>();
                for(String str : lstPayloads){
                    processPayload(str);
                }
              if(!scoreList.isEmpty() && scoreList.size()>0){
                CibisUtility.createScoreReportdetails(scoreList);
              }

                  }
        }catch(Exception e){
            System.debug('**CibisScoreReportRespHandler==> '+e.getMessage());
             System.debug('**CibisScoreReportRespHandler==> '+e.getStackTraceString());
                   System.debug('**CibisScoreReportRespHandler==> '+e.getCause());
        }
    }

     public static void processPayload(String responsePayLoad)
     {
        CibisScoreReportResponseEventWrap responseEvent = (CibisScoreReportResponseEventWrap) JSON.deserialize(responsePayLoad,CibisScoreReportResponseEventWrap.class);        
          if(responseEvent != null && responseEvent.responseStatus == 'SUCCESS' && responseEvent.transactionId != null){   
             scoreList.addAll(responseEvent.Payload.cibisScoringInfo);
            } 
            else if(responseEvent != null && responseEvent.responseStatus == 'FAILED' && responseEvent.transactionId != null){
              
            }
    
     }

}