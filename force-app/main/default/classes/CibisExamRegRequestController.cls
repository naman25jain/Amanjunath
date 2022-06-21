public with sharing class CibisExamRegRequestController{
    public static void ExamRegRequestPayload(String conExamId,String entity){
        String conId = '';
        try 
        {   
            String caseId = conExamId;
            if(!String.isBlank(caseId)){
            List<case> caseList = [SELECT Id,Internal_Status__c,RecordType.DeveloperName,Account.Medschool_Code__c,ContactId, Contact.Birthdate, Contact.Email,Contact.FirstName,
                                   Contact.Generational_Suffix__c,Contact.Gender__c,Contact.LastName,Contact.MiddleName,Contact.MobilePhone,Contact.Native_Language__c,
                                   Contact.USMLE_ID__c,Contact.US_Social_Security__c,Contact.RecordType.DeveloperName,Contact.MailingStreet,Contact.MailingCity,
                                   Contact.MailingPostalCode,Contact.MailingState,(Select Id,Test_Accommodations_needed__c,EP_end_Date__c,EP_start_Date__c,Exam__c,
                                   Exam_Request_Id__c, Exam_Types__c, Exam_Status__c FROM  Exam_Registrations__r) FROM Case WHERE Id=:caseId ]; 
            if(caseList != null && caseList.size() > 0){  
            contact examRegContact = caseList[0].Contact;
            conId = examRegContact.Id;
            List<Contact_Association_Type__c> catList = [SELECT Id,Contact__c,Start_Date__c,End_Date__c,End_Month__c,End_Year__c,Start_Month__c,Start_Year__c 
                                                         FROM Contact_Association_Type__c WHERE Contact__c =: conId];            
            if(catList != null && !catList.isEmpty()){             
            CibisExamRegRequest.examRegPayload payloadObj =  new CibisExamRegRequest.examRegPayload();
                payloadObj.USMLEId = (examRegContact.USMLE_ID__c != null && examRegContact.USMLE_ID__c != '')?examRegContact.USMLE_ID__c:'';
                Exam_Registration__c examRegRecord = new Exam_Registration__c();
                if(caseList[0].Exam_Registrations__r != null && caseList[0].Exam_Registrations__r.size() > 0){
                examRegRecord = caseList[0].Exam_Registrations__r;
                payloadObj.exam = (examRegRecord.Exam__c != null && examRegRecord.Exam__c != '')?examRegRecord.Exam__c:'';
                payloadObj.eligibilityStartDate = String.valueOf(examRegRecord.EP_start_Date__c);
                payloadObj.eligibilityEndDate = String.valueOf(examRegRecord.EP_end_Date__c);
                String accommodationRequest = examRegRecord.Test_Accommodations_needed__c;
                //payloadObj.accommodationRequestFlag = (examRegRecord.Test_Accommodations__c != null && examRegRecord.Test_Accommodations__c != '')?examRegRecord.Test_Accommodations__c:'';
                  if(accommodationRequest == 'Yes'){
                    payloadObj.accommodationRequestFlag = 'Y';
                  }
                  else{
                    payloadObj.accommodationRequestFlag = 'N';
                  }
                }
                payloadObj.lastName = (examRegContact.LastName != null && examRegContact.LastName !='')?examRegContact.LastName:'';
                payloadObj.restOfName = (examRegContact.firstName != null && examRegContact.firstName != '')?examRegContact.firstName:'';
                payloadObj.firstName = '';
                payloadObj.middleName = '';
                payloadObj.generationSuffix = (examRegContact.Generational_Suffix__c != null && examRegContact.Generational_Suffix__c !='')?examRegContact.Generational_Suffix__c:'';
                String gender = examRegContact.Gender__c;
                if(gender == 'Male'){
                    payloadObj.gender = 'M';
                }
                else if(gender == 'Female'){
                    payloadObj.gender = 'F';
                }
                else if(gender == 'X'){
                    payloadObj.gender = 'X';
                }
                else{
                    payloadObj.gender = '';
                }  
                String englishNativeLanguage = examRegContact.Native_Language__c;
                if(englishNativeLanguage == 'English'){
                    payloadObj.englishNativeFlag = 'Y';
                }
                else{
                    payloadObj.englishNativeFlag = 'N';
                }                
                String endMonthValue = '';
                String startMonth = catList[0].Start_Month__c;
                String endMonth = catList[0].End_Month__c;
                if(endMonth == 'January' || startMonth == 'January'){
                    endMonthValue = '01';
                }
                else if(endMonth == 'February'|| startMonth == 'February'){
                    endMonthValue = '02';
                }
                else if(endMonth == 'March' || startMonth == 'March'){
                    endMonthValue = '03';
                }
                else if(endMonth == 'April' || startMonth == 'April'){
                    endMonthValue = '04';
                }
                else if(endMonth == 'May' || startMonth == 'May'){
                    endMonthValue = '05';
                }
                else if(endMonth == 'June' || startMonth == 'June'){
                    endMonthValue = '06';
                }
                else if(endMonth == 'July' || startMonth == 'July'){
                    endMonthValue = '07';
                }
                else if(endMonth == 'August' || startMonth == 'August'){
                    endMonthValue = '08';
                }
                else if(endMonth == 'September' || startMonth == 'September'){
                    endMonthValue = '09';
                }
                else if(endMonth == 'October' || startMonth == 'October'){
                    endMonthValue = '10';
                }
                else if(endMonth == 'November' || startMonth == 'November'){
                    endMonthValue = '11';
                }
                else if(endMonth == 'December' || startMonth == 'December'){
                    endMonthValue = '12';
                }
                String usStateCode = examRegContact.MailingState;
                if(usStateCode == 'Alabama'){
                    payloadObj.state = 'AL';
                }
                if(usStateCode == 'Alaska'){
                    payloadObj.state = 'AK';
                }
                if(usStateCode == 'Arizona'){
                    payloadObj.state = 'AZ';
                }
                if(usStateCode == 'Arkansas'){
                    payloadObj.state = 'AR';
                }
                if(usStateCode == 'California'){
                    payloadObj.state = 'CA';
                }
                if(usStateCode == 'Colorado'){
                    payloadObj.state = 'CO';
                }
                if(usStateCode == 'Connecticut'){
                    payloadObj.state = 'CT';
                }
                if(usStateCode == 'Delaware'){
                    payloadObj.state = 'DE';
                }
                if(usStateCode == 'District of Columbia'){
                    payloadObj.state = 'DC';
                }
                if(usStateCode == 'Florida'){
                    payloadObj.state = 'FL';
                }
                if(usStateCode == 'Georgia'){
                    payloadObj.state = 'GA';
                }
                if(usStateCode == 'Hawaii'){
                    payloadObj.state = 'HI';
                }
                if(usStateCode == 'Idaho'){
                    payloadObj.state = 'ID';
                }
                if(usStateCode == 'Illinois'){
                    payloadObj.state = 'IL';
                }
                if(usStateCode == 'Indiana'){
                    payloadObj.state = 'IN';
                }
                if(usStateCode == 'Iowa'){
                    payloadObj.state = 'IA';
                }
                if(usStateCode == 'Kansas'){
                    payloadObj.state = 'KS';
                }
                if(usStateCode == 'Kentucky'){
                    payloadObj.state = 'KY';
                }
                if(usStateCode == 'Louisiana'){
                    payloadObj.state = 'LA';
                }
                if(usStateCode == 'Maine'){
                    payloadObj.state = 'ME';
                }
                if(usStateCode == 'Maryland'){
                    payloadObj.state = 'MD';
                }
                if(usStateCode == 'Massachusetts'){
                    payloadObj.state = 'MA';
                }
                if(usStateCode == 'Michigan'){
                    payloadObj.state = 'MI';
                }
                if(usStateCode == 'Minnesota'){
                    payloadObj.state = 'MN';
                }
                if(usStateCode == 'Mississippi'){
                    payloadObj.state = 'MS';
                }
                if(usStateCode == 'Missouri'){
                    payloadObj.state = 'AO';
                }
                if(usStateCode == 'Montana'){
                    payloadObj.state = 'MT';
                }
                if(usStateCode == 'Nebraska'){
                    payloadObj.state = 'NE';
                }
                if(usStateCode == 'Nevada'){
                    payloadObj.state = 'NV';
                }
                if(usStateCode == 'New Hampshire'){
                    payloadObj.state = 'NH';
                }
                if(usStateCode == 'New Jersey'){
                    payloadObj.state = 'NJ';
                }
                if(usStateCode == 'New Mexico'){
                    payloadObj.state = 'NM';
                }
                if(usStateCode == 'New York'){
                    payloadObj.state = 'NY';
                }
                if(usStateCode == 'North Carolina'){
                    payloadObj.state = 'NC';
                }
                if(usStateCode == 'North Dakota'){
                    payloadObj.state = 'ND';
                }
                if(usStateCode == 'Ohio'){
                    payloadObj.state = 'OH';
                }
                if(usStateCode == 'Oklahoma'){
                    payloadObj.state = 'OK';
                }
                if(usStateCode == 'Oregon'){
                    payloadObj.state = 'OR';
                }
                if(usStateCode == 'Pennsylvania'){
                    payloadObj.state = 'PA';
                }
                if(usStateCode == 'Rhode Island'){
                    payloadObj.state = 'RI';
                }
                if(usStateCode == 'South Carolina'){
                    payloadObj.state = 'SC';
                }
                if(usStateCode == 'South Dakota'){
                    payloadObj.state = 'SD';
                }
                if(usStateCode == 'Tennessee'){
                    payloadObj.state = 'TN';
                }
                if(usStateCode == 'Texas'){
                    payloadObj.state = 'TX';
                }
                if(usStateCode == 'Utah'){
                    payloadObj.state = 'UT';
                }
                if(usStateCode == 'Vermont'){
                    payloadObj.state = 'VT';
                }
                if(usStateCode == 'Virginia'){
                    payloadObj.state = 'va';
                }
                if(usStateCode == 'Washington'){
                    payloadObj.state = 'wA';
                }
                if(usStateCode == 'West Virginia'){
                    payloadObj.state = 'wv';
                }
                if(usStateCode == 'Wisconsin'){
                    payloadObj.state = 'wi';
                }
                if(usStateCode == 'Wyoming'){
                    payloadObj.state = 'wy';
                }
                String canStateCode = examRegContact.MailingState;
                if(canStateCode == 'Alberta'){
                    payloadObj.state = 'AB';
                }
                if(canStateCode == 'British Columbia'){
                    payloadObj.state = 'BC';
                }
                if(canStateCode == 'Manitoba'){
                    payloadObj.state = 'MB';
                }
                if(canStateCode == 'New Brunswick'){
                    payloadObj.state = 'NB';
                }
                if(canStateCode == 'Newfoundland and Labrador'){
                    payloadObj.state = 'NL';
                }
                if(canStateCode == 'Northwest Territories'){
                    payloadObj.state = 'NT';
                }
                if(canStateCode == 'Nova Scotia'){
                    payloadObj.state = 'NS';
                }
                if(canStateCode == 'Nunavut'){
                    payloadObj.state = 'NU';
                }
                if(canStateCode == 'Ontario'){
                    payloadObj.state = 'ON';
                }
                if(canStateCode == 'Prince Edward Island'){
                    payloadObj.state = 'PE';
                }
                if(canStateCode == 'Quebec'){
                    payloadObj.state = 'QC';
                }
                if(canStateCode == 'Saskatchewan'){
                    payloadObj.state = 'SK';
                }
                if(canStateCode == 'Yukon'){
                    payloadObj.state = 'YT';
                }
                String startYearValue = catList[0].Start_Year__c;
                String endYearValue = catList[0].End_Year__c;
                String startDate = startYearValue + '-' + endMonthValue + '-01';
                payloadObj.schoolStartDate = (startDate != null && startDate != '')?startDate:'';
                String endDate = endYearValue + '-' + endMonthValue + '-01';
                payloadObj.schoolEndDate = (endDate != null && endDate != '')?endDate:'';
                payloadObj.dateOfBirth = String.valueOf(examRegContact.Birthdate);
                payloadObj.address1 = (examRegContact.MailingStreet != null && examRegContact.MailingStreet != '')?examRegContact.MailingStreet:'';
                payloadObj.address4 = (examRegContact.MailingStreet != null && examRegContact.MailingStreet != '')?examRegContact.MailingStreet:'';
                payloadObj.city = (examRegContact.MailingCity != null && examRegContact.MailingCity != '')?examRegContact.MailingCity:'';
                payloadObj.state = (examRegContact.MailingState != null && examRegContact.MailingState != '')?examRegContact.MailingState:'';
                payloadObj.zip = (examRegContact.MailingPostalCode != null && examRegContact.MailingPostalCode != '')?examRegContact.MailingPostalCode:'';
                payloadObj.schoolId = (caseList[0].Account.Medschool_Code__c != null && caseList[0].Account.Medschool_Code__c != '')?caseList[0].Account.Medschool_Code__c:'';                
                payloadObj.SSN = (examRegContact.US_Social_Security__c!= null && examRegContact.US_Social_Security__c !='')?examRegContact.US_Social_Security__c:'';                
                payloadObj.daytimePhone = (examRegContact.MobilePhone != null && examRegContact.MobilePhone != '')?examRegContact.MobilePhone:'';
                payloadObj.emailAddress = examRegContact.Email;
                CibisExamRegRequest examRegObj = new CibisExamRegRequest();
                examRegObj.payload = payloadObj;
                examRegObj.transactionId = examRegContact.Id;
                examRegObj.USMLEId = examRegContact.USMLE_ID__c;
                examRegObj.entity = entity;
                examRegObj.subEntity = '';
                examRegObj.operation = 'POST';
                examRegObj.field = '';
            // Create an instance of the event with field values
            String payload = JSON.serialize(examRegObj);
            Cibis_Entity_Search_Request_Event__e requestEvent = new Cibis_Entity_Search_Request_Event__e(Payload__c=payload,Entity__c = entity);
            // Call method to publish events
            Database.SaveResult sr = EventBus.publish(requestEvent);
            // Inspect publishing result
            if (sr.isSuccess()) 
            {  
                System.debug('the exam registration request payoad is sent as' + sr.isSuccess());            
            } 
            else 
            {
                for(Database.Error err : sr.getErrors()) 
                {
                    system.debug('candidate creation error message is' + err.getMessage());
                }
            }         
            }    
        }   
        } else{
                system.debug('the contact Id is empty');
            }
        }
        catch(Exception e)
        {
            throw e; 
        }
    }
}