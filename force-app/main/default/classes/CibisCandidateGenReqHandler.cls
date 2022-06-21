/*
 CIBIS - Expose methods to build/handle payload for Cibis Candidate Creation Request Event Platform Event
*/
public with sharing class CibisCandidateGenReqHandler{
    public static map<Id,Id> conCaseIdMap = new map<Id,Id>();
    
    public static List<Cibis_Entity_Search_Request_Event__e> constructPayload(String entity,set<Id> caseIds){
        // return variable declaration
        list<Cibis_Entity_Search_Request_Event__e>  cibisCandReqList=new list<Cibis_Entity_Search_Request_Event__e>();
        try 
        {
            map<String,string> genderMap=new map<String,String>{'Male'=>'M','Female'=>'F','X'=>'X'};
                map<String,String> monthNameMap=new map<String,string>{'January'=>'01','February'=>'02','March'=>'03','April'=>'04','May'=>'05','June'=>'06','July'=>'07',
                    'August'=>'08','September'=>'09','October'=>'10','November'=>'11','December'=>'12'};
                        if(!caseIds.isEmpty()){
     
                            for(Case c:[Select id,contactId from Case where ID IN:caseIds AND  RecordType.developerName=:Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND Internal_Status__c=:Constants.CASE_STATUS_PENDING_CIBIS ]){
                               conCaseIdMap.put(c.contactId,c.Id); 
                            }
                            
                            if(conCaseIdMap != null && conCaseIdMap.size() > 0){
                                list<Contact_Association_Type__c> lstConAss = [select Id,Contact__c,Graduation_Month__c,Contact__r.Birthdate,Contact__r.Email,Contact__r.Firstname,Contact__r.Generational_Suffix__c,
                                                                           Contact__r.Gender__c,Contact__r.Graduation_Year__c,Contact__r.LastName,Contact__r.Account.Medschool_Code__c,Contact__r.National_Identification__c, Contact__r.RecordType.DeveloperName, Contact__r.USMLE_ID__c,
                                                                           Contact__r.US_Social_Security__c,Contact__r.npsp__Deceased__c,Contact__r.National_ID_Country__c,Contact__r.MiddleName,Graduation_Year__c,Start_Month__c,Start_Year__c,
                                                                           RecordType.DeveloperName FROM Contact_Association_Type__c WHERE RecordType.DeveloperName =:Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL
                                                                           AND Contact__c IN:conCaseIdMap.keyset() AND  Contact__r.USMLE_ID__c != null  AND Contact__r.RecordType.DeveloperName =:Constants.CONTACT_RECORD_TYPE_APPLICANT WITH SECURITY_ENFORCED];
                                
                               System.debug('lstConAss => '+lstConAss);
                                for(Contact_Association_Type__c catRecord:lstConAss) {
                                    
                                    CibisCandidateRequestEventWrap.candidatePayLoad payloadObj =  new CibisCandidateRequestEventWrap.candidatePayLoad();
                                    payloadObj.USMLEId = (catRecord.Contact__r.USMLE_ID__c != null && catRecord.Contact__r.USMLE_ID__c != '')?catRecord.Contact__r.USMLE_ID__c:'';
                                    payloadObj.lastName = (catRecord.Contact__r.LastName != null && catRecord.Contact__r.LastName != '')?catRecord.Contact__r.LastName:'';
                                    payloadObj.firstName = '';
                                    payloadObj.middleName = '';
                                    payloadObj.restOfName = (catRecord.Contact__r.FirstName != null && catRecord.Contact__r.FirstName != '')?catRecord.Contact__r.FirstName:'';
                                    payloadObj.generationSuffix = (catRecord.Contact__r.Generational_Suffix__c != null && catRecord.Contact__r.Generational_Suffix__c != '')?catRecord.Contact__r.Generational_Suffix__c:'';
                                    
                                    if(genderMap.containskey(catRecord.Contact__r.Gender__c)){
                                        payloadObj.gender = genderMap.get(catRecord.Contact__r.Gender__c); 
                                    }                
                                    else{
                                        payloadObj.gender = '';
                                    }  
                                    payloadObj.dateOfBirth = String.valueOf(catRecord.Contact__r.Birthdate);
                                    payloadObj.schoolId = (catRecord.Contact__r.Account.Medschool_Code__c != null && catRecord.Contact__r.Account.Medschool_Code__c != '')?catRecord.Contact__r.Account.Medschool_Code__c:'';
                                    payloadObj.SSN = (catRecord.Contact__r.US_Social_Security__c != null && catRecord.Contact__r.US_Social_Security__c != '')?catRecord.Contact__r.US_Social_Security__c:'';
                                    payloadObj.graduationYear = (catRecord.Contact__r.Graduation_Year__c != null && catRecord.Contact__r.Graduation_Year__c != '')?catRecord.Contact__r.Graduation_Year__c:'';
                                    
                                    if(monthNameMap.containskey(catRecord.Graduation_Month__c)){
                                        payloadObj.graduationMonth =monthNameMap.get(catRecord.Graduation_Month__c);
                                    }                   
                                    else{
                                        payloadObj.graduationMonth = '';
                                    }
                                    payloadObj.schoolStartYear = (catRecord.Start_Year__c != null && catRecord.Start_Year__c != '')?catRecord.Start_Year__c:'';
                                    if(monthNameMap.containskey(catRecord.Start_Month__c)){
                                        payloadObj.schoolStartMonth = monthNameMap.get(catRecord.Start_Month__c);
                                    }                    
                                    else{
                                        payloadObj.graduationMonth = '';
                                    }
                                    payloadObj.emailAddress = (catRecord.Contact__r.Email != null && catRecord.Contact__r.Email != '')?catRecord.Contact__r.Email:'';
                                    payloadObj.nid = (catRecord.Contact__r.National_Identification__c != null && catRecord.Contact__r.National_Identification__c !='')?catRecord.Contact__r.National_Identification__c:'';
                                    payloadObj.nidCountryId = (catRecord.Contact__r.National_ID_Country__c != null && catRecord.Contact__r.National_ID_Country__c != '')?catRecord.Contact__r.National_ID_Country__c:'';
                                    CibisCandidateRequestEventWrap candCreatObj = new CibisCandidateRequestEventWrap();
                                    candCreatObj.payload = payloadObj;
                                    candCreatObj.USMLEId = catRecord.Contact__r.USMLE_ID__c;
                                    candCreatObj.entity = Constants.CIBIS_CANDIDATE_TYPE;
                                    candCreatObj.subEntity = '';
                                    if(conCaseIdMap.containskey(catRecord.Contact__c)){
                                       candCreatObj.transactionId =Constants.CIBIS_CANDIDATE_EVENT+'-'+conCaseIdMap.get(catRecord.Contact__c)+'-'+catRecord.Contact__c+'-'+GenericUtilities.getUUID();  
                                    }
                                    else{
                                        candCreatObj.transactionId =Constants.CIBIS_CANDIDATE_EVENT+'-'+catRecord.Contact__c+'-'+GenericUtilities.getUUID(); 
                                    }                                 
                                    candCreatObj.operation = 'POST';
                                    candCreatObj.field = '';
                                    String payload = JSON.serialize(candCreatObj);
                                    System.debug('*****CibisCandidateRequestEventWrap***'+payload);
                                    cibisCandReqList.add(new Cibis_Entity_Search_Request_Event__e(Payload__c=payload));
                                } 
                            }
                            
                            
                        }
            // return Platform Event List
            return cibisCandReqList;
        }
        catch(Exception e)
        {
         system.debug('===CandidateCreationError===> ' + e.getMessage());
            throw e; 
        }
    }
    
}