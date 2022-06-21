// US 16089- This class is called from flow
public with sharing class InvocableFlowClass{
	@invocableMethod
    public static void calledbyFlow(List<FlowClassParameters> paramList){
        for(FlowClassParameters param : paramList){
            if(param.method == 'updateSendMethodFlow'){
                updateSendMethodFlow();
            }
            else if(param.method == 'updateNotVerifiedEntityFlag'){
                updateNotVerifiedEntityFlag();
            }
        }
    }
    // This method is used to update isnotUpdatedbySendMethodFlow
    public static void updateSendMethodFlow(){
        Constants.isnotUpdatedbySendMethodFlow = false;
    }
    // This method is used to update isupdatedbyNotVerifiedEntity
    public static void updateNotVerifiedEntityFlag(){
        Constants.isupdatedbyNotVerifiedEntity = true;
    }
    public class FlowClassParameters{
        @InvocableVariable
        public string method;
    }
}