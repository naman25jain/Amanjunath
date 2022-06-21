public with sharing class CloudStorageUtils{
    @TestVisible
    private static  String STORAGE_URL;
    @TestVisible
    private static  String STORAGE_ACCOUNT;
    @TestVisible
    private static  String STORAGE_CONTAINER;
    @TestVisible
    private static  String STORAGE_CONTAINER_URL;
    @TestVisible
    private static  String SHARED_KEY;
    @TestVisible
    private static  String STORAGE_CANONICAL_URL;
    @TestVisible
    public static  String STORAGE_MODE;

    static{
        Cloud_Storage_Config__c settings = Cloud_Storage_Config__c.getOrgDefaults();
        STORAGE_URL = settings.Account_URL__c;
        STORAGE_ACCOUNT = settings.Account_Name__c;
        STORAGE_CONTAINER = settings.Container_Name__c;
        SHARED_KEY = settings.Shared_Key__c;
        STORAGE_CONTAINER_URL = STORAGE_URL + '/' + STORAGE_CONTAINER + '/';
        STORAGE_CANONICAL_URL =  '/blob/' + STORAGE_ACCOUNT + '/' + STORAGE_CONTAINER + '/';
        STORAGE_MODE = settings.Mode__c;
     }
     // Build request headers
     public static CloudStorageParameters getRequestHeaders(DocumentEnums.DocumentAccessLevel documentAccessLevel,
                                                            String fileName, 
                                                            String payLoad){
        try{
            String fullFileURL = STORAGE_CONTAINER_URL + fileName;
            String sasToken = generateSasToken(fileName, documentAccessLevel);
            List<HttpHeader> httpHeaders = new List<HttpHeader>{
            new HttpHeader('x-ms-version', '2019-02-02'),
            new HttpHeader('x-ms-meta-Payload', payLoad),
            new HttpHeader('x-ms-blob-type', 'BlockBlob')
        };
        CloudStorageParameters storageObject = new CloudStorageParameters(fileName, 
                                                                          fullFileURL, 
                                                                          sasToken, 
                                                                          fullFileURL + sasToken, 
                                                                          httpHeaders);
        return storageObject;
        }catch(Exception e){
            throw e;
        }
    }

    // Get request url
    public static String getRequestUrl(DocumentEnums.DocumentAccessLevel documentAccessLevel,
                                        String fileName){
        try {
            String fullFileURL = STORAGE_CONTAINER_URL + fileName;
            String sasToken = generateSasToken(fileName, documentAccessLevel);
            System.debug('generateSasToken===> ' + sasToken);
        return fullFileURL + sasToken;
        }catch(Exception e){
            throw e;
        }
    }

    public static HttpResponse calloutAzureDocURL(string azureDocUrl){
        blob resbody;
        string pdf;
        HttpResponse response;
        
        try {
            string strJson; 
            Http http = new Http(); 
            HttpRequest request = new HttpRequest(); 
            request.setEndpoint(azureDocUrl);  
            request.setMethod('GET');
            response = http.send(request);

            if (response.getStatusCode() == 200) {                 
                resbody = response.getBodyAsBlob();
                pdf = EncodingUtil.Base64Encode(resbody); 
            }   

        } catch (Exception e) {
            System.debug(e.getMessage());
            throw e;            
        } 
        return response; 
    } 

    @AuraEnabled
    public static string getBase64Pdf(string surl){
        string pdfBase64String;
        HttpResponse res = calloutAzureDocURL(surl); 
        try {
            if (res.getStatusCode() == 200) {                 
                Blob resbody = res.getBodyAsBlob();
                pdfBase64String = EncodingUtil.Base64Encode(resbody);
            }   
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw e;
        }
        return pdfBase64String; 
    }
    
    @AuraEnabled(cacheable = false)
    public static String getFileUrlWithSAS(String fileName){
        try {
            String fullFileURLWithSasToken = getRequestUrl(DocumentEnums.DocumentAccessLevel.READ, fileName);
            return fullFileURLWithSasToken;
        }catch(Exception e){
            throw e;
        }
    }

    public static string createGuidBasedFileName(String fileExt){
         try{
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            return guid + '.' + fileExt;
         }catch(Exception e){
             throw e;
         }
    }

    @TestVisible
     private static string generateSASToken(String fileName, 
                                            DocumentEnums.DocumentAccessLevel documentAccessLevel){
        try{
            String tokenPermissions;
            switch on documentAccessLevel{
                when CREATE{
                    tokenPermissions = 'c'; 
                }
                when READ{
                    tokenPermissions = 'r';
                }
                when CREATE_UPDATE{
                    tokenPermissions = 'w';
                }
                when else{
                    return null;
                  }
            }    
            Datetime tokenExpiration = system.Datetime.now();
            tokenExpiration = tokenExpiration.addMinutes(1);    
            String key = string.valueOf(SHARED_KEY);
            String spe = tokenPermissions;                                              // Signed permissions: Read, Read / Write, etc., we will likely only be issuing either read (r) for existing files and write (w) for new files
            String st = '';                                                             // Signed start (optional): When the token will begin allowing access
            String se = tokenExpiration.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');      // Signed expiration: When the token expires. Format output example: 2020-01-16T18:54:19Z
            String res = STORAGE_CANONICAL_URL + fileName;                              // Resource (new with 2018-11-09 and later): Specifies resource type (blob, file, etc.)
            String si = '';                                                             // Signed identifier (optional): The identifier of a specific stored access policy           
            String sip = '';                                                            // Signed IP range: Allow requests only from this Ip / range.
            String spr = 'https';                                                       // Signed protocol: Allows restriction to http or https (we only ever want https)
            String sv = '2019-02-02';                                                   // Signed version: Specifies the version of the Azure blob service API (currently the latest)
            String sr = 'b';                                                            // Signed resource: Specifies resource TYPE (blob, file, etc.)
            String ssn = '';                                                            // Signed snap shot: Specifies a specific file snapshot, if needed
            String rscc = '';
            String rscd = '';
            String rsce = '';
            String rscl = '';
            String rsct = '';    
            String sts = spe + '\n' + st + '\n' + se + '\n' + res + '\n' + si + '\n' + sip + '\n' + spr + '\n' + sv + '\n' + sr + '\n' + ssn + '\n' + rscc + '\n' + rscd + '\n' + rsce + '\n' + rscl + '\n' + rsct;
            Blob data = crypto.generateMac('HmacSHA256', Blob.valueOf(sts), EncodingUtil.base64Decode(key));
            String sig = EncodingUtil.base64Encode(data);
            sig = EncodingUtil.urlEncode(sig, 'UTF-8');       
            String sasURL = '?sv=' + sv + '&se=' + EncodingUtil.urlEncode(se, 'UTF-8') + '&sr=' + sr + '&sp=' + spe + '&sig=' + sig + '&spr=' + spr;
            return sasURL;
        } 
        catch (Exception e){
        throw e;
    }
  }
}