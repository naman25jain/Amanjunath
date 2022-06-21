/**
 * @description Helper class for Region Change Helper
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   18-MAR-2020
 */
public with sharing class RegionChangeHelper {

    public RegionChangeHelper() {

    }

    public class ExamRegistrationObjWrapper {
        @auraenabled public string recordIdVal { get; set; }
        @auraenabled public String examType { get; set; }
        @auraenabled public Date epStartDate { get; set; }
        @auraenabled public Date epEndDate { get; set; }
        @auraenabled public string eligibilityPeriod { get; set; }
        @auraenabled public string caseId { get; set; }
        @auraenabled public string regionSurchargeId { get; set; }        
        @auraenabled public string surcharge { get; set; }
        @auraenabled public string regionName { get; set; }
        @auraenabled public string regionId { get; set; }
        @auraenabled public string testAccommodNeeded { get; set; } 
        @auraenabled public Boolean isRequestedRegionChange { get; set; }      
        @auraenabled public list <RegionChangeHelper.RegionSurchargeObjWrapper> regionSurchargeWrapperList { get; set; }

        public ExamRegistrationObjWrapper(String id, String examType1, Date epStartDate1, Date epEndDate1, string eligibilityPeriod1, string caseId1, string regionSurchargeId1, String surcharge1, String regionName1, String regionId1, string testAccommodNeeded1, Boolean isRequestedRegionChange1, list <RegionChangeHelper.RegionSurchargeObjWrapper> surchargeLists) {
            recordIdVal             =   id;
            examType                =   examType1;
            epStartDate             =   epStartDate1;
            epEndDate               =   epEndDate1;
            eligibilityPeriod       =   eligibilityPeriod1;
            caseId                  =   caseId1;
            regionSurchargeId       =   regionSurchargeId1;
            surcharge               =   surcharge1;
            regionName              =   regionName1;
            regionId                =   regionId1;
            testAccommodNeeded      =   testAccommodNeeded1;
            isRequestedRegionChange =   isRequestedRegionChange1;

            if (surchargeLists != null && !surchargeLists.isEmpty()) {
                regionSurchargeWrapperList = new list <RegionSurchargeObjWrapper> ();
                regionSurchargeWrapperList.addAll(surchargeLists);
            } else {
                regionSurchargeWrapperList = null;
            }                      
        }
    }

    public class RegionSurchargeObjWrapper {
        @auraenabled public string regionSurchargeIdVal { get; set; }
        @auraenabled public string regionName { get; set; }
        @auraenabled public string regionId { get; set; }
        @auraenabled public string regionShortDescription { get; set; }
        @auraenabled public string regionSurcharge { get; set; }
        @auraenabled public string selectedSurchargeId { get; set; }

        public RegionSurchargeObjWrapper(String regionSurchargeIdVal1, String regionName1, String regionId1, String regionShortDescription1, String regionSurcharge1, String selectedSurchargeId1) {
            regionSurchargeIdVal    =   regionSurchargeIdVal1;
            regionName              =   regionName1;
            regionId                =   regionId1;
            regionShortDescription  =   regionShortDescription1;
            regionSurcharge         =   regionSurcharge1;
            selectedSurchargeId     =   selectedSurchargeId1;
        }
    }
}