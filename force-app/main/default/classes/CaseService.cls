/*
    Provides service layer functionality related to Cases.
 */
public class CaseService{
    private final static String UNEXPECTED_ERROR = 'An unexpected error occurred in the service layer class, CaseService.';
    /*
        Mass updates the status of a case's assets and affirmations in a bulkified manner. This method can update
        affirmations independent of updating assets.
        Must pass in a caseId, and at least one of assetStatus or affirmationStatus.
     */
    public static void massUpdateCaseAssetsAndAffirmations(String caseId, String assetStatus, String affirmationStatus){
        if(caseId == null || caseId == '') throw new InvalidParameterException('Must provide a case id.');
        if(assetStatus == null && affirmationStatus == null) throw new InvalidParameterException('Must provide either an assetStatus, affirmationStatus, or both.');
        Case c = [select Id from Case where Id = :caseId];
        if(c == null) throw new InvalidParameterException('Could not find case with id ' + caseId);
        try{
            // only update assets if assetStatus is provided, but record assetId for use with affirmations
            List<Asset> assets = [select Id, Status from Asset where Case__c = :caseId  AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION];
            List<String> assetIds = new List<String>();
            for(Asset ass : assets){
                if(assetStatus!=null) ass.Status = assetStatus;
                assetIds.add(ass.Id);
            }
            if(assetStatus!=null) update assets;
            if(affirmationStatus!=null){
                List<Affirmation__c> affirmations = [select Id, Status__c from Affirmation__c where Asset__c in :assetIds];
                for (Affirmation__c aff : affirmations){
                    aff.Status__c = affirmationStatus;
                }
                update affirmations;
            }
        }catch (Exception ex){
            throw new ServiceException(UNEXPECTED_ERROR, ex);
        }
    }
    /*
        Returns the Case specified by caseId. If not found, returns null.
     */
    public static Case getCase(String caseId){
        if(caseId == null) throw new InvalidParameterException('CaseId cannot be null');
        if(String.isEmpty(caseId)) throw new InvalidParameterException('CaseId cannot be empty');
        try{
            return [SELECT
                    AccountId,
                    Action_Required__c,
                    Applicant_Last_Submission_Date__c,
                    AssetId,
                    BusinessHoursId,
                    Case_Status__c,
                    CaseNumber,
                    ClosedDate,
                    Comments,
                    Contact.FirstName,
        			Contact.LastName,
                    ContactEmail,
                    ContactFax,
                    ContactId,
                    ContactMobile,
                    ContactPhone,
                    CreatedById,
                    CreatedDate,
                    Description,
                    Id,
                    IsClosed,
                    IsClosedOnCreate,
                    IsDeleted,
                    IsEscalated,
                    LastModifiedById,
                    LastModifiedDate,
                    LastReferencedDate,
                    LastViewedDate,
                    Origin,
                    OwnerId,
                    ParentId,
                    Payment_Made__c,
                    Priority,
                    Reason,
                    RecordTypeId,
                    Service__c,
                    SourceId,
                    Internal_Status__c,
                    Subject,
                    SuppliedCompany,
                    SuppliedEmail,
                    SuppliedName,
                    SuppliedPhone,
                    SystemModstamp,
                    Type,
                    ValidationPassed_AdditionalInformation__c,
                    ValidationPassed_Biographics__c,
                    Contact.Name,
                    Account.Name,
                    Verification_Request__c,
                    Entity__c,
                    recordType.DeveloperName
            FROM
                    Case
            WHERE Id = :caseId];
        }
        catch(Exception ex){
            return null;
        }
    }
    public static void updateCase(Case c){
        if(c == null) throw new ServiceException('Case argument cannot be null.');
        if(c.Id == null) throw new ServiceException('Case.Id cannot be null.');
        updateCase(new Case[] { c });
    }
    public static void updateCase(List<Case> cases){
        if(cases == null) throw new ServiceException('Cases argument cannot be null.');
        if(cases.size() == 0) throw new ServiceException('Cases size cannot be 0.');
        update cases;
    }
    /*
        Returns attribute value as String or null.
        All cases attribute names are unique per case, so only one value can be returned.
        If the case attribute cannot be found, method returns null.
     */
    public static String getCaseAttribute(String caseId, String name){
        List<Case_Attribute__c> attributes = [select Value__c from Case_Attribute__c where Case__c = :caseId and Name = :name];
        if(attributes.size() == 1){
            return attributes[0].Value__c;
        }
        return null;
    }
    /*
        Sets an attribute value.
        If no attribute by that name is found, creates it.
        If an attribute by that name is found, updates it.
     */
    public static void setCaseAttribute(String caseId, String name, String value){
        Map<String, Map<String, String>> attributeMap = createAttributeMap(caseId, name, value);
        setCaseAttributes(attributeMap);
    }
    /*
        Bulkified method to set case attribute(s). Each case id can have one or more case attributes. Case attributes
        are set via the following rules:
         - If no attribute by that name is found, creates it.
         - If an attribute by that name is found, updates it.

        attributeMap is defined as:
            Map<String(caseId), Map<String(name), String(value)>
     */
    public static void setCaseAttributes(Map<String, Map<String, String>> attributeMap){
        if(attributeMap == null) throw new ServiceException('AttributeMap argument cannot be null.');
        if(attributeMap.keySet().size() == 0) throw new ServiceException('AttributeMap keySet size cannot be 0.');
        List<Case_Attribute__c> toCreate = new List<Case_Attribute__c>();
        List<Case_Attribute__c> toUpdate = new List<Case_Attribute__c>();
		List<Case_Attribute__c> attributes = [select Case__c, Name, Value__c from Case_Attribute__c where Case__c IN :attributeMap.keySet() ORDER BY Case__c];
		Map<String, List<Case_Attribute__c>> caseToAttributesMap = new Map<String, List<Case_Attribute__c>>();
		String curCase = '';
		for(Case_Attribute__c ca : attributes){
			if(curCase == ''){
				curCase = ca.Case__c;
				caseToAttributesMap.put(curCase, new List<Case_Attribute__c>());
			}else if(curCase != ca.Case__c){
				curCase = ca.Case__c;
				caseToAttributesMap.put(curCase, new List<Case_Attribute__c>());
			}
			caseToAttributesMap.get(curCase).add(ca);
		}
        for(String caseId : attributeMap.keySet()){
            Map<String, String> nameValueMap = attributeMap.get(caseId);
            if(nameValueMap == null) throw new ServiceException('NameValueMap argument cannot be null.');
            if(nameValueMap.keySet().size() == 0) throw new ServiceException('NameValueMap keySet size cannot be 0.');
            for(String name : nameValueMap.keySet()){
                String value = nameValueMap.get(name);
                Boolean found = false;
                List<Case_Attribute__c> curCaseAttributes = caseToAttributesMap.get(caseId);
                if(curCaseAttributes != null && curCaseAttributes.size() > 0){
	                for(Case_Attribute__c ca : curCaseAttributes){
	                	if(name == ca.Name){
	                		found = true;
	                		ca.Value__c = value;
	                		toUpdate.add(ca);
	                		break;
	                	}
	                }
                }
                if(!found){
                    Case_Attribute__c attr = new Case_Attribute__c(
                            Case__c = caseId,
                            Name = name,
                            Value__c = value
                    );
                    toCreate.add(attr);
                }
            }
        }
        insert toCreate;
        update toUpdate;
    }
    /*
        Convenience method to create Attribute Map for bulkified operations.
     */
    public static Map<String, Map<String, String>> createAttributeMap(String caseId, String name, String value){
        if(caseId == null) throw new InvalidParameterException('CaseId cannot be null');
        if(String.isEmpty(caseId)) throw new InvalidParameterException('CaseId cannot be empty');
        if(name == null) throw new InvalidParameterException('Name cannot be null');
        if(String.isEmpty(name)) throw new InvalidParameterException('Name cannot be empty');
        if(value == null) throw new InvalidParameterException('Value cannot be null');
        if(String.isEmpty(value)) throw new InvalidParameterException('Value cannot be empty');
        Map<String, Map<String, String>> attributeMap = new Map<String, Map<String, String>>();
        Map<String, String> nameValueMap = new Map<String, String>();
        nameValueMap.put(name, value);
        attributeMap.put(caseId, nameValueMap);
        return attributeMap;
    }
    /*
        Convenience method to append to the Attribute Map.
     */
    public static Map<String, Map<String, String>> appendToAttributeMap(Map<String, Map<String, String>> attributeMap, String caseId, String name, String value){
        if(attributeMap == null) throw new InvalidParameterException('AttributeMap cannot be null');
        Map<String, Map<String, String>> newAttributeMap = createAttributeMap(caseId, name, value);
        attributeMap.put(caseId, newAttributeMap.get(caseId));
        return attributeMap;
    }
    /*
        Removes a single case attribute.
     */
    public static void removeCaseAttribute(String caseId, String name){
        if(caseId == null) throw new InvalidParameterException('CaseId cannot be null');
        if(String.isEmpty(caseId)) throw new InvalidParameterException('CaseId cannot be empty');
        if(name == null) throw new InvalidParameterException('Name cannot be null');
        if(String.isEmpty(name)) throw new InvalidParameterException('Name cannot be empty');
        Map<String, String> attributeMap = new Map<String, String>();
        attributeMap.put(caseId, name);
        removeCaseAttributes(attributeMap);
    }
    /*
        Bulkified method to remove multiple case attributes.
        attributeMap is defined as:
            Map<String(caseId), String(name)>

     */
    public static void removeCaseAttributes(Map<String, String> attributeMap){
        if(attributeMap == null) throw new ServiceException('AttributeMap argument cannot be null.');
        if(attributeMap.keySet().size() == 0) throw new ServiceException('AttributeMap keySet size cannot be 0.');
        List<Case_Attribute__c> attributeToDelete = new List<Case_Attribute__c>();
        List<Case_Attribute__c> caseAttributes = [select Id, Name, Case__c from Case_Attribute__c where Case__c in :attributeMap.keySet()];
        for(Case_Attribute__c attr : caseAttributes){
            if(attr.Name == attributeMap.get(attr.Case__c)) attributeToDelete.add(attr);
        }
        delete attributeToDelete;
    }
    /*
        Returns a collection of child cases of the specific parent case.
        If none are found, returns empty list.
     */
    public static List<Case> getChildCases(string parentCaseId){
        if(parentCaseId == null) throw new InvalidParameterException('ParentCaseId cannot be null');
        if(String.isEmpty(parentCaseId)) throw new InvalidParameterException('ParentCaseId cannot be empty');
        return [SELECT
                AccountId,
                Action_Required__c,
                Applicant_Last_Submission_Date__c,
                AssetId,
                BusinessHoursId,
                Case_Status__c,
                CaseNumber,
                ClosedDate,
                Comments,
                ContactEmail,
                ContactFax,
                ContactId,
                ContactMobile,
                ContactPhone,
                CreatedById,
                CreatedDate,
                Description,
                Id,
                IsClosed,
                IsClosedOnCreate,
                IsDeleted,
                IsEscalated,
                LastModifiedById,
                LastModifiedDate,
                LastReferencedDate,
                LastViewedDate,
                Origin,
                OwnerId,
                ParentId,
                Payment_Made__c,
                Priority,
                Reason,
                RecordTypeId,
                Service__c,
                SourceId,
                Internal_Status__c,
                Subject,
                SuppliedCompany,
                SuppliedEmail,
                SuppliedName,
                SuppliedPhone,
                SystemModstamp,
                Type,
                ValidationPassed_AdditionalInformation__c,
                ValidationPassed_Biographics__c,
                Contact.Name,
                Account.Name,
                Verification_Request__c
        FROM
                Case
        WHERE ParentId = :parentCaseId]; 
    }
    /*
        Return a single case by a verification request Id. If there are 0 or more than 1, will return null;
     */
    public static Case getCaseByVerificationRequestId(String verificationRequestId){
        if(verificationRequestId == null) throw new InvalidParameterException('verificationRequestId cannot be null');
        if(String.isEmpty(verificationRequestId)) throw new InvalidParameterException('verificationRequestId cannot be empty');
        List<Case> cases = [SELECT
                AccountId,
                Action_Required__c,
                Applicant_Last_Submission_Date__c,
                AssetId,
                BusinessHoursId,
                Case_Status__c,
                CaseNumber,
                ClosedDate,
                Comments,
                ContactEmail,
                ContactFax,
                ContactId,
                ContactMobile,
                ContactPhone,
                CreatedById,
                CreatedDate,
                Description,
                Id,
                IsClosed,
                IsClosedOnCreate,
                IsDeleted,
                IsEscalated,
                LastModifiedById,
                LastModifiedDate,
                LastReferencedDate,
                LastViewedDate,
                Origin,
                OwnerId,
                ParentId,
                Payment_Made__c,
                Priority,
                Reason,
                RecordTypeId,
                Service__c,
                SourceId,
                Internal_Status__c,
                Subject,
                SuppliedCompany,
                SuppliedEmail,
                SuppliedName,
                SuppliedPhone,
                SystemModstamp,
                Type,
                ValidationPassed_AdditionalInformation__c,
                ValidationPassed_Biographics__c,
                Contact.Name,
                Account.Name,
                Verification_Request__c
        FROM
                Case
        WHERE
        (RecordType.Name = :Constants.CASE_RECORD_TYPE_CREDENTIAL_REVIEW OR RecordType.DeveloperName = :Constants.CASE_RECORD_TYPE_IFOM_REQUEST) AND Verification_Request__c = :verificationRequestId];
        if(cases.size() == 1){
            return cases[0];
        }
        else{
            return null;
        }
    }

    public static Case getCasebyVerificationIdAndRecordType(Id verifId, string cseRecType){
        List<Case> lstCase; 

        if (Case.SObjectType.getDescribe().isSearchable()){
            lstCase = [SELECT AccountId,
                        Action_Required__c,
                        Applicant_Last_Submission_Date__c,
                        AssetId,
                        BusinessHoursId,
                        Case_Status__c,
                        CaseNumber,
                        ClosedDate,
                        Comments,
                        ContactEmail,
                        ContactFax,
                        ContactId,
                        ContactMobile,
                        ContactPhone,
                        CreatedById,
                        CreatedDate,
                        Description,
                        Id,
                        IsClosed,
                        IsClosedOnCreate,
                        IsDeleted,
                        IsEscalated,
                        LastModifiedById,
                        LastModifiedDate,
                        LastReferencedDate,
                        LastViewedDate,
                        Origin,
                        OwnerId,
                        ParentId,
                        Payment_Made__c,
                        Priority,
                        Reason,
                        RecordTypeId,
                        Service__c,
                        SourceId,
                        Internal_Status__c,
                        Subject,
                        SuppliedCompany,
                        SuppliedEmail,
                        SuppliedName,
                        SuppliedPhone,
                        SystemModstamp,
                        Type,
                        ValidationPassed_AdditionalInformation__c,
                        ValidationPassed_Biographics__c,
                        Contact.Name,
                        Account.Name,
                        Verification_Request__c,
                        (SELECT id FROM Contact_Association_Types__r)
                        FROM Case 
                        WHERE Verification_Request__c =: verifId 
                        AND RecordType.DeveloperName = :cseRecType];
        }
        if(lstCase.size() == 1){
            return lstCase[0];
        }
        else{
            return null;
        } 

    }
}