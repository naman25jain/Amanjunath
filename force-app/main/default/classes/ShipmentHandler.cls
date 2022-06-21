/**
 * Sampath Karnati
 * * Common Shipment Utils 
 * ? Exposed as Public
 */
public with sharing class ShipmentHandler {

    static final String CREATED = 'Created';
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static HttpResponse saveShipmentToAzure(Blob document, CloudStorageParameters requestHeaders) {
        
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod('PUT');
            for(HttpHeader httpHeader : requestHeaders.HttpHeaders){
                httpRequest.setHeader(httpHeader.Name, httpHeader.Value);
            }
            httpRequest.setHeader('Content-Type', Constants.ZPL_CONTENT_TYPE);
            httpRequest.setEndpoint(requestHeaders.FileUrlWithToken);
            httpRequest.setBodyAsBlob(document);

            Http httpCall = new Http();
            HttpResponse response = httpCall.send(httpRequest);
            
            return response;
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static Attachment getShipmentLabel(Id shipmentId) {
        
           // Get the shipment attachment
           List<Attachment> attachments =  [SELECT Id, Body, ContentType 
                                            FROM Attachment 
                                            WHERE ParentId =: shipmentId
                                            WITH SECURITY_ENFORCED
                                            ];                            
            if(!attachments.isEmpty()) {
                return attachments[0];
            }

          return null;
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static Boolean deleteShipmentLabelAttachment(Id shipmentId) {
        
           // Get the shipment attachment
           List<Attachment> attachments =  [SELECT Id, Body, ContentType 
                                            FROM Attachment 
                                            WHERE ParentId =: shipmentId
                                            WITH SECURITY_ENFORCED
                                            ];  
                                            
             // Check for accessability
             SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, attachments);

             Delete securityDecision.getRecords();

             return true;
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static String fileName(Id id, string contentType) {
            return id + '_' + 
                   Constants.ASSET_TYPE_SHIPPING_LABEL.replace(' ', '_') + '_' +
                   String.valueOf(datetime.now()).replace(' ', '_').replace(':', '_') +
                   '.' + contentType.substringAfter('/');
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public class SaveDocumentCall implements Queueable, Database.AllowsCallouts {
        
       Id shipmentId;
       string payload;

       public SaveDocumentCall(Id shipmentId, string payload){
           this.shipmentId = shipmentId;
           this.payload = payload;
       }
       public void execute(System.QueueableContext ctx) {
           
                // Get shipment attachment
                Attachment attachment = ShipmentHandler.getShipmentLabel(shipmentId);
                                        
                if(attachment!=null) 
                {
                    String fileName = ShipmentHandler.fileName(shipmentId, attachment.ContentType);

                    CloudStorageParameters requestHeaders = CloudStorageUtils.getRequestHeaders(DocumentEnums.DocumentAccessLevel.CREATE_UPDATE, 
                                                                                                fileName, 
                                                                                                payload);

                    HttpResponse response = ShipmentHandler.saveShipmentToAzure(attachment.Body, requestHeaders);

                    string status = response.getStatus();
            
                    if(status == CREATED){
                        CloudStorageController.processResponse(payload, requestHeaders.FileUrl);
                    }

                    ShipmentHandler.deleteShipmentLabelAttachment(shipmentId);
                }

       }
   }
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
}