/**
 * Created by Matthew on 11/13/18.
 */
public class ContactAssociationTypeViewModel{
    @AuraEnabled
    public String Id {get; set;}
    @AuraEnabled
    public String Name{get; set;}
    @AuraEnabled
    public String AlternativeName{get; set;}
    @AuraEnabled
    public String Address1{get; set;}
    @AuraEnabled
    public String Address2{get; set;}
    @AuraEnabled
    public String Address3{get; set;}
    @AuraEnabled
    public String Address4{get; set;}
    @AuraEnabled
    public String Country{get; set;}
    @AuraEnabled
    public String DegreeTitle{get; set;}
    @AuraEnabled
    public String StudentId{get; set;}
    @AuraEnabled
    public String UniversityName{get; set;}
    @AuraEnabled
    public Date StartDate{get; set;}
    //Code added - shailaja - 8/25/2020, user story#7211
    @AuraEnabled
    public String StartYear{get; set;}
    @AuraEnabled
    public String StartMonth{get; set;}
    @AuraEnabled
    public String EndYear{get; set;}
    @AuraEnabled
    public String EndMonth{get; set;}
    @AuraEnabled
    public Date EndDate{get; set;}
    @AuraEnabled
    public Date DegreeDate{get; set;}
    //Code added by Shailaja - 9/24/2020
    @AuraEnabled
    public String DegreeYear{get; set;}
    @AuraEnabled
    public String DegreeMonth{get; set;}
    @AuraEnabled
    public String Type{get; set;}
    @AuraEnabled
    public String AccountId{get; set;}
    public ContactAssociationTypeViewModel(){}
}