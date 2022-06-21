@isTest 
public class AKANamesDuplicateMatchModelTest {
    @isTest public static void comparetest(){
                Integer result = 1;
        		Integer Score= 1;
                AKANamesDuplicateMatchModel model=new AKANamesDuplicateMatchModel();
                model.Score=100;
        		model.ID='test';
       			model.Name ='test';
               	model.AccountName ='test';
                model.compareTo(model);
    }
}