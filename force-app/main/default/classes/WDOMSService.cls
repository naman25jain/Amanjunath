public with sharing class WDOMSService {
    public static List<account> getAccountforWDOMS(Id accid){
        List<account> accs= ([
                            SELECT 
                            Id,
                            WDOMS_ID__c,
                            Medschool_Code__c,
                            Name,
                            isDeleted,
                            BillingStreet,                            
                            BillingCity,
                            BillingPostalCode,
                            BillingStateCode,
                            BillingCountry, 
                            BillingCountryCode,
                            University_Name__c,
                            Deleted__c,
                            website,
                            Description,
                            sch_Year_Opened__c,
                            Curriculum_Duration__c,
                            Institution_ID__c,
                            sch_School_Type__c,
                            sch_Active__c,
                            sch_Year_Closed__c,
                            sch_Publish__c,
                            Unique_Medical_School_ID__c,
                            BillingLatitude, 
                            BillingLongitude,
                            LastModifiedDate,                        
                            XREF_MS_Code__c,
                            Add_IMED_Date__c,
                            Entrance_Exam_Required__c,
                            Total_Enrollment__c,
                            Name_Language__c,
                            Curr_Other_Country_Flag__c, 
                            Tuition_Paid_Portion__c,
                            Clinical_Facilities_Flag__c,
                            Clinical_Percentage_of_Curriculum__c,                            
                            Genders_Admitted__c,
                            WDOMS_Added_Date__c,
                            ISO_Subdivision__c,
                            sch_Public_Private__c                            
                            FROM Account
                            WHERE Account.Id  =: accid 
                            WITH SECURITY_ENFORCED
                            LIMIT 1
                            ]); 
        return accs;         
    }


    public static List<Task> getComments (Id recId){        
        String returnNote =''; 
	    Set<Id> docIdSet = new Set<Id>();		
        string myBlob; 

        Id tskRectype = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Comments').getRecordTypeId();
        List<Task> ts = [SELECT Comment_Type__c, Description 
                        FROM Task 
                        WHERE RecordTypeId =: tskRectype
                        AND WhatId =: recId                        
                        WITH SECURITY_ENFORCED
                        ORDER BY LastModifiedDate ASC]; 
        return ts; 
       
    }

    public static List<Program__c> getProgramforWDOMS(Id accid){
        List<Program__c> progs= ([
                            SELECT                             
                            Account__c,
                            Accreditation_Effective_Date__c,
                            Accreditation_Name__c,
                            Accredited_Length_Training__c,
                            Active__c,
                            Address1__c,
                            Address2__c,
                            Address3__c,
                            Address__c,
                            City__c,Comments_Curriculum__c,
                            Comments_Internal__c,
                            Comments_Publishedl__c,
                            CreatedDate,
                            Curriculum_Duration_Yrs__c,
                            Date_Curriculum_Last_Visited__c,
                            Dicipline_Profession__c,
                            Distance_Education__c,
                            Entrance_Exam_Required__c,
                            Foreign_Students__c,
                            Genders_Admitted__c,
                            Id,
                            Internship_Duration_Mos__c,
                            Internship_Required__c,
                            Interview_Required__c,
                            IsDeleted,
                            Language_s_of_Instruction__c,                                                        
                            Name,
                            Operational_Status__c,
                            Phone__c,
                            Prerequisite__c,
                            Program_Code__c,
                            Program_Id__c,
                            Program_Year__c,
                            RecordTypeId,
                            Social_Service_Duration__c,
                            Social_Service_Required__c,
                            Specialty__c,
                            State__c,
                            Students_Who_Pay_Tuition__c,                            
                            URL__c,
                            Year_Instruction_Ended__c,
                            Year_Instruction_Started__c,
                            Zip__c,
                            WDOMS_ID__c,
                            LastModifiedDate
                            FROM Program__c 
                            WHERE Account__c  =: accid                             
                            WITH SECURITY_ENFORCED
                            LIMIT 1
                             ]);         
        return progs;         
    }

    public static List<Program__c> getProgramforWDOMSbyProgramId(Id progId){
        List<Program__c> progs= ([
                            SELECT                             
                            Account__c,
                            Accreditation_Effective_Date__c,
                            Accreditation_Name__c,
                            Accredited_Length_Training__c,
                            Active__c,
                            Address1__c,
                            Address2__c,
                            Address3__c,
                            Address__c,
                            City__c,Comments_Curriculum__c,
                            Comments_Internal__c,
                            Comments_Publishedl__c,
                            CreatedDate,
                            Curriculum_Duration_Yrs__c,
                            Date_Curriculum_Last_Visited__c,
                            Dicipline_Profession__c,
                            Distance_Education__c,
                            Entrance_Exam_Required__c,
                            Foreign_Students__c,
                            Genders_Admitted__c,
                            Id,
                            Internship_Duration_Mos__c,
                            Internship_Required__c,
                            Interview_Required__c,
                            IsDeleted,
                            Language_s_of_Instruction__c,                                                        
                            Name,
                            Operational_Status__c,
                            Phone__c,
                            Prerequisite__c,
                            Program_Code__c,
                            Program_Id__c,
                            Program_Year__c,
                            RecordTypeId,
                            Social_Service_Duration__c,
                            Social_Service_Required__c,
                            Specialty__c,
                            State__c,
                            Students_Who_Pay_Tuition__c,                            
                            URL__c,
                            Year_Instruction_Ended__c,
                            Year_Instruction_Started__c,
                            Zip__c,
                            WDOMS_ID__c,
                            ECFMG_OK__c,
                            Country__c,
                            Local_licensure_eligibility__c, 
                            LastModifiedDate
                            FROM Program__c 
                            WHERE Id  =: progId                             
                            WITH SECURITY_ENFORCED
                            LIMIT 1
                             ]);         
        return progs;         
    }

    public static List<Account_Language__c> getAccountLanguageforWDOMS(Id acclangid){
        List<Account_Language__c> accLangs= ([
                            SELECT 
                            Id,
                            Name,
                            Account__c,
                            Language__c,
                            WDOMS_ID__c,                           
                            LastModifiedDate,
                            Account__r.WDOMS_ID__c 
                            FROM Account_Language__c
                            WHERE Id  =: acclangid 
                            WITH SECURITY_ENFORCED
                            LIMIT 1
                             ]); 
        return accLangs;         
    }

    public static List<aka_Names__c> getAKAforWDOMS(Id akaId){
        List<aka_Names__c> aka = ([
                            SELECT 
                            Id,
                            Name,
                            Account__c,
                            Translation__c, 
                            Year_From__c, 
                            Year_To__c,
                            WDOMS_ID__c,
                            Language__c, 
                            Official_Former_Name__c, 
                            LastModifiedDate 
                            FROM aka_Names__c
                            WHERE Id  =: akaId 
                            WITH SECURITY_ENFORCED
                            LIMIT 1
                             ]); 
        return aka;         
    }

    public static List<Account_Affiliation__c> getAffiliation_School_N_Program_forWDOMS(Id affiliationId){         
        List<Account_Affiliation__c> accAffi = ([
                            SELECT 
                            Id,
                            Name,
                            Account1__c,
                            Account2__c, 
                            Account1__r.WDOMS_ID__c,
                            Account2__r.WDOMS_ID__c,
                            Program__c,                              
                            YearFrom__c, 
                            YearTo__c,
                            Active__c,
                            WDOMS_ID__c, 
                            LastModifiedDate 
                            FROM Account_Affiliation__c
                            WHERE Id  =: affiliationId 
                            WITH SECURITY_ENFORCED
                            LIMIT 1
                             ]); 
        return accAffi;         
    }

    public static List<Additional_Info__c> getSchoolContactContactInfoWDOMS(Id infoId){                
       List<Additional_Info__c> accAffi = ([
                           SELECT 
                           Id,
                           Name,
                           Account__c,
                           Account__r.WDOMS_ID__c,
                           Contact__c, 
                           Contact__r.WDOMS_ID__c,
                           Type__c, 
                           Value__c,
                           Description__c,
                           WDOMS_ID__c, 
                           Language__c, 
                           LastModifiedDate 
                           FROM Additional_Info__c
                           WHERE Id  =: infoId 
                           WITH SECURITY_ENFORCED
                           LIMIT 1
                            ]);                                   
       return accAffi;         
    }
    
    public static List<Object2Degree__c> getObject2DegreeInfoWDOMS(Id o2dId){    
    List<Object2Degree__c> o2d = ([
                       SELECT 
                       Id,
                       Name,
                       Account__c,
                       Account__r.Medschool_Code__c,
                       Program__c,
                       Program__r.Name, 
                       Degree__c,
                       Degree__r.Name,
                       Graduation_Year__c,
                       RecordTypeId,
                       WDOMS_ID__c,
                       Year_Ok__c,
                       Medical_License_Name__c,  
                       LastModifiedDate 
                       FROM Object2Degree__c
                       WHERE Id  =: o2dId 
                       WITH SECURITY_ENFORCED
                       LIMIT 1
                        ]); 
    return o2d;         
    }

    public static List<Degree__c> getDegreeInfoWDOMS(Id degreeId){        
        List<Degree__c> lDegree = ([
                           SELECT 
                           Id,
                           Name,
                           Active__c,
                           Abbreviation__c,                           
                           Abbreviation_Translation__c, 
                           Title_Translation__c,
                           WDOMS_ID__c, 
                           LastModifiedDate 
                           FROM Degree__c
                           WHERE Id  =: degreeId 
                           WITH SECURITY_ENFORCED
                           LIMIT 1
                            ]); 
        return lDegree;         
    }
    

    public static string getWDOMSIdByAccountId(String accId){         
        List<account> accs= ([
            SELECT 
            Id,
            WDOMS_ID__c
            FROM account 
            WHERE Id  =: accId  
            WITH SECURITY_ENFORCED
            LIMIT 1
            ]);            
            return accs[0].WDOMS_ID__c;        
    }
   
    public static string getMedSchoolCodeByAccountId(String accId){         
        List<account> accs= ([
            SELECT 
            Id,
            Medschool_Code__c
            FROM account 
            WHERE Id  =: accId  
            WITH SECURITY_ENFORCED
            LIMIT 1
            ]);            
            return accs[0].Medschool_Code__c;        
    }

    public static string getProgramWDOMSIdByProgId(String progId){  
        String progWdomsId;     
        List<Program__c> progs= ([
            SELECT 
            Id,
            WDOMS_ID__c
            FROM Program__c 
            WHERE Id  =: progId  
            WITH SECURITY_ENFORCED
            LIMIT 1
            ]);  
            if ( progs.size () > 0) {
                progWdomsId = progs[0].WDOMS_ID__c; 
            }      
            return progWdomsId;        
    }

    public static string getDegreeWDOMSIdByDegreeId(String degId){         
        List<Degree__c> degs= ([
            SELECT 
            Id,
            WDOMS_ID__c
            FROM Degree__c 
            WHERE Id  =: degId  
            WITH SECURITY_ENFORCED
            LIMIT 1
            ]);            
            return degs[0].WDOMS_ID__c;        
    }

    public static List<Account_Language__c> getAccountLanguageByAccountId(string accId){        
        List<Account_Language__c> accLanguages = ([
            SELECT Id 
            FROM Account_Language__c
            WHERE Account__c =: accId
            WITH SECURITY_ENFORCED            
        ]);
        return accLanguages; 
    }

    public static List<aka_Names__c> getAKAIdByAccountId(string accId){        
        List<aka_Names__c> listAkas  = ([
            SELECT Id 
            FROM aka_Names__c
            WHERE Account__c =: accId
            WITH SECURITY_ENFORCED            
        ]);
        return listAkas; 
    }

    public static List<Additional_Info__c> getAdditionalInfoByAccountId(string accId){        
        List<Additional_Info__c> additionInfos  = ([
            SELECT Id, 	
                Contact__c, 
                Type__c,
                Language__c
            FROM Additional_Info__c
            WHERE Account__c =: accId
            WITH SECURITY_ENFORCED            
        ]);
        return additionInfos; 
    }

    public static List<Account_Affiliation__c> getAccountAffiliationAccountId(string accId){        
        List<Account_Affiliation__c> accAffiliations  = ([
            SELECT Id, 	
                Program__c, 
                Account1__c,
                Account2__c,
                recordType.Name
            FROM Account_Affiliation__c
            WHERE (Account1__c =: accId
            OR Account2__c =: accId)
            WITH SECURITY_ENFORCED            
        ]);
        return accAffiliations; 
    }

    public static List<Account_Affiliation__c> getAccountAffiliationByProgramId(string progId){        
        List<Account_Affiliation__c> accAffiliations  = ([
            SELECT Id, 	
                Program__c, 
                Account1__c,
                Account2__c,
                recordType.Name
            FROM Account_Affiliation__c
            WHERE Program__c =: progId
            AND recordType.Name =: Constants.PROGRAM_TYPE_EDUCATIONAL_PROGRAM
            WITH SECURITY_ENFORCED            
        ]);
        return accAffiliations; 
    }

}