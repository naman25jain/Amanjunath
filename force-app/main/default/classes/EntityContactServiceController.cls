/**
 * Helper class for EntityContactServiceController Form
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   07-JUL-2020
 */
public with sharing class EntityContactServiceController {


    // get set of values of all the status not needed to display for entity
    public static Set<String> getCaseStatusesForDisplayEntity() {
        return new Set<String>{
                'Rejected'
        };
    }


    /* Purpose : Method to fetch Primary Entity in the Entity contact */
    @AuraEnabled(Cacheable = true)
    public static List<EntityContactServiceHelper.EntityConWrapper> getEntity(String conId) {
        List<EntityContactServiceHelper.EntityConWrapper> evWrapList = new List<EntityContactServiceHelper.EntityConWrapper>();
        List<Contact> contactList = new List<Contact>();
        if (Schema.SObjectType.Contact.isAccessible()) {
            contactList = [Select Id,AccountId,Account.Name,Name from Contact where Id = :conId WITH SECURITY_ENFORCED];
            if (!contactList.isEmpty()) {
                List<EntityContactServiceHelper.EntityOptionsWrapper> entityOptionList = new List<EntityContactServiceHelper.EntityOptionsWrapper>() ;
                Map<String, EntityContactServiceHelper.EntityOptionsWrapper> entityOptionUniqueVal = new Map<String, EntityContactServiceHelper.EntityOptionsWrapper>() ;
                Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Entity_User_Request').getRecordTypeId();
                Id accountRecordTypeHousehold = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId();
                if (Schema.sObjectType.Case.isAccessible()) {
                    for (Case caseRec : [
                            SELECT Id, Entity__r.Name, Entity__c
                            FROM Case
                            WHERE ContactId = :conId
                            AND RecordTypeId = :caseRecordTypeId
                            AND Entity__r.RecordTypeId != :accountRecordTypeHousehold
                            AND Internal_Status__c NOT IN :getCaseStatusesForDisplayEntity() WITH SECURITY_ENFORCED
                    ]) {
                        EntityContactServiceHelper.EntityOptionsWrapper entityOption = new EntityContactServiceHelper.EntityOptionsWrapper(caseRec.Entity__c, caseRec.Entity__r.Name) ;
                        entityOptionUniqueVal.put(caseRec.Entity__c, entityOption);
                    }
                }
                if (Schema.SObjectType.CONTACT2ACCTSERVICE__c.isAccessible()) {
                    for (CONTACT2ACCTSERVICE__c con2AccSer : [
                            Select Id,Name,Service_Contact__c,Service_Contact__r.Name,Account_Service__c,Account_Service__r.Account__c,
                                    Account_Service__r.Account__r.Name,Account_Service__r.Service_Name__c,Role__c,Account_Service__r.Service__c,
                                    Active__c
                            from CONTACT2ACCTSERVICE__c
                            where Service_Contact__c = :conId And Active__c = :TRUE
                    ]) {
                        EntityContactServiceHelper.EntityOptionsWrapper entityOptionWrap = new EntityContactServiceHelper.EntityOptionsWrapper(con2AccSer.Account_Service__r.Account__c, con2AccSer.Account_Service__r.Account__r.Name) ;
                        entityOptionUniqueVal.put(con2AccSer.Account_Service__r.Account__c, entityOptionWrap);
                    }
                }
                entityOptionList.addAll(entityOptionUniqueVal.values());
                EntityContactServiceHelper.EntityConWrapper evWrap = new EntityContactServiceHelper.EntityConWrapper(contactList[0].Id, contactList[0].Name, entityOptionList);
                evWrapList.add(evWrap);
            }
        }
        return evWrapList;
    }

    /**
     * Created by Balashankar     
     * Method Name: getServices
     * Purpose : Method to fetch services for selected Account
     */
    @AuraEnabled(Cacheable = true)
    public static List<EntityContactServiceHelper.EntitySerWrapper> getServices(String accId, String conId) {

        List<EntityContactServiceHelper.EntitySerWrapper> entSerWrapList = new List<EntityContactServiceHelper.EntitySerWrapper>();
        if (accId != '') {
            for (CONTACT2ACCTSERVICE__c con2AccSer : [
                    Select Id,Name,Service_Contact__c,Service_Contact__r.Name,Account_Service__c,Account_Service__r.Account__c,
                            Account_Service__r.Account__r.Name,Account_Service__r.Service_Name__c,Role__c,Account_Service__r.Service__c,
                            Active__c
                    from CONTACT2ACCTSERVICE__c
                    where Service_Contact__c = :conId And Account_Service__r.Account__c = :accId And Active__c = :TRUE
            ]) {
                EntityContactServiceHelper.EntitySerWrapper entServ = new EntityContactServiceHelper.EntitySerWrapper(con2AccSer.Id, con2AccSer.Account_Service__r.Service_Name__c, con2AccSer.Role__c);
                entSerWrapList.add(entServ);
            }
        }
        return entSerWrapList;
    }

    /**
     * Created by Balashankar     
     * Method Name: changeRole
     * Purpose : Method to fetch services for selected Account
     */
    @AuraEnabled(Cacheable = true)
    public static Boolean changeRole(String accId, String serName) {

        Boolean rolecheck = False;
        List<CONTACT2ACCTSERVICE__c> contList = new List<CONTACT2ACCTSERVICE__c>();
        contList = [
                Select Id,Name,Service_Contact__c,Service_Contact__r.Name,Account_Service__c,Account_Service__r.Account__c,
                        Account_Service__r.Account__r.Name,Account_Service__r.Service_Name__c,Role__c,Account_Service__r.Service__c,
                        Active__c
                from CONTACT2ACCTSERVICE__c
                where Account_Service__r.Account__c = :accId And Active__c = :TRUE And
                Account_Service__r.Service_Name__c = :serName And Role__c = 'Coordinator' And Service_Contact__c != NULL
        ];

        if (contList.size() > 1) {
            rolecheck = True;
        }

        return rolecheck;
    }


    /**
     * Created by Balashankar     
     * Method Name: updateRole
     * Purpose : Method to update role for User
     */
    @AuraEnabled
    public static void updateRole(String serviceId, String roleValue) {
        CONTACT2ACCTSERVICE__c con2Acc = new CONTACT2ACCTSERVICE__c(Id = serviceId);
        con2Acc.Role__c = roleValue;
        update con2Acc;
    }

    /**
     * Created by Balashankar     
     * Method Name: deleteRole
     * Purpose : Method to delete role for User
     */
    @AuraEnabled
    public static Boolean deleteRole(String serviceId, String accountId, String conId) {
        List<CONTACT2ACCTSERVICE__c> con2AccSerCordList = new List<CONTACT2ACCTSERVICE__c>();
        List<CONTACT2ACCTSERVICE__c> con2AccSerUserList = new List<CONTACT2ACCTSERVICE__c>();

        List<CONTACT2ACCTSERVICE__c> serNameList = new List<CONTACT2ACCTSERVICE__c>();
        serNameList = [Select Id,Name,Account_Service__r.Service__r.Name from CONTACT2ACCTSERVICE__c where Id = :serviceId];


        con2AccSerCordList = [
                Select Id,Name,Service_Contact__c,Service_Contact__r.Name,Account_Service__c,Account_Service__r.Account__c,
                        Account_Service__r.Account__r.Name,Account_Service__r.Service_Name__c,Role__c,Account_Service__r.Service__c,
                        Active__c
                from CONTACT2ACCTSERVICE__c
                where Account_Service__r.Account__c = :accountId And Active__c = :TRUE And
                Role__c = :constants.CASE_SOURCE_COORDINATOR And Account_Service__r.Service__r.Name = :serNameList[0].Account_Service__r.Service__r.Name
        ];
        con2AccSerUserList = [
                Select Id,Name,Service_Contact__c,Service_Contact__r.Name,Account_Service__c,Account_Service__r.Account__c,
                        Account_Service__r.Account__r.Name,Account_Service__r.Service_Name__c,Role__c,Account_Service__r.Service__c,
                        Active__c
                from CONTACT2ACCTSERVICE__c
                where Account_Service__r.Account__c = :accountId And Active__c = :TRUE And
                Role__c = :constants.CASE_ROLE_USER And Account_Service__r.Service__r.Name = :serNameList[0].Account_Service__r.Service__r.Name
        ];
        Boolean retunVal = false;


        if (con2AccSerCordList.size() == 1 && con2AccSerUserList.Size() > 0 && con2AccSerCordList[0].Id == serviceId) {
            retunVal = true;
        } else {
            deleteRoleSonarfix(con2AccSerCordList, accountId, conId, serviceId);

            CONTACT2ACCTSERVICE__c con2Acc = new CONTACT2ACCTSERVICE__c(Id = serviceId);
            con2Acc.Active__c = FALSE;
            update con2Acc;
            retunVal = false;

        }

        return retunVal;
    }

    /**
    * Created by Balashankar
    * Method Name: deleteRoleSonarfix
    * Purpose : Method to delete role for User
    */
    public static void deleteRoleSonarfix(List<CONTACT2ACCTSERVICE__c> con2AccSerCordList, String accountId, String conId, String serviceId) {
        if (con2AccSerCordList.size() == 1 && con2AccSerCordList[0].Id == serviceId) {


            List<Account2Service__c> acct2ServList = new List<Account2Service__c>();
            acct2ServList = [
                    Select Id,Name,Account__c,Active__c,Service__c
                    From Account2Service__c
                    Where Id = :con2AccSerCordList[0].Account_Service__c
                    And Active__c = TRUE
            ];

            if (acct2ServList.size() > 0) {
                Account2Service__c accSer = new Account2Service__c(Id = acct2ServList[0].Id);
                accSer.Active__c = False;
                update accSer;

                Set<String> servSet = new Set<String>{
                        constants.SERVICE_NAME_ENROLLMENT_VERIFICATION, constants.SERVICE_NAME_CREDENTIAL_VERIFICATION
                };

                List<Service__c> servList = new List<Service__c>();
                servList = [Select Id,Name from Service__c Where Id = :acct2ServList[0].Service__c and Name IN:servSet];

                if (servList.size() > 0) {
                    List<Account2Service__c> acct2ServPerformanceList = new List<Account2Service__c>();
                    acct2ServPerformanceList = [
                            Select Id,Name,Account__c,Active__c,Service__c,Service_Name__c
                            From Account2Service__c
                            Where Account__c = :accountId
                            And Service__r.Name = :constants.SERVICE_NAME_PERFORMANCE_DATA and Active__c = TRUE
                    ];
                    deleteRolePerformaceList(acct2ServPerformanceList, conId);


                }


            }
        }
    }

    /**
    * Created by Balashankar
    * Method Name: deleteRolePerformaceList
    * Purpose : Method to delete role for User
    */
    public static void deleteRolePerformaceList(List<Account2Service__c> acct2ServPerformanceList, String conId) {
        if (acct2ServPerformanceList.size() > 0) {
            Account2Service__c perServiceToDeAct = new Account2Service__c(Id = acct2ServPerformanceList[0].Id);
            perServiceToDeAct.Active__c = False;
            Update perServiceToDeAct;


            List<CONTACT2ACCTSERVICE__c> conAccListToDeAct = new List<CONTACT2ACCTSERVICE__c>();
            for (CONTACT2ACCTSERVICE__c con2AccSerPerformanceList : [
                    Select Id,Name,Service_Contact__c,Service_Contact__r.Name,Account_Service__c,Account_Service__r.Account__c,
                            Account_Service__r.Account__r.Name,Account_Service__r.Service_Name__c,Role__c,Account_Service__r.Service__c,
                            Active__c
                    from CONTACT2ACCTSERVICE__c
                    where Account_Service__r.Id = :acct2ServPerformanceList[0].Id And Active__c = TRUE
            ]) {

                CONTACT2ACCTSERVICE__c co = new CONTACT2ACCTSERVICE__c(Id = con2AccSerPerformanceList.Id);
                co.Active__c = False;
                conAccListToDeAct.add(co);
            }

            if (conAccListToDeAct.size() > 0) {
                update conAccListToDeAct;
            }
        }
    }

    /**
       * Created by Varsha Hariharan
       * Method Name: getServicesOfEntity
       * Purpose: Method to get the list of services of an Entity
      **/
    @AuraEnabled(cacheable = true)
    public static List<Service__c> getServicesOfEntity(string accountId) {
        List<Service__c> listToReturn = new List<Service__c>();
        List<Account> accRec = new List<Account>();
        List<String> accType = new List<String>();
        accRec = [select Id, Account_Type__c from Account where Id = :accountId];
        if (accRec[0].Account_Type__c != NULL) {
            accType = accRec[0].Account_Type__c.split(',');
        }
        if (accType.size() > 0) {
            for (integer countVar = 0; countVar < accType.size(); countvar++) {
                accType[countVar] = accType[countVar].trim();
            }
        }
        List<EntityType2Service__c> entityServList = new List<EntityType2Service__c>();
        Set<String> servIdList = new Set<String>();
        if (accType.size() > 0) {
            entityServList = [Select Service__c from EntityType2Service__c where Entity_Type__r.Entity_Type__c IN:accType];
        }
        if (entityServList.size() > 0) {
            for (integer count = 0; count < entityServList.size(); count++) {
                servIdList.add(entityServList[count].Service__c);
            }
        }
        if (servIdList.size() > 0)
            listToReturn = [Select Id, Name from Service__c where Id IN:servIdList];

        return listToReturn;
    }

    /**
      * Created by Varsha Hariharan
      * Method Name: validateRecord
      * Purpose: Method to get the list of services of an Entity
     **/
    @AuraEnabled
    public static List<Boolean> validateRecord(string serviceId, string role, string accountId, string contactId) {
        List<Boolean> validationsResult = new List<Boolean>();
        String servName;
        Boolean activeEntityUser;
        Boolean activeCoordUserPresent;
        Boolean newService;
        Boolean signReqd;
        Boolean sealReqd;
        Boolean perfDataOne;
        Boolean perfDataTwo;
        Boolean perfDataThree;

        List<Service__c> servRec = new List<Service__c>([Select Name from Service__c where Id = :serviceId]);
        if (servRec.size() > 0) {
            servName = servRec[0].Name;
        }
        activeEntityUser = checkUser(contactId);
        if (role == 'User') {
            activeCoordUserPresent = checkRole(serviceId, accountId);
        } else {
            activeCoordUserPresent = true;
        }
        newService = checkService(serviceId, contactId, accountId);
        List<Service__c> servList = new List<Service__c>();
        servList = [Select Id, Signature_Required__c, Seal_Required__c from Service__c where Id = :serviceId];
        Boolean signVal;
        Boolean sealVal;
        if (servList.size() > 0) {
            signVal = servList[0].Signature_Required__c;
            sealVal = servList[0].Seal_Required__c;
            if (signVal == true) {
                signReqd = checkSign(contactId);
            } else {
                signReqd = true;
            }
            if (sealVal == true) {
                sealReqd = checkSeal(accountId);
            } else {
                sealReqd = true;
            }
        }
        if (servName == 'Performance Data') {
            perfDataOne = checkPIA(accountId);
            perfDataTwo = checkEnrollment(accountId);
            perfDataThree = checkCred(accountId);
        } else {
            perfDataOne = true;
            perfDataTwo = true;
            perfDataThree = true;
        }
        if (perfDataOne && perfDataTwo && perfDataThree && sealReqd && signReqd && newService && activeCoordUserPresent && activeEntityUser) {
            insertRec(serviceId, role, accountId, contactId, servName);
        }
        validationsResult.add(activeEntityUser);
        validationsResult.add(activeCoordUserPresent);
        validationsResult.add(signReqd);
        validationsResult.add(sealReqd);
        validationsResult.add(perfDataOne);
        validationsResult.add(perfDataTwo);
        validationsResult.add(perfDataThree);
        validationsResult.add(newService);
        return validationsResult;
    }
    public static void insertRec(string serviceId, string role, string accountId, string contactId, string servName) {
        List<CONTACT2ACCTSERVICE__c> conRec = new List<CONTACT2ACCTSERVICE__c>();
        CONTACT2ACCTSERVICE__c recToInsert = new CONTACT2ACCTSERVICE__c();
        conRec = [Select Id from CONTACT2ACCTSERVICE__c where Service_Contact__c = :contactId AND Account_Service__r.Service__c = :serviceId AND Active__c = FALSE];
        if (conRec.size() > 0) {
            recToInsert.Id = conRec[0].Id;
        }
        recToInsert.Service_Contact__c = contactId;
        recToInsert.Active__c = true;
        recToInsert.Role__c = role;
        List<Account2Service__c> ac2servRec = new List<Account2Service__c>();
        ac2servRec = [Select Id, Active__c from Account2Service__c where Account__c = :accountId AND Service__c = :serviceId];
        if (ac2servRec.size() > 0) {
            if (ac2servRec[0].Active__c == false) {
                Account2Service__c newaccRec2 = new Account2Service__c(Id = ac2servRec[0].Id, Active__c = true, Start_Date__c = system.today());
                update newaccRec2;
            }
            if (ac2servRec[0].Active__c == true) {
                Account2Service__c newaccRec2 = new Account2Service__c(Id = ac2servRec[0].Id, Start_Date__c = system.today());
                update newaccRec2;
            }
            recToInsert.Account_Service__c = ac2servRec[0].Id;
        } else {
            Account2Service__c newaccRec = new Account2Service__c();
            newaccRec.Account__c = accountId;
            newaccRec.Service__c = serviceId;
            newaccRec.Active__c = true;
            newaccRec.Start_Date__c = system.today();
            insert newaccRec;
            recToInsert.Account_Service__c = newaccRec.Id;
        }
        upsert recToInsert;
    }

    public static boolean checkUser(String conId) {
        Contact myCon = [Select Id, Active_Entity_Portal_User__c from Contact where Id = :conId];
        if (myCon.Active_Entity_Portal_User__c == TRUE) {
            return true;
        } else {
            return false;
        }
    }
    public static boolean checkRole(String servId, String accId) {
        List<CONTACT2ACCTSERVICE__c> recList = new list<CONTACT2ACCTSERVICE__c>();
        recList = [Select Id from Contact2AcctService__c where Active__c = TRUE AND Role__c = 'Coordinator' AND Account_Service__r.Service__c = :servId AND Account_Service__r.Account__c = :accId AND Service_Contact__c != NULL];
        if (recList.size() > 0) {
            return true;
        } else {
            return false;
        }
    }
    public static boolean checkService(String servId, String conId, String accId) {
        List<CONTACT2ACCTSERVICE__c> conRec = new List<CONTACT2ACCTSERVICE__c>();
        conRec = [Select Id from CONTACT2ACCTSERVICE__c where Service_Contact__c = :conId AND Account_Service__r.Service__c = :servId AND Active__c = TRUE AND Account_Service__r.Account__c = :accId AND Service_Contact__c != NULL];
        if (conRec.size() > 0) {
            return false;
        } else {
            return true;
        }
    }
    public static boolean checkSign(String conId) {
        List<Asset> assetRec = new List<Asset>();
        assetRec = [Select Id from Asset where ContactId = :conId AND Type__c = 'User Signature' AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION];
        if (assetRec.size() > 0) {
            return true;
        } else {
            return false;
        }
    }
    public static boolean checkSeal(String accId) {
        List<Asset> assetRecSeal = new List<Asset>();
        assetRecSeal = [Select Id from Asset where AccountId = :accId AND Type__c = 'Entity Seal' AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION];
        if (assetRecSeal.size() > 0) {
            return true;
        } else {
            return false;
        }
    }
    public static boolean checkPIA(String accId) {
        List<Asset> assetRecPerform = new List<Asset>();
        assetRecPerform = [Select Id from Asset where accountId = :accId AND Type__c = 'Completed PIA' AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION];
        if (assetRecPerform.size() > 0) {
            return true;
        } else {
            return false;
        }
    }
    public static boolean checkEnrollment(String accId) {
        List<Account2Service__c> acc2ServList = new List<Account2Service__c>();
        acc2ServList = [SELECT Id from Account2Service__c where Active__c = TRUE AND Account__c = :accId AND Service__r.Name = 'Enrollment Verification'];
        if (acc2ServList.size() > 0) {
            return true;
        } else {
            return false;
        }
    }
    public static boolean checkCred(String accId) {
        List<Account2Service__c> acc2ServList2 = new List<Account2Service__c>();
        acc2ServList2 = [SELECT Id from Account2Service__c where Active__c = TRUE AND Account__c = :accId AND Service__r.Name = 'Credential Verification'];
        if (acc2ServList2.size() > 0) {
            return true;
        } else {
            return false;
        }
    }
}