public with sharing class VerificationStatusHelper{
    public static VerificationStatusResponse getVeficationRequest(string  correlationId){
        string verId; 
        string extRequestId =''; 
        string actionType = '';
        string caseId =''; 
        VerificationStatusResponse vsr = new VerificationStatusResponse(); 
        List<VerificationStatusResponse.cls_applicant>  listapplicants = new List<VerificationStatusResponse.cls_applicant>(); 
        VerificationStatusResponse.cls_applicant  app = new VerificationStatusResponse.cls_applicant();      
        List<VerificationStatusResponse.cls_finalMedicalDiploma> lstfinalDiplomas = new  List<VerificationStatusResponse.cls_finalMedicalDiploma>(); 
        VerificationStatusResponse.cls_finalMedicalDiploma fmd = new VerificationStatusResponse.cls_finalMedicalDiploma(); 
        List<VerificationStatusResponse.cls_finalMedSchoolTranscript> lstMedSchTrans = new List<VerificationStatusResponse.cls_finalMedSchoolTranscript>();
        VerificationStatusResponse.cls_finalMedSchoolTranscript medSchTran =new VerificationStatusResponse.cls_finalMedSchoolTranscript(); 
        List<VerificationStatusResponse.cls_alternateGraduationDocument> lstAltGrdDocu = new List<VerificationStatusResponse.cls_alternateGraduationDocument>();
        VerificationStatusResponse.cls_alternateGraduationDocument altGradDocu =new VerificationStatusResponse.cls_alternateGraduationDocument(); 
        List<VerificationStatusResponse.cls_internCertPreDiploma> lstIntpreDiploma  = new List<VerificationStatusResponse.cls_internCertPreDiploma>();
        VerificationStatusResponse.cls_internCertPreDiploma intPreDiploma =new VerificationStatusResponse.cls_internCertPreDiploma(); 
        List<VerificationStatusResponse.cls_internCertPostDiploma> lstIntproDiploma  = new List<VerificationStatusResponse.cls_internCertPostDiploma>();
        VerificationStatusResponse.cls_internCertPostDiploma intProDiploma =new VerificationStatusResponse.cls_internCertPostDiploma(); 
        List<VerificationStatusResponse.cls_medicalLicensure> lstMedLicensure  = new List<VerificationStatusResponse.cls_medicalLicensure>();
        VerificationStatusResponse.cls_medicalLicensure medLicensure =new VerificationStatusResponse.cls_medicalLicensure(); 
        List<VerificationStatusResponse.cls_postgraduateMedicalEducationCredential> lstPostMedEduCred = new List<VerificationStatusResponse.cls_postgraduateMedicalEducationCredential>();
        VerificationStatusResponse.cls_postgraduateMedicalEducationCredential postMedEduCred =new VerificationStatusResponse.cls_postgraduateMedicalEducationCredential(); 
        List<VerificationStatusResponse.cls_studentMedicalSchoolTranscript> lstStuMedSchTranscript = new List<VerificationStatusResponse.cls_studentMedicalSchoolTranscript>();
        VerificationStatusResponse.cls_studentMedicalSchoolTranscript stuMedSchTranscript =new VerificationStatusResponse.cls_studentMedicalSchoolTranscript(); 
        list<Verification_Request__c> lstVerificatinRequests = getVeficationRequestByCorrelationId(correlationId); 
        if(lstVerificatinRequests.size()>0){
            verId = lstVerificatinRequests[0].Id;
            extRequestId = lstVerificatinRequests[0].Request_Id__c; 
            list<Case> lstCases = getCaseByVerifRequestId(verId); 
            if(lstCases.size() >0){
                vsr.Credentials = new VerificationStatusResponse.cls_Credentials(); 
                caseId = lstCases[0].Id; 
                actionType = lstCases[0].Internal_Status__c; 
                list<Asset> lstAssets = getAssetByCaseId(caseId); 
                app.lastName = lstCases[0].Contact.Lastname; 
                app.restOfName = lstCases[0].Contact.FirstName; 
                app.generationalSuffix =  lstCases[0].Contact.Generational_Suffix__c; 
                app.dateOfBirth = string.valueOfGmt(lstCases[0].Contact.Birthdate); 
                app.gender = lstCases[0].Contact.Gender__c; 
                app.citizenshipAtBirth = lstCases[0].Contact.Citizenship_at_Birth__c;
                app.residenceCountry = lstCases[0].Contact.Current_Citizenship__c; 
                app.email = lstCases[0].Contact.Email; 
                app.isUSMLE = string.valueOf(lstVerificatinRequests[0].Is_USMLE__c);   //Need to ask user
                app.USMLEId =  lstCases[0].Contact.USMLE_ID__c; 
                app.isEICS = string.valueOf(lstVerificatinRequests[0].Is_EICS__c);  //Need to ask user
                app.EICSId = lstCases[0].Contact.EICS_ID__c; 
                app.ECFMGId = lstCases[0].Contact.ECFMG_ID__c; 
                app.candidateCode = lstCases[0].Contact.Candidate_Code__c; 
                app.degreeMedicalSchoolCode = lstCases[0].Contact.Medschool_Code__c; 
                app.graduationDate = string.valueOfGmt(lstVerificatinRequests[0].Graduation_Date__c); //need to ask user
                app.previousLastName = lstCases[0].Contact.Previous_Last_Name__c; 
                app.previousRestOfName = lstCases[0].Contact.Previous_Rest_of_Name__c; 
                app.comments = lstCases[0].External_Close_Comments__c; 
                listapplicants.add(app);         
                vsr.applicant = listapplicants[0];  
                for(Integer i=0; i<lstAssets.size(); i++){
                    String docType = lstAssets[i].Type__c.trim(); 
                    docType = docType.replaceAll('/', '-'); 
                    String finalDiploma = 'Final Medical School Transcript'; 
                    switch on docType{                
                        when 'Alternate Graduation Document'{                                    
                            altGradDocu.externalDocumentId = extRequestId;
                            altGradDocu.fileName = lstAssets[i].Filename__c;
                            altGradDocu.nameOnDocument =lstAssets[i].Name_on_Document__c;
                            altGradDocu.actionDate = string.valueOfGmt(lstCases[0].Action_Date__c);
                            altGradDocu.actionType = actionType;
                            altGradDocu.verificationDate=string.valueOfGmt(lstCases[0].Verification_Status_Date__c);
                            altGradDocu.documentStatus = lstAssets[i].Status;
                            altGradDocu.medicalSchoolCode=lstCases[0].Contact.Medschool_Code__c;
                            altGradDocu.eVerify =  lstCases[0].eVerify__c;
                            altGradDocu.institutionId = lstCases[0].Institution_ID__c; //maybe from verification request object            
                            altGradDocu.verificationFile =lstAssets[i].Azure_Storage_URL__c;
                            lstAltGrdDocu.add(altGradDocu); 
                            vsr.Credentials.alternateGraduationDocument = lstAltGrdDocu;     
                        }                
                        when 'Final Medical Diploma'{
                            fmd.externalDocumentId = extRequestId;
                            fmd.fileName = lstAssets[i].Filename__c;
                            fmd.nameOnDocument =lstAssets[i].Name_on_Document__c;
                            fmd.actionDate = string.valueOfGmt(lstCases[0].Action_Date__c);
                            fmd.actionType = actionType;
                            fmd.verificationDate=string.valueOfGmt(lstCases[0].Verification_Status_Date__c);
                            fmd.documentStatus = lstAssets[i].Status;
                            fmd.medicalSchoolCode=lstCases[0].Contact.Medschool_Code__c; 
                            fmd.eVerify =  lstCases[0].eVerify__c;
                            fmd.institutionId = lstCases[0].Institution_ID__c; //maybe from verification request object            
                            fmd.verificationFile =lstAssets[i].Azure_Storage_URL__c;
                            lstfinalDiplomas.add(fmd);   
                            vsr.Credentials.finalMedicalDiploma = lstfinalDiplomas;                                                    
                        }                
                        when 'Final Medical School Transcript'{
                            medSchTran.externalDocumentId = extRequestId;
                            medSchTran.fileName = lstAssets[i].Filename__c;
                            medSchTran.nameOnDocument = lstAssets[i].Name_on_Document__c;
                            medSchTran.actionDate = string.valueOfGmt(lstCases[0].Action_Date__c);
                            medSchTran.actionType = actionType;
                            medSchTran.verificationDate = string.valueOfGmt(lstCases[0].Verification_Status_Date__c);
                            medSchTran.documentStatus = lstAssets[i].Status;
                            medSchTran.medicalSchoolCode = lstCases[0].Contact.Medschool_Code__c;
                            medSchTran.eVerify = lstCases[0].eVerify__c;
                            medSchTran.institutionId = lstCases[0].Institution_ID__c; //maybe from verification request object            
                            medSchTran.verificationFile =lstAssets[i].Azure_Storage_URL__c;
                            lstMedSchTrans.add(medSchTran); 
                            vsr.Credentials.finalMedSchoolTranscript =lstMedSchTrans; 
                        }                                 
                        when 'Pregraduate Internship Credential'{
                            intPreDiploma.externalDocumentId = extRequestId;
                            intPreDiploma.fileName = lstAssets[i].Filename__c;
                            intPreDiploma.nameOnDocument =lstAssets[i].Name_on_Document__c;
                            intPreDiploma.actionDate = string.valueOfGmt(lstCases[0].Action_Date__c);
                            intPreDiploma.actionType = actionType;
                            intPreDiploma.verificationDate=string.valueOfGmt(lstCases[0].Verification_Status_Date__c);
                            intPreDiploma.documentStatus = lstAssets[i].Status;
                            intPreDiploma.medicalSchoolCode=lstCases[0].Contact.Medschool_Code__c;
                            intPreDiploma.eVerify =  lstCases[0].eVerify__c;
                            intPreDiploma.institutionId = lstCases[0].Institution_ID__c; //maybe from verification request object            
                            intPreDiploma.verificationFile =lstAssets[i].Azure_Storage_URL__c;
                            lstIntpreDiploma.add(intPreDiploma); 
                            vsr.Credentials.internCertPreDiploma = lstIntpreDiploma; 
                        }                
                        when 'Internship Certificate Post Diploma'{
                            intProDiploma.externalDocumentId = extRequestId;
                            intProDiploma.fileName = lstAssets[i].Filename__c;
                            intProDiploma.nameOnDocument =lstAssets[i].Name_on_Document__c;
                            intProDiploma.actionDate = string.valueOfGmt(lstCases[0].Action_Date__c);
                            intProDiploma.actionType = actionType;
                            intProDiploma.verificationDate=string.valueOfGmt(lstCases[0].Verification_Status_Date__c);
                            intProDiploma.documentStatus =lstAssets[i].Status;
                            intProDiploma.medicalSchoolCode=lstCases[0].Contact.Medschool_Code__c;
                            intProDiploma.eVerify =  lstCases[0].eVerify__c;
                            intProDiploma.institutionId = lstCases[0].Institution_ID__c; //maybe from verification request object            
                            intProDiploma.verificationFile =lstAssets[i].Azure_Storage_URL__c;
                            lstIntproDiploma.add(intProDiploma); 
                            vsr.Credentials.internCertPostDiploma = lstIntproDiploma;
                        }                
                        when 'Medical Registration Certificate-License to Practice Medicine' {
                            medLicensure.externalDocumentId = extRequestId;
                            medLicensure.fileName = lstAssets[i].Filename__c;
                            medLicensure.nameOnDocument =lstAssets[i].Name_on_Document__c;
                            medLicensure.actionDate = string.valueOfGmt(lstCases[0].Action_Date__c);
                            medLicensure.actionType = actionType;
                            medLicensure.verificationDate=string.valueOfGmt(lstCases[0].Verification_Status_Date__c);
                            medLicensure.documentStatus = lstAssets[i].Status;
                            medLicensure.medicalSchoolCode=lstCases[0].Contact.Medschool_Code__c;
                            medLicensure.eVerify =  lstCases[0].eVerify__c;
                            medLicensure.institutionId = lstCases[0].Institution_ID__c; //maybe from verification request object            
                            medLicensure.verificationFile =lstAssets[i].Azure_Storage_URL__c;
                            lstMedLicensure.add(medLicensure); 
                            vsr.Credentials.medicalLicensure = lstMedLicensure; 
                        }                
                        when 'Postgraduate Medical Education Credential'{
                            postMedEduCred.externalDocumentId = extRequestId;
                            postMedEduCred.fileName = lstAssets[i].Filename__c;
                            postMedEduCred.nameOnDocument =lstAssets[i].Name_on_Document__c;
                            postMedEduCred.actionDate = string.valueOfGmt(lstCases[0].Action_Date__c);
                            postMedEduCred.actionType = actionType;
                            postMedEduCred.verificationDate=string.valueOfGmt(lstCases[0].Verification_Status_Date__c);
                            postMedEduCred.documentStatus = lstAssets[i].Status;
                            postMedEduCred.medicalSchoolCode=lstCases[0].Contact.Medschool_Code__c;
                            postMedEduCred.eVerify =  lstCases[0].eVerify__c;
                            postMedEduCred.institutionId = lstCases[0].Institution_ID__c; //maybe from verification request object            
                            postMedEduCred.verificationFile =lstAssets[i].Azure_Storage_URL__c;
                            lstPostMedEduCred.add(postMedEduCred); 
                            vsr.Credentials.postgraduateMedicalEducationCredential = lstPostMedEduCred;
                        }                                
                        when  'Student Medical School Transcript'{                 
                            stuMedSchTranscript.externalDocumentId = extRequestId;
                            stuMedSchTranscript.fileName = lstAssets[i].Filename__c;
                            stuMedSchTranscript.nameOnDocument =lstAssets[i].Name_on_Document__c;
                            stuMedSchTranscript.actionDate = string.valueOfGmt(lstCases[0].Action_Date__c);
                            stuMedSchTranscript.actionType = actionType;
                            stuMedSchTranscript.verificationDate=string.valueOfGmt(lstCases[0].Verification_Status_Date__c);
                            stuMedSchTranscript.documentStatus = lstAssets[i].Status;
                            stuMedSchTranscript.medicalSchoolCode=lstCases[0].Contact.Medschool_Code__c;
                            stuMedSchTranscript.eVerify =  lstCases[0].eVerify__c;
                            stuMedSchTranscript.institutionId = lstCases[0].Institution_ID__c; //maybe from verification request object            
                            stuMedSchTranscript.verificationFile =lstAssets[i].Azure_Storage_URL__c;
                            lstStuMedSchTranscript.add(stuMedSchTranscript); 
                            vsr.Credentials.studentMedicalSchoolTranscript = lstStuMedSchTranscript;
                        } 
                    }    
                }  
            }  
        }
        return vsr; 
    }

    public static List<VerificationStatus> getVerificationStatus(string sender){
        List<Verification_Request__c> vrs =  getVerificationRequestStatusBySource(sender); 
        List<VerificationStatus> lstVerificationStatus = new List<VerificationStatus> (); 
        for(Verification_Request__c vr : vrs){
            VerificationStatus vs = new VerificationStatus(); 
            vs.requestId = vr.CorrelationId__c; 
            vs.status = vr.Status__c;
            lstVerificationStatus.add(vs);
        }
        return lstVerificationStatus; 
    }
    public static List<Verification_Request__c> getVeficationRequestByCorrelationId(string correlationId){
        try{
            List<Verification_Request__c> vr = [SELECT Id, CorrelationId__c, ECFMG_Id__c, EICS_ID__c, Medschool_Code__c, Medschool_Name__c, USMLE_ID__c,
                                                 Status__c, Account_Type__c, Is_EICS__c,  Is_USMLE__c, Request_Id__c, Graduation_Date__c
                                                FROM Verification_Request__c
                                                WHERE  CorrelationId__c =:correlationId
                                                WITH SECURITY_ENFORCED];  
            return vr;     
        }
        catch (Exception e){
            throw e; 
        }
    }
    private static List<Asset> getAssetByCaseId(Id caseId){
        try{
            List<Asset> listAssets = [SELECT Id, Case__c, Name, type__c, ContactId, Name_on_Document__c, Azure_Storage_URL__c, Filename__c, Status
                                    FROM Asset
                                    WHERE  Case__c =:caseId
                                    WITH SECURITY_ENFORCED];  
            return listAssets;  
        } 
        catch (Exception e){
            throw e; 
        }
    }
    public static Verification_Request__c updateVeficationRequest(string strCorrelationId){
        string verRequestId =''; 
        Verification_Request__c vr = new Verification_Request__c(); 
        if(String.isNotEmpty(strCorrelationId)){
            List<Verification_Request__c> lstvr=  getVeficationRequestByCorrelationId(strCorrelationId); 
            verRequestId = lstvr[0].Id; 
            if(String.isNotEmpty(verRequestId)){
                if(Verification_Request__c.sObjectType.getDescribe().isUpdateable() && Verification_Request__c.sObjectType.getDescribe().isCreateable()){                
                vr.Id = verRequestId; 
                vr.Status__c = 'Downloaded';  
                upsert vr; 
                }
            }
        }
        return vr; 
    } 
    public static List<Case> getCaseByVerifRequestId(Id verificationRequestID){
        try{
            List<Case> listCase = [SELECT Id, Contact.Name, Contact.lastname, Contact.firstName, Contact.Generational_Suffix__c, 
                                    Contact.Birthdate, Contact.Gender__c, Contact.Citizenship_at_Birth__c, Contact.Current_Citizenship__c , Contact.Email,
                                    Contact.USMLE_ID__c, Contact.EICS_ID__c, Contact.ECFMG_ID__c, Contact.Candidate_Code__c, Contact.Medschool_Code__c, 
                                    Contact.Previous_Last_Name__c, Contact.Previous_Rest_of_Name__c, External_Close_Comments__c, Institution_ID__c, 
                                    Internal_Status__c, Type, recordType.Name, Verification_Request__c, Verification_Request__r.Name, Verification_Status_Date__c,
                                    eVerify__c, Action_Date__c                                  
                                FROM Case
                                WHERE  Verification_Request__c =:verificationRequestID
                                WITH SECURITY_ENFORCED];  
            return listCase;    
        } 
        catch (Exception e){
            throw e; 
        }
    }
    public static list<Verification_Request__c> getVerificationRequestStatusBySource(string source){
        List<Verification_Request__c> vr = [SELECT CorrelationId__c, Status__c, Request_Id__c 
                                        FROM Verification_Request__c
                                        WHERE  Sender__c = :source
                                        AND CorrelationId__c != null
                                        WITH SECURITY_ENFORCED]; 
        return vr;
    }
}