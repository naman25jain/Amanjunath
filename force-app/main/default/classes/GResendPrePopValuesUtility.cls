//Uitlity class for GResendPrePopValues
public with sharing class GResendPrePopValuesUtility {
    //Copying address from related Contact2AccountService to ad-hoc Send Request. Changes as part of US 20990
    public static void processGetPrePopAddressValues(SObject sourceObjRec){
        String verPackObj = String.ValueOf(sourceObjRec.get('Verification_Packet__c'));
        List<Verification_Packet__c> verPack = new List<Verification_Packet__c>();
        List<Case> caseRecord = new List<Case>();
        List<Account2Service__c> account2ServiceList = new List<Account2Service__c>();
        List<CONTACT2ACCTSERVICE__c> CONTACT2ACCTSERVICEList = new List<CONTACT2ACCTSERVICE__c>();
        if(verPackObj != NULL){
			verPack = [SELECT Id, Case__c
                       FROM Verification_Packet__c 
                       WHERE Id =: verPackObj WITH SECURITY_ENFORCED LIMIT 1];
		}
        if(!verPack.isEmpty() && verPack[0].Case__c != NULL){
			caseRecord = [SELECT Id, Entity__c, Document_Type__c, Send_Method__c, Internal_Status__c 
                          FROM Case 
                          WHERE Id =:verPack[0].Case__c WITH SECURITY_ENFORCED LIMIT 1];
		}
        if(!caseRecord.isEmpty() && caseRecord[0].Entity__c != NULL){
            account2ServiceList = [SELECT Id, Account__c 
                                   FROM Account2Service__c 
                                   WHERE Account__c =: caseRecord[0].Entity__c AND 
                                   Service__r.Name = 'Credential Verification' WITH SECURITY_ENFORCED LIMIT 1];
        }
        if(!account2ServiceList.isEmpty()){
            CONTACT2ACCTSERVICEList = [SELECT Id, Account_Service__c, Street__c, City__c, 
                                       Country__c, State__c, Postal_Code__c
                                       FROM CONTACT2ACCTSERVICE__c 
                                       WHERE Active__c = true AND Account_Service__c =: account2ServiceList[0].Id AND 
                                       Preferred_mode_of_communication__c = 'Paper' AND 
                                       Credential_Type__c =: caseRecord[0].Document_Type__c WITH SECURITY_ENFORCED LIMIT 1];        
        }        
        if(!CONTACT2ACCTSERVICEList.isEmpty() && caseRecord[0].Send_Method__c == 'Paper' && 
                (caseRecord[0].Internal_Status__c == Constants.CASE_STATUS_SENT_FOR_VERIFICATION || 
                caseRecord[0].Internal_Status__c == Constants.CASE_STATUS_RESENT_FOR_VERIFICATION)){
                sourceObjRec.put('City__c',CONTACT2ACCTSERVICEList[0].City__c);
                sourceObjRec.put('Street__c',CONTACT2ACCTSERVICEList[0].Street__c);
                sourceObjRec.put('Country__c',CONTACT2ACCTSERVICEList[0].Country__c);
                sourceObjRec.put('State__c',CONTACT2ACCTSERVICEList[0].State__c);
                sourceObjRec.put('Postal_Code__c',CONTACT2ACCTSERVICEList[0].Postal_Code__c);
            }

    }
}