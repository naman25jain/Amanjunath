/**
* Check for OFAC Countries, Account Establishment and Biographic Information change 
* criteria and display the link for App for Cert & Exam Registration
*
* @author        Enable Consulting
* @version       1.0
* @createdDate   13-DEC-2019
*/
public with sharing class ServicesComponentController {

    /**
     * Created by Aslam
     * Method Name: getOFACAccessCheck
     * Purpose : Referencing an OFAC__c object to determine if this Contact should be allowed
     *           access to the App for cert based on the MailingCountry or contact's degree medical school billing country
     *           is in restricted countries to enable for exam registration
     * Return Type : String
     */
    @AuraEnabled(cacheable = true)
    public static String getOFACAccessCheck() {
        
        Id contactId = getContactId();
        
        String contactAssTypeCountry = getAccountCountry(contactId);
        String contactMailingCountry = getContactCountry(contactId);
        
        string allowExamReg = getStepNumber();
        string validtionMsg = '';
        string validtionMsgExamReg = '';
        string validtionMsgExamRegDean = '';
        
        boolean valFail = false;

        List<Asset> assetList = new List<Asset>([select id,status,RecordType.DeveloperName,Dean_s_Letter_Date__c from asset where contactId=:contactId and (Type__c= :constants.ASSET_TYPE_DEAN_LETTER OR Type__c= :constants.ASSET_TYPE_FINAL_MED_DIPLOMA)  and status =:constants.ASSET_STATUS_ACCEPTED]);

        Map < String, OFAC__c > ofacCountriesMap = getOFACCountryList();

        if(!ofacCountriesMap.isEmpty()){
            //Restriction by ECFMG for both appforCert and ExamReg for contact country
            if(ofacCountriesMap.containsKey(contactMailingCountry) && ofacCountriesMap.get(contactMailingCountry).type__c==System.Label.OFAC_NOT_ALLOWED){
                valFail = true;
                validtionMsg = validtionMsg + System.Label.OFAC_Not_Allowed_Error_Message + '<br>';
            }
            //to show validation only when user click on Exam Registration link.
            else if(allowExamReg == 'ExamReg'){
                validtionMsgExamReg = examRegValiationOfac(contactAssTypeCountry,contactMailingCountry);
                if(validtionMsgExamReg != 'Success'){
                    validtionMsg = validtionMsg + validtionMsgExamReg;
                    valFail = true;
                }
            }
        }
        
        validtionMsgExamRegDean = examRegValidation(allowExamReg,assetList, contactId);
        if(validtionMsgExamRegDean != 'Success'){
            validtionMsg = validtionMsg + validtionMsgExamRegDean;
            valFail = true;
        }

        if(valFail){
           return validtionMsg;
        }
        else{
            return 'Success';
        }     
    }

     /**
     * Created by Jofrin
     * Method Name: examRegValiationOfac
     * Purpose : Continuation of getOFACAccessCheck method to check the validation of Exam Registration for OFAC.
     * Return Type : String
     */

    @AuraEnabled(cacheable = true)
    public static string examRegValiationOfac(String contactAssTypeCountry, String contactMailingCountry){
        string validtionMsg = '';
        boolean valFail = false;
        Map < String, OFAC__c > ofacCountriesMap = getOFACCountryList();

        if(ofacCountriesMap.containsKey(contactAssTypeCountry) && (ofacCountriesMap.get(contactAssTypeCountry).type__c==System.Label.OFAC_NOT_ALLOWED || 
            ofacCountriesMap.get(contactAssTypeCountry).type__c==System.Label.OFAC_NOT_ALLOWED1)){ 
            valFail = true;
            validtionMsg = validtionMsg + System.Label.OFAC_warning_error_message + '<br>';
        }
        if(ofacCountriesMap.containsKey(contactMailingCountry) && ofacCountriesMap.get(contactMailingCountry).type__c==System.Label.OFAC_NOT_ALLOWED1){
            valFail = true;
            validtionMsg = validtionMsg + System.Label.OFAC_Not_Allowed_Error_Message + '<br>';
        }
        if(valFail){
            return validtionMsg;
        }
        else{
            return 'Success';
        }
        
    }

    /**
     * Created by Jofrin
     * Method Name: examRegValiation
     * Purpose : Continuation of getOFACAccessCheck method to check the validation of Exam Registration.
     * Return Type : String
     */

    @AuraEnabled(cacheable = true)
    public static string examRegValidation(string allowExamReg, List<Asset> assetList, Id contactId){
        string validtionMsg = '';
        boolean valFail = false;
        
        List<Asset> deansLetterList = [select id from asset where contactId=:contactId and RecordType.DeveloperName=:Constants.ASSET_RECORD_TYPE_APP_FOR_CERT and Type__c= :constants.ASSET_TYPE_DEAN_LETTER AND status !=:constants.ASSET_STATUS_REJECTED  AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION];
        List<String> recTypeList = new List<String>();
        recTypeList.add(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE);    
        List<Case> existingCases = new List<Case> ([Select id,Internal_Status__c,ContactId,isClosed,Service__c,RecordType.DeveloperName,Case_Status__c from Case where ContactId=:contactId 
                                                and isClosed = FALSE and RecordType.DeveloperName IN :recTypeList]);
                                
        if(allowExamReg == 'ExamReg'){
            if(!deansLetterList.isEmpty() && assetList.isEmpty()){ 
                validtionMsg = validtionMsg + System.Label.App_for_Cert_Dean_s_Letter_Date_should_not_be_a_future_date + '<br>';
                valFail = true;    
            }
            if(!existingCases.isEmpty()){ 
                validtionMsg = validtionMsg + System.Label.Biographic_change_error_message +'<br>';
                valFail = true;
            }
        }
        if(valFail){
            return validtionMsg;
        }
        else{
            return 'Success';
        }
    }

    /**
     * Created by Reshma
     * Method Name: getContactCountry
     * Purpose : To get contact mailing country
     * Return Type : String
     */
    public static String getContactCountry(Id contactId) {
        Contact thisContact = [Select id,MailingCountry from Contact where id=:contactId Limit 1];
        String contactMailingCountry ='';
        if(thisContact.MailingCountry != null && thisContact.MailingCountry != ''){
            contactMailingCountry = thisContact.MailingCountry;
        }
        return contactMailingCountry;
    }

    /**
     * Created by Reshma
     * Method Name: getAccountCountry
     * Purpose : To get account billing country
     * Return Type : String
     */
    public static String getAccountCountry(Id contactId) {
        List<Contact_Association_Type__c> contactATList = new List<Contact_Association_Type__c>([Select id,RecordType.DeveloperName,Account__r.name,Account__r.Id,Contact__r.Id,Account__r.BillingCountry,Contact__r.MailingCountry from Contact_Association_Type__c where  Contact__r.Id =:contactId and RecordType.DeveloperName=:Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL]);
        String contactAssTypeCountry ='';
        if(!contactATList.isEmpty()){
            contactAssTypeCountry = contactATList[0].Account__r.BillingCountry;
        }
        return contactAssTypeCountry;
    }

     /**
    * Created by Jofrin
    * Method Name: getStepNumber
    * Purpose : Indicates the progress in lightning progress indicator 
    * Return Type : String
    */
    @AuraEnabled(cacheable=true)
    public static String getStepNumber() {
    
        string contactId = getContactId();
        List < String > recTypeList = new List < String > ();
        recTypeList.add(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION);
        recTypeList.add(Constants.CASE_RECORD_TYPE_APP_FOR_CERT);

        List<Case> existingCases = new List<Case>([Select id,ContactId,isClosed,Service__c,RecordType.DeveloperName,Case_Status__c from Case where ContactId=:contactId 
                                    and RecordType.DeveloperName IN :recTypeList]);
        List<Case> existingAppForCase = new List<Case>([Select id,ContactId,isClosed,Service__c,RecordType.DeveloperName,Case_Status__c from Case where ContactId=:contactId 
                                    and RecordType.DeveloperName=:Constants.CASE_RECORD_TYPE_APP_FOR_CERT and Case_Status__c=:Constants.CASE_STATUS_ACCEPTED]);
        
        for(Case thisCase:existingCases){
            if(thisCase.Case_Status__c == Constants.CASE_STATUS_ACCEPTED && thisCase.RecordType.DeveloperName==Constants.CASE_RECORD_TYPE_APP_FOR_CERT){
                return 'ExamReg';
            } 
            else if(thisCase.Case_Status__c == Constants.CASE_STATUS_ACCOUNT_ESTABLISHED && thisCase.RecordType.DeveloperName==Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION && existingAppForCase.size() == 0){
                return 'AppForCert';
            } 
    } 
        return 'AccountEst';
    }

    /**
     * Created by Aslam
     * Method Name: getAccountEstablishment
     * Purpose : Checks for Account Establishment, Biographic Change, and Application for Certification cases
     *           And determines if the AppforCert link should be enabled or not
     * Return Type : String
     */
    @AuraEnabled(cacheable = true)
    public static String getAccountEstablishment() {

        Id currentUser = UserInfo.getUserId();
        List < User > userList = new List < User > ([select contactId from User u where u.Id =: currentUser]);
        Id contactId = userList[0].contactId;
        List < String > recTypeList = new List < String > ();
        recTypeList.add(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE);
        recTypeList.add(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION);
        recTypeList.add(Constants.CASE_RECORD_TYPE_APP_FOR_CERT);
        recTypeList.add(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION);

        List<Case> existingCases = new List<Case>([Select id,ContactId,isClosed,Service__c,RecordType.DeveloperName,Case_Status__c from Case where ContactId=:contactId 
                                    and RecordType.DeveloperName IN :recTypeList]);

        if(existingCases.isEmpty()){
            return System.Label.Account_establishment_error_message;
        }
        for (Case thisCase: existingCases) {
            if (thisCase.Case_Status__c != Constants.CASE_STATUS_ACCOUNT_ESTABLISHED && thisCase.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION) {
                return System.Label.Account_establishment_error_message + '<br>';
            } else if (thisCase.isClosed == false && thisCase.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE) {
                return System.Label.Biographic_change_error_message + '<br>';
            } else if (thisCase.isClosed == true && thisCase.Case_Status__c != Constants.CASE_STATUS_REJECTED && thisCase.Case_Status__c != Constants.CASE_STATUS_EXPIRED && thisCase.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_APP_FOR_CERT) {
                return System.Label.App_for_cert_exists_error_message  + '<br>';
            } else if (thisCase.Case_Status__c != Constants.CASE_STATUS_PENDING_SUBMISSION && thisCase.Case_Status__c != Constants.CASE_STATUS_REJECTED && thisCase.Case_Status__c != Constants.CASE_STATUS_EXPIRED && thisCase.Case_Status__c != Constants.CASE_STATUS_CANCELLED && thisCase.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_APP_FOR_CERT) {
                return System.Label.App_for_cert_submitted_error_message + '<br>';
            }
        }
        return 'Success';

    }   

    /**
     * Created by Aslam
     * Method Name: getOFACCountryList
     * Purpose : Fetches the list of OFAC countries
     * Return Type : Map of OFAC Country Name String and OFAC object
     */
    public static Map < String, OFAC__c > getOFACCountryList() {
        Map < String, OFAC__c > ofacCountriesMap = new Map < String, OFAC__c > ();
        for (OFAC__c ofacCountry: [Select id, Country__c, Type__c, Description__c from OFAC__c]) {
            ofacCountriesMap.put(ofacCountry.Country__c, ofacCountry);
        }
        return ofacCountriesMap;
    }

    /**
     * Created by Aslam
     * Method Name: getContactId
     * Purpose : Get current user's contact id
     * Return Type : String
     */
    @AuraEnabled(cacheable = true)
    public static String getContactId() {
        String contactId = null;
        Id currentUser = UserInfo.getUserId();
        List < User > userList = new List < User > ([select contactId from User u where u.Id =: currentUser]);
        if (!userList.isEmpty()){
            contactId = userList[0].contactId;
        }
        return contactId;
    }

     /**
     * Created by Jofrin
     * Method Name: enableTranscriptLink
     * Purpose : Show Transcript request link
     * Return Type : String
     */
    @AuraEnabled(cacheable = true)
    public static String enableTranscriptLink() {
        string contactId = getContactId();
        List<Exam_Registration__c > examRegList = new List<Exam_Registration__c >([Select id, Applicant__c, case__c, EP_start_Date__c, EP_end_Date__c, Exam_taken_date__c, Exam_Status__c, Exam_Types__c from Exam_Registration__c where (Exam_Status__c != :constants.EXAM_REGISTRATION_EXAM_STATUS_NOSHOW and Exam_Status__c != '' and Exam_Status__c != null) AND Applicant__c = :contactId]);
        System.debug(examRegList);
        if (examRegList.size()>0){
            return 'true';
        }
        else{
            return 'false';
        }
    }
 /**
     * Created by Shaik
     * Method Name: enableUSMLETranscriptLink
     * Purpose : display eligibility message
     * Return Type : Contact
     */
    @AuraEnabled(cacheable=false)
    public static Contact enableUSMLETranscriptLink() {
        return [SELECT Id, USMLE_Transcript_Eligibility_Message__c, USMLE_Transcript_Eligible__c FROM Contact WHERE Id =:getContactId() LIMIT 1];
    }

    @AuraEnabled
    public static Contact checkUSMLTranscriptEligibility(String strContactId, map<String, String> mapContentData){
        try {
            Contact objCon = null;
            if(String.isNotBlank(strContactId)) {
                List<Exam_Registration__c> lstExamResult = [SELECT Id, Applicant__c, case__c, EP_start_Date__c, EP_end_Date__c, 
                                                            Exam_taken_date__c, Exam_Status__c, Exam_Types__c 
                                                            FROM Exam_Registration__c 
                                                            WHERE Exam_Status__c != null
                                                            AND Applicant__c = :strContactId];
                
                if(lstExamResult != null && !lstExamResult.isEmpty()) {
                    CibisRequestUtilityHandler.cibisPlatformEventPublish(new Map<String,Set<Id>>{Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT => new set<Id>{strContactId}});
                    objCon =  new Contact(Id = strContactId, USMLE_Transcript_Eligibility_Message__c = mapContentData.get('CIBIS_USMLE_TRANSCRIPT_ELIGIBLE_CHECK_MSG').stripHtmlTags());
                }
                else {
                    objCon =  new Contact(Id = strContactId, USMLE_Transcript_Eligibility_Message__c = mapContentData.get('CIBIS_USMLE_TRANSCRIPT_NOT_ELIGIBLE_MSG').stripHtmlTags());
                }
            }
            else {
                throw new AuraHandledException('Contact not exist please contact the admin!!');
            }

            if(objCon != null) {
                update objCon;
                return objCon;
            }
            else {
                return null;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Created by Jofrin
     * Method Name: transcriptLinkValidation
     * Purpose : Validation for Transcript request link
     * Return Type : String
     */
    @AuraEnabled(cacheable = false)
    public static String transcriptLinkValidation() {

        string currentContactId = getContactId();
        Contact applicantRec = new Contact();
        applicantRec = [Select id,NBME_Exam_Exists__c, Step_3_Exists__c from Contact where id =:currentContactId LIMIT 1];
        string validtionMsg = '';
        validtionMsg = checkValNonUSMLETranLink();
        if(validtionMsg == 'true'){
            validtionMsg = '';
        }
        if(applicantRec.Step_3_Exists__c == true){
            validtionMsg = validtionMsg + System.label.Transcript_Request_Link_Validation_Step3+ '<br>';
            return validtionMsg;
        }
        else if(applicantRec.NBME_Exam_Exists__c == true){
            validtionMsg = validtionMsg + System.label.Transcript_Request_Link_Validation_NBMEExam+ '<br>';
            return validtionMsg;
        }
        else{
            if(string.isNotEmpty(validtionMsg)){
                return validtionMsg;
            }
            return 'true';
        } 
    }

     /**
     * Created by Jofrin
     * Method Name: checkValidationUpdateMyAppClick
     * Purpose : Validation on clicking Update My Application button
     * Return Type : String
     */
    @AuraEnabled(cacheable = false)
    public static String checkValidationUpdateMyAppClick() {

        string currentContactId = getContactId();
        String contactMailingCountry = getContactCountry(currentContactId);
        Map < String, OFAC__c > ofacCountriesMap = getOFACCountryList();
        String validtionMsg ='';

        List<Case> existingCases = new List<Case>([Select id,ContactId,isClosed,Service__c,RecordType.DeveloperName,Case_Status__c from Case where ContactId=:currentContactId 
                                    and RecordType.DeveloperName =:Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE and Internal_Status__c != :Constants.CASE_STATUS_ACCEPTED and Internal_Status__c != :Constants.CASE_STATUS_REJECTED and Internal_Status__c != :Constants.CASE_STATUS_CANCELLED_BY_APPLICANT and Internal_Status__c != :Constants.CASE_STATUS_CANCELLED_BY_ECFMG]);

        if(!existingCases.isEmpty()){
            validtionMsg = 	System.Label.Biographic_change_error_message  + '<br>';
            return validtionMsg;
        }
        else if(!ofacCountriesMap.isEmpty() && ofacCountriesMap.containsKey(contactMailingCountry) && ofacCountriesMap.get(contactMailingCountry).type__c==System.Label.OFAC_NOT_ALLOWED){
            validtionMsg = System.Label.OFAC_Not_Allowed_Error_Message + '<br>';
            return validtionMsg;
        }
        return validtionMsg;
    }

  /**
     * Created by Jofrin
     * Method Name: checkValNonUSMLETranLink
     * Purpose : Validation on clicking nonUSMLETranscriptLink
     * Return Type : String
     */
    @AuraEnabled(cacheable = false)
    public static String checkValNonUSMLETranLink() {

        string currentContactId = getContactId();
        String contactMailingCountry = getContactCountry(currentContactId);
        Map < String, OFAC__c > ofacCountriesMap = getOFACCountryList();
        String validtionMsg ='';

        List<Case> existingCases = new List<Case>([Select id,ContactId,isClosed,Service__c,RecordType.DeveloperName,Case_Status__c from Case where ContactId=:currentContactId 
                                    and RecordType.DeveloperName =:Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE and Internal_Status__c != :Constants.CASE_STATUS_ACCEPTED and Internal_Status__c != :Constants.CASE_STATUS_REJECTED and Internal_Status__c != :Constants.CASE_STATUS_CANCELLED_BY_APPLICANT and Internal_Status__c != :Constants.CASE_STATUS_CANCELLED_BY_ECFMG]);

        if(!existingCases.isEmpty()){
            validtionMsg =  validtionMsg + System.Label.Biographic_change_error_message  + '<br>';
        }
        if(!ofacCountriesMap.isEmpty() && ofacCountriesMap.containsKey(contactMailingCountry) && ofacCountriesMap.get(contactMailingCountry).type__c==System.Label.OFAC_NOT_ALLOWED){
            validtionMsg = validtionMsg + System.Label.OFAC_Not_Allowed_Error_Message + '<br>';
        }
        if(string.isNotEmpty(validtionMsg)){
            return validtionMsg;
        }
        return 'true';
    }

}