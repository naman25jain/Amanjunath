@isTest
public with sharing class WDOMSResponseServiceTestFactory {
    
    public static string adminEmailtest { 
    	get {
        	return 'testerSFAdmin@unknownmail.com';
    	}
    }
    public static string reviewerEmailtest { 
    	get {
        	return 'testerReviewer@unknownmail.com';
    	}
    }
    
    private static CurrentEntityIDSequence__c settingsInstance;
        
    static {
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        upsert settingsInstance;
    }
    @TestSetup
    public static void servicePageSetup() {

        //Create user 
        Id profId=[Select id from profile where name='Salesforce Reviewer' LIMIT 1].id;
        date birthdate1 = date.valueOf('2000-01-01');
        string emailtest = reviewerEmailtest;
        String userName = reviewerEmailtest;
        string lastname = 'Last';
        string firstname = 'First';
        User userRev = new User(alias='userRev',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=profId,country='United States',IsActive=true, timezonesidkey='America/Los_Angeles',username=username);       
        insert UserRev; 

        Id profId2=[Select id from profile where name='Salesforce Admin' LIMIT 1].id;        
         emailtest = adminEmailtest;
         userName = adminEmailtest;
         lastname = 'Admin';
         firstname = 'First';
        User userAdmin = new User(alias='sfAdmin',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=profId2,country='United States',IsActive=true,timezonesidkey='America/Los_Angeles',username=username);       
        insert userAdmin; 

        Id accountId; 
        Id programId; 
        Id accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Entity').getRecordTypeId();
        Id affRectype = Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Educational Program').getRecordTypeId();
        Id progRectype = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Educational Program').getRecordTypeId();
        Id affRectypeAccAff = Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Academic Affiliation').getRecordTypeId();
        Account acc= new Account(); 

        acc.RecordTypeId = accRectype; 
        acc.School__c= true;
        acc.WDOMS_ID__c = '1234';
        acc.Medschool_Code__c = '098123';
        acc.Name = 'MedicalSchoolTest';
        acc.BillingCountry= 'Nepal'; 
        acc.BillingStreet = '3624 Market ST';
        acc.BillingCity = 'Philadelphia';
        acc.Alternative_Name__c = 'MST';
        acc.website ='www.mst.org';
        acc.Description =' n/A';
        acc.Year_Opened__c ='2004';
        acc.Entrance_Exam_Required__c = '';
        acc.Total_Enrollment__c = '180';
        acc.Institution_ID__c = '1234';
        acc.sch_School_Type__c = 'Medical School';
        acc.sch_Active__c = 'Yes';        
        acc.sch_Year_Closed__c='';
        acc.sch_Publish__c = true;

        acc.Curr_Other_Country_Flag__c ='Yes';
        acc.Tuition_Paid_Portion__c = 'All';
        acc.Clinical_Facilities_Flag__c = 'Yes';
        insert acc;
        accountId = acc.Id; 
        
        //Create Program
        Program__c p = new Program__c(); 
        p.Name = 'Test Program'; 
        p.Account__c = accountId; 
        p.WDOMS_ID__c = '23456'; 
        p.RecordTypeId = progRectype; 
        p.Date_Curriculum_Last_Visited__c = Date.newInstance(1960, 2, 19);
        p.Language_s_of_Instruction__c = 'French;English'; 
        insert p; 
        programId = p.Id; 

        //create account language 
        Account_Language__c al = new Account_Language__c(); 
        al.account__c = accountId; 
        al.Language__c = 'English'; 
        al.WDOMS_ID__c = '9999'; 
        insert al; 

        //create contact contact object (additional info)
        Additional_Info__c ai = new Additional_Info__c(); 
        ai.account__c = accountId; 
        ai.WDOMS_ID__c = '8888';
        ai.Type__c = 'Email'; 
        ai.Value__c = 'abcd@ecfmg.org'; 
        insert ai; 

        //create school url
        Additional_Info__c u = new Additional_Info__c(); 
        u.account__c = accountId; 
        u.WDOMS_ID__c = '9999';
        u.Type__c = 'URL'; 
        u.Value__c = 'www.test.ecfmg.org'; 
        insert u; 

        account a2= new Account(); 
        a2.name = 'New school'; 
        a2.BillingCountry= 'Nepal';
        insert a2; 

        //create Account Affiliation 
        Account_Affiliation__c aa = new Account_Affiliation__c();
        aa.RecordTypeId = affRectypeAccAff; 
        aa.Account1__c =accountId;        
        aa.Account2__c = a2.Id; 
        aa.WDOMS_ID__c = '7777'; 
        aa.YearFrom__c = '2002';
        aa.YearTo__c = '2010'; 
        aa.Active__c= 'YES';        
        insert aa; 
        
        Account_Affiliation__c paa = new Account_Affiliation__c(); 
        paa.RecordTypeId = affRectype; 
        paa.Account1__c =accountId; 
        paa.Program__c= programId; 
        paa.WDOMS_ID__c = '2222'; 
        paa.Active__c= 'NO';
        insert paa; 


        //create AKA
        aka_Names__c aka = new aka_Names__c();
        aka.Name = 'BN AKA Test'; 
        aka.Account__c = accountId; 
        aka.Year_From__c = '1980';
        aka.Year_To__c =  '1991'; 
        aka.WDOMS_ID__c = '12345';
        insert aka; 

        //Create contentNote 
        ContentNote cn = new ContentNote();
        cn.Title = 'Test'; 
        cn.content = Blob.valueOf('This is unit test'); 
        insert cn;       

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = accountId;
        cdl.ContentDocumentId = cn.Id; 
        insert cdl; 


        Id tskRectype = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Comments').getRecordTypeId();
        task accImedComment = new task(); 
        accImedComment.Description = 'This is IMED comment'; 
        accImedComment.Comment_Type__c = 'IMED';
        accImedComment.recordTypeId = tskRectype; 
        accImedComment.WhatId = accountId; 
        insert accImedComment; 

        task accCurrComment = new task(); 
        accCurrComment.Description = 'This is Curriculum comment'; 
        accCurrComment.Comment_Type__c = 'Curriculum';
        accCurrComment.recordTypeId = tskRectype; 
        accCurrComment.WhatId = accountId; 
        insert accCurrComment; 

        task accIntComment = new task(); 
        accIntComment.Description = 'This is Internal comment'; 
        accIntComment.Comment_Type__c = 'Internal';
        accIntComment.recordTypeId = tskRectype; 
        accIntComment.WhatId = accountId; 
        insert accIntComment; 

        task prgImedComment = new task(); 
        prgImedComment.Description = 'This is IMED comment'; 
        prgImedComment.Comment_Type__c = 'IMED';
        prgImedComment.recordTypeId = tskRectype; 
        prgImedComment.WhatId = programId; 
        insert prgImedComment; 

        task prgCurrComment = new task(); 
        prgCurrComment.Description = 'This is Curriculum comment'; 
        prgCurrComment.Comment_Type__c = 'Curriculum';
        prgCurrComment.recordTypeId = tskRectype; 
        prgCurrComment.WhatId = programId; 
        insert prgCurrComment; 

        task prgIntComment = new task(); 
        prgIntComment.Description = 'This is Internal comment'; 
        prgIntComment.Comment_Type__c = 'Internal';
        prgIntComment.recordTypeId = tskRectype; 
        prgIntComment.WhatId = programId; 
        insert prgIntComment; 


        Degree__c d = new Degree__c(); 
        d.Name = 'Degree Title Test'; 
        d.Abbreviation__c = 'DTT'; 
        d.WDOMS_ID__c = '6611'; 
        insert d; 

        //create object2degree
        Object2Degree__c o2d = new Object2Degree__c(); 
        o2d.Account__c = accountId; 
        o2d.Program__c = programId; 
        o2d.Degree__c = d.Id; 
        o2d.Graduation_Year__c = '2014'; 
        o2d.WDOMS_ID__c = '6666'; 
        insert o2d; 


    }
}