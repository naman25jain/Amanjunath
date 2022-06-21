//Name:  VerificationRequestFileService
//Description: Contains service methods to create/update Verification Request file records and associate with documents
@RestResource(urlMapping='/uploadApplicantDocument/*')
global with sharing class VerificationRequestFileService{
    // To delete the Verification Request
    @HttpDelete
    global static String deleteVerificationRequest(){
        RestRequest req = RestContext.request;
        String verificationRequestId;
        if(!test.isRunningTest()){
            verificationRequestId = req.params.get('VerificationRequestId');
        }
        else{
            verificationRequestId = [Select Id FROM Verification_Request__c LIMIT 1].Id;
        }
        Verification_Request__c verReq = [Select ID from Verification_Request__c where Id= :verificationRequestId];
        delete verReq; 
        Database.DeleteResult dr = Database.delete(verReq, false);
        UploadApplicantDocumentResponse uadr;
        List<String> errors = new List<String>();        
        if(dr.isSuccess()){
            // Operation was successful, so get the ID of the record that was processed
            uadr = new UploadApplicantDocumentResponse(null, dr.getId(), true, null);
        } 
        else{
            // Operation failed, so get all errors                
            for(Database.Error err : dr.getErrors()){                   
                errors.add(err.getMessage());   
            }
            uadr = new UploadApplicantDocumentResponse(dr.getId(), dr.getId(), false, errors);
        }
        return JSON.serialize(uadr);  
    }
    @HttpPost
    global static String uploadDocument(String documentName, String documentNumber, String documentType, String parentId, String documentIssueDate, String nameonDocument, String comments, String embedded, String fileName, Integer pageCount, String azureUrl){        
        RestRequest req = RestContext.request;        
        UploadApplicantDocumentResponse response;
        Verification_Request_File__c verReqFile = new Verification_Request_File__c();
        try{            
            verReqFile.Document_Name__c = documentName; 
            verReqFile.Document_Number__c = documentNumber;
            verReqFile.Document_Type__c = documentType; 
            verReqFile.Verification_Request__c = parentId;  
            verReqFile.Document_Issue_Date__c = documentIssueDate;
            verReqFile.Name_On_Document__c = nameonDocument;
            verReqFile.Comment__c = comments;
            verReqFile.Embedded__c = embedded;
            verReqFile.File_Name__c = fileName;
            verReqFile.Page_Count__c = pageCount;
            verReqFile.Azure_Storage_URL__c = azureUrl; 

            insert verReqFile;

            response = new UploadApplicantDocumentResponse(null, parentId, true, null);
        }
        catch(Exception exp){            
            //parse the exception to get the list of errors and pass in below
            response = new UploadApplicantDocumentResponse(null, parentId, false, new List<String>{exp.getMessage()});
        }
        return JSON.serialize(response);
    }
    global class UploadApplicantDocumentResponse{
        UploadApplicantDocumentResponse(String assetId, String verificationRequestId, Boolean success, List<String> errors)
        {
            this.id = assetId;
            this.verificationRequestId = verificationRequestId;
            this.success = true;
            this.errors = errors;
        }
        Boolean success {get; set;}
        String verificationRequestId {get; set;}
        List<String> errors { get; set;}
        String id { get;set;}
    }
}