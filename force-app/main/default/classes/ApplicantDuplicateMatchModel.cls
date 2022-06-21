// Created by Matthew on 2019-05-24.
public class ApplicantDuplicateMatchModel implements Comparable{
    @AuraEnabled
    public String contactId{get;set;}
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public String LastName { get; set; }
    @AuraEnabled
    public String RestOfName { get; set; }
    @AuraEnabled
    public Date BirthDate { get; set; }
    @AuraEnabled
    public String BirthCountry { get; set; }
    @AuraEnabled
    public String Gender { get; set; }
    @AuraEnabled
    public String MedschoolCode { get; set; }
    @AuraEnabled
    public Integer overallMatch {get;set;}
    @AuraEnabled
    public Integer Score { get; set; }
    @AuraEnabled
    public String SSN {get;set;}
    @AuraEnabled
    public String usmleId{get;set;}
    @AuraEnabled
    public String ScorePercentage{
        get{
            return String.valueOf(Score) + Constants.PERCENT_CHARACTER;
        }
    }
    // sorts lists of this in descending order by score
    public Integer compareTo(Object compareTo){
        ApplicantDuplicateMatchModel compareToModel = (ApplicantDuplicateMatchModel)compareTo;
        Integer result = 0;
        if(Score>compareToModel.Score){
            result = -1;
        }
        else if(Score<compareToModel.Score){
            result = 1;
        }
        return result;
    }
}