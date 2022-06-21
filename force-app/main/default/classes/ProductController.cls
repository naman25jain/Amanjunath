public with sharing class ProductController {
    public ProductController() {
    }
    @AuraEnabled
    public static Product2[] getProductsRelatedToCase(string caseType, string caseExam){
        try{            
            Case_Record_Type_To_Product__mdt[] caseToProduct = [SELECT Product_Name__c 
                                                        FROM Case_Record_Type_To_Product__mdt 
                                                        WHERE Case_Record_Type__c =: caseType
                                                        AND Exam_Type__c =: caseExam
                                                        AND Active__c =: true
                                                        WITH SECURITY_ENFORCED];
            List<string> productNames = new List<string>();
            for(Case_Record_Type_To_Product__mdt c2p : caseToProduct){
                productNames.add(c2p.Product_Name__c);
            }
            Product2[] products = getProductsByName(productNames);
            if(!products.isEmpty()){
                return products;
            }                
        }
        catch(Exception e){
            throw e; 
        }
        return null;
    }
    @AuraEnabled
    public static Product2[] getProductsByName(List<string> productNames){
        try{
            Boolean activeFlag = true;
            Product2[] products = [SELECT Id, Name FROM Product2 WHERE IsActive =: activeFlag AND Name IN :productNames WITH SECURITY_ENFORCED];
            if(!products.isEmpty()){
                return products;
            }    
        }
        catch(Exception e){
            throw e; 
        }
        return null;
    }
}