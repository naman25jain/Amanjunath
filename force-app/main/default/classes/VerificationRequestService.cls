/**
 * Created by Matthew on 2019-06-07.
 */
public with sharing class VerificationRequestService{
    private final static String UNEXPECTED_ERROR = 'An unexpected error occurred in the service layer class, VerificationRequestService.';
    /*
        Returns the verification request specified by verification request id. If not found, returns null.
     */
    public static Verification_Request__c getVerificationRequest(String id){
        if(id == null) {throw new InvalidParameterException('Id cannot be null. Perhaps the case is missing the verification request.');}
        if(String.isEmpty(id)) {throw new InvalidParameterException('Id cannot be empty. Perhaps the case is missing the verification request.');}
        List<Verification_Request__c> req =
        [SELECT
                Account_Exact_Scenario_Score__c,
                Account_Non_Exact_Scenario_Score__c,
                Account_Type__c,
                Phone__c,
                Parent_Affiliation__c,
                Batch_Id__c,
                Birth_Country__c,
                Birth_Date__c,
                Candidate_Code__c,
                Client_Batch_Create_Date__c,
                Client_Institution_ID__c,
                Client_Provided_Entity_ID__c,
                Client_Provided_Entity_Name__c,
                Comments__c,
                Contact_Exact_Scenario_Score__c,
                Contact_Non_Exact_Scenario_Score__c,
                CreatedById,
                CreatedDate,
                Current_Citizenship__c,
                Degree_Granting_Medical_School__c,
                EICS_ID__c,
                EPIC_ID__c,
                ECFMG_Id__c,
                Exact_Match_Account__c,
                Exact_Match_Contact__c,
                Gender__c,
                Generational_Suffix__c,
                Graduation_Date__c,
                Graduation_Year__c,
                Id,
                Institution_Address__c,
                Institution_City__c,
                Institution_Country_Code__c,
                Institution_ID__c,
                Institution_Name__c,
                Institution_Postal_Code__c,
                Institution_State_Code__c,
                Is_EICS__c,
                Is_EPIC__c,
                Is_USMLE__c,
                IsDeleted,
                Last_Name__c,
                LastModifiedById,
                LastModifiedDate,
                LastReferencedDate,
                LastViewedDate,
                Medschool_Code__c,
                Medschool_Name__c,
                Medical_School_Student_ID__c,
                Name,
                OwnerId,
                Previous_Last_Name__c,
                Previous_Rest_of_Name__c,
                Request_Id__c,
                Request_Type__c,
                Residence_Country__c,
                Rest_of_Name__c,
                Sender__c,
                Status__c,
                SystemModstamp,
                University_Code__c,
                University_Name__c,
                Urgent__c,
                USMLE_ID__c,
                Email__c,
                Graduation_Month__c,
                Eligibility_Case_ID__c,
                Registration_ID__c,
                Medical_School_Degree__c,
                Middle_Name__c
        FROM Verification_Request__c
        WHERE Id = :Id WITH SECURITY_ENFORCED];
        if(req.size() == 0){return null;}
        return req[0];
    }
    /*
        Returns the verification request files specified by verification request id. Returns empty list .
     */
    public static List<Verification_Request_File__c> getVerificationRequestFiles(String verificationRequestId){
        if(verificationRequestId == null) { throw new InvalidParameterException('verificationRequestId cannot be null');}
        if(String.isEmpty(verificationRequestId)) { throw new InvalidParameterException('verificationRequestId cannot be empty');}
        List<Verification_Request_File__c> req =
        [SELECT
                Comment__c,
                CreatedById,
                CreatedDate,
                Document_Issue_Date__c,
                Document_Name__c,
                Document_Number__c,
                Document_Type__c,
                Embedded__c,
                File_Name__c,
                Id,
                IsDeleted,
                LastModifiedById,
                LastModifiedDate,
                LastReferencedDate,
                LastViewedDate,
                Name,
                Name_On_Document__c,
                Page_Count__c,
                Status__c,
                SystemModstamp,
                Verification_Request__c,
                Verification_Request_Status__c,
                Azure_Storage_URL__c
        FROM
                Verification_Request_File__c
        WHERE
                Verification_Request__c = :verificationRequestId WITH SECURITY_ENFORCED];
        return req;
    }
    /*
        Creates assets from the verification request files on associated with the verification request.
        Also, link files from the verification request file to the the corresponding asset.
     */
    public static void createAssetsFromVerificationRequestFiles(String verificationRequestId){
        if(verificationRequestId == null) {throw new InvalidParameterException('verificationRequestId cannot be null');}
        if(String.isEmpty(verificationRequestId)) {throw new InvalidParameterException('verificationRequestId cannot be empty');}
        case cse;
        // for IFOM case, case is queried by caseId(verificationRequest) instead of verificationRequest Id #Bug20591
        if(getSobjectType(verificationRequestId) == 'Case'){
            cse = CaseService.getCase(verificationRequestId);
            verificationRequestId = cse.Verification_Request__c;
            if(cse == null){
                throw new ServiceException('Could not find the IFOM case');
            }
        }else{
            cse = CaseService.getCasebyVerificationIdAndRecordType(verificationRequestId, Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION);
            if(cse == null){
                cse = CaseService.getCasebyVerificationIdAndRecordType(verificationRequestId, Constants.CASE_RECORD_TYPE_FCVS_REQUEST);
                if (cse == null){
                    throw new ServiceException('Could not find the credential verification case or there is more than one credential verification case associated with this verification request.');
                }
            }
        }
        String catId; 
        string catsId; 
        Contact_Association_Type__c contactAssociationType; 
        Contact_Association_Type_Staging__c contactAssotionTypeStaging; 
        List<Contact_Association_Type__c> lstContatAssocTypes = ContactAssociationTypeService.getContatAssocTypesByCaseId(cse.Id); 
        List<Contact_Association_Type_Staging__c> lstContactAssocTypeStagings =   getContatAssocTypeStagingByCaseId(cse.Id); 
        if (lstContatAssocTypes.size()>0){
            catId = lstContatAssocTypes[0].Id; 
            contactAssociationType  =lstContatAssocTypes[0];         
        }
        if (lstContactAssocTypeStagings.size()>0){
            catsId = lstContactAssocTypeStagings[0].Id; 
            contactAssotionTypeStaging  =lstContactAssocTypeStagings[0];         
        }        
        List<Verification_Request_File__c> vrfs = getVerificationRequestFiles(verificationRequestId);
        if(vrfs.size() == 0) {return;}
        List<Asset_Mapping__mdt> assetMappings = [select File_Document_Type__c, Asset_Name__c, Asset_Record_Type_Name__c, Product_Code__c, Asset_Status__c, Case_Document_Type__c, Asset_Type__c from Asset_Mapping__mdt WITH SECURITY_ENFORCED];
        if(assetMappings.size() == 0){
            throw new ServiceException('Asset Mapping custom metadata now defined.');
        }
        List<RecordType> assetRecordTypes = [select Id, Name from RecordType where SobjectType = 'Asset' and (Name = :Constants.ASSET_RECORD_TYPE_IDENTITY or Name = :Constants.ASSET_RECORD_TYPE_CREDENTIAL) WITH SECURITY_ENFORCED];
        Map<String, String> assetRecordTypeNameToIdMap = new  Map<String, String>();
        for(RecordType rt : assetRecordTypes){
            assetRecordTypeNameToIdMap.put(rt.Name, rt.Id);
        }
        List<String> productCodes = new List<String>();
        Map<String, String> documentTypeToAssetNameMap = new Map<String, String>();
        Map<String, String> documentTypeToProductCodeMap = new Map<String, String>();
        Map<String, String> documentTypeToRecordTypeIdMap = new Map<String, String>();
        Map<String, String> documentTypeToCaseDocumentTypeMap = new Map<String, String>();
        Map<String, String> documentTypeToAssetStatusMap = new Map<String, String>(); 
        Map<String, String> documentTypeToAssetTypeMap = new Map<String, String>(); 

        for(Asset_Mapping__mdt am : assetMappings){
            productCodes.add(am.Product_Code__c);
            documentTypeToAssetNameMap.put(am.File_Document_Type__c, am.Asset_Name__c);
            documentTypeToProductCodeMap.put(am.File_Document_Type__c, am.Product_Code__c);
            documentTypeToRecordTypeIdMap.put(am.File_Document_Type__c, assetRecordTypeNameToIdMap.get(am.Asset_Record_Type_Name__c));
            documentTypeToCaseDocumentTypeMap.put(am.File_Document_Type__c, am.Case_Document_Type__c);
            documentTypeToAssetStatusMap.put(am.File_Document_Type__c, am.Asset_Status__c);  
            documentTypeToAssetTypeMap.put(am.File_Document_Type__c,am.Asset_Type__c); 
        }
        List<Product2> products = [select Id, ProductCode from Product2 where ProductCode in :productCodes WITH SECURITY_ENFORCED];
        Map<String, String> productCodeToIdMap = new Map<String, String>();
        for(Product2 prod : products){
            productCodeToIdMap.put(prod.ProductCode, prod.Id);
        }
        Map<String, String> documentTypeToProductIdMap = new Map<String, String>();
        for(Asset_Mapping__mdt am : assetMappings){
            documentTypeToProductIdMap.put(am.File_Document_Type__c, productCodeToIdMap.get(am.Product_Code__c));
        }        
        List<Verification_Request_File__c> lstVerReqFiles = new List<Verification_Request_File__c>();
        List<Asset> assets = new List<Asset>();                
        string transcaseDocType;
        String docSelectedByApplicant;         
        boolean isAssetNameNeedsUpdate = false; 
        try{
            for(Verification_Request_File__c vrf : vrfs){
                
                String caseDocType = documentTypeToCaseDocumentTypeMap.get(vrf.Document_Type__c);                
                if (!string.isBlank(caseDocType)){
                    transcaseDocType = caseDocType;                      
                }                               
                vrf.Status__c =  Constants.VERIFICATION_REQUEST_FILE_STATUS_PROCESSED; 
                lstVerReqFiles.add(vrf);
                Asset aAsset = new Asset(
                    Name =  documentTypeToAssetNameMap.get(vrf.Document_Type__c),
                    Type__c = documentTypeToAssetTypeMap.get(vrf.Document_Type__c),
                    Status = documentTypeToAssetStatusMap.get(vrf.Document_Type__c),
                    Product2Id = documentTypeToProductIdMap.get(vrf.Document_Type__c),
                    AccountId = cse.AccountId,
                    ContactId = cse.ContactId,
                    Case__c = cse.Id,
                    InstallDate = Datetime.now().dateGmt(),
                    RecordTypeId = documentTypeToRecordTypeIdMap.get(vrf.Document_Type__c),                                                
                    Azure_Storage_URL__c = vrf.Azure_Storage_URL__c, 
                    Name_on_Document__c = vrf.Name_On_Document__c,
                    Contact_Association_Type__c =  catId,
                    Contact_Association_Type_Staging__c = catsId, 
                    Source_Document__c =  isSourceDocument(documentTypeToAssetNameMap.get(vrf.Document_Type__c))                       
                    ); 
                assets.add(aAsset);  
                
                if  (vrf.Document_Type__c == 'TRANS') {                    
                    isAssetNameNeedsUpdate = true; 
                }               
                if (!string.isBlank(caseDocType)){                    
                    docSelectedByApplicant =   getDocSelectedByApplicant(caseDocType);                       
                    cse.document_type__c = caseDocType;                      
                    cse.Document_type_selected_by_applicant__c = docSelectedByApplicant;   
                }     
            }
        }
        catch(Exception ex){
            throw new ServiceException('It would seem there is a missing mapping whilst creating an asset. Here are the technical details: ' + ex.getStackTraceString());
        }
        if (Schema.sObjectType.Asset.isCreateable()){
            insert assets;            
        }
        if (Schema.sObjectType.Asset.isUpdateable()){
            If (isAssetNameNeedsUpdate){
                for(Asset a :assets){
                    if (a.Type__c == 'Translation'){
                        a.Name = transcaseDocType + ' - Translation'; 
                    }
                }
                update assets; 
            }
        }        
        if (Schema.sObjectType.Case.isUpdateable()){
            update cse; 
        }    

        if (Schema.sObjectType.Contact_Association_Type__c.isUpdateable()){
            if (contactAssociationType != null){
                contactAssociationType.Credential_Type__c = docSelectedByApplicant; 
                update contactAssociationType;
            } 
        }
        if (Schema.sObjectType.Contact_Association_Type_Staging__c.isUpdateable()){
            if (contactAssociationType != null){
                contactAssotionTypeStaging.Credential_Type__c = docSelectedByApplicant; 
                update contactAssotionTypeStaging;
            } 
        }
        if (Schema.sObjectType.Verification_Request_File__c.isUpdateable()){
            update lstVerReqFiles; 
        }

    }
    /**
    * @name createContactAssociationTypes
    * @description: Create Contact Association Type record
    * @param List<String> caseIds
    * @return void
    **/
    public static void createContactAssociationTypes(List<String> caseIds){        
        List<Contact_Association_Type__c> newConAssociationTypeList = new List<Contact_Association_Type__c>();
        Set<String> contactSet = new Set<String>();
        Set<String> contactUniqueSet = new Set<String>();
        Set<Id> conAscTypeConSet = new Set<Id>();
        Id caseCredentialVerificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();             
        Id caseIFOMRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IFOM_REQUEST).getRecordTypeId();
        try{
            List<Case_Attribute__c> caseAttrList = [SELECT Id, Name, Case__r.ContactId, Value__c,
                    Case__r.Verification_Request__r.Graduation_Date__c, Case__r.Verification_Request__r.Graduation_Year__c,
                    Case__r.Verification_Request__r.Medical_School_Degree__c, Case__r.Verification_Request__r.Graduation_Month__c,
                    Case__r.Verification_Request__r.Medical_School_Student_ID__c, Case__r.RecordTypeId, Case__r.Document_type_selected_by_applicant__c, Case__c
            FROM Case_Attribute__c
            WHERE Case__c IN : caseIds
            AND Name =: Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME
            WITH SECURITY_ENFORCED
            ORDER BY Case__c];
            // loop through the case attribute records to get the account id and other details
            // assuming one to one mapping b/w verification request, case, case attribute (LINKED_ENTITY_ID) and contact            
            for(Case_Attribute__c itr:caseAttrList){
                contactSet.add(itr.Case__r.ContactId);                
            }
            List<Contact_Association_Type__c> conAssociationTypeList = [SELECT Id, Contact__c
                                                                FROM Contact_Association_Type__c
                                                                WHERE Contact__c IN: contactSet
                                                                AND Type__c=:Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL
                                                                AND RecordTypeId=:Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId()];            
            for(Contact_Association_Type__c itr:conAssociationTypeList){
                conAscTypeConSet.add(itr.Contact__c);
            }
            // loop through the case attribute records to get the account id and other details
            // assuming one to one mapping b/w verification request, case, case attribute (LINKED_ENTITY_ID) and contact
            for(Case_Attribute__c itr:caseAttrList)
            {   
                if (!string.isBlank(itr.Case__r.ContactId)){                       
                string selectedDocType =  getDocSelectedByApplicant(itr.Case__r.Document_type_selected_by_applicant__c); 
                    if((itr.Case__r.RecordTypeId == caseCredentialVerificationRecordTypeId) || (itr.Case__r.RecordTypeId == Constants.MEDEDUFORMID) ) {
                        
                        newConAssociationTypeList.add(new Contact_Association_Type__c(Account__c=itr.value__c, Contact__c=itr.Case__r.ContactId,
                        RecordTypeId=Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId(),
                        Degree_Issue_Date__c= itr.Case__r.Verification_Request__r.Graduation_Date__c,
                        Graduation_Year__c = itr.Case__r.Verification_Request__r.Graduation_Year__c,
                        Type__c=Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL,  
                        Credential_Type__c = selectedDocType,                                              
                        Case__c = itr.Case__c));
                        
                    }
                    else if(itr.Case__r.RecordTypeId == caseIFOMRequestRecordTypeId){
                        newConAssociationTypeList.add(new Contact_Association_Type__c(Account__c=itr.value__c, Contact__c=itr.Case__r.ContactId,
                        RecordTypeId=RecordTypeUtility.getRecordTypeIdByName('Contact_Association_Type__c', Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MED_SCHOOL),
                        Graduation_Month__c = getMonthAsText(itr.Case__r.Verification_Request__r.Graduation_Month__c),
                        Graduation_Year__c = itr.Case__r.Verification_Request__r.Graduation_Year__c,
                        Degree_Title__c = itr.Case__r.Verification_Request__r.Medical_School_Degree__c,
                        Student_ID__c = itr.Case__r.Verification_Request__r.Medical_School_Student_ID__c));
                    }
                }                
            }
            If (Schema.sObjectType.Contact_Association_Type__c.isCreateable()){
                insert newConAssociationTypeList;    
            }        
        }
        catch(Exception exp){
            throw new ServiceException(Label.SystemError+' '+exp);
        }
    }
     /**
    * @name createCATS
    * @description: Create Contact Association Type staging record
    * @param List<String> caseIds
    * @return void
    **/
    public static void createCATS(List<String> caseIds){        
        List<Contact_Association_Type_Staging__c> newCATSList = new List<Contact_Association_Type_Staging__c>();
        Set<String> contactSet = new Set<String>();
        Set<String> contactUniqueSet = new Set<String>();
        Set<Id> conAscTypeStagingConSet = new Set<Id>();
        Id caseCredentialVerificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();             
        Id caseIFOMRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IFOM_REQUEST).getRecordTypeId();
        Id catsRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId(); 
        try{
            List<Case_Attribute__c> caseAttrList = [SELECT Id, Name, Case__r.ContactId, Value__c,
                    Case__r.Verification_Request__r.Graduation_Date__c, Case__r.Verification_Request__r.Graduation_Year__c,
                    Case__r.Verification_Request__r.Medical_School_Degree__c, Case__r.Verification_Request__r.Graduation_Month__c,
                    Case__r.Verification_Request__r.Medical_School_Student_ID__c, Case__r.RecordTypeId, Case__r.Document_type_selected_by_applicant__c, Case__c
            FROM Case_Attribute__c
            WHERE Case__c IN : caseIds
            AND Name =: Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME
            WITH SECURITY_ENFORCED
            ORDER BY Case__c];
      
            // loop through the case attribute records to get the account id and other details
            // assuming one to one mapping b/w verification request, case, case attribute (LINKED_ENTITY_ID) and contact
            for(Case_Attribute__c itr:caseAttrList)
            {   
                if (!string.isBlank(itr.Case__r.ContactId)){                       
                string selectedDocType =  getDocSelectedByApplicant(itr.Case__r.Document_type_selected_by_applicant__c); 
                    if((itr.Case__r.RecordTypeId == caseCredentialVerificationRecordTypeId) || (itr.Case__r.RecordTypeId == Constants.MEDEDUFORMID) ) {
                        
                        newCATSList.add(new Contact_Association_Type_Staging__c(Account__c=itr.value__c, Contact__c=itr.Case__r.ContactId,
                                        RecordTypeId=Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId(),
                                        Degree_Issue_Date__c= itr.Case__r.Verification_Request__r.Graduation_Date__c,
                                        Graduation_Year__c = itr.Case__r.Verification_Request__r.Graduation_Year__c,
                                        Type__c=Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL,  
                                        Credential_Type__c = selectedDocType,                                              
                                        Case__c = itr.Case__c));
                        
                    }
                    else if(itr.Case__r.RecordTypeId == caseIFOMRequestRecordTypeId){
                        newCATSList.add(new Contact_Association_Type_Staging__c(Account__c=itr.value__c, Contact__c=itr.Case__r.ContactId,
                                        RecordTypeId=RecordTypeUtility.getRecordTypeIdByName('Contact_Association_Type_Staging__c', Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MED_SCHOOL),
                                        Graduation_Month__c = getMonthAsText(itr.Case__r.Verification_Request__r.Graduation_Month__c),
                                        Graduation_Year__c = itr.Case__r.Verification_Request__r.Graduation_Year__c,
                                        Degree_Title__c = itr.Case__r.Verification_Request__r.Medical_School_Degree__c,
                                        Student_ID__c = itr.Case__r.Verification_Request__r.Medical_School_Student_ID__c));
                    }
                }                
            }
            if (Schema.SObjectType.Contact_Association_Type_Staging__c.isCreateable()){
                insert newCATSList; 
            }          
        }
        catch(Exception exp){            
            throw new ServiceException(Label.SystemError+' '+exp);
        }
    }

    public static List<Contact_Association_Type_Staging__c> getContatAssocTypeStagingByCaseId (String caseId){

        List<Contact_Association_Type_Staging__c> lstCATS = [SELECT Id FROM Contact_Association_Type_Staging__c where Case__c =: caseId WITH SECURITY_ENFORCED]; 
        return lstCATS; 
    }

    // Create Contact Association Type record
    public static String getMonthAsText(Decimal monthAsDec){
        Integer monthAsInt = Integer.valueOf(monthAsDec);
        Map<Integer,String> monthMap = new Map<Integer,String>();
        monthMap.put(1,'January');
        monthMap.put(2,'February');
        monthMap.put(3,'March');
        monthMap.put(4,'April');
        monthMap.put(5,'May');
        monthMap.put(6,'June');
        monthMap.put(7,'July');
        monthMap.put(8,'August');
        monthMap.put(9,'September');
        monthMap.put(10,'October');
        monthMap.put(11,'November');
        monthMap.put(12,'December');
        return monthMap.get(monthAsInt);
    }

    public static boolean isSourceDocument(string docType){
        switch on  docType {
            when  'Photo', 'Release','Translation'  {
                return false; 
            }
            when else {
                return true; 
            }
        }
    }

    public static string getDocSelectedByApplicant(string docType){
        String docSelectedbyApplicant; 
        if (docType==Constants.CASE_DOC_TYPE_PREGRADUATE_INTERNSHIP_CREDENTIAL){
            docSelectedbyApplicant = Constants.CASE_APP_SELECTED_DOC_TYPE_PREGRADUATE_INTERNSHIP_CERTIFICATE; 
        }else if (docType==Constants.CASE_DOC_TYPE_POSTGRADUATE_MEDICAL_EDUCATION_CREDENTIAL){
            docSelectedbyApplicant = Constants.CASE_APP_SELECTED_DOC_TYPE_POSTGRADUATE_TRAINING_CREDENTIAL; 
        }else if (docType == Constants.CASE_DOC_TYPE_MEDICAL_SCHOOL_FORM){
            docSelectedbyApplicant = Constants.CONASCTYPE_CRED_TYPES_MED_REG_CERT_LIC_PRAC_MED;
        }else {
            docSelectedbyApplicant = docType; 
        }
        return docSelectedbyApplicant; 
    }
    public static String getSobjectType(String recordId){
        Id currentId = recordId;
        Schema.SObjectType sobjectType = currentId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        return sobjectName;
    }
}