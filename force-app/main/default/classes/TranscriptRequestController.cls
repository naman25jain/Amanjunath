/**
 * Class for TranscriptRequest
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   25-MARCH-2020
 */
public with sharing class TranscriptRequestController{
    /**
     * Method Name: getTranscriptRequest
     * Purpose : Method to get Transcript Request
     * Return Type : Transcript Request records
     * @Params :
     */
    @AuraEnabled(cacheable = false)
    public static TranscriptRequestHelper.TranscriptObjWrapper getTranscriptRequest(String linkSource){
        try{
            Id currentUser = AppForCertHelper.retrieveCurrentContactId();
            String primaryTranscriptId = '';
            String primaryNameOfReceipt = '';
            String primaryOrganization = '';
            String primaryStreet = '';
            String primaryCity = '';
            String primaryState = '';
            String primaryCountry = '';
            String primaryPostalCode = '';
            String primaryTelephoneNumber = '';
            String primaryCourier = '';
            Boolean primarySendToSelf = false;
            Boolean primaryRequestAnotherTranscript = false;
            String secondaryTranscriptId = '';
            String secondaryNameOfReceipt = '';
            String secondaryOrganization = '';
            String secondaryStreet = '';
            String secondaryCity = '';
            String secondaryState = '';
            String secondaryCountry = '';
            String secondaryPostalCode = '';
            String secondaryTelephoneNumber = '';
            String secondaryCourier = '';
            Boolean secondarySendToSelf = false;
            Boolean primarySendToSameAddressTranscript = false;
            Boolean numberOfCopMorethanOne = false;
            String linkSourceVal = '';
            Id transcriptReqRecordTypeId = getTransRecordTypeId(linkSource);
            List<Transcript_Request__c> existingPrimaryTranscript = new List<Transcript_Request__c>();
            existingPrimaryTranscript = [SELECT Id,Name_of_Recipient__c,Organization__c,Send_to_Self__c,Street__c,City__c,State__c,
                                Country__c,Zip_Postal_Code__c,Telephone_Number__c,Courier__c,
                                Parent_Transcript_Request__c,Send_to_Same_Address__c,Number_of_Copies__c,Link_Source__c
                                FROM Transcript_Request__c WHERE Contact__c =: currentUser
                                AND Case__r.Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION 
                                AND Parent_Transcript_Request__c = null
                                AND Case__r.RecordTypeId =: transcriptReqRecordTypeId WITH SECURITY_ENFORCED];                    
            if(!existingPrimaryTranscript.isEmpty()){
                primaryTranscriptId = existingPrimaryTranscript[0].Id;
                primaryNameOfReceipt = existingPrimaryTranscript[0].Name_of_Recipient__c;
                primaryOrganization = existingPrimaryTranscript[0].Organization__c;
                primaryStreet = existingPrimaryTranscript[0].Street__c;
                primaryCity = existingPrimaryTranscript[0].City__c;
                primaryState = existingPrimaryTranscript[0].State__c;
                primaryCountry = existingPrimaryTranscript[0].Country__c;
                primaryPostalCode = existingPrimaryTranscript[0].Zip_Postal_Code__c;
                primaryTelephoneNumber = existingPrimaryTranscript[0].Telephone_Number__c;
                if(existingPrimaryTranscript[0].Courier__c==true){
                    primaryCourier = 'Yes';
                }else if(existingPrimaryTranscript[0].Courier__c == false){
                    primaryCourier = 'No';
                }
                primarySendToSelf = existingPrimaryTranscript[0].Send_to_Self__c;
                primarySendToSameAddressTranscript = existingPrimaryTranscript[0].Send_to_Same_Address__c;
                if(existingPrimaryTranscript[0].Number_of_Copies__c == 2){
                    numberOfCopMorethanOne = true;
                    primaryRequestAnotherTranscript = true;
                }
                linkSourceVal = existingPrimaryTranscript[0].Link_Source__c;
                List<Transcript_Request__c> existingSecondaryTranscript = new List<Transcript_Request__c>();
                existingSecondaryTranscript = [SELECT Id,Name_of_Recipient__c,Organization__c,Send_to_Self__c,Street__c,City__c,State__c,
                                    Country__c,Zip_Postal_Code__c,Telephone_Number__c,Courier__c,
                                    Parent_Transcript_Request__c,Send_to_Same_Address__c,Number_of_Copies__c
                                    FROM Transcript_Request__c WHERE Contact__c =: currentUser
                                    AND Case__r.Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION 
                                    AND Parent_Transcript_Request__c =: existingPrimaryTranscript[0].Id
                                    AND Case__r.RecordTypeId =: transcriptReqRecordTypeId WITH SECURITY_ENFORCED];
                if(!existingSecondaryTranscript.isEmpty()){
                    primaryRequestAnotherTranscript = true;
                    secondaryTranscriptId = existingSecondaryTranscript[0].Id;
                    secondaryNameOfReceipt = existingSecondaryTranscript[0].Name_of_Recipient__c;
                    secondaryOrganization = existingSecondaryTranscript[0].Organization__c;
                    secondaryStreet = existingSecondaryTranscript[0].Street__c;
                    secondaryCity = existingSecondaryTranscript[0].City__c;
                    secondaryState = existingSecondaryTranscript[0].State__c;
                    secondaryCountry = existingSecondaryTranscript[0].Country__c;
                    secondaryPostalCode = existingSecondaryTranscript[0].Zip_Postal_Code__c;
                    secondaryTelephoneNumber = existingSecondaryTranscript[0].Telephone_Number__c;
                    if(existingSecondaryTranscript[0].Courier__c==true){
                        secondaryCourier = 'Yes';
                    }else if(existingSecondaryTranscript[0].Courier__c == false){
                        secondaryCourier = 'No';
                    }
                    secondarySendToSelf = existingSecondaryTranscript[0].Send_to_Self__c;
                }
            }
            TranscriptRequestHelper.TranscriptObjWrapper tempTRObj = new TranscriptRequestHelper.TranscriptObjWrapper(primaryTranscriptId,primaryNameOfReceipt,primaryOrganization,primaryStreet,primaryCity,primaryState,primaryCountry,primaryPostalCode,primaryTelephoneNumber,primaryCourier,primarySendToSelf,primaryRequestAnotherTranscript,secondaryTranscriptId,secondaryNameOfReceipt,secondaryOrganization,secondaryStreet,secondaryCity,secondaryState,secondaryCountry,secondaryPostalCode,secondaryTelephoneNumber,secondaryCourier,secondarySendToSelf,primarySendToSameAddressTranscript,numberOfCopMorethanOne,linkSourceVal);
            return tempTRObj;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    /**
     * Method Name: getTranscriptContactDetails
     * Purpose : Method to get Contact details
     * Return Type : Contact records
     * @Params :
     */
    @AuraEnabled(Cacheable = true)
    public static String getTranscriptContactDetails() {
        String returnVal ='';

        Id currentUser = AppForCertHelper.retrieveCurrentContactId();
        List<Contact> con = [Select Id,MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode,Name
                                From Contact Where Id = : currentUser];
        if(!con.isEmpty()){
            String splitter = '^$??^';
            String retunNegativeVal = 'NULL';
            String str = '';
            String city = '';
            String state = '';
            String cont = '';
            String code = '';
            String cName = '';
            str = nullChecker(con[0].MailingStreet,retunNegativeVal);
            city =nullChecker(con[0].MailingCity,retunNegativeVal);
            state =nullChecker(con[0].MailingState,retunNegativeVal);
            cont =nullChecker(con[0].MailingCountry,retunNegativeVal);
            code =nullChecker(con[0].MailingPostalCode,retunNegativeVal);
            cName =nullChecker(con[0].Name,retunNegativeVal);

            returnVal = str + splitter + city + splitter + state + splitter + cont + splitter + code + splitter + cName ;
        }

        return returnVal;
    }

    /**
     * Method Name: nullChecker
     * Purpose : Method to used in contact details null checking
     * Return Type : string
     */
    public static string nullChecker(String val,String returnNegVal){
        String returnVal = '';
        if(val != null && val != ''){
            returnVal =val;
        }
        else{
            returnval = returnNegVal;
        }
        return returnVal;
    }

    /**
     * Method Name: fatchPickListValue
     * Purpose : Method to get picklist values
     * Return Type : picklist values wrapper
     */
    @AuraEnabled(cacheable = true)
    public static List < TranscriptRequestHelper.FatchValueWrapper > fatchPickListValue(sObject objInfo, string picklistFieldApi) {
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objInfo.getSObjectType().getDescribe();

        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();

        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = fieldMap.get(picklistFieldApi).getDescribe().getPickListValues();

        // Create a list of wrapper to store picklist value/lable
        list < TranscriptRequestHelper.FatchValueWrapper > objWrapper = new list < TranscriptRequestHelper.FatchValueWrapper > ();

        for (Schema.PicklistEntry a: values) {
            TranscriptRequestHelper.FatchValueWrapper oFatchValueWrapper = new TranscriptRequestHelper.FatchValueWrapper();
            oFatchValueWrapper.slabel = a.getLabel();
            oFatchValueWrapper.svalue = a.getValue();
            objWrapper.add(oFatchValueWrapper);
        }
        return objWrapper;

    }
    /**
     * Created by Chinmay on March 26th, 2020
     * Method Name: getTrascriptDetails
     * Purpose : Method to retrieve list of Transcript Request records of the applicant
     * Return Type : List of Transcript Request records
     */
    @AuraEnabled
    public static List <Transcript_Request__c> getTrascriptDetails(String linkSource){
        try{
            Id contactId = AppforCertHelper.retrieveCurrentContactId();
            Id transcriptReqRecordTypeId = getTransRecordTypeId(linkSource);
            List<Transcript_Request__c> transcriptDetailsToReturn = new List<Transcript_Request__c>([SELECT Case__c, City__c, Contact__c, Country__c,
                Courier__c, Name_of_Recipient__c, Number_of_Copies__c, Organization__c,
                Parent_Transcript_Request__c, Send_to_Same_Address__c, Send_to_Self__c,
                State__c, Street__c, Telephone_Number__c,
                Zip_Postal_Code__c
                FROM Transcript_Request__c
                WHERE Contact__c =: contactId 
                AND Case__r.Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION
                AND Case__r.RecordTypeId =: transcriptReqRecordTypeId
                ORDER BY createdDate ASC
            ]);
            return transcriptDetailsToReturn;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    /**
     * Method Name: getTermsandConditionsTranscripts
     * Purpose : Method to fetch Terms and conditions for Transcript Request
     * Return Type : List of wrapper with terms content
     * @Params : None
     */
    @AuraEnabled(Cacheable = true)
    public static List < AppForCertHelper.TermsObjWrapper > getTermsandConditionsTranscripts() {
        List < AppForCertHelper.TermsObjWrapper > fetchedValuesToReturn = new List < AppForCertHelper.TermsObjWrapper > ();
        List < Terms_and_Conditions__c > termsList = new List < Terms_and_Conditions__c > ();
        termsList = [Select Id, Copy__c, Name, Short_Copy__c From Terms_and_Conditions__c Where Product__r.Name =: Constants.PRODUCT_NAME_TRANSCRIPT_REQUEST_LEGAL_TERMS
            and Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
            Order By CreatedDate ASC
        ];
        if (!termsList.isEmpty()) {
            For(Terms_and_Conditions__c terms: termsList) {
                string termsId = terms.Id;
                string termsContent = terms.Copy__c;
                string termsCheckBox = terms.Short_Copy__c;

                AppForCertHelper.TermsObjWrapper tempTermsObj = new AppForCertHelper.TermsObjWrapper(termsId, termsContent, termsCheckBox);

                fetchedValuesToReturn.add(tempTermsObj);
            }
        }

        return fetchedValuesToReturn;
    }
    // Method to create new Transcript Requests, parent case and child cases
    @AuraEnabled
    public static Boolean createTranscriptRequestCases(String jsonString){
        try{
            Id contactId = AppForCertHelper.retrieveCurrentContactId();
            TranscriptRequestHelper.TranscriptObjWrapper  objectList = (TranscriptRequestHelper.TranscriptObjWrapper) JSON.deserialize(jsonString, TranscriptRequestHelper.TranscriptObjWrapper.class);
            Id transcriptReqRecordTypeId = getTransRecordTypeId(objectList.linkSource);
            List<Case> existingParentCase = [SELECT Id FROM Case WHERE ContactId =: contactId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND ParentId = Null
                                             AND RecordTypeId =: transcriptReqRecordTypeId AND Service__c =: Constants.CASE_SERVICE_ECFMG_CERTIFICATION WITH SECURITY_ENFORCED LIMIT 1];
            Case parentCase = new Case();
            List<Case> childCases = new List<Case>();
            if(!existingParentCase.isEmpty()){
                parentCase = existingParentCase[0];
                childCases = [SELECT Id FROM Case WHERE ContactId =: contactId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND ParentId =: parentCase.Id
                                        AND RecordTypeId =: transcriptReqRecordTypeId AND Service__c =: Constants.CASE_SERVICE_ECFMG_CERTIFICATION WITH SECURITY_ENFORCED ORDER BY Casenumber];
            }else{
                parentCase = initializeCase(transcriptReqRecordTypeId);
                parentCase = createCase(parentCase);
            }
            Case primCase = new Case();
            If(!childCases.isEmpty()){
                primCase.Id = childCases[0].Id;
            }else{
                primCase = initializeCase(transcriptReqRecordTypeId);
                primCase.ParentId = parentCase.Id;
            }
            primCase.Courier_Required__c = getCourierRequired(objectList.primaryCourier);
            primCase = createCase(primCase);
            Transcript_Request__c primTrans = createPrimaryTranscript(objectList, primCase);
            if(objectList.primaryRequestAnotherTranscript && !objectList.primarySendToSameAddressTranscript){
                Case secCase = new Case();
                if(childCases.size()>1){
                    secCase.Id = childCases[1].Id;
                }else{
                    secCase = initializeCase(transcriptReqRecordTypeId);
                    secCase.ParentId = parentCase.Id;
                }
                secCase.Courier_Required__c = getCourierRequired(objectList.secondaryCourier);
                secCase = createCase(secCase);
                createSecondaryTranscript(objectList, secCase, primTrans);
            }else if(childCases.size()>1){
                markCaseForDeletion(childCases[1]);
            }
            return true;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static Boolean getCourierRequired(String courierReq){
        try{
            Boolean outcome;
            if(courierReq == 'Yes'){
                outcome = true;
            }else if(courierReq == 'No'){
                outcome = false;
            }
            return outcome;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static Case initializeCase(Id transcriptReqRecordTypeId){
        try{
            Id contactId = AppForCertHelper.retrieveCurrentContactId();
            Group g = [SELECT Id, Name, Group.DeveloperName FROM Group WHERE Type = 'Queue' AND Group.DeveloperName =: Constants.QUEUE_USMLE_TRANSCRIPTS WITH SECURITY_ENFORCED];
            Case cse = new Case();
            cse.ContactId = contactId;
            cse.OwnerId = g.Id;
            cse.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
            cse.RecordTypeId = transcriptReqRecordTypeId;
            cse.Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION; 
            return cse; 
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static Case createCase(Case cse){
        try{
            if(Schema.sObjectType.Case.isCreateable() && Schema.sObjectType.Case.isUpdateable()){
                UPSERT cse;
            }
            return cse;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static void markCaseForDeletion(Case cse){
        try{
            cse.Internal_status__c = Constants.CASE_STATUS_MARKED_FOR_DELETION;
            cse.parentId = Null;
            if(Schema.sObjectType.Case.isUpdateable()){
                UPDATE cse;
            }
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static Transcript_Request__c createPrimaryTranscript(TranscriptRequestHelper.TranscriptObjWrapper objectList, Case primCase){
        try{
            Id currentUser = AppForCertHelper.retrieveCurrentContactId();
            List<Transcript_Request__c> existingPrimTrans = [SELECT Id FROM Transcript_Request__c WHERE Case__c =: primCase.Id WITH SECURITY_ENFORCED LIMIT 1];
            Decimal numberOfCop = 1;
            Transcript_Request__c primTrans = new Transcript_Request__c();
            if(!existingPrimTrans.isEmpty()){
                primTrans.Id = existingPrimTrans[0].Id;
            }
            primTrans.Case__c = primCase.Id;
            primTrans.Name_of_Recipient__c = objectList.primaryNameOfReceipt;
            primTrans.Organization__c = objectList.primaryOrganization;
            primTrans.Send_to_Self__c = objectList.primarySendToSelf;
            primTrans.Street__c = objectList.primaryStreet;
            primTrans.City__c = objectList.primaryCity;
            primTrans.State__c = objectList.primaryState;
            primTrans.Country__c = objectList.primaryCountry;
            primTrans.Zip_Postal_Code__c = objectList.primaryPostalCode;
            if(objectList.primaryTelephoneNumber != null && objectList.primaryTelephoneNumber != ''){
                primTrans.Telephone_Number__c = objectList.primaryTelephoneNumber;
            }
            primTrans.Courier__c = getCourierRequired(objectList.primaryCourier);
            primTrans.Contact__c = currentUser;
            primTrans.Send_to_Same_Address__c = objectList.primarySendToSameAddressTranscript;
            if(objectList.primarySendToSameAddressTranscript){
                numberOfCop = 2;
            }
            primTrans.Number_of_Copies__c = numberOfCop;
            primTrans.Link_Source__c = objectList.linkSource;
            if(Schema.sObjectType.Transcript_Request__c.isCreateable() && Schema.sObjectType.Transcript_Request__c.isUpdateable()){
                UPSERT primTrans;
            }
            return primTrans;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static Transcript_Request__c createSecondaryTranscript(TranscriptRequestHelper.TranscriptObjWrapper objectList, Case secCase, Transcript_Request__c primTrans){
        try{
            Id currentUser = AppForCertHelper.retrieveCurrentContactId();
            List<Transcript_Request__c> existingSecTrans = [SELECT Id FROM Transcript_Request__c WHERE Case__c =: secCase.Id WITH SECURITY_ENFORCED LIMIT 1];
            Transcript_Request__c secTrans = new Transcript_Request__c();
            if(!existingSecTrans.isEmpty()){
                secTrans.Id = existingSecTrans[0].Id;
            }
            secTrans.Case__c = secCase.Id;
            secTrans.Name_of_Recipient__c = objectList.secondaryNameOfReceipt;
            secTrans.Organization__c = objectList.secondaryOrganization;
            secTrans.Send_to_Self__c = objectList.secondarySendToSelf;
            secTrans.Street__c = objectList.secondaryStreet;
            secTrans.City__c = objectList.secondaryCity;
            secTrans.State__c = objectList.secondaryState;
            secTrans.Country__c = objectList.secondaryCountry;
            secTrans.Zip_Postal_Code__c = objectList.secondaryPostalCode;
            if(objectList.secondaryTelephoneNumber != null && objectList.secondaryTelephoneNumber != ''){
                secTrans.Telephone_Number__c = objectList.secondaryTelephoneNumber;
            }
            secTrans.Courier__c = getCourierRequired(objectList.secondaryCourier);
            secTrans.Contact__c = currentUser;
            secTrans.Parent_Transcript_Request__c = primTrans.Id;
            secTrans.Link_Source__c = objectList.linkSource;
            if(Schema.sObjectType.Transcript_Request__c.isCreateable() && Schema.sObjectType.Transcript_Request__c.isUpdateable()){
                UPSERT secTrans;
            }
            return secTrans;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    // Method to update parent and child USMLE/NON-USMLE status as Pending Review
    @AuraEnabled
    public static List<String> updateCaseStatus(){
        try{
            Id contactId = AppForCertHelper.retrieveCurrentContactId();
            List<String> caseNumbers = new List<String>();
            List<Case> caseList = [SELECT Id, Internal_Status__c, CaseNumber, ParentId FROM Case WHERE ContactId =: contactId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION
                                   AND (RecordTypeId =: Constants.USMLETRANSCRIPTCASERECORDTYPEID OR RecordTypeId =: Constants.NONUSMLETRANSCCASERDTYPEID) AND Service__c =: Constants.CASE_SERVICE_ECFMG_CERTIFICATION WITH SECURITY_ENFORCED];
            for(Case cse : caseList){
                cse.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
                String csNumber;
                if(cse.ParentId != Null){
                    if(!caseNumbers.isEmpty()){
                        csNumber = ' ' + String.valueOf(cse.CaseNumber);
                    }else{
                        csNumber = String.valueOf(cse.CaseNumber);
                    }
                    caseNumbers.add(csNumber);
                }
            }
            if(Schema.sObjectType.Transcript_Request__c.isUpdateable()){
                UPDATE caseList;
            }
            return caseNumbers;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }       
    }
    public static Id getTransRecordTypeId(String linkSource){
        try{
            Id transcriptReqRecordTypeId;
            if(linkSource == Constants.TRANSCRIPT_LINK_SOURCE){
                transcriptReqRecordTypeId = Constants.USMLETRANSCRIPTCASERECORDTYPEID;
            }else{
                transcriptReqRecordTypeId = Constants.NONUSMLETRANSCCASERDTYPEID;
            }
            return transcriptReqRecordTypeId;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    /**
     * Created by Jofrin
     * Method Name: enableUSMLETranscriptRequestLink
     * Purpose : Method to display USMLE Transcript Request link.
     * Return Type : string
     */
    @AuraEnabled(Cacheable = true)
    public static String enableUSMLETranscriptRequestLink() {

        String returnVal='';
        Id currentContactId = AppForCertHelper.retrieveCurrentContactId();

        List<Exam_Registration__c> examHistoryList = new List<Exam_Registration__c>([Select id,Applicant__c from Exam_Registration__c where Applicant__c = :currentContactId AND RecordType.DeveloperName=:Constants.CIBIS_EXAM_REG_HISTORY_NON_USMLE]);  
        if(!examHistoryList.isEmpty()){
            returnVal = 'true';
        }
        else{
            returnVal = 'false';
        }
        return returnVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getAddressDetailsByPlaceId(String placeId){
        String result = null;
        try{
            if(placeId != null) {
                String apiURL = Constants.GOOGLE_API_ADDRESS_PLACE +
                  EncodingUtil.urlEncode(placeId, 'UTF-8') + '&key=' + getAPIKey();
                HttpResponse res = getResponse(apiURL);
                if(res.getStatusCode() == 200) {
                    result = res.getBody();
                }
            }
        }
        catch(exception e) {
            //Handling exception
            throw new AuraHandledException('Error while getting location predictions ---> '+e.getMessage());
        }
        return result;
    }
    
    //Generic method to get GoogleAPIKey from Custom Label.
    public static String getAPIKey() {
        String api = Label.GoogleAPIKey;
        return api;
    }

    //Generic Http Callout Method
    public static HttpResponse getResponse(String strURL){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        res = h.send(req);
        return res;
    }
    
    //Method to make a Callout to Google Place API to get search predications based on input search string
    @AuraEnabled(cacheable=true)
    public static String getAddressSet(String searchText, Boolean showInternationalAddresses){
        String result = null;
        try{
            if(searchText != null) {
                String apiURL = Constants.GOOGLE_API_ADDRESS_AUTOCOMPLETE +
                  EncodingUtil.urlEncode(searchText,
                    'UTF-8') + '&key=' + getAPIKey();
                
                HttpResponse res = getResponse(apiURL);

                if(res.getStatusCode() == 200) {
                    result = res.getBody();
                }
            }
        }
        catch(exception e) {
            //Handling exception
            system.debug(e.getMessage());
            throw new AuraHandledException('Error while getting location predictions ---> '+e.getMessage());
        }
        return result;
    }

    // Purpose: To check if the Transcript request submitted has OFAC Country
    
    @AuraEnabled(cacheable = true)
    public static List<Boolean> checkOFACRestriction(String prCountry, String secCountry){
        List<Boolean> retVal = new list<Boolean>();
        List<OFAC__c> ofacRestrictedList = new List<OFAC__c>([Select Id, Country__c from OFAC__c where Type__c =: Constants.RESTRICTED_BY_ECFMG ]);
        if(ofacRestrictedList.size() > 0){
            Set<String> countryList = new Set<String>();
            for(Integer loopVar = 0; loopVar < ofacRestrictedList.size(); loopVar++){
                countryList.add(ofacRestrictedList[loopVar].Country__c);
            }
            if(countryList.contains(prCountry)){
                retVal.add(true);
            }
            else{
                retVal.add(false);
            }
            if(countryList.contains(secCountry)){
                retVal.add(true);
            }
            else{
                retVal.add(false);
            }
        }
        else{ 
            retVal.add(false);
            retVal.add(false);
        }
        return retVal;
    }
    @AuraEnabled(cacheable = false)
    public static String getTransscriptRequestCases(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        String parentCaseId = '';
        List<Case> existingParentCase = [SELECT Id FROM Case WHERE ContactId =: contactId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND ParentId = null
                                             AND (RecordTypeId =: Constants.USMLETRANSCRIPTCASERECORDTYPEID OR RecordTypeId =: Constants.NONUSMLETRANSCCASERDTYPEID) AND Service__c =: Constants.CASE_SERVICE_ECFMG_CERTIFICATION WITH SECURITY_ENFORCED LIMIT 1];
        if(!existingParentCase.isEmpty()){
            parentCaseId = existingParentCase[0].Id;
        }
        return parentCaseId;
    }
}