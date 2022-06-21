/**
@Name: Shaik Nagajani
@Description: 
- This class contains the palnet press related constants.

@History
VERSION     AUTHOR             DATE            DETAIL
1.0         Shaik Nagajani     15/Nov/2021     Created the Apex class.
**/

public class PlanetPressConstants {
    
    // Collections
    public static final set<String> setServiceNamesRelForm = new set<String>{'EICS'}; 
    public static final set<String> setServiceNamesRedacted = new set<String>{'EPIC', 'ECFMG Certificate', 'FCVS', 'Application for Certification'};
    public static final set<String> setRecDevNames = new set<String>{'Medical_Education_Form', 'Credential_Verification'};
    
    public static final String STATUS_SEPARATOR = '-@-';
    public static final String REQUEST = 'Request';
    public static final String RESPONSE = 'Response';
    public static final String INTERNAL_STATUS_REQ = 'Printing';  
    public static final String SHIPPING_LABEL = 'Shipping Label';
    public static final String SHIPPING_LABEL_PRINTER = 'ZebraZP500';
    public static final String CASE_SERVICE_FIELD_API_NAME = 'Case_Service_Family__c';
    public static final String INTERNAL_STATUS_PENDING_PRINT = 'Pending Print';
    public static final String INTERNAL_STATUS_PENDING_ERROR = 'Print Error';
    public static final String STRING_SEPARATOR = '@~'; 
    public static final String Verification_Packet = 'VerificationPacket';
    public static final String Secretary_Document = 'SecretaryDocument';
    public static final String Secretary_Document_Name = 'Secretary_Document';
    public static final String Print_Entity = 'PrintDocuments';
    public static final String PRINT_TRANSACTION_KEY_TYPE = 'PRINTING_PRESS';
    public static final String PRINT_CUSTOM_CLASS_NAME = 'DocumentPrintUtilities';
    public static final String Trans_Status_Failed = 'Failed';
    public static final String Trans_Status_Printed = 'Printed';
    public static final String ID_FORM_NOTARIZED = 'ID Form Notarized';
    public static final String REDACTED_FORM = 'Redacted ID Form';
    public static final String Redacted_NonRedacted_Form = 'Redacted/NonRedacted Form';
    public static final String PHOTO = 'Photo';
    public static final String USMLE_Transcript = 'USMLE_Transcript';
    public static final String Non_USMLE_Transcript = 'Non_USMLE_Transcript';
    public static final String Pending_Print_Resend = 'Pending Print - Resend';
    public static final String Pending_Print_Verification_Incomplete = 'Pending Print - Verification Incomplete';
    public static final String Resent_for_Verification = 'Resent for Verification';
    public static final String Incomplete_Resent_for_Verification = 'Incomplete - Resent for Verification';
    public static final String Cover_Letter = 'Cover Letter';
    public static final String Incomplete_Cover_Letter = 'Incomplete Cover Letter';
    
}