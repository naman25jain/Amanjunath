/**Test classes to be included for this class
 * TimedResendsControllerTest
 * InvestigationCaseTriggerHandlerTest
 * DocumentsPrintControllerTest
 * ApplicantCommunityControllerTest
 * CibisEligbilityCheckflagDisableBatchTest
 * CibisRequestUtilityHandlerTest
 * CibisResponseUtilityHandlerTest
 * CibisUsmleTranscriptsHandlerTest
 * CibisUtilityTest
 * ECFMGTestFactoryTest
 * EPICRestReportsTest
 * CredentialVerificationTriggerHandlerTest
 * ContentManagerRecordsTest
 * ECFMGDefaultTestData_Test
 * Contact2AcctServiceTriggerTest
 * EligibilityPeriodTriggerHandlerTest
 * EntityUserRequestTriggerHandlerTest
 * ERASControllerTest
 * TaskTriggerTest
 * TranscriptShipmentHandlerTest
 */
public class ECFMGDefaultTestData {
    /**
    * Standard User
    **/
    public class SystemAdminUser extends ECFMGTestFactoryObject  {
 
        sObject defaults()
        {
            // Default user object
            User rec = new User();
            String orgId = UserInfo.getOrganizationId();
           
            // Default values
            rec.Alias = 'adminUsr';
            rec.UserName = rec.Alias + '@'+ orgId+'.anytest.com';
            rec.ProfileId = profileIdByName('Salesforce Admin');
 
            rec.Email = rec.Alias + '@any.test.com';
            rec.FirstName = 'Admin';
            rec.LastName = 'User';
 
            rec.EmailEncodingKey = EMAIL_ENCODING_KEY; // Context values taken from the Factory
            rec.LanguageLocaleKey = LANGUAGE_LOCALE_KEY;
            rec.LocaleSidKey = LOCALE_SID_KEY;
            rec.TimeZoneSidKey = TIMEZONE_SID_KEY;
 
            return (sObject) rec;
        }
 
        // Custom maker method allowing us to set the username based on any custom alias value provided
        // making it easier to identify records created
        public override sObject make(sObject sourceObject) {
 
            // get and merge defaults
            sObject rec = (sObject) defaults();
            sourceObject = mergeFields(rec, sourceObject);
 
            // Custom logic to Update the username based on Alias if it's not the same as the default
            if (((User)sourceObject).Alias!=null && ((User)sourceObject).username == ((User)rec).username) {
                String orgId = UserInfo.getOrganizationId();
                ((User)sourceObject).username = ((User)sourceObject).Alias + '@'+ orgId+'.anytest.com';
            }
 
            // Add to the Templates's list of records created and return the result for this record
            add(sourceObject);
 
            return (sObject) sourceObject;
        }
    }
   
    /*** Default Account Data ***/
    public class DefaultAccountData extends ECFMGTestFactoryObject {
       
                // Mandatory minimum default set up, returns an sObject, in this case a default Account for the Sales Cloud
        sObject defaults() {
 
            // Default object
            Account rec = new Account();
 
            // Default values
            rec.Name = 'A Customer Account';
            rec.ShippingStreet = 'Nr 1 Some Street';
            rec.ShippingPostalCode = '11111';
            rec.ShippingCity = 'A City';
            rec.BillingCountry = COUNTRY_NAME;
            rec.ShippingCountry = COUNTRY_NAME;
            return (sObject) rec;
        }
 
    }
 
    /*** Default Contact Data ***/
    public class DefaultContactData extends ECFMGTestFactoryObject {
 
        // Mandatory minimum default set up, returns an sObject, in this case a default Contact for the Sales Cloud
        sObject defaults() {
            // Default object
            Contact rec = new Contact();
 
            rec.FirstName = 'Uri';
            rec.LastName = 'Steck';
            rec.Email = 'thegreatest@climber.example.com';
           
            return (sObject) rec;
        }
    }
   
    /*** Default Opportunity Data ***/
    public class DefaultOpportunityData extends ECFMGTestFactoryObject {
 
        // Mandatory minimum default set up, returns an sObject, in this case a default OPPORTUNITY for the Sales Cloud
        sObject defaults() {
            // Default object
            Opportunity rec = new Opportunity();
 
            rec.Name = 'An Oppty';
            rec.StageName  = 'Analyse';
            rec.CloseDate = System.today() + 90;
           
            return (sObject) rec;
        }
    }
   
    /** Default Case Data **/
    public class DefaultCaseData extends ECFMGTestFactoryObject{
        sObject defaults() {
            // Default Case
            Case rec = new Case();
 
            rec.Subject  = 'Analyse';
            rec.Origin = 'Web';
            rec.isCibisTranReqInit__C = true;
            rec.Cibis_Transcript_Status__c = 'APP IRREGULAR;ECFMG;EXAM IRREGULAR;FSMB;NBME;SECR DOC;USMLE;';
           
            return (sObject) rec;
        }
    }
 
    /**
    * Business Objects: Complete Customer... etc.
    **/
    public class DefaultCustomer extends ECFMGTestFactoryObject {
 
        // Default can return null for complex objects, the make method is the key part
        sObject defaults() {
            return null;
        }
       
        // Custom override for the maker
        public override sObject make(sObject sourceObject) {
            // Create an account
            Account customerAccount = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, (Account)sourceObject);
 
            // We want some unique name for the child component emails etc. so strip the account name
            String cleanNameForRelatedRecords = customerAccount.name.replaceAll('[^a-zA-Z0-9]','');
 
            // Create contacts for the account and add them to the factory
            Integer contactsToCreate = 2;
            for (Integer i = 0; i<contactsToCreate; i++) {
                String contactFirstName = customerAccount.name;
                String contactUniqueEmail = cleanNameForRelatedRecords+'_'+i+'@donotsend.example.com';
                ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(Account = customerAccount, FirstName = contactFirstName, LastName = 'Contact '+i, Email = contactUniqueEmail));
            }
 
            // Create opportunties for the account and add them to the factory
            Integer opptysToCreate = 2;
            for (Integer i = 0; i<opptysToCreate; i++) {
                ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultOpportunityData.class, new Opportunity(Account = customerAccount, Name = customerAccount.name +' Test Oppty '+i));
            }
 
            // Return the passed Account object as a root reference
            return (sObject) customerAccount;
        }
    }
 
    /*** Default Assest Data ***/
    public class DefaultAssest extends ECFMGTestFactoryObject {
        sObject defaults() {
            // Default object
            Asset rec = new Asset();
 
            // Default values
            rec.Name = 'A Wind Turbine';
 
            return (sObject) rec;
        }
    }
    //*/
 
    /** Default Cibis_Entity_Search_Response_Event Data */
    public class CibisEntitySearchResponseEventTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Cibis_Entity_Search_Response_Event__e evt = new Cibis_Entity_Search_Response_Event__e();
            evt.Date_Time__c = Datetime.now();
            evt.Error_Description__c = 'Error occured';
            evt.Exception__c = 'Fatal Error';
            evt.Source__c = 'CIBIS';
            return (sObject) evt;
        }
    }
 
    /** Default Contact Manager  */
    public class DefaultContactManagerTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Content_Manager__c cm = new Content_Manager__c();
            cm.Name = 'CIBIS Contact Email';
            cm.Subject__c = 'Test Email';
            cm.Content__c = 'Test Content Email';
            return (sObject) cm;
        }
    }
 
    /** Default Contact Manager  */
    public class DefaultProductTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Product2 pd = new Product2();
            pd.Name = 'ID Form';
            return (sObject) pd;
        }
    }
 
    /** Default Exam Registration Data  */
    public class DefaultExamRegistrationTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Exam_Registration__c em = new Exam_Registration__c();
            em.Exam_Status__c = 'Pass';
            em.Exam_Types__c = 'USMLE Step 1';
            return (sObject) em;
        }
    }
 
    /** Default Contact Association Data  */
    public class DefaultContactAssociationTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Contact_Association_Type__c cat = new Contact_Association_Type__c();
            cat.Start_Year__c = '2019';
            cat.End_Year__c = '2021';
            cat.Start_Month__c = 'January';
            cat.End_Month__c = 'December';
            return (sObject) cat;
        }
    }
    /** Default Contact Association Type Staging Data  */
    public class DefaultContactAssociationStagingTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Contact_Association_Type_Staging__c cat = new Contact_Association_Type_Staging__c();
            cat.Start_Year__c = '2019';
            cat.End_Year__c = '2021';
            cat.Start_Month__c = 'January';
            cat.End_Month__c = 'December';
            return (sObject) cat;
        }
    }
   
    /** Default Transcript Annotation Data  */
    public class DefaultTranscriptAnnotationTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Transcript_Anotation__c ta = new Transcript_Anotation__c();
            return (sObject) ta;
        }
    }

    /** Default Case Line Data  */
    public class DefaultCaseLineTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Case_Line__c cline = new Case_Line__c();
            return (sObject) cline;
        }
    }

    /** Default Transcript Request Data  */
    public class DefaultTranscriptRequestTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Transcript_Request__c treq = new Transcript_Request__c();
            treq.Name_of_Recipient__c = 'Test User'; 
            treq.Organization__c = 'Test Organisation'; 
            treq.Send_to_Same_Address__c = true; 
            treq.Send_to_Self__c = true;
            treq.City__c = 'Street 123'; 
            treq.Country__c = 'United States'; 
            treq.State__c = 'California';
            treq.Street__c = 'Adyar Main Road';
            treq.Zip_Postal_Code__c = '123456';
            return (sObject) treq;
        }
    }
   
    /** Default Asset Data  */
    public class DefaultAssestTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Asset ast = new Asset();
            ast.Type__c = 'Final Medical Diploma';
            return (sObject) ast;
        }
    }
   
    /** Default Asset Verification Data  */
    public class DefaultAssestVerficationTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Asset2Verification__c astVerify = new Asset2Verification__c();
            return (sObject) astVerify;
        }
    }
   
    /** Default Verification Packet Data  */
    public class DefaultVerificationPacketTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Verification_Packet__c vPacket = new Verification_Packet__c();
            vPacket.Is_Active__c = true;
            return (sObject) vPacket;
        }
    }
    /** Default Content Version Data  */
    public class DefaultContentVersionTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
           ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.PathOnClient = 'Score Recheck Letter' + '.pdf';
            cv.Title = 'Score Recheck Letter';
            return (sObject) cv;
        }
    }
   
    /** Default Content Document Link Data  */
    public class DefaultContentDocumentLinkTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.shareType = 'V';
            return (sObject) cdl;
        }
    }
   
    /** Default Content Manager Annotation Data  */
    public class DefaultContentManagerTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Content_Manager__c cm = new Content_Manager__c();
            return (sObject) cm;
        }
    }

    /** Default Case Data **/
    public class DefaultDocConfigData extends ECFMGTestFactoryObject{
        sObject defaults() {
            // Default doc config
            cadmus_core__Doc_Config__c rec = new cadmus_core__Doc_Config__c();            
            return (sObject) rec;
        }
    }
    /** Default AffirmationTest Data  */
    public class DefaultAffirmationTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
           Affirmation__c affr = new Affirmation__c();
            return (sObject) affr;
        }
    }
    /** Default Case Data **/
    public class DefaultAssetData extends ECFMGTestFactoryObject{
        sObject defaults(){
            // Default Case
            Asset rec = new Asset(); 
            rec.name  = 'Final Medical Diploma';
            rec.type__c  = 'Final Medical Diploma';
            rec.Status  = 'In Progress';           
            return (sObject) rec;
        }
    } 
    /** Default Service Data  */
    public class DefaultServiceTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Service__c ser = new Service__c();
            return (sObject) ser;
        }
    }
     /** Default Case2Service Data  */
     public class DefaultCase2ServiceTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Case2Service__c case2Ser = new Case2Service__c();
            return (sObject) case2Ser;
        }
    }
    /** Default Account2Service Data  */
    public class DefaultAccount2ServiceTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Account2Service__c case2Ser = new Account2Service__c();
            return (sObject) case2Ser;
        }
    }
    /** Default OFAC Data  */
    public class DefaultOfacTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            OFAC__c ofac = new OFAC__c(Country__c='Albania', Type__c=System.Label.OFAC_NOT_ALLOWED);
            return (sObject) ofac;
        }
    }         
    /** Default Task Data  */
    public class DefaultTaskTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Task tsk = new Task();
            return (sObject) tsk;
        }
    }
    /** Default Send Request  */
    public class DefaultSendRequestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Send_Request__c sendReq = new Send_Request__c();
            return (sObject) sendReq;
        }
    }
    /** Default Contact2AccountService  */
    public class DefaultContact2AccSerData extends ECFMGTestFactoryObject {
        sObject defaults(){
            CONTACT2ACCTSERVICE__c cont2AccSer = new CONTACT2ACCTSERVICE__c();
            return (sObject) cont2AccSer;
        }
    }
    /** Default Eligibility Period Data */
    public class DefaultEPTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Eligibility_Period__c epRecord = new Eligibility_Period__c();
            return (sObject) epRecord;
        }
    }
    /** Default user Data  */
    public class DefaultUserTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            user usr = new user();
            return (sObject) usr;
        }
    }
    /** Default Transfer Credit Data  */
    public class DefaultTransferCreditTestData extends ECFMGTestFactoryObject {
        sObject defaults(){
            Transfer_Credit__c tc = new Transfer_Credit__c();
            return (sObject) tc;
        }
    }
}