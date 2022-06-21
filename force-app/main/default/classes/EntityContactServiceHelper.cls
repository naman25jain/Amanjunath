/**
 * wrapper class for EntityContactServiceController
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   26-MAY-2020
 */
public with sharing class EntityContactServiceHelper {
    public EntityContactServiceHelper() {

    }
    /* Wrapper class to Primary Entity to the form
     */
    public class EntityConWrapper {
        @auraenabled public string conId { get; set; }
        @auraenabled public string conName { get; set; }    
        @auraenabled public List<EntityOptionsWrapper> accName { get; set; }
        
        public EntityConWrapper(String conIdVal,String conNameVal,List<EntityOptionsWrapper> accNameVal) {
            conId = conIdVal;
            conName = conNameVal;
            accName = accNameVal;
            
        }
    }

     /* Wrapper class to get Account Id and Account Name
     */
    public class EntityOptionsWrapper {
            @auraenabled public string accId { get; set; }
            @auraenabled public string accName { get; set; }    
                        
            public EntityOptionsWrapper(String accIdVal,String accNameVal) {
                accId = accIdVal;
                accName = accNameVal;
                
                
            }
    }

     /* Wrapper class to send services to the form 
     */
    public class EntitySerWrapper {
        @auraenabled public string serviceId { get; set; }
        @auraenabled public string serviceName { get; set; }
        @auraenabled public string role { get; set; }    
                    
        public EntitySerWrapper(String serviceIdVal,String serviceNameVal,String roleVal) {
            serviceId = serviceIdVal;
            serviceName = serviceNameVal;
            role = roleVal;            
            
        }
}
    
}