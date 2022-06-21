public with sharing class ChargentFlowAPI {

    public class FlowInputs {
        @InvocableVariable(required=true)
        public String transactionId;

        @InvocableVariable(required=false)
        public Decimal amount;
    }

    @InvocableMethod
    public static void refundTransaction(List<FlowInputs> inputs) {

        String transactionId = inputs[0].transactionId;
        Decimal amount = inputs[0].amount;
     	
        if (amount != null) {
            callout(transactionId, amount);
        } else {
            callout(transactionId);
        }

    }
       
    @future(callout = true)
    public static void callout(String transactionId) {
        try {

            ResponseData data = new ResponseData();

            if (!Test.isRunningTest()) {
                // Call the Chargent API to perform the refund.
                ChargentOrders.TChargentOperations.TChargentResult refundResult = ChargentOrders.TChargentOperations.RefundTransaction_Click(transactionId);
                // data = (ResponseData) JSON.deserialize(refundResult.responseData, ResponseData.class);
            } else {
                data = (ResponseData) JSON.deserialize(mockResponse(transactionId), ResponseData.class);
            }

            System.debug(data);

        } catch (Exception e) {
            System.debug('An error occured in the callout(transactionId) method: ' + e.getMessage());
        }
    }

    @future(callout = true)
    public static void callout(String transactionId, Decimal amount) {
        try {

            ResponseData data = new ResponseData();

            Parameters params = new Parameters();
            params.ObjectId = transactionId;
            params.Amount = amount;

            String serializedParams = JSON.serialize(params);
            System.debug(serializedParams);

            if (!Test.isRunningTest()) {
                // Call the Chargent API to perform the refund.
                ChargentOrders.TChargentOperations.TChargentResult refundResult = ChargentOrders.TChargentOperations.RefundTransaction_ClickJSON(serializedParams);
                // data = (ResponseData) JSON.deserialize(refundResult.responseData, ResponseData.class);
            } else {
                data = (ResponseData) JSON.deserialize(mockResponse(transactionId), ResponseData.class);
            }

            System.debug(data);

        } catch (Exception e) {
            System.debug('An error occured in the callout(transactionId, amount) method: ' + e.getMessage());
        }
    }

    public class Response {
        String message {get;set;}
        Boolean reload {get;set;}
        String status {get;set;}
        String transactionId {get;set;}
        String order_JSON {get;set;}
        String transaction_JSON {get;set;}
        String responseData {get;set;} // JSON?
    }
   
    public class ResponseData {
        String transactionId {get;set;}
        String responseStatus {get;set;}
        String responseMessage {get;set;}
        String responseCode {get;set;}
        String reasonText {get;set;}
        String objectId {get;set;}
        String gatewayId {get;set;}
        String chargentMessage {get;set;}
        String avsCode {get;set;}
        Boolean isApproved {get;set;}
    }

    public class Parameters {
        String ObjectId {get;set;}
        Decimal Amount {get;set;}
    }

    private static String mockResponse(String transactionId) {

        if (transactionId == null) {
            throw new NullPointerException();
        }

        ResponseData data = new ResponseData();
        data.transactionId = '000000000000002';
        data.responseStatus = 'Approved';
        data.responseMessage = 'This transaction has been approved';
        data.responseCode = '1';
        data.reasonText = null;
        data.objectId = transactionId;
        data.gatewayId = '1234567';
        data.chargentMessage = 'Any messages if presented';
        data.avsCode = '123';
        data.isApproved = true;

        Response response = new Response();
        response.message = 'deprecated';
        response.reload = true;
        response.status = 'OK'; // can be either 'OK' or 'FAILURE'
        response.transactionId = 'deprecated';
        response.order_JSON = null;
        response.transaction_JSON = null;
        response.responseData = JSON.serialize(data);

        return JSON.serialize(response);
    }
}