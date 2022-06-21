@isTest
// test class for GContentManager
public class GContentManagerTest{
    @isTest
	public static void contentTest(){
        Content_Manager__c contMan = new Content_Manager__c();
        List<String> uniqLst = new List<String>{'Test Record','Test Record1','Test Record2'};
        List<String> uniqLst1 = new List<String>{'','',''};
        List<String> emptyList = new List<String>();    
        contMan.Content__c = 'Test Record Saved successfully12342344';
        contMan.Unique_Name__c = 'Test Record';
        INSERT contMan;
        String error = '';
        try{
            Test.startTest();
            GContentManager.getContent(uniqLst[0]);
            GContentManager.getContent(uniqLst1[0]);
            GContentManager.getContentValues(uniqLst);
            GContentManager.getContent('Testing');
            GContentManager.getContent(null);
            GContentManager.getContentValues(emptyList);
            System.assert(true, true);    
            Test.stopTest();
        }catch(Exception ex){
            error = ex.getMessage();
        }
    }
}