public class HttpHeader {
    public HttpHeader(String name, String value) {
        this.Name = name;
        this.Value = value;
    }

    @AuraEnabled
    public String Name { get;set; }

    @AuraEnabled
    public String Value { get;set; }
}