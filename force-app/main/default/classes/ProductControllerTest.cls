@isTest
public class ProductControllerTest {
    @isTest
    static void testProductController(){
        Product2 p = new Product2();
        p.Name = 'Step 1 Exam';
        p.Description='Test Product Entry For Product';
        p.productCode = 'SFDCPanther-123';
        p.IsActive = true;
        insert p;
        //ProductController pc = new ProductController();
        //CustomMetadataDAOTest.setMetadata('SELECT Product_Name__c FROM Case_Record_Type_To_Product__mdt WHERE Case_Record_Type__c =: caseType AND Exam_Type__c =: caseExam AND Active__c =: true WITH SECURITY_ENFORCED',(List<Case_Record_Type_To_Product__mdt>) JSON.deserialize('[{"Product_Name__c":"Test Product","Case_Record_Type__c" :"Non_USMLE_Transcript","Exam_Type__c":"Pass","Active__c":"true"}]',List<Case_Record_Type_To_Product__mdt>.class ));
        /*Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
    	customMetadata.fullName = 'Case_Record_Type_To_Product.Not_Found_Code';
        customMetadata.label = 'Not_Found_Code';        
        Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
    	customField1.field = 'Product_Name__c';
    	customField1.value = 'Test Product';        
        Metadata.CustomMetadataValue customField2 = new Metadata.CustomMetadataValue();
    	customField2.field = 'Case_Record_Type__c';
    	customField2.value = 'Non_USMLE_Transcript';        
        Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue();
    	customField3.field = 'Exam_Type__c';
    	customField3.value = 'Pass';        
        customMetadata.values.add(customField1);
        customMetadata.values.add(customField2);
        customMetadata.values.add(customField3);
    	Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
    	mdContainer.addMetadata(customMetadata);        
        //Case_Record_Type_To_Product__mdt caseRtype2Product = new Case_Record_Type_To_Product__mdt();
        //caseRtype2Product.Product_Name__c = 'Test Product';
        //caseRtype2Product.Case_Record_Type__c = 'Non_USMLE_Transcript';
        //caseRtype2Product.Exam_Type__c = 'Pass';
        insert caseRtype2Product;        
        //Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();*/
        ProductController.getProductsRelatedToCase('Exam_Registration', 'USMLE Step 1');
    }
    @isTest
    static void testProductControllerEmpty(){
        new ProductController();
        String errorMsg = '';
        try{
            ProductController.getProductsRelatedToCase('', '');
        }catch(Exception ex){
            errorMsg = ex.getMessage();
        }
        system.assert(String.isNotBlank(errorMsg),'No error message');
    }
}