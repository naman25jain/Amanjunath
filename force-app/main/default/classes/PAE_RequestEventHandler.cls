//Handler class for Applicant Batch Event when the Platform event is created then log to the Batch Error Log Custom Object
public class PAE_RequestEventHandler{
    //After insert Methods
    public void onAfterInsert(List<PAE_request__e> newList, Map<Id,PAE_request__e> newMap){
        createPlatformEventLogsForProject(newList);
    }
    //This method creates a log record for Platform Events created during Applicant Event Insert
    public void createPlatformEventLogsForProject(List<PAE_request__e> EventList){
        Map<Id, Verification_Request__c> paeVerfReqMap = new Map<Id, Verification_Request__c>();
        Map<Id, List<Verification_Request_File__c>> paeDocsMap = new Map<Id, List<Verification_Request_File__c>>();
        List<Verification_Request__c> verificationReq = new List<Verification_Request__c>();
        List<Verification_Request_File__c> doclist;
        List<Verification_Request_File__c> newFilesToInsert = new List<Verification_Request_File__c>();
        String jsonString;
        PlatformEvent_JSONClass evtJson = new PlatformEvent_JSONClass();
        Verification_Request__c newEvent;
        String AckToken;
        String verReqCredentialReviewRecordTypeId;
        try{
            for(PAE_request__e event : EventList){
                jsonString = event.Payload__c;
                newEvent = new Verification_Request__c();
                evtJson = PlatformEvent_JSONClass.parse(event.Payload__c);
                doclist = new List<Verification_Request_File__c>();
                AckToken = evtJson.AckToken;
                if(evtJson.Applicant != null || evtJson.Requester != null){
                    if(evtJson.AckToken != null){
                        newEvent.AckToken__c = evtJson.AckToken;
                    }
                    if(evtJson.AckToken != null){
                        newEvent.CorrelationId__c = evtJson.CorrelationID;
                    }
                    if(evtJson.RawJSONUri != null){
                        newEvent.RawJsonUri__c = evtJson.RawJSONUri;
                    }
                    if(evtJson.EnrichedJSONUri != null){
                        newEvent.EnrichedJsonUri__c = evtJson.EnrichedJSONUri;
                    }
                    if(evtJson.Requester.Sender != null){
                        newEvent.Sender__c = evtJson.Requester.Sender;
                    }
                    //get verification request record type
                    verReqCredentialReviewRecordTypeId = Schema.SObjectType.Verification_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.VERIFICATION_REQUEST_RECORD_TYPE_CREDENTIAL_REVIEW).getRecordTypeId();
                    newEvent.RecordTypeId = verReqCredentialReviewRecordTypeId;
                    newEvent.Last_Name__c = evtJson.Applicant.LastName;
                    if(evtJson.Applicant.RestOfName != null){
                        newEvent.Rest_of_Name__c = evtJson.Applicant.RestOfName;
                    }
                    if(evtJson.Applicant.DateOfBirth != null){
                        newEvent.Birth_Date__c = Date.valueOf(evtJson.Applicant.DateOfBirth);
                    }
                    if(evtJson.Applicant.Gender != null){
                        newEvent.Gender__c = evtJson.Applicant.Gender;
                    }
                    if(evtJson.Applicant.CitizenshipAtBirth != null){
                        newEvent.Current_Citizenship__c = evtJson.Applicant.CitizenshipAtBirth;
                    }
                    if(evtJson.Applicant.ResidenceCountry != null){
                        newEvent.Residence_Country__c = evtJson.Applicant.ResidenceCountry;
                    }
                    if(evtJson.Applicant.IsUSMLE != null){
                        newEvent.Is_USMLE__c = evtJson.Applicant.IsUSMLE;
                    }
                    if(evtJson.Applicant.USMLEId != null){
                        newEvent.USMLE_ID__c = evtJson.Applicant.USMLEId;
                    }
                    if(evtJson.Applicant.IsEICS != null){
                        newEvent.Is_EICS__c = evtJson.Applicant.IsEICS;
                    }
                    if(evtJson.Applicant.EICSId != null){
                        newEvent.EICS_ID__c = evtJson.Applicant.EICSId;
                    }
                    if(evtJson.Applicant.CandidateCode != null){
                        newEvent.Candidate_Code__c = String.valueOf(evtJson.Applicant.CandidateCode);
                    }
                    if(evtJson.Applicant.DegreeMedicalSchoolCode != null){
                        newEvent.Medschool_Code__c = evtJson.Applicant.DegreeMedicalSchoolCode;
                    }
                    if(evtJson.Applicant.GraduationDate != null){
                        newEvent.Graduation_Date__c = Date.valueOf(evtJson.Applicant.GraduationDate);
                    }
                    if(evtJson.Applicant.PreviousLastName != null){
                        newEvent.Previous_Last_Name__c = evtJson.Applicant.PreviousLastName;
                    }
                    if(evtJson.Applicant.PreviousRestOfName != null){
                        newEvent.Previous_Rest_of_Name__c = evtJson.Applicant.PreviousRestOfName;
                    }
                    if(evtJson.Applicant.Comments != null){
                        newEvent.Comments__c = evtJson.Applicant.Comments;
                    }
                    if(evtJson.Applicant.ECFMGId != null){
                        newEvent.ECFMG_Id__c = evtJson.Applicant.ECFMGId;
                    }
                    if(evtJson.Applicant.GenerationalSuffix != null){
                        newEvent.Generational_Suffix__c = evtJson.Applicant.GenerationalSuffix;
                    }
                    if(evtJson.Applicant.Email != null){
                        newEvent.Email__c = evtJson.Applicant.Email;
                    }
                    verificationReq.add(newEvent);
                    paeVerfReqMap.put(newEvent.Id, newEvent);
                }
                if(evtJson.Documents != null){
                    if(evtJson.Documents.Release != null){
                        Verification_Request_File__c newDoc = new Verification_Request_File__c();
                        newDoc.Document_Name__c = evtJson.Documents.Release.FileName;
                        newDoc.Document_Number__c = evtJson.Documents.Release.ExternalDocumentId;
                        newDoc.FileUri__c = evtJson.Documents.Release.FileUri;
                        doclist.add(newDoc);
                    }
                    if(evtJson.Documents.Photos != null){
                        for(PlatformEvent_JSONClass.Release photo: evtJson.Documents.Photos){
                            Verification_Request_File__c newDoc = new Verification_Request_File__c();
                            if(photo.FileName != null){
                                newDoc.Document_Name__c = photo.FileName;
                            }
                            if(photo.ExternalDocumentId != null){
                                newDoc.Document_Number__c = photo.ExternalDocumentId;
                            }
                            if(photo.FileUri != null){
                                newDoc.FileUri__c = photo.FileUri;
                            }
                            doclist.add(newDoc);
                        }
                    }
                }
                if(evtJson.Credentials != null){
                    if(evtJson.Credentials.FinalMedicalDiploma != null){
                        for(PlatformEvent_JSONClass.FinalMedicalDiploma oFinalMedicalDiploma: evtJson.Credentials.FinalMedicalDiploma){
                            Verification_Request_File__c newDoc = new Verification_Request_File__c();
                            if(oFinalMedicalDiploma.FileName != null){
                                newDoc.Document_Name__c = oFinalMedicalDiploma.FileName;
                            }
                            if(oFinalMedicalDiploma.ExternalDocumentId != null){
                                newDoc.Document_Number__c = oFinalMedicalDiploma.ExternalDocumentId;
                            }
                            if(oFinalMedicalDiploma.FileUri != null){
                                newDoc.FileUri__c = oFinalMedicalDiploma.FileUri;
                            }
                            if(oFinalMedicalDiploma.MedicalSchoolCode != null){
                                newDoc.Medical_School_Code__c = oFinalMedicalDiploma.MedicalSchoolCode;
                            }
                            if(oFinalMedicalDiploma.MedicalSchoolName != null){
                                newDoc.Medical_School_Name__c = oFinalMedicalDiploma.MedicalSchoolName;
                            }
                            if(oFinalMedicalDiploma.NameOnDocument != null){
                                newDoc.Name_On_Document__c = oFinalMedicalDiploma.NameOnDocument;
                            }
                            if(oFinalMedicalDiploma.DocumentIssueDate != null){
                                newDoc.Document_Issue_Date__c = oFinalMedicalDiploma.DocumentIssueDate;
                            }
                            doclist.add(newDoc);
                        }
                    }
                    if(evtJson.Credentials.FinalMedSchoolTranscript != null){
                        for(PlatformEvent_JSONClass.FinalMedicalDiploma oFinalMedSchoolTranscript: evtJson.Credentials.FinalMedSchoolTranscript){
                            Verification_Request_File__c newDoc = new Verification_Request_File__c();
                            if(oFinalMedSchoolTranscript.FileName != null){
                                newDoc.Document_Name__c = oFinalMedSchoolTranscript.FileName;
                            }
                            if(oFinalMedSchoolTranscript.ExternalDocumentId != null){
                                newDoc.Document_Number__c = oFinalMedSchoolTranscript.ExternalDocumentId;
                            }
                            if(oFinalMedSchoolTranscript.FileUri != null){
                                newDoc.FileUri__c = oFinalMedSchoolTranscript.FileUri;
                            }
                            if(oFinalMedSchoolTranscript.MedicalSchoolCode != null){
                                newDoc.Medical_School_Code__c = oFinalMedSchoolTranscript.MedicalSchoolCode;
                            }
                            if(oFinalMedSchoolTranscript.MedicalSchoolName != null){
                                newDoc.Medical_School_Name__c = oFinalMedSchoolTranscript.MedicalSchoolName;
                            }
                            if(oFinalMedSchoolTranscript.NameOnDocument != null){
                                newDoc.Name_On_Document__c = oFinalMedSchoolTranscript.NameOnDocument;
                            }
                            if(oFinalMedSchoolTranscript.DocumentIssueDate != null){
                                newDoc.Document_Issue_Date__c = oFinalMedSchoolTranscript.DocumentIssueDate;
                            }
                            doclist.add(newDoc);
                        }
                    }
                    if(evtJson.Credentials.StudentMedicalSchoolTranscript != null){
                        for(PlatformEvent_JSONClass.FinalMedicalDiploma oStudentMedicalSchoolTranscript: evtJson.Credentials.StudentMedicalSchoolTranscript){
                            Verification_Request_File__c newDoc = new Verification_Request_File__c();
                            if(oStudentMedicalSchoolTranscript.FileName != null){
                                newDoc.Document_Name__c = oStudentMedicalSchoolTranscript.FileName;
                            }
                            if(oStudentMedicalSchoolTranscript.ExternalDocumentId != null){
                                newDoc.Document_Number__c = oStudentMedicalSchoolTranscript.ExternalDocumentId;
                            }
                            if(oStudentMedicalSchoolTranscript.FileUri != null){
                                newDoc.FileUri__c = oStudentMedicalSchoolTranscript.FileUri;
                            }
                            if(oStudentMedicalSchoolTranscript.MedicalSchoolCode != null){
                                newDoc.Medical_School_Code__c = oStudentMedicalSchoolTranscript.MedicalSchoolCode;
                            }
                            if(oStudentMedicalSchoolTranscript.MedicalSchoolName != null){
                                newDoc.Medical_School_Name__c = oStudentMedicalSchoolTranscript.MedicalSchoolName;
                            }
                            if(oStudentMedicalSchoolTranscript.NameOnDocument != null){
                                newDoc.Name_On_Document__c = oStudentMedicalSchoolTranscript.NameOnDocument;
                            }
                            if(oStudentMedicalSchoolTranscript.DocumentIssueDate != null){
                                newDoc.Document_Issue_Date__c = oStudentMedicalSchoolTranscript.DocumentIssueDate;
                            }
                            doclist.add(newDoc);
                        }
                    }
                    if(evtJson.Credentials.AlternateGraduationDocument != null){
                        for(PlatformEvent_JSONClass.FinalMedicalDiploma oAlternateGraduationDocument: evtJson.Credentials.AlternateGraduationDocument){
                            Verification_Request_File__c newDoc = new Verification_Request_File__c();
                            if(oAlternateGraduationDocument.FileName != null){
                                newDoc.Document_Name__c = oAlternateGraduationDocument.FileName;
                            }
                            if(oAlternateGraduationDocument.ExternalDocumentId != null){
                                newDoc.Document_Number__c = oAlternateGraduationDocument.ExternalDocumentId;
                            }
                            if(oAlternateGraduationDocument.FileUri != null){
                                newDoc.FileUri__c = oAlternateGraduationDocument.FileUri;
                            }
                            if(oAlternateGraduationDocument.MedicalSchoolCode != null){
                                newDoc.Medical_School_Code__c = oAlternateGraduationDocument.MedicalSchoolCode;
                            }
                            if(oAlternateGraduationDocument.MedicalSchoolName != null){
                                newDoc.Medical_School_Name__c = oAlternateGraduationDocument.MedicalSchoolName;
                            }
                            if(oAlternateGraduationDocument.NameOnDocument != null){
                                newDoc.Name_On_Document__c = oAlternateGraduationDocument.NameOnDocument;
                            }
                            if(oAlternateGraduationDocument.DocumentIssueDate != null){
                                newDoc.Document_Issue_Date__c = oAlternateGraduationDocument.DocumentIssueDate;
                            }
                            doclist.add(newDoc);
                        }
                    }
                    if(evtJson.Credentials.MedicalLicensure != null){
                        for(PlatformEvent_JSONClass.MedicalLicensure oMedicalLicensure: evtJson.Credentials.MedicalLicensure){
                            Verification_Request_File__c newDoc = new Verification_Request_File__c();
                            if(oMedicalLicensure.FileName != null){
                                newDoc.Document_Name__c = oMedicalLicensure.FileName;
                            }
                            if(oMedicalLicensure.ExternalDocumentId != null){
                                newDoc.Document_Number__c = oMedicalLicensure.ExternalDocumentId;
                            }
                            if(oMedicalLicensure.FileUri != null){
                                newDoc.FileUri__c = oMedicalLicensure.FileUri;
                            }
                            if(oMedicalLicensure.NameOnDocument != null){
                                newDoc.Name_On_Document__c = oMedicalLicensure.NameOnDocument;
                            }
                            if(oMedicalLicensure.DocumentIssueDate != null){
                                newDoc.Document_Issue_Date__c = oMedicalLicensure.DocumentIssueDate;
                            }
                            if(oMedicalLicensure.Institution != null){
                                if(oMedicalLicensure.Institution.Address != null){
                                    if(oMedicalLicensure.Institution.Address.Street != null){
                                        newDoc.Institution_Address__c = oMedicalLicensure.Institution.Address.Street;
                                    }
                                    if(oMedicalLicensure.Institution.Address.City != null){
                                        newDoc.Institution_City__c = oMedicalLicensure.Institution.Address.City;
                                    }
                                    if(oMedicalLicensure.Institution.Address.Country != null){
                                        newDoc.Institution_Country__c = oMedicalLicensure.Institution.Address.Country;
                                    }
                                    if(oMedicalLicensure.Institution.Address.State != null){
                                        newDoc.Institution_State__c = oMedicalLicensure.Institution.Address.State;
                                    }
                                    if(oMedicalLicensure.Institution.Address.PostalCode != null){
                                        newDoc.Institution_Postal_Code__c = oMedicalLicensure.Institution.Address.PostalCode;
                                    }
                                }
                                if(oMedicalLicensure.Institution.ClientInstitutionId != null){
                                    newDoc.Institution_ID__c = oMedicalLicensure.Institution.ClientInstitutionId;
                                }
                                if(oMedicalLicensure.Institution.InstitutionName != null){
                                    newDoc.Institution_Name__c = oMedicalLicensure.Institution.InstitutionName;
                                }
                                if(oMedicalLicensure.Institution.ECFMGInstitutionId != null){
                                    newDoc.ECFMG_Institution_ID__c = oMedicalLicensure.Institution.ECFMGInstitutionId;
                                }
                                if(oMedicalLicensure.Institution.Comments != null){
                                    newDoc.Comment__c = oMedicalLicensure.Institution.Comments;
                                }
                            }
                            doclist.add(newDoc);
                        }
                    }
                    if(evtJson.Credentials.PostgraduateMedicalEducationCredential != null){
                        for(PlatformEvent_JSONClass.PostgraduateMedicalEducationCredential oPostgraduateMedicalEducationCredential: evtJson.Credentials.PostgraduateMedicalEducationCredential){
                            Verification_Request_File__c newDoc = new Verification_Request_File__c();
                            if(oPostgraduateMedicalEducationCredential.FileName != null){
                                newDoc.Document_Name__c = oPostgraduateMedicalEducationCredential.FileName;
                            }
                            if(oPostgraduateMedicalEducationCredential.ExternalDocumentId != null){
                                newDoc.Document_Number__c = oPostgraduateMedicalEducationCredential.ExternalDocumentId;
                            }
                            if(oPostgraduateMedicalEducationCredential.FileUri != null){
                                newDoc.FileUri__c = oPostgraduateMedicalEducationCredential.FileUri;
                            }
                            if(oPostgraduateMedicalEducationCredential.MedicalSchoolCode != null){
                                newDoc.Medical_School_Code__c = oPostgraduateMedicalEducationCredential.MedicalSchoolCode;
                            }
                            if(oPostgraduateMedicalEducationCredential.MedicalSchoolName != null){
                                newDoc.Medical_School_Name__c = oPostgraduateMedicalEducationCredential.MedicalSchoolName;
                            }
                            if(oPostgraduateMedicalEducationCredential.NameOnDocument != null){
                                newDoc.Name_On_Document__c = oPostgraduateMedicalEducationCredential.NameOnDocument;
                            }
                            if(oPostgraduateMedicalEducationCredential.DocumentIssueDate != null){
                                newDoc.Document_Issue_Date__c = oPostgraduateMedicalEducationCredential.DocumentIssueDate;
                            }
                            if(oPostgraduateMedicalEducationCredential.Institution != null){
                                if(oPostgraduateMedicalEducationCredential.Institution.Address != null){
                                    if(oPostgraduateMedicalEducationCredential.Institution.Address.Street != null){
                                        newDoc.Institution_Address__c = oPostgraduateMedicalEducationCredential.Institution.Address.Street;
                                    }
                                    if(oPostgraduateMedicalEducationCredential.Institution.Address.City != null){
                                        newDoc.Institution_City__c = oPostgraduateMedicalEducationCredential.Institution.Address.City;
                                    }
                                    if(oPostgraduateMedicalEducationCredential.Institution.Address.Country != null){
                                        newDoc.Institution_Country__c = oPostgraduateMedicalEducationCredential.Institution.Address.Country;
                                    }
                                    if(oPostgraduateMedicalEducationCredential.Institution.Address.State != null){
                                        newDoc.Institution_State__c = oPostgraduateMedicalEducationCredential.Institution.Address.State;
                                    }
                                    if(oPostgraduateMedicalEducationCredential.Institution.Address.PostalCode != null){
                                        newDoc.Institution_Postal_Code__c = oPostgraduateMedicalEducationCredential.Institution.Address.PostalCode;
                                    }
                                }
                                if(oPostgraduateMedicalEducationCredential.Institution.ClientInstitutionId != null){
                                    newDoc.Institution_ID__c = oPostgraduateMedicalEducationCredential.Institution.ClientInstitutionId;
                                }
                                if(oPostgraduateMedicalEducationCredential.Institution.InstitutionName != null){
                                    newDoc.Institution_Name__c = oPostgraduateMedicalEducationCredential.Institution.InstitutionName;
                                }
                                if(oPostgraduateMedicalEducationCredential.Institution.ECFMGInstitutionId != null){
                                    newDoc.ECFMG_Institution_ID__c = oPostgraduateMedicalEducationCredential.Institution.ECFMGInstitutionId;
                                }
                                if(oPostgraduateMedicalEducationCredential.Institution.Comments != null){
                                    newDoc.Comment__c = oPostgraduateMedicalEducationCredential.Institution.Comments;
                                }
                            }
                            doclist.add(newDoc);
                        }
                    }
                    if(evtJson.Credentials.InternCertPreDiploma != null){
                        for(PlatformEvent_JSONClass.PostgraduateMedicalEducationCredential oInternCertPreDiploma: evtJson.Credentials.InternCertPreDiploma){
                            Verification_Request_File__c newDoc = new Verification_Request_File__c();
                            if(oInternCertPreDiploma.FileName != null){
                                newDoc.Document_Name__c = oInternCertPreDiploma.FileName;
                            }
                            if(oInternCertPreDiploma.ExternalDocumentId != null){
                                newDoc.Document_Number__c = oInternCertPreDiploma.ExternalDocumentId;
                            }
                            if(oInternCertPreDiploma.FileUri != null){
                                newDoc.FileUri__c = oInternCertPreDiploma.FileUri;
                            }
                            if(oInternCertPreDiploma.MedicalSchoolCode != null){
                                newDoc.Medical_School_Code__c = oInternCertPreDiploma.MedicalSchoolCode;
                            }
                            if(oInternCertPreDiploma.MedicalSchoolName != null){
                                newDoc.Medical_School_Name__c = oInternCertPreDiploma.MedicalSchoolName;
                            }
                            if(oInternCertPreDiploma.NameOnDocument != null){
                                newDoc.Name_On_Document__c = oInternCertPreDiploma.NameOnDocument;
                            }
                            if(oInternCertPreDiploma.DocumentIssueDate != null){
                                newDoc.Document_Issue_Date__c = oInternCertPreDiploma.DocumentIssueDate;
                            }
                            if(oInternCertPreDiploma.Institution != null){
                                if(oInternCertPreDiploma.Institution.Address != null){
                                    if(oInternCertPreDiploma.Institution.Address.Street != null){
                                        newDoc.Institution_Address__c = oInternCertPreDiploma.Institution.Address.Street;
                                    }
                                    if(oInternCertPreDiploma.Institution.Address.City != null){
                                        newDoc.Institution_City__c = oInternCertPreDiploma.Institution.Address.City;
                                    }
                                    if(oInternCertPreDiploma.Institution.Address.Country != null){
                                        newDoc.Institution_Country__c = oInternCertPreDiploma.Institution.Address.Country;
                                    }
                                    if(oInternCertPreDiploma.Institution.Address.State != null){
                                        newDoc.Institution_State__c = oInternCertPreDiploma.Institution.Address.State;
                                    }
                                    if(oInternCertPreDiploma.Institution.Address.PostalCode != null){
                                        newDoc.Institution_Postal_Code__c = oInternCertPreDiploma.Institution.Address.PostalCode;
                                    }
                                }
                                if(oInternCertPreDiploma.Institution.ClientInstitutionId != null){
                                    newDoc.Institution_ID__c = oInternCertPreDiploma.Institution.ClientInstitutionId;
                                }
                                if(oInternCertPreDiploma.Institution.InstitutionName != null){
                                    newDoc.Institution_Name__c = oInternCertPreDiploma.Institution.InstitutionName;
                                }
                                if(oInternCertPreDiploma.Institution.ECFMGInstitutionId != null){
                                    newDoc.ECFMG_Institution_ID__c = oInternCertPreDiploma.Institution.ECFMGInstitutionId;
                                }
                                if(oInternCertPreDiploma.Institution.Comments != null){
                                    newDoc.Comment__c = oInternCertPreDiploma.Institution.Comments;
                                }
                            }
                            doclist.add(newDoc);
                        }
                    }
                    if(evtJson.Credentials.InternCertPostDiploma != null){
                        for(PlatformEvent_JSONClass.PostgraduateMedicalEducationCredential oInternCertPostDiploma: evtJson.Credentials.InternCertPostDiploma){
                            Verification_Request_File__c newDoc = new Verification_Request_File__c();
                            if(oInternCertPostDiploma.FileName != null){
                                newDoc.Document_Name__c = oInternCertPostDiploma.FileName;
                            }
                            if(oInternCertPostDiploma.ExternalDocumentId != null){
                                newDoc.Document_Number__c = oInternCertPostDiploma.ExternalDocumentId;
                            }
                            if(oInternCertPostDiploma.FileUri != null){
                                newDoc.FileUri__c = oInternCertPostDiploma.FileUri;
                            }
                            if(oInternCertPostDiploma.MedicalSchoolCode != null){
                                newDoc.Medical_School_Code__c = oInternCertPostDiploma.MedicalSchoolCode;
                            }
                            if(oInternCertPostDiploma.MedicalSchoolName != null){
                                newDoc.Medical_School_Name__c = oInternCertPostDiploma.MedicalSchoolName;
                            }
                            if(oInternCertPostDiploma.NameOnDocument != null){
                                newDoc.Name_On_Document__c = oInternCertPostDiploma.NameOnDocument;
                            }
                            if(oInternCertPostDiploma.DocumentIssueDate != null){
                                newDoc.Document_Issue_Date__c = oInternCertPostDiploma.DocumentIssueDate;
                            }
                            if(oInternCertPostDiploma.Institution != null){
                                if(oInternCertPostDiploma.Institution.Address != null){
                                    if(oInternCertPostDiploma.Institution.Address.Street != null){
                                        newDoc.Institution_Address__c = oInternCertPostDiploma.Institution.Address.Street;
                                    }
                                    if(oInternCertPostDiploma.Institution.Address.City != null){
                                        newDoc.Institution_City__c = oInternCertPostDiploma.Institution.Address.City;
                                    }
                                    if(oInternCertPostDiploma.Institution.Address.Country != null){
                                        newDoc.Institution_Country__c = oInternCertPostDiploma.Institution.Address.Country;
                                    }
                                    if(oInternCertPostDiploma.Institution.Address.State != null){
                                        newDoc.Institution_State__c = oInternCertPostDiploma.Institution.Address.State;
                                    }
                                    if(oInternCertPostDiploma.Institution.Address.PostalCode != null){
                                        newDoc.Institution_Postal_Code__c = oInternCertPostDiploma.Institution.Address.PostalCode;
                                    }
                                }
                                if(oInternCertPostDiploma.Institution.ClientInstitutionId != null){
                                    newDoc.Institution_ID__c = oInternCertPostDiploma.Institution.ClientInstitutionId;
                                }
                                if(oInternCertPostDiploma.Institution.InstitutionName != null){
                                    newDoc.Institution_Name__c = oInternCertPostDiploma.Institution.InstitutionName;
                                }
                                if(oInternCertPostDiploma.Institution.ECFMGInstitutionId != null){
                                    newDoc.ECFMG_Institution_ID__c = oInternCertPostDiploma.Institution.ECFMGInstitutionId;
                                }
                                if(oInternCertPostDiploma.Institution.Comments != null){
                                    newDoc.Comment__c = oInternCertPostDiploma.Institution.Comments;
                                }
                            }
                            doclist.add(newDoc);
                        }
                    }
                }
                paeDocsMap.put(newEvent.Id, doclist);
            }
            Database.SaveResult[] result = Database.insert(paeVerfReqMap.values(), false);
            if(result[0].isSuccess()){
                for(Id paeReqId: paeVerfReqMap.keySet()){
                    for(Verification_Request_File__c reqDoc: paeDocsMap.get(paeReqId)){
                        reqDoc.Verification_Request__c = paeVerfReqMap.get(paeReqId).Id;
                        newFilesToInsert.add(reqDoc);
                    }
                }
                if(newFilesToInsert.size()> 0){
                    Database.SaveResult[] docResult = Database.insert(newFilesToInsert, false);
                    if(docResult[0].isSuccess()){
                        PAE_response__e response = new PAE_response__e();
                        response.Success__c = 'true';
                        response.AckToken__c = AckToken;
                        response.Payload__c = jsonString;
                        Database.SaveResult sr = EventBus.publish(response);
                    }else{
                        PAE_response__e response = new PAE_response__e();
                        response.Success__c = 'false';
                        response.AckToken__c = AckToken;
                        response.Payload__c = jsonString;
                        Database.SaveResult sr = EventBus.publish(response);
                    }
                }else{
                    PAE_response__e response = new PAE_response__e();
                    response.Success__c = 'true';
                    response.AckToken__c = AckToken;
                    response.Payload__c = jsonString;
                    Database.SaveResult sr = EventBus.publish(response);
                }
            }else{
                PAE_response__e response = new PAE_response__e();
                response.Success__c = 'false';
                response.AckToken__c = AckToken;
                response.Payload__c = jsonString;
                Database.SaveResult sr = EventBus.publish(response);
            }
        }catch(Exception e){
            System.debug('Exception ************** ' +e.getMessage());
            PAE_response__e response = new PAE_response__e();
            response.Success__c = 'false';
            response.AckToken__c = AckToken;
            response.Payload__c = jsonString;
            response.Error__c = e.getMessage();
            Database.SaveResult sr = EventBus.publish(response);
        }
    }
}