/**
 *   Sampath Karnati 
 * * Abstract Base class for common functionality
 * ? Exposed as Public
 */
public with sharing abstract class BaseController{
   public static Id getUserId(){
        return UserInfo.getUserId();
    }
    public static Id getCurrentUserContactId(Id userId){
        try{
            List<User> currentUser = [SELECT contactId 
                                        FROM User 
                                        WHERE Id =: userId
                                        WITH SECURITY_ENFORCED];
            if(!currentUser.isEmpty()){
              return currentUser[0].contactId;
            }    
        }
        catch(QueryException e){
                throw e; 
        }
        return null;
    }
    public static Constants getAllConstants(){
        return new Constants();
    }
}