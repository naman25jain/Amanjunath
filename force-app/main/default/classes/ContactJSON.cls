public class ContactJSON{
    public String APIName;
    public String label;
    public DateTime dateValue;
    public String value;
    public String fieldType;
    public Boolean isDate;
    public Boolean isPicklist;
    public Boolean isReference;
    public Boolean isString;
    public Boolean isRequired;
    public List<String> pickListVal;
    public static List<ContactJSON> parse(String json){
        return (List<ContactJSON>) System.JSON.deserialize(json, List<ContactJSON>.class);
    }
}