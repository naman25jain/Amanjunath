public class ContactMedicalSchoolViewModel{
    @AuraEnabled
    public String SchoolName{get; set;}
    @AuraEnabled
    public String Address1{get; set;}
    @AuraEnabled
    public String Address2{get; set;}
    @AuraEnabled
    public String Address3{get; set;}
    @AuraEnabled
    public String Address4{get; set;}
    @AuraEnabled
    public String DegreeTitle{get; set;}
    @AuraEnabled
    public String StudentId{get; set;}
    @AuraEnabled
    public Date StartDate{get; set;}
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
    public ContactMedicalSchoolViewModel(){}
}