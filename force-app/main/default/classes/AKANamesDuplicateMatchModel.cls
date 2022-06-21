public class AKANamesDuplicateMatchModel implements Comparable{
    @AuraEnabled
    public String Id{get;set;}
    @AuraEnabled
    public Integer Score{get;set;}
    @AuraEnabled
    public String Name{get;set;}
    @AuraEnabled
    public String AccountName{get;set;}
    // sorts lists of this in descending order by score
    public Integer compareTo(Object compareTo){
        AKANamesDuplicateMatchModel compareToModel = (AKANamesDuplicateMatchModel)compareTo;
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