/**
@Name: Shaik Nagajani
@Description: 
- This class contains the palnet press printing related methods.

@History
VERSION     AUTHOR             DATE            DETAIL
1.0         Shaik Nagajani     15/Nov/2021     Created the Apex class.
*/
public class PrintResponseEventTriggerHelper {
    public static list<Print_Response_Event__e> lstprintReses = new List<Print_Response_Event__e>();
    public static set<String> setRecDevNames = new set<String>{'Medical_Education_Form', 'Credential_Verification'};

    public static void handlePrintResponses(list<Print_Response_Event__e> lstPrintResponses) {
        if(lstPrintResponses != null && !lstPrintResponses.isEmpty()) {
            Map<Id, Case> mapCases = new Map<Id, Case>();
            Map<String, List<ECFMG_Print_Config__mdt>> mapCsDevNameAndMdts = new Map<String, List<ECFMG_Print_Config__mdt>>();
            List<String> lstCasesToQuery = new List<String>();
            List<Case> lstCasesToUpdate = new List<Case>();
            List<String> lstCsDevNames = new List<String>();

            for(Print_Response_Event__e iterator : lstPrintResponses) {
                lstCasesToQuery.add(getCaseIdFromResponse(iterator));
            }
            map<Id, Case> mapCaseData = getCaseInformations(lstCasesToQuery);

            if(mapCaseData != null && !mapCaseData.isEmpty()) {
                if(mapCaseData != null && !mapCaseData.isEmpty()) {
                    for(Case cs : mapCaseData.values()) {
                        lstCsDevNames.add(cs.RecordType.DeveloperName);
                    }
                }
            }

            if(lstCsDevNames != null && !lstCsDevNames.isEmpty()) mapCsDevNameAndMdts = getMdtsBasedonCaseDevNames(lstCsDevNames);

            for(Print_Response_Event__e iterator : lstPrintResponses) {
                if(String.isNotBlank(iterator.Payload__c)) {
                    DocumentPrintJSONResponse obj = DocumentPrintJSONResponse.parse(iterator.Payload__c);
                    String strPrvsCaseStatus = '';
                    String strStatus = '';
                    Case objCase = null;
                    if(obj.caseId != null && mapCaseData.containsKey(obj.caseId)) objCase = mapCaseData.get(obj.caseId);
                    if(objCase != null) {
                        if(obj.transactionStatus == PlanetPressConstants.Trans_Status_Failed) {
                            strStatus = PlanetPressConstants.INTERNAL_STATUS_PENDING_ERROR;
                            lstprintReses.add(iterator);
                        }
                        else if(obj.transactionStatus == PlanetPressConstants.Trans_Status_Printed) {
                            if(objCase.RecordType.DeveloperName != null && mapCsDevNameAndMdts.containsKey(objCase.RecordType.DeveloperName)) {
                                strStatus = (mapCsDevNameAndMdts.get(objCase.RecordType.DeveloperName) != null ? mapCsDevNameAndMdts.get(objCase.RecordType.DeveloperName)[0].Case_Status__c : null);
                            }
                            lstprintReses.add(iterator);
                        }
                        if(objCase.RecordType.DeveloperName != null && setRecDevNames.contains(objCase.RecordType.DeveloperName)) {
                            if(obj.transactionId.contains(PlanetPressConstants.Pending_Print_Resend)) {
                                objCase.Internal_Status__c = PlanetPressConstants.Resent_for_Verification; 
                            }
                            else if(obj.transactionId.contains(PlanetPressConstants.Pending_Print_Verification_Incomplete)) {
                                objCase.Internal_Status__c = PlanetPressConstants.Incomplete_Resent_for_Verification;
                            }
                            else {
                            	objCase.Internal_Status__c = strStatus;
                        	}
                        }
                        else {
                            objCase.Internal_Status__c = strStatus;
                        }
                    }

                    lstCasesToUpdate.add(objCase);
                }
            }
            System.debug('lstprintReses => '+lstprintReses);
            if(lstCasesToUpdate != null && !lstCasesToUpdate.isEmpty()) GenericUtilities.updateSobjects(lstCasesToUpdate);

            if(lstprintReses != null && !lstprintReses.isEmpty()) GenericUtilities.upsertErrorLogForEvents(lstprintReses, null, PlanetPressConstants.RESPONSE);
        }

    }

    public static map<Id, Case> getCaseInformations(list<String> lstCaseIds) {
        if(lstCaseIds != null && !lstCaseIds.isEmpty()) return new map<Id, Case>([SELECT Id, RecordTypeId, RecordType.DeveloperName, Internal_Status__c FROM Case WHERE Id =: lstCaseIds]);
        else return null;
    }

    public static Map<String, List<ECFMG_Print_Config__mdt>> getMdtsBasedonCaseDevNames(List<String> lstCsDevNames) {
        Map<String, List<ECFMG_Print_Config__mdt>> mapCsDevNameAndMdts = new Map<String, List<ECFMG_Print_Config__mdt>>();
        list<ECFMG_Print_Config__mdt> lstMdts = [SELECT Id, Case_Status__c, Record_Type_Dev_Name__c FROM ECFMG_Print_Config__mdt WHERE Record_Type_Dev_Name__c IN :lstCsDevNames];

        for(ECFMG_Print_Config__mdt md : lstMdts) {
            if(!mapCsDevNameAndMdts.containsKey(md.Record_Type_Dev_Name__c))  mapCsDevNameAndMdts.put(md.Record_Type_Dev_Name__c, new list<ECFMG_Print_Config__mdt>{md});
            else mapCsDevNameAndMdts.get(md.Record_Type_Dev_Name__c).add(md);
        }

        return mapCsDevNameAndMdts;
    }

    

    public static String getCaseIdFromResponse(Print_Response_Event__e objEvent) {
        if(String.isNotBlank(objEvent.Payload__c)) {
            DocumentPrintJSONResponse obj = DocumentPrintJSONResponse.parse(objEvent.Payload__c);
            return obj.caseId;
        }
        else {
            return null;
        }
    }
}