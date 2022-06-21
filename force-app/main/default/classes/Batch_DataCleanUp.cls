public class Batch_DataCleanUp implements Database.Batchable<sObject>,Database.Stateful{
    
    public integer currentSequence;
    public boolean lastSequence = false;
    public string query;
    public boolean allOrNone;
    
    public Batch_DataCleanUp(string query,integer seq, boolean allOrNone){
        this.query = string.isNotEmpty(query) ? query : getSObjectInfoToDelete(seq);
        this.allOrNone = allOrNone;
        this.currentSequence = seq;
    }
    public Batch_DataCleanUp() {}
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('scope'+scope);
        try{
            if('User' == ((Id)scope[0].get('Id')).getSObjectType().getDescribe().getName()){
                List<User> lstUsers = new List<User>();
                set<Id> uId = new set<Id>();
                List<Contact> lstContacts = new List<Contact>();
                for(sobject u : scope){
                    lstUsers.add(new User(Id = ((Id)u.get('Id')), isactive = false)) ;
                    uId.add((Id)u.get('Id'));
                }
                 if(lstUsers != null && !lstUsers.isempty()){
                    update lstUsers;
                }
                for(User u1:[Select Id, contactId from User where Id=:uId and isActive=false]){
                    lstContacts.add(new Contact(Id=((Id)u1.get('contactId')),Active_Entity_Portal_User__c=false));
                }
                if(lstContacts !=null && !lstContacts.isempty()){
                    update lstContacts;
                }
            }
            
            else{
                deleteSObjects(scope,allOrNone); //or use database.delete
            }
        }catch(Exception ex){
            //error logging
            system.debug('ERROR:'+ex);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
        
        if(lastSequence!=true){
            ++currentSequence;
            String query = getSObjectInfoToDelete(currentSequence);
            if(string.isNotEmpty(query)){
                database.executeBatch(new Batch_DataCleanUp(null,currentSequence,allOrNone));
            }
        }
    }
    
    public List<Database.DeleteResult> deleteSObjects(List<SObject> recordsToDelete, Boolean allOrNone){
        
        try{
            
            List<Id> sIdS= new List<Id>();
            List<Database.DeleteResult> results = Database.delete(recordsToDelete, allOrNone);
            for (Database.DeleteResult result: results)
            {
                if (!result.isSuccess())
                {
                    //Again, this is only for a single record
                    List<Database.Error> errors = result.getErrors();
                    //error logging
                }
                else{
                    sIdS.add(result.getId());
                }
            }
            if(!sIdS.isEmpty()){
                Database.emptyRecycleBin(sIdS);
            }
        }catch(Exception ex){
            //error logging
            system.debug('ERROR:'+ex);
        }
        return null;
    }
    
    public string getSObjectInfoToDelete(Integer sequence){
        try{
            Batch_DataCleanUpConfig__mdt mdt = [Select Id, sObject_API_Name__c, Delete_Old_Data_N_Days__c, Where_Clause__c,is_LastSequence__c from Batch_DataCleanUpConfig__mdt where sequence__c =: sequence
                                                and Is_Active__c = true];
            
            if(mdt.is_LastSequence__c==true){
                lastSequence = true;
            }
            
            return prepareQuery(mdt);
        }catch(Exception ex){
            //error logging
            system.debug('ERROR:'+ex);
        }
        return null;
    }
    
    public string prepareQuery(Batch_DataCleanUpConfig__mdt mdt){
        string query = 'Select Id from '+mdt.sObject_API_Name__c;
        if(mdt.Delete_Old_Data_N_Days__c != null && mdt.Delete_Old_Data_N_Days__c > 0){
            Datetime dtOld = system.now().adddays(-1 * Integer.valueof(mdt.Delete_Old_Data_N_Days__c));
            string formattedOldDate = dtOld.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            if(mdt.sObject_API_Name__c!='User'){
                if(string.isnotEmpty(mdt.Where_Clause__c))
                    return query +' where createddate <=  '+formattedOldDate+' and '+mdt.Where_Clause__c;
                else
                    return query +' where createddate <=  '+formattedOldDate; 
            }
            else{
                if(string.isnotEmpty(mdt.Where_Clause__c))
                    return query +' where LastLoginDate <=  '+formattedOldDate+' and '+mdt.Where_Clause__c;
                else
                    return query +' where LastLoginDate <=  '+formattedOldDate; 
            }
            
        }
        else if(string.isnotEmpty(mdt.Where_Clause__c)){
            return query +' where '+mdt.Where_Clause__c;
        }
        system.debug('query'+query);
        return query;
    }
}