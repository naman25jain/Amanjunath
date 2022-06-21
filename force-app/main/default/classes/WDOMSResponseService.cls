public with sharing class WDOMSResponseService {

    private static List<String> sIds = new List<String>(); 
    

    public static string decodeStringValue(string s){
        string returnValue; 
        switch on s {
            when 'Yes' {
                returnValue = 'Y';
            }
            when 'No'{
                returnValue = 'N'; 
            }
        }
        return returnValue; 
        
    }

    public static string decodeBooleanToString(Boolean a){
        string returnValue; 
        If (a){            
            returnValue = 'Y';
        }else {
            returnValue = 'N';  
        }
        return returnValue;         
    }

    public static string decodeCountry(string countryName){
        string returnValue; 
        switch on countryName {
            when 'United States'{
                returnValue = 'USA';
            } when else{
                returnValue = countryName; 
            }
        }
        return returnValue;         
    }

    public static string getSchoolTypeCode(string schType){
        string returnValue; 
        if (!string.isBlank(schType)){
            if (schType =='Both'){
                returnValue = 'MIXED PUBLIC/PRIVATE'; 
            }else{
                returnValue = schType.toUpperCase(); 
            }
        }
        return returnValue; 
    }

    public static WDOMSAccountResponse.Payload buildAccountResponse(Id accId){    
                  
        string notes; 
        string curriculumComments; 
        string imedComments; 
        string internalComments; 

        List<account> acc = WDOMSService.getAccountforWDOMS(accId); 
        account a= acc[0]; 
        List<Program__c> p = WDOMSService.getProgramforWDOMS(accId); 
        List<Task> ts = WDOMSService.getComments(accid); 
        if (ts.size()>0){
            map<string, string> commentMap = new map<string, string>();
            for (task t: ts){
                commentMap.put(t.Comment_Type__c, t.Description); 
            }    
            for(string commentType : commentMap.keySet()){              
                switch on commentType{
                    when 'IMED'{
                        imedComments = commentMap.get(commentType);
                    }
                    when 'Curriculum'{
                        curriculumComments = commentMap.get(commentType);
                    }
                    when 'Internal'{
                        internalComments = commentMap.get(commentType);
                    }
                }
            }
        }
             
        WDOMSAccountResponse.Payload pl = new WDOMSAccountResponse.Payload(); 
        WDOMSAccountResponse.cls_payload pload = new WDOMSAccountResponse.cls_payload(); 
                
            pload.sfSchoolId = a.WDOMS_ID__c; 
            pload.medSchoolCode = a.Medschool_Code__c; 
            pload.schoolName = a.Name;                         
            pload.countryCode = decodeCountry(a.BillingCountry); 
            pload.deletedFlag =decodeStringValue(String.valueOf(a.IsDeleted)); 
            pload.address1 =  a.BillingStreet; 
            pload.city = a.BillingCity; 
            pload.stateCode = String.isBlank(a.BillingStateCode) ? a.BillingStateCode : a.BillingStateCode.toUppercase(); 
            pload.zip = a.BillingPostalCode;             
            pload.universityName =a.University_Name__c; 
            pload.schoolUrl = a.website; 
            pload.imedComments = imedComments; 
            pload.startYear = a.sch_Year_Opened__c; 
            pload.curriculumDuration = String.valueOf(a.Curriculum_Duration__c); 
            pload.entranceExamFlag = decodeStringValue(a.Entrance_Exam_Required__c);
            pload.totalEnrollment =a.Total_Enrollment__c;
            pload.schoolId = String.valueOf(a.Institution_ID__c); 
            pload.schoolTypeCode = getSchoolTypeCode(a.sch_Public_Private__c); 
            pload.currentlyOperationalFlag = decodeStringValue(a.sch_Active__c);             
            pload.yearClosed = a.sch_Year_Closed__c; 
            pload.wdmsVisibleFlag = decodeBooleanToString(a.sch_Publish__c); 
            if (p.size() > 0){                                                
                pload.mdtProgramGenderTypeCode = p[0].Genders_Admitted__c; 
            }           
            pload.currOtherCountryFlag = decodeStringValue(a.Curr_Other_Country_Flag__c);
            pload.tuitionPaidPortion = a.Tuition_Paid_Portion__c;
            pload.clinicalFacilitiesFlag = decodeStringValue(a.Clinical_Facilities_Flag__c);
            if (p.size() > 0){                                               
                pload.mdtProgramGenderTypeCode = p[0].Genders_Admitted__c; 
            }   
            pload.currClinicalPct = a.Clinical_Percentage_of_Curriculum__c;          
            pload.wdmsAddedDate = String.valueOf(a.WDOMS_Added_Date__c);

            pload.ISOSubdivisionCode = 	a.ISO_Subdivision__c; 
            pload.xrefMSCode = a.XREF_MS_Code__c; 
            pload.nameLanguageCode = a.Name_Language__c; 
            pload.notes = internalComments;  
            pload.curriculumComments = curriculumComments;  
            pload.latitude = String.valueOf(a.BillingLatitude); 
            pload.longitude = String.valueOf(a.BillingLongitude);         
        pl.payload  = pload; 
        return pl; 
    } 
    
    public static WDOMSMdtProgramResponse.Payload buildMdtProgramResponse(Id progId){
        string notes; 
        string curriculumComments; 
        string imedComments; 
        string internalComments; 
        integer currLastVisitMonth; 
        integer currLastVisitYear; 

        List<Task> ts = WDOMSService.getComments(progId); 
        if (ts.size()>0){
            map<string, string> commentMap = new map<string, string>();
            for (task t: ts){
                commentMap.put(t.Comment_Type__c, t.Description); 
            }    
            for(string commentType : commentMap.keySet()){                
                switch on commentType{
                    when 'Public'{
                        imedComments = commentMap.get(commentType);
                    }
                    when 'Curriculum'{
                        curriculumComments = commentMap.get(commentType);
                    }
                    when 'Internal'{
                        internalComments = commentMap.get(commentType);
                    }
                }
            }
        }
        List<Program__c> progs = WDOMSService.getProgramforWDOMSbyProgramId(progId); 
        WDOMSMdtProgramResponse.Payload pl = new WDOMSMdtProgramResponse.Payload(); 
        WDOMSMdtProgramResponse.Cls_payload pload = new WDOMSMdtProgramResponse.Cls_payload();      

        if (progs[0].Date_Curriculum_Last_Visited__c !=null){
           currLastVisitMonth = progs[0].Date_Curriculum_Last_Visited__c.Month(); 
           currLastVisitYear = progs[0].Date_Curriculum_Last_Visited__c.Year();            
        }       
        pload.sfmdtProgramId = progs[0].WDOMS_ID__c; 
        pload.programName = progs[0].Name; 
        pload.yearEst = progs[0].Year_Instruction_Started__c; 
        pload.operational =  decodeStringValue(progs[0].Operational_Status__c); 
        pload.durationYears = String.valueOf(progs[0].Curriculum_Duration_Yrs__c); 
        pload.internshipReq = decodeStringValue(progs[0].Internship_Required__c); 
        pload.socservreq =  decodeStringValue(progs[0].Social_Service_Required__c); 
        pload.eligLocalLic =  decodeBooleanToString(progs[0].Local_licensure_eligibility__c); 
        pload.curriculumComment =curriculumComments; 
        pload.publicComment = imedComments; 
        pload.internalComment = internalComments; 
        pload.mdtProgDisciplineTypeCode = String.isBlank(progs[0].Dicipline_Profession__c) ? progs[0].Dicipline_Profession__c : progs[0].Dicipline_Profession__c.toUppercase(); 
        pload.mdtProgramGenderTypeCode = String.isBlank(progs[0].Genders_Admitted__c) ? progs[0].Genders_Admitted__c : progs[0].Genders_Admitted__c.toUppercase(); 
        pload.mdtProgramDistEdTypeCode = String.isBlank(progs[0].Distance_Education__c) ? progs[0].Distance_Education__c : progs[0].Distance_Education__c.toUppercase(); 
        pload.mdtProgramEntExamTypeCode = String.isBlank(progs[0].Entrance_Exam_Required__c) ? progs[0].Entrance_Exam_Required__c : progs[0].Entrance_Exam_Required__c.toUppercase();   
        pload.address1 = progs[0].Address__c;
        pload.address2 = progs[0].Address2__c;
        pload.address3 = progs[0].Address3__c;        
        pload.city = progs[0].City__c; 
        pload.stateCode =  String.isBlank(progs[0].State__c) ? progs[0].State__c : progs[0].State__c.toUppercase(); 
        pload.zip = progs[0].Zip__c; 
        pload.ecfmgOkFlag =  decodeBooleanToString(progs[0].ECFMG_OK__c); 
        pload.mdtFseTypeCode = String.isBlank(progs[0].Foreign_Students__c) ? progs[0].Foreign_Students__c : progs[0].Foreign_Students__c.toUppercase(); 
        pload.internshipLength = String.valueOf(progs[0].Internship_Duration_Mos__c);
        pload.socServLength = String.valueOf(progs[0].Social_Service_Duration__c); 
        pload.curriculumRevisedYear = String.valueOf(currLastVisitYear); 
        pload.curriculumRevisedMonth = String.valueOf(currLastVisitMonth);         
        pload.mdtEducationTypeCode = String.isBlank(progs[0].Prerequisite__c) ? progs[0].Prerequisite__c : progs[0].Prerequisite__c.toUppercase(); 
        pload.tuitionPaidPortion = progs[0].Students_Who_Pay_Tuition__c;
        pload.yearEnd = progs[0].Year_Instruction_Ended__c; 
        pload.interviewReqTypeCode =  String.isBlank(progs[0].Interview_Required__c) ? progs[0].Interview_Required__c : progs[0].Interview_Required__c.toUppercase();   
        pl.payload = pload;         
        return pl; 

    }
    
    public static WDOMSAccLangResponse.Payload buildAccLanguageResponse(Id accLangId){    
               
        List<Account_Language__c> a = WDOMSService.getAccountLanguageforWDOMS(accLangId);   
        WDOMSAccLangResponse.Payload pl = new WDOMSAccLangResponse.Payload();       
        WDOMSAccLangResponse.cls_payload pload = new WDOMSAccLangResponse.cls_payload();  

            pload.language = a[0].Language__c; 
            pload.sfschoolId = a[0].Account__r.WDOMS_ID__c; 
            pload.SF_schoolLanguageId =  a[0].WDOMS_ID__c;             
            pl.payload = pload;             
        return pl; 
    }  

    public static WDOMSAccContactContactInfoResponse.Payload buildSchContactContactInfoResponse(Id contactContactId){           
        List<Additional_Info__c> a = WDOMSService.getSchoolContactContactInfoWDOMS(contactContactId);   
        WDOMSAccContactContactInfoResponse.Payload pl = new WDOMSAccContactContactInfoResponse.Payload();    
        List<WDOMSAccContactContactInfoResponse.cls_payload> ploads = new List<WDOMSAccContactContactInfoResponse.cls_payload>();     
        WDOMSAccContactContactInfoResponse.cls_payload pload = new WDOMSAccContactContactInfoResponse.cls_payload();  
            pload.schoolContactId = Integer.valueOf(a[0].WDOMS_ID__c);
            pload.contactTypeCode = a[0].Type__c; 
            pload.contactData = a[0].Value__c;
            pload.description = a[0].Description__c;  
            pload.SF_mscContactInfoId =  a[0].WDOMS_ID__c; 
            ploads.add(pload); 
            pl.payload = ploads;             
        return pl; 
    }  

   
    public static WDOMSAccContactInfoResponse.Payload buildSchContactInfoResponse(Id schContactId){                    
        List<Additional_Info__c> a = WDOMSService.getSchoolContactContactInfoWDOMS(schContactId);   
        WDOMSAccContactInfoResponse.Payload pl = new WDOMSAccContactInfoResponse.Payload();                
        WDOMSAccContactInfoResponse.cls_payload pload = new WDOMSAccContactInfoResponse.cls_payload();  
        if (!String.isBlank(a[0].WDOMS_ID__c)){
            pload.sfSchoolContactInfoId = a[0].WDOMS_ID__c;
        }
            pload.contactTypeCode = a[0].Type__c; 
            pload.contactData = a[0].Value__c;
            pload.description = a[0].Description__c;              
            pload.sfschoolId = WDOMSService.getWDOMSIdByAccountId(a[0].Account__c);             
            pl.payload = pload;             
        return pl; 
    } 

    public static WDOMSAccURLResponse.Payload buildSchUrlResponse(Id addInfoId){                       
        List<Additional_Info__c> a = WDOMSService.getSchoolContactContactInfoWDOMS(addInfoId);   
        WDOMSAccURLResponse.Payload pl = new WDOMSAccURLResponse.Payload();               
        WDOMSAccURLResponse.cls_payload pload = new WDOMSAccURLResponse.cls_payload();  
        if (!String.isBlank(a[0].WDOMS_ID__c)){
            pload.sfurlId = a[0].WDOMS_ID__c;
        }            
            pload.url = a[0].Value__c;           
            pload.sfschoolId = WDOMSService.getWDOMSIdByAccountId(a[0].Account__c); 
            pload.language = a[0].Language__c;             
            pl.payload = pload;               
        return pl; 
    } 

    public static WDOMSAccountAffiliationResponse.Payload buildSchoolAffiliationResponse(Id schAffId){     
        String affTypeCode='';              
        List<Account_Affiliation__c> a = WDOMSService.getAffiliation_School_N_Program_forWDOMS(schAffId);   
        WDOMSAccountAffiliationResponse.Payload pl = new WDOMSAccountAffiliationResponse.Payload();              
        WDOMSAccountAffiliationResponse.Cls_payload pload = new WDOMSAccountAffiliationResponse.Cls_payload();          
        if (!String.isBlank(a[0].Active__c)){
            if (a[0].Active__c== 'YES'){
                affTypeCode = 'CUR';
            }else{
                affTypeCode = 'PRI';
            }
        }
            pload.schoolAffiliationId = a[0].WDOMS_ID__c;
            pload.updateDtime = String.valueOf(a[0].LastModifiedDate); 
            pload.schoolAffiliationTypeCode = affTypeCode;             
            if(!String.isBlank(a[0].Account1__c)){
                pload.sfParentSchoolId = WDOMSService.getWDOMSIdByAccountId(a[0].Account1__c); 
            }
            if(!String.isBlank(a[0].Account2__c)){
                pload.sfSchoolId = WDOMSService.getWDOMSIdByAccountId(a[0].Account2__c); 
            }
            pload.endYear = a[0].YearTo__c; 
            pload.startYear = a[0].YearFrom__c; 
            pl.payload = pload;             
        return pl; 
    } 

    public static WDOMSSchoolProgramResponse.Payload buildSchoolProgramResponse(Id schAffId){     
        String affTypeCode='';              
        List<Account_Affiliation__c> a = WDOMSService.getAffiliation_School_N_Program_forWDOMS(schAffId);   
        WDOMSSchoolProgramResponse.Payload pl = new WDOMSSchoolProgramResponse.Payload();              
        WDOMSSchoolProgramResponse.Cls_payload pload = new WDOMSSchoolProgramResponse.Cls_payload();              
            if(!String.isBlank(a[0].Account1__c)){
                pload.sfschoolId = WDOMSService.getWDOMSIdByAccountId(a[0].Account1__c); 
            }
            if(!String.isBlank(a[0].Program__c)){
                pload.sfmdtprogramId = WDOMSService.getProgramWDOMSIdByProgId(a[0].Program__c); 
            }  
            pl.payload = pload;          
        return pl; 
    } 

    public static WDOMSAkaResponse.Payload buildSchAKAResponse(Id aksId){                  
        List<aka_Names__c> a = WDOMSService.getAKAforWDOMS(aksId);   
        WDOMSAkaResponse.Payload pl = new WDOMSAkaResponse.Payload();            
        WDOMSAkaResponse.cls_payload pload = new WDOMSAkaResponse.Cls_payload();  
            pload.sfakaId = a[0].WDOMS_ID__c;
            pload.akaName = a[0].Name;             
            pload.officialFormerNameFlag =  decodeBooleanToString(a[0].Official_Former_Name__c);
            pload.akaEffectiveFromYear = a[0].Year_From__c; 
            pload.akaEffectiveToYear = a[0].Year_To__c; 
            pload.sfschoolId = WDOMSService.getWDOMSIdByAccountId(a[0].Account__c);
            pload.language = a[0].Language__c;             
            pl.payload = pload;             
        return pl; 
    } 

    public static WDOMSMDTProgramDegreeTypeResponse.Payload buildMdtProgramDegreeTypeResponse(Id mdtDegId){                  
        List<Degree__c> a = WDOMSService.getDegreeInfoWDOMS(mdtDegId);           
        WDOMSMDTProgramDegreeTypeResponse.Payload pl = new WDOMSMDTProgramDegreeTypeResponse.Payload();            
        WDOMSMDTProgramDegreeTypeResponse.Cls_payload pload = new WDOMSMDTProgramDegreeTypeResponse.Cls_payload();  
            pload.sfmdtProgramDegreeTypeId= a[0].WDOMS_ID__c;
            pload.mdtProgramDegreeTypeDesc = a[0].Name;             
            pload.degreeAbbreviation =  a[0].Abbreviation__c;
            pload.activeFlag = decodeBooleanToString(a[0].Active__c); 
            pload.englishDegreeTitle = a[0].Title_Translation__c; 
            pload.englishDegreeAbbreviation = a[0].Abbreviation_Translation__c;                       
            pl.payload = pload;                      
        return pl; 
    } 

    public static WDOMSMDTProgramDegreeResponse.Payload buildMdtProgramDegreeResponse(Id obj2degId){                  
        List<Object2Degree__c> a = WDOMSService.getObject2DegreeInfoWDOMS(obj2degId);           
        WDOMSMDTProgramDegreeResponse.Payload pl = new WDOMSMDTProgramDegreeResponse.Payload();            
        WDOMSMDTProgramDegreeResponse.Cls_payload pload = new WDOMSMDTProgramDegreeResponse.Cls_payload();  
            pload.sfmdtProgramId= WDOMSService.getProgramWDOMSIdByProgId(a[0].Program__c);
            pload.sfmdtProgramDegreeId =     a[0].WDOMS_ID__c;         
            pload.sfmdtProgramDegreeTypeId =  WDOMSService.getDegreeWDOMSIdByDegreeId(a[0].Degree__c);
            pload.issuedBy = WDOMSService.getWDOMSIdByAccountId(a[0].Account__c); 
                       
            pl.payload = pload;                        
        return pl; 
    }
    
    public static WDOMSMdtGradYearResponse.Payload buildMdtGradYearResponse(Id obj2degId){                  
        List<Object2Degree__c> a = WDOMSService.getObject2DegreeInfoWDOMS(obj2degId);  
        WDOMSMdtGradYearResponse.Payload pl = new WDOMSMdtGradYearResponse.Payload();            
        WDOMSMdtGradYearResponse.Cls_payload pload = new WDOMSMdtGradYearResponse.Cls_payload();  
            pload.medSchoolCode= a[0].Account__r.Medschool_Code__c;
            pload.gradYear =     a[0].Graduation_Year__c;         
            pload.yearOkFlag =  decodeBooleanToString(a[0].Year_Ok__c);
            pload.medDegreeName = a[0].Degree__r.Name; 
            pload.medLicName = a[0].Medical_License_Name__c;                        
            pl.payload = pload;                        
        return pl; 
    } 
 


    public static void raiseplatformEventforWDOMS(String objType, id objId, string operationType){

        string payload ='';         
        WDOMSRequest__e wr = new WDOMSRequest__e();     
        string paramvalues = 'paramvalues - objType = '+objType+' objId ='+objId+'operationType ='+operationType;        
        
        switch on objType {
            when 'School' {                              
                WDOMSAccountResponse.Payload ar = buildAccountResponse(objId);                 
                ar.operation = operationType; 
                ar.subEntity = ''; 
                ar.entity = objType; 
                wr.payload__c = json.serialize(ar);                  
                        
            }
            when 'schoolLanguage' {
                WDOMSAccLangResponse.Payload ar = buildAccLanguageResponse(objId);  
                ar.operation = operationType; 
                ar.subEntity = ''; 
                ar.entity = objType;                                
                wr.payload__c = json.serialize(ar);                   
            }
            when 'schoolContactContactInfo' {                               
                WDOMSAccContactContactInfoResponse.Payload ar = buildSchContactContactInfoResponse(objId);                 
                 ar.operation = operationType; 
                 ar.subEntity = ''; 
                 ar.entity = objType; 
                 wr.payload__c = json.serialize(ar);                   
             }
             when 'schoolContactInfo' {                                               
                WDOMSAccContactInfoResponse.Payload ar = buildSchContactInfoResponse(objId);                 
                 ar.operation = operationType; 
                 ar.subEntity = ''; 
                 ar.entity = objType; 
                 wr.payload__c = json.serialize(ar);                   
             }
             when 'schoolAffiliation' {  
                WDOMSAccountAffiliationResponse.Payload ar = buildSchoolAffiliationResponse(objId);                                                         
                 ar.operation = operationType; 
                 ar.subEntity = ''; 
                 ar.entity = objType; 
                 wr.payload__c = json.serialize(ar);                   
             }  
             when 'schoolprogram' {  
                WDOMSSchoolProgramResponse.Payload ar = buildSchoolProgramResponse(objId);                                                         
                 ar.operation = operationType; 
                 ar.subEntity = ''; 
                 ar.entity = objType; 
                 wr.payload__c = json.serialize(ar);                   
             }  

             when 'schoolAka' {                  
                WDOMSAkaResponse.Payload  ar = buildSchAKAResponse(objId);                                                     
                 ar.operation = operationType; 
                 ar.subEntity = ''; 
                 ar.entity = objType; 
                 wr.payload__c = json.serialize(ar);                   
             }
             when 'schoolURL'{
                WDOMSAccURLResponse.Payload ar = buildSchUrlResponse(objId);                 
                 ar.operation = operationType; 
                 ar.subEntity = ''; 
                 ar.entity = objType; 
                 wr.payload__c = json.serialize(ar);                   
             }
             when 'MDTProgram'{
                WDOMSMdtProgramResponse.Payload ar = buildMdtProgramResponse(objId);                 
                 ar.operation = operationType; 
                 ar.subEntity = ''; 
                 ar.entity = objType; 
                 wr.payload__c = json.serialize(ar);                   
             }
             when 'MDTProgramDegreeType'{
                WDOMSMDTProgramDegreeTypeResponse.Payload ar = buildMdtProgramDegreeTypeResponse(objId);                 
                 ar.operation = operationType; 
                 ar.subEntity = ''; 
                 ar.entity = objType; 
                 wr.payload__c = json.serialize(ar);                   
             }   
             when 'MDTProgramDegree'{
                WDOMSMDTProgramDegreeResponse.Payload ar = buildMdtProgramDegreeResponse(objId);                 
                 ar.operation = operationType; 
                 ar.subEntity = ''; 
                 ar.entity = objType; 
                 wr.payload__c = json.serialize(ar);                   
             }             
             when 'MDTGradYear'{
                WDOMSMdtGradYearResponse.Payload ar = buildMdtGradYearResponse(objId);                 
                 ar.operation = operationType; 
                 ar.subEntity = ''; 
                 ar.entity = objType; 
                 wr.payload__c = json.serialize(ar);                   
             }                                  
        }
        sIds.add(objId);                
        logMessage(' Payload before raising event for  '+objType+' is : ' +wr);   
        if (wr !=null){
            Database.SaveResult sr = EventBus.publish(wr); 
            if (sr.isSuccess()) {
                sIds.add(sr.getId());
                logMessage('WDOMS Response publish successfully for '+objType);                              
            } else {
                String logMessage = '';
                for(Database.Error err : sr.getErrors()) {                    
                    logMessage += err.getMessage() + '--';
                    sIds.add(sr.getId());                            
                }
                logMessage(logMessage);           
            }   
        }
        else{
            logMessage('Object type not found  '+objType);  
        }

    } 

    public static void raiseplatformEventforWDOMS(String objType, List<id> objIds, string operationType){
        string payload ='';         
        WDOMSRequest__e wr = new WDOMSRequest__e();                
        for (id objId :  objIds ){
            raiseplatformEventforWDOMS(objType, objId, operationType ); 
        }        
    } 

    public static void raisePEforProgramLanguage(String objType, Map<Id, String> programLangMap , String operationType){        
       
        List<String> messages = new List<String> (); 
        for (Id key: programLangMap.keySet()){
        //for( Id objId: objIds){
            string objId = key; 
            string [] tempLangs = programLangMap.get(key).split(';');             

            system.debug( 'tempLangs --->'+tempLangs ); 
            string wdomsIdforProgram = WDOMSService.getProgramWDOMSIdByProgId(objId);
            if(!string.isBlank(wdomsIdforProgram)){
                for(string lang: tempLangs ){
                    WDOMSRequest__e wr = new WDOMSRequest__e(); 
                    WDOMSMDTProgramLanguageResponse.Payload plr = new WDOMSMDTProgramLanguageResponse.Payload(); 
                    WDOMSMDTProgramLanguageResponse.Cls_payload pload = new WDOMSMDTProgramLanguageResponse.Cls_payload();             
                    pload.language = lang; 
                    pload.sfmdtProgramId = wdomsIdforProgram; 
                    plr.payload = pload;
                    plr.entity = objType; 
                    plr.operation = operationType;                   
                    wr.payload__c = json.serialize(plr);
                    sIds.add(objId); 
                    messages.add(' Payload before raising event for  '+objType+' is : ' +wr);                     
                    if (wr !=null){
                        Database.SaveResult sr = EventBus.publish(wr); 
                        if (sr.isSuccess()) {
                            sIds.add(sr.getId());
                            messages.add('WDOMS Response publish successfully for '+objType);                                             
                        } else {
                            String logMessage = '';
                            for(Database.Error err : sr.getErrors()) {                    
                                logMessage += err.getMessage() + '--';
                                sIds.add(sr.getId());                            
                            }
                            messages.add(logMessage);                                      
                        }   
                    }
                    else{                        
                        messages.add('Object type not found  '+objType);
                    }
                }
            }
        }
        if(messages.size()>0){
            logMessages(messages); 
        }
    }

    public static Boolean logMessage(String message){
        if(String.isNotBlank(message)){
            Log_Message__c logMsg = new Log_Message__c();
            logMsg.Exception__c	= message;
            logMsg.Record_Id__c = String.valueOf(sIds);
            logMsg.Source__c = 'WDOMSResponseServices';
            logMsg.Date_Time_Logged__c = DateTime.now();            
            if(!Test.isRunningTest() && Log_Message__c.SObjectType.getDescribe().isCreateable()) {
                insert logMsg;
            }
            return true;
        }
        return false;
    }
    
    public static void logMessages(List<String> messages){
        for(String msg: messages){
            logMessage(msg);
        }
    } 

}