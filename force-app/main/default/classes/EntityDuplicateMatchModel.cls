/**
 * Created by Matthew on 2019-05-24.
 */
public class EntityDuplicateMatchModel implements Comparable{
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public Integer Score { get; set; }
    @AuraEnabled
    public String SchoolCode { get; set; }
    @AuraEnabled
    public String SchoolName { get; set; }
    @AuraEnabled
    public String City { get; set; }
    @AuraEnabled
    public String Country { get; set; }
    @AuraEnabled
    public String InstitutionId { get; set; }
    @AuraEnabled
    public String InstitutionName { get; set; }
    // sorts lists of this in descending order by score
    public Integer compareTo(Object compareTo){
        EntityDuplicateMatchModel compareToModel = (EntityDuplicateMatchModel)compareTo;
        Integer result = 0;
        if(Score > compareToModel.Score){
            result = -1;
        }
        else if(Score < compareToModel.Score){
            result = 1;
        }
        return result;
    }
}