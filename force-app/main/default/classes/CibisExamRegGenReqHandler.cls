//CIBIS
public with sharing class CibisExamRegGenReqHandler{
    public static list<Cibis_Entity_Search_Request_Event__e> constructPayload(String entity,set<Id> caseIds){
        //return variable declaration
        list<Cibis_Entity_Search_Request_Event__e> cibisExamReqList;
         list<npsp__Error__c> npspErrorLogs=new list<npsp__Error__c>();
        try 
        {   
            if(!caseIds.isEmpty()){  
               cibisExamReqList =  new list<Cibis_Entity_Search_Request_Event__e>(); 
                List<Exam_Registration__c> examRegistrations=[Select Id,Test_Accommodations_needed__c,EP_end_Date__c,EP_start_Date__c,Exam__c,case__c,case__r.Internal_Status__c,case__r.RecordType.DeveloperName,
                                                              case__r.Account.Medschool_Code__c,Applicant__c,Applicant__r.Birthdate, Applicant__r.Email,Applicant__r.FirstName,
                                                              Applicant__r.Generational_Suffix__c,Applicant__r.Gender__c,Applicant__r.LastName,Applicant__r.MiddleName,Applicant__r.MobilePhone,Applicant__r.Native_Language__c,
                                                              Applicant__r.USMLE_ID__c,Applicant__r.US_Social_Security__c,Applicant__r.RecordType.DeveloperName,Applicant__r.MailingStreet,Applicant__r.MailingCity,
                                                              Applicant__r.MailingPostalCode,Applicant__r.MailingState  from  Exam_Registration__c where case__c IN:caseIds WITH SECURITY_ENFORCED];                       
                
                if(!examRegistrations.isEmpty()){ 
                    set<Id> contactIds=new set<Id>();
                    map<Id,Contact_Association_Type__c> conAssociateMap=new map<Id,Contact_Association_Type__c>();
                    map<String,string> genderMap=new map<String,String>{'Male'=>'M','Female'=>'F','X'=>'X'};
                        map<String,String> monthNameMap=new map<String,string>{'January'=>'01','February'=>'02','March'=>'03','April'=>'04','May'=>'05','June'=>'06','July'=>'07',
                            'August'=>'08','September'=>'09','October'=>'10','November'=>'11','December'=>'12'};
                                system.debug('examRegistrations'+examRegistrations);
                                For(Exam_Registration__c examReg:examRegistrations){
                                     system.debug('examReg.Applicant__c'+examReg.Applicant__c);
                                   if(examReg.Applicant__c!=null){
                                        contactIds.add(examReg.Applicant__c); 
                                        system.debug('contactIds'+contactIds);
                                    }                        
                                }
                    if(!contactIds.isEmpty()){
                        
                        For(Contact_Association_Type__c cat:[SELECT Id,Contact__c,Start_Date__c,End_Date__c,End_Month__c,End_Year__c,Start_Month__c,Start_Year__c 
                                                             FROM Contact_Association_Type__c WHERE Contact__c IN:contactIds and RecordType.DeveloperName=:Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL]){
                                                                 conAssociateMap.put(cat.Contact__c,cat);
                                                               system.debug('conAssociateMap'+conAssociateMap);   
                                                             }   
                    }
                    if(!conAssociateMap.isEmpty()) {
                        map<String,String> stateCodeMap=new map<String,String>();                
                        For(Countries_and_States__c cs:Countries_and_States__c.getall().values()){
                            stateCodeMap.put(cs.State_Name__c,cs.State_Code__c);  
                            system.debug('stateCodeMap'+stateCodeMap);
                        }
                     
                        For(Exam_Registration__c examReg:examRegistrations){
                            if(conAssociateMap.containskey(examReg.Applicant__c)){
                                Contact_Association_Type__c cat=conAssociateMap.get(examReg.Applicant__c);
                                system.debug('Contact_Association_Type__c'+cat);
                                CibisExamRegRequestEventWrap.examRegPayload payloadObj =  new CibisExamRegRequestEventWrap.examRegPayload();   
                                payloadObj.USMLEId = (examReg.Applicant__r.USMLE_ID__c != null && examReg.Applicant__r.USMLE_ID__c != '')?examReg.Applicant__r.USMLE_ID__c:''; 
                                payloadObj.exam = (examReg.Exam__c != null && examReg.Exam__c != '')?examReg.Exam__c:'';
                                payloadObj.eligibilityStartDate =examReg.EP_start_Date__c!=null ? String.valueOf(examReg.EP_start_Date__c):'';
                                payloadObj.eligibilityEndDate =examReg.EP_end_Date__c!=null ? String.valueOf(examReg.EP_end_Date__c):'';
                                payloadObj.accommodationRequestFlag=examReg.Test_Accommodations_needed__c == 'YES' ? 'Y' :'N';
                                payloadObj.lastName = (examReg.Applicant__r.LastName != null && examReg.Applicant__r.LastName !='') ? examReg.Applicant__r.LastName:'';
                                payloadObj.restOfName = (examReg.Applicant__r.firstName != null && examReg.Applicant__r.firstName != '') ? examReg.Applicant__r.firstName:'';
                                payloadObj.firstName = '';
                                payloadObj.middleName = '';
                                payloadObj.generationSuffix = (examReg.Applicant__r.Generational_Suffix__c != null && examReg.Applicant__r.Generational_Suffix__c !='') ? examReg.Applicant__r.Generational_Suffix__c:'';
                                payloadObj.gender =genderMap.containskey(examReg.Applicant__r.Gender__c) ? genderMap.get(examReg.Applicant__r.Gender__c) :'';
                                payloadObj.englishNativeFlag = examReg.Applicant__r.Native_Language__c=='English' ? 'Y' : 'N';
                                payloadObj.schoolStartDate=string.valueOf(cat.Start_Year__c)+'-'+((Integer.valueOf(monthNameMap.get(cat.Start_Month__c)) < Integer.valueOf(monthNameMap.get(cat.End_Month__c)))  ? monthNameMap.get(cat.Start_Month__c) : monthNameMap.get(cat.End_Month__c))+'-01';
                                payloadObj.schoolEndDate=string.valueOf(cat.End_Year__c)+'-'+((Integer.valueOf(monthNameMap.get(cat.Start_Month__c)) < Integer.valueOf(monthNameMap.get(cat.End_Month__c)))  ? monthNameMap.get(cat.Start_Month__c) : monthNameMap.get(cat.End_Month__c))+'-01';
                                payloadObj.state = stateCodeMap.containskey(examReg.Applicant__r.MailingState) ? stateCodeMap.get(examReg.Applicant__r.MailingState) : '';
                                payloadObj.dateOfBirth =examReg.Applicant__r.Birthdate!=null ? String.valueOf(examReg.Applicant__r.Birthdate):null;
                                payloadObj.address1 = (examReg.Applicant__r.MailingStreet != null && examReg.Applicant__r.MailingStreet != '')?examReg.Applicant__r.MailingStreet:'';
                                payloadObj.city = (examReg.Applicant__r.MailingCity != null && examReg.Applicant__r.MailingCity != '')?examReg.Applicant__r.MailingCity:'';                             
                                payloadObj.zip = (examReg.Applicant__r.MailingPostalCode != null && examReg.Applicant__r.MailingPostalCode != '')?examReg.Applicant__r.MailingPostalCode:'';
                                payloadObj.address4 = payloadObj.city+', '+ payloadObj.state+' '+ payloadObj.zip;
                                payloadObj.schoolId = (examReg.case__r.Account.Medschool_Code__c != null && examReg.case__r.Account.Medschool_Code__c !='') ? examReg.case__r.Account.Medschool_Code__c:'';                
                                payloadObj.SSN = (examReg.Applicant__r.US_Social_Security__c!= null && examReg.Applicant__r.US_Social_Security__c !='')?examReg.Applicant__r.US_Social_Security__c:'';                
                                payloadObj.daytimePhone = (examReg.Applicant__r.MobilePhone != null && examReg.Applicant__r.MobilePhone != '')?examReg.Applicant__r.MobilePhone:'';
                                payloadObj.emailAddress = examReg.Applicant__r.Email;
                                CibisExamRegRequestEventWrap examRegObj = new CibisExamRegRequestEventWrap();
                                examRegObj.payload = payloadObj;
                                examRegObj.transactionId =Constants.CIBIS_REGISTRATION_EVENT+'-'+examReg.case__c+'-'+GenericUtilities.getUUID();
                                examRegObj.USMLEId = examReg.Applicant__r.USMLE_ID__c;
                                examRegObj.entity = Constants.CIBIS_EXAM_TYPE;
                                examRegObj.subEntity = '';
                                examRegObj.operation = 'POST';
                                examRegObj.field = '';
                                String payload = JSON.serialize(examRegObj);       
                                   system.debug('CibisExamRegGenReqHandler'+payload);
                                cibisExamReqList.add(new Cibis_Entity_Search_Request_Event__e(Payload__c=payload));
                                system.debug('cibisExamReqList'+cibisExamReqList);
                            }
                        }
                    }
                }
            }
            system.debug('CibisExamRegGenReqHandler'+cibisExamReqList);
            return cibisExamReqList;
        }
        catch(Exception e)
        {
            System.debug('****CibisExamRegGenReqHandler***'+e.getMessage());
            throw e; 
        }
    }
}