public with sharing class WDOMSResponseHandler {
    static final Integer SUCCESS = 200;
    public static void handleResponseEventPayload(string payload){       
        WDOMSResponse response = new WDOMSResponse();
        try{  
            WDOMSResponseService.logMessage('Response payload for WDOMSResponseHandler '  + payload);                      
            response = (WDOMSResponse)System.JSON.deserialize(payload, WDOMSResponse.class);
            handleEvent(response);           
        }
        catch(Exception e){
            WDOMSResponseService.logMessage('WDOMSResponse failed with error: ' + e);
        }
    }

    @TestVisible
    private static void handleEvent(WDOMSResponse response){
        try{
            if(response.status == SUCCESS){
                WDOMSResponseService.logMessage('WDOMSResponse received Sucessfully. CorrelationID: '  + response.payload.correlationID);
                
            }else{
                WDOMSResponseService.logMessage('Failed Response: '  + response);
                WDOMSResponseService.logMessage('WDOMSResponse received Failed. CorrelationID: '  + response.payload.correlationID);
                throw new ServiceException (response.errorDescription + ' - ' + response.payload);
            }
        }        
        catch(Exception e){
            throw e; 
        }
    }

}