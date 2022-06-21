/**
 * * Sampath Karnati 
 * * Test Factory class for Common Shipment Set up
 * ? Exposed as Public
 */
@isTest
public class ShipmentTestFactory {

    // Constants
    public static final String CARRIER_TYPE = 'FedEx';
    public static final String LABEL_TYPE = 'PDF';
    public static final String CURRENCY_TYPE = 'USD';
    public static final String DIMENSION_UNIT = 'IN';
    public static final String WEIGHT_UNIT = 'LB';
    public static final String PACKAGE_TYPE = 'YOUR_PACKAGING';
    public static final String SENDER = 'SENDER';
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
    * * Sampath Karnati 
    * * Create a new shipment
    */
    public static zkmulti__MCShipment__c getShipment() {

       // Create new shipment
       zkmulti__MCShipment__c shipment = new zkmulti__MCShipment__c(
                                        zkmulti__Carrier__c = CARRIER_TYPE,
                                        zkmulti__Label_Image_Type__c = LABEL_TYPE,
                                        // sender info
                                        zkmulti__Sender_Name__c = ConstantsTest.TEST_NAME,	
                                        zkmulti__Sender_City__c = ConstantsTest.TEST_CITY,
                                        zkmulti__Sender_Company__c = ConstantsTest.TEST_NAME,
                                        zkmulti__Sender_Country__c = ConstantsTest.TEST_COUNTRY,
                                        zkmulti__Sender_Email__c = ConstantsTest.TEST_EMAIL + ConstantsTest.TEST_EMAIL_DOMAIN,
                                        zkmulti__Sender_Phone__c = ConstantsTest.TEST_PHONE,
                                        zkmulti__Sender_State_Province__c = ConstantsTest.TEST_STATE,
                                        zkmulti__Sender_Street__c = ConstantsTest.TEST_STREET,
                                        zkmulti__Sender_Zip_Postal_Code__c = ConstantsTest.TEST_POSTAL_CODE,
                                        zkmulti__Sender_Address_is_Residential__c = false,
                                        // recipient info	
                                        zkmulti__Recipient_City__c = ConstantsTest.TEST_CITY,
                                        zkmulti__Recipient_Company__c = ConstantsTest.TEST_NAME,
                                        zkmulti__Recipient_Country__c = ConstantsTest.TEST_COUNTRY,
                                        zkmulti__Recipient_Email__c = ConstantsTest.TEST_EMAIL + ConstantsTest.TEST_EMAIL_DOMAIN,
                                        zkmulti__Recipient_Name__c = ConstantsTest.TEST_NAME,
                                        zkmulti__Recipient_Phone__c = ConstantsTest.TEST_PHONE,
                                        zkmulti__Recipient_State_Province__c = ConstantsTest.TEST_STATE,
                                        zkmulti__Recipient_Street__c = ConstantsTest.TEST_STREET,
                                        zkmulti__Recipient_Zip_Postal_Code__c = ConstantsTest.TEST_POSTAL_CODE,
                                        zkmulti__Ship_Date__c = Date.today(),
                                        zkmulti__Currency__c = CURRENCY_TYPE,
                                        zkmulti__Dimension_Units__c = DIMENSION_UNIT,
                                        zkmulti__Weight_Units__c = WEIGHT_UNIT,
                                        zkmulti__Package_Type__c = PACKAGE_TYPE,
                                        zkmulti__Payment_Type__c = SENDER,
                                        zkmulti__Billing_Country__c = ConstantsTest.TEST_COUNTRY
                                        );

       insert shipment;

       return shipment;
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}