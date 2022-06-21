/**
 * Created by Matthew on 1/1/19.
 */

public class CaseImageModel {

    public CaseImageModel(String nameArg, String descriptionArg, String urlArg, String refArg) {
        Name = nameArg;
        Description = descriptionArg;
        Url = urlArg;
        Reference = refArg;
    }

    @AuraEnabled
    public String Name { get; set; }

    @AuraEnabled
    public String Description { get; set; }

    @AuraEnabled
    public String Url { get; set; }

    @AuraEnabled
    public String Reference { get; set; }

}