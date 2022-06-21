/**
 * Sampath Karnati 
 * * Class to expose constants for Unit Testing
 * ? Exposed as Public
 */
public class ConstantsTest{    
   // General
   public static final String TEST_STRING = 'Test';
   public static final String TEST_STATUS_ACTIVE = 'Active';
   public static final String TEST_STATUS_INACTIVE = 'Inactive';
   // Profiles
   public static final String TEST_PROFILE_SALESFORCE_VIEWER = 'Salesforce Viewer';
   public static final String TEST_PROFILE_COMMUNITY_LOGIN = '4-Customer Community Plus Login';
   public static final String TEST_PROFILE_READONLY = 'Read Only';
   public static final String TEST_PROFILE_INACTIVE_EMPLOYEE = '5-Inactive-Unknown-Employee';
   // Terms and Conditions
   public static final String TEST_TERMS_CONDITIONS_NAME_ACTIVE = 'Test Terms And Conditions - Active';
   public static final String TEST_TERMS_CONDITIONS_NAME_INACTIVE = 'Test Terms And Conditions - Inactive';
   // Product
   public static final String TEST_PRODUCT = 'Test Product';   
   //User/Contact
   public static final String TEST_USER_ALIAS ='TAlias';
   public static final String TEST_NAME = 'Test User';
   public static final String TEST_EMAIL = 'TestEmail';
   public static final String TEST_EMAIL_DOMAIN = '@unknownmail.com';
   public static final String TEST_USERNAME = 'TestUser';
   public static final String TEST_COUNTRY = 'United States';
   public static final String TEST_STATE = 'PA';
   public static final String TEST_CITY = 'Philadelphia';
   public static final String TEST_POSTAL_CODE = '19104';
   public static final String TEST_STREET = '1234 Market Street';
   public static final String TEST_TIMEZONE = 'America/Los_Angeles';
   public static final String TEST_ENCODING_KEY = 'UTF-8';
   public static final String TEST_LANGUAGE_KEY = 'en_US';
   public static final date TEST_DOB = date.valueOf('2000-01-01');
   public static final String TEST_PHONE = '1234567890';
   //Asset
   public static final String TEST_ASSET_NAME_RELATED_TO_CASE ='Asset Related To Case';
   public static final String TEST_ASSET_STATUS_IN_PROGRESS ='In Progress';
   public static final String TEST_ASSET_NAME_ID_FORM_TEMPLATE = 'ID Form Template';
   public static final String TEST_ASSET_AZURE_STORAGE_URL = 'https://testurl.com';
   public static final String TEST_ASSET_AZURE_FILE_URL = 'https://testurl.com/test.pdf';
   //Cloud Document
   public static final String TEST_CLOUD_DOCUMENT_NAME = 'test';
   //Test Entity Account Name
   public static final String TEST_ENTITY_ACCOUNT_NAME = 'Test Entity Account';
   //Case
   public static final String TEST_CASE_STATUS_WORKING ='Working';
   public static final String TEST_CASE_STATUS_NEW ='New';
   public static final String TEST_ECFMG_PORTAL_CASE_URL = 'https://test.com';
   //Document Type for Asset
   public static final String TEST_ASSET_DOCUMENT_TYPE ='Returned Enrollment Verification';
   //Email Template
   public static final String TEST_EMAIL_TEMPLATE_NAME = 'Test_Template_Name';
   public static final String TEST_EMAIL_TEMPLATE_HTML = '<table border="0"</table>';
   //Org Wide Email Address
   public static final String TEST_ORG_WIDE_EMAIL_DISPLAY_NAME = 'Test Admin';
   public static final String TEST_ORG_WIDE_EMAIL_ADDRESS = 'test@ecfmg.org';
   //Notary Transaction Request Event
   public static final String TEST_NOTARY_TRANSACTION_REQUEST_PAYLOAD = '{"redirectUrl":"https://www.test.org",' + 
                                                                           '"parties":[{"phone":"11111111111","lastName":"test","firstName":"test","email":"test@gmail.com"}],' + 
                                                                           '"documents":[{"url":"https://test.org/test.pdf","name":"IDForm"}],' +
                                                                            '"caseId":"CASE_ID_PLACEHOLDER"}';
   //Online Notary Transaction
   public static final String TEST_ONLINE_NOTARY_TRANSACTION_SIGNING_SESSION_URL = 'https://test.com';
   public static final String TEST_ONLINE_NOTARY_TRANSACTION_STATUS = 'Transaction Created';
   public static final String TEST_ONLINE_NOTARY_TRANSACTION_STATUS_REJECTED = 'Rejected';
   public static final String TEST_ONLINE_NOTARY_TRANSACTION_ID = 'txn1234';
   //Notary Transaction Response Event
   public static final String TEST_NOTARY_TRANSACTION_RESPONSE_PAYLOAD = '{"message":"Successfully retrived",' +    
                                                                        '"data":{"documents":[{"devNotaryLink":"https://test-sandbox.notarycam.com/signingRoom/12ac/45cd"}],' +
                                                                        '"signingviews": [{"deepLink":"https://test-sandbox.notarycam.com/signingRoom/12ac/45cd","txnId": "test12acde76gh95dg"}],'+
                                                                        '"participants": [{"user": {"firstName": "Abc", "lastName" :"LName", "email": "abcd@ecfmg.org", '+
                                                                        '"Address":{"street":"5 Test Lane", "city":"testville", "state":"PA", "postalCode":"1923", "country":"USA"} },' +
                                                                        '"roomURL": "https://test-sandbox.notarycam.com/signingRoom/12ac/45cd",'+
                                                                        '"redirectUrl": "https://redirectUrl.com", "role": "signer"}, {"user": {"firstName": "notary", "lastName" :"LName", "email": "abcd1@ecfmg.org"}, "role":"notary", "roomUrl":"abcd.com"} ],' + 
                                                                        '"status": "Transaction Created",  "archived":false, "department": "123456"},'+
                                                                        '"caseId":"CASE_ID_PLACEHOLDER",'+
                                                                        '"responseStatus":"Success",'+
                                                                        '"errorDescription":"", "apiVersion":"v4", "transactionId":"test12acde76gh95dg"}';   
   public static final String TEST_NOTARY_TRANSACTION_RESPONSE_ERROR_PAYLOAD = '{"caseId":"CASE_ID_PLACEHOLDER",'+
                                                                                 '"responseStatus":"Error",'+
                                                                                 '"errorDescription":"test error description"}'; 
   //Notary Transaction Update Event

   public static final String TEST_NOTARY_TRANSACTION_UPDATE_REJECT_PAYLOAD = '{"message":"Invalid Doc",' +
                                                                           '"data":{"documents":[{"devNotaryLink":"https://test-sandbox.notarycam.com/signingRoom/12ac/45cd"}],' +
                                                                           '"signingviews": [{"deepLink":"https://test-sandbox.notarycam.com/signingRoom/12ac/45cd","txnId": "test12acde76gh95dg"}],'+
                                                                           '"participants": [],' + 
                                                                           '"status": "Rejected"},'+
                                                                           '"transactionId":"TRANSACTION_ID_PLACEHOLDER",'+
                                                                           '"caseId":"CASE_ID_PLACEHOLDER",'+
                                                                           '"responseStatus":"Rejected",'+
                                                                           '"errorDescription":"This case is rejected"}'; 

   public static final String TEST_NOTARY_TRANSACTION_COMPLETE_SUCCESS_PAYLOAD = '{"message":"Successfully Retrived",' +
                                                                           '"data":{"documents":[{"devNotaryLink":"https://test-sandbox.notarycam.com/signingRoom/12ac/45ce"}],' +
                                                                           '"signingviews": [{"deepLink":"https://test-sandbox.notarycam.com/signingRoom/12ac/45ce","txnId": "test12acde76gh95dg"}],'+
                                                                           '"participants": [{"user": {"firstName": "Abc", "lastName" :"LName", "role": "signer"},' +
                                                                           '"roomURL": "https://test-sandbox.notarycam.com/signingRoom/12ac/45cd"}],' + 
                                                                           '"status": "Complete - Success"},'+
                                                                           '"transactionId":"TRANSACTION_ID_PLACEHOLDER",'+
                                                                           '"responseStatus":"SUCCESS",'+
                                                                           '"errorDescription":"",'+'"azureUrl":"null" }';    
   public static final String TEST_NOTARY_TRANSACTION_UPDATE_SUCCESS_PAYLOAD = '{"message":"Successfully Retrived",' +
                                                                           '"data":{"documents":[{"thumbnailURL":"https://test-sandbox.notarycam.com/thumbnail/12ac45ce","name": "test123.pdf"}],' +
                                                                           '"participants": [{"user": {"firstName": "Abc", "lastName" :"LName", "email": "abcd@ecfmg.org" }, "Role":"signer",' +
                                                                           '"roomURL": "https://test-sandbox.notarycam.com/signingRoom/12ac/45cd", "redirectUrl": "https://redirectUrl.com" } ],' + 
                                                                           '"status": "Complete - Success"},'+
                                                                           '"transactionId":"TRANSACTION_ID_PLACEHOLDER",'+
                                                                           '"responseStatus":"Success",'+
                                                                           '"errorDescription":"",'+'"azureUrl":"null" }'; 

   public static final String TEST_NOTARY_TRANSACTION_UPDATE_SUCCESS_PAYLOAD_IN_PROGRESS = '{"message":"Successfully Retrived",' +
                                                                           '"data":{"documents":[{"thumbnailURL":"https://test-sandbox.notarycam.com/thumbnail/12ac45ce","name": "test123.pdf"}],' +
                                                                           '"participants": [{"user": {"firstName": "Abc", "lastName" :"LName", "email": "abcd@ecfmg.org" },' +
                                                                           '"roomURL": "https://test-sandbox.notarycam.com/signingRoom/12ac/45cd"}],' + 
                                                                           '"status": "Complete - Success"},'+
                                                                           '"transactionId":"TRANSACTION_ID_PLACEHOLDER",'+
                                                                           '"responseStatus":"In-progress",'+
                                                                           '"errorDescription":"",'+'"azureUrl":"null" }';                                                                            
   // Case Comment
   public static final String TEST_CASE_COMMENT = 'test comemnt';
   // Attachment
   public static final String TEST_PDF_CONTENT_TYPE = 'application/pdf';
   public static final String TEST_BASE64_PDF_ATTACHMENT =  'JVBERi0xLjcKCjEgMCBvYmogICUgZW50cnkgcG9pbnQKPDwKICAvVHlwZSAvQ2F0YWxvZwog' +
                                                            'IC9QYWdlcyAyIDAgUgo+PgplbmRvYmoKCjIgMCBvYmoKPDwKICAvVHlwZSAvUGFnZXMKICAv' +
                                                            'TWVkaWFCb3ggWyAwIDAgMjAwIDIwMCBdCiAgL0NvdW50IDEKICAvS2lkcyBbIDMgMCBSIF0K' +
                                                            'Pj4KZW5kb2JqCgozIDAgb2JqCjw8CiAgL1R5cGUgL1BhZ2UKICAvUGFyZW50IDIgMCBSCiAg' +
                                                            'L1Jlc291cmNlcyA8PAogICAgL0ZvbnQgPDwKICAgICAgL0YxIDQgMCBSIAogICAgPj4KICA+' +
                                                            'PgogIC9Db250ZW50cyA1IDAgUgo+PgplbmRvYmoKCjQgMCBvYmoKPDwKICAvVHlwZSAvRm9u' +
                                                            'dAogIC9TdWJ0eXBlIC9UeXBlMQogIC9CYXNlRm9udCAvVGltZXMtUm9tYW4KPj4KZW5kb2Jq' +
                                                            'Cgo1IDAgb2JqICAlIHBhZ2UgY29udGVudAo8PAogIC9MZW5ndGggNDQKPj4Kc3RyZWFtCkJU' +
                                                            'CjcwIDUwIFRECi9GMSAxMiBUZgooSGVsbG8sIHdvcmxkISkgVGoKRVQKZW5kc3RyZWFtCmVu' +
                                                            'ZG9iagoKeHJlZgowIDYKMDAwMDAwMDAwMCA2NTUzNSBmIAowMDAwMDAwMDEwIDAwMDAwIG4g' +
                                                            'CjAwMDAwMDAwNzkgMDAwMDAgbiAKMDAwMDAwMDE3MyAwMDAwMCBuIAowMDAwMDAwMzAxIDAw' +
                                                            'MDAwIG4gCjAwMDAwMDAzODAgMDAwMDAgbiAKdHJhaWxlcgo8PAogIC9TaXplIDYKICAvUm9v' +
                                                            'dCAxIDAgUgo+PgpzdGFydHhyZWYKNDkyCiUlRU9G';
   // Shipment
   public static final String TEST_SHIPMENT_PDF_FILE_NAME = 'helloword';
   public static final String TEST_SHIPMENT_PAYLOAD = 'testpayload';  
   
   public static final String API_STATUS_SUCCESS = 'Success';
   public static final String API_STATUS_ERROR = 'Error';
   public static final String API_STATUS_IN_PROGRESS = 'In-progress';
}