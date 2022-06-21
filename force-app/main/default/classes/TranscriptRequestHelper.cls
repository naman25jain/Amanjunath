public with sharing class TranscriptRequestHelper {
        /* Wrapper class to send Transript Request data to be displayed in Transcript request form
     */
    public class TranscriptObjWrapper {
        @auraenabled public string primaryTranscriptId { get; set; }
        @auraenabled public string primaryNameOfReceipt { get; set; }
        @auraenabled public string primaryOrganization { get; set; }
        @auraenabled public string primaryStreet{ get; set; }
        @auraenabled public string primaryCity { get; set; }
        @auraenabled public string primaryState { get; set; }
        @auraenabled public string primaryCountry { get; set; }
        @auraenabled public string primaryPostalCode { get; set; }
        @auraenabled public string primaryTelephoneNumber { get; set; }
        @auraenabled public string primaryCourier { get; set; }
        @auraenabled public Boolean primarySendToSelf { get; set; }
        @auraenabled public Boolean primaryRequestAnotherTranscript { get; set; }
        @auraenabled public string secondaryTranscriptId { get; set; }
        @auraenabled public string secondaryNameOfReceipt { get; set; }
        @auraenabled public string secondaryOrganization { get; set; }
        @auraenabled public string secondaryStreet{ get; set; }
        @auraenabled public string secondaryCity { get; set; }
        @auraenabled public string secondaryState { get; set; }
        @auraenabled public string secondaryCountry { get; set; }
        @auraenabled public string secondaryPostalCode { get; set; }
        @auraenabled public string secondaryTelephoneNumber { get; set; }
        @auraenabled public string secondaryCourier { get; set; }
        @auraenabled public Boolean secondarySendToSelf { get; set; }
        @auraenabled public Boolean primarySendToSameAddressTranscript { get; set; }
        @auraenabled public Boolean numberOfCopMorethanOne { get; set; }
        @auraenabled public string linkSource { get; set; }
        
        public TranscriptObjWrapper(string primaryTranscriptIdVal,string primaryNameOfReceiptVal,string primaryOrganizationVal,string primaryStreetVal,string primaryCityVal,string primaryStateVal,string primaryCountryVal,string primaryPostalCodeVal,string primaryTelephoneNumberVal,string primaryCourierVal,Boolean primarySendToSelfVal,Boolean primaryRequestAnotherTranscriptVal,string secondaryTranscriptIdVal,string secondaryNameOfReceiptVal,string secondaryOrganizationVal,string secondaryStreetVal,string secondaryCityVal,string secondaryStateVal,string secondaryCountryVal,string secondaryPostalCodeVal,string secondaryTelephoneNumberVal,string secondaryCourierVal,Boolean secondarySendToSelfVal,Boolean primarySendToSameAddressTranscriptVal,Boolean numberOfCopMorethanOneVal,String linkSourceVal) {
            primaryTranscriptId =primaryTranscriptIdVal;
            primaryNameOfReceipt =primaryNameOfReceiptVal;
            primaryOrganization =primaryOrganizationVal;
            primaryStreet=primaryStreetVal;
            primaryCity =primaryCityVal;
            primaryState =primaryStateVal;
            primaryCountry =primaryCountryVal;
            primaryPostalCode =primaryPostalCodeVal;
            primaryTelephoneNumber =primaryTelephoneNumberVal;
            primaryCourier =primaryCourierVal;
            primarySendToSelf =primarySendToSelfVal;
            primaryRequestAnotherTranscript =primaryRequestAnotherTranscriptVal;
            secondaryTranscriptId =secondaryTranscriptIdVal;
            secondaryNameOfReceipt =secondaryNameOfReceiptVal;
            secondaryOrganization =secondaryOrganizationVal;
            secondaryStreet=secondaryStreetVal;
            secondaryCity =secondaryCityVal;
            secondaryState =secondaryStateVal;
            secondaryCountry =secondaryCountryVal;
            secondaryPostalCode =secondaryPostalCodeVal;
            secondaryTelephoneNumber =secondaryTelephoneNumberVal;
            secondaryCourier =secondaryCourierVal;
            secondarySendToSelf =secondarySendToSelfVal;
            primarySendToSameAddressTranscript=primarySendToSameAddressTranscriptVal;
            numberOfCopMorethanOne = numberOfCopMorethanOneVal;
            linkSource = linkSourceVal;
        }

    }

    public class FatchValueWrapper {
        @auraenabled public string slabel {get;set;}
        @auraenabled public string svalue {get;set;}
 
    }

}