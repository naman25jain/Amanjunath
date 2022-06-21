@isTest
public class ChargentFlowAPITest {

    @TestSetup
    static void makeData() {
        BillingTestFactory.testCreateBilling();
    }
    
    @IsTest
    static void testAPI() {

        User contextUser = [SELECT Id FROM User LIMIT 1];
        System.assert(contextUser.Id != null, 'User not found error!');

        ChargentFlowAPI.FlowInputs inputs = new ChargentFlowAPI.FlowInputs();
        inputs.transactionId = '0000000000001';
        
        Test.startTest();
        System.runAs(contextuser) {

            ChargentFlowAPI.refundTransaction( new List<ChargentFlowAPI.FlowInputs> { inputs } );
            
        }
        Test.stopTest();
        
    }

    @IsTest
    static void testAPIWithAmount() {

        User contextUser = [SELECT Id FROM User LIMIT 1];
        System.assert(contextUser.Id != null, 'User not found error!');

        ChargentFlowAPI.FlowInputs inputs = new ChargentFlowAPI.FlowInputs();
        inputs.transactionId = '0000000000001';
        inputs.amount = 10.0;
        
        Test.startTest();
        System.runAs(contextuser) {

            ChargentFlowAPI.refundTransaction( new List<ChargentFlowAPI.FlowInputs> { inputs } );
            
        }
        Test.stopTest();
        
    }

    @IsTest
    static void testError() {

        User contextUser = [SELECT Id FROM User LIMIT 1];
        System.assert(contextUser.Id != null, 'User not found error!');

        ChargentFlowAPI.FlowInputs inputs = new ChargentFlowAPI.FlowInputs();
        inputs.transactionId = null;
        
        Test.startTest();
        System.runAs(contextuser) {

            ChargentFlowAPI.refundTransaction( new List<ChargentFlowAPI.FlowInputs> { inputs } );
            
        }
        Test.stopTest();
        
    }

    @IsTest
    static void testErrorWithAmount() {

        User contextUser = [SELECT Id FROM User LIMIT 1];
        System.assert(contextUser.Id != null, 'User not found error!');

        ChargentFlowAPI.FlowInputs inputs = new ChargentFlowAPI.FlowInputs();
        inputs.transactionId = null;
        inputs.amount = 10.0;
        
        Test.startTest();
        System.runAs(contextuser) {

            ChargentFlowAPI.refundTransaction( new List<ChargentFlowAPI.FlowInputs> { inputs } );
            
        }
        Test.stopTest();
        
    }
}