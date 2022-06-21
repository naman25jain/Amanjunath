public class CloudStorageParameters {
    public CloudStorageParameters(String fileName, String fileUrl, String token, String fileUrlWithToken, List<HttpHeader> httpHeaders) {
        this.Filename = fileName;
        this.FileUrl = fileUrl;
        this.Token = token;
        this.FileUrlWithToken = fileUrlWithToken;
        this.HttpHeaders = httpHeaders;
    }

    @AuraEnabled
    public String Token { get;set; }

    @AuraEnabled
    public String Filename { get;set; }

    @AuraEnabled
    public String FileUrl { get;set; }

    @AuraEnabled
    public String FileUrlWithToken { get;set; }

    @AuraEnabled
    public List<HttpHeader> HttpHeaders{ get;set; }
}