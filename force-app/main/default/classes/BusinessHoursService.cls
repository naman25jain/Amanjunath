/**
 * Created by Manjari on 8/8/2019.
 */
@RestResource(urlMapping='/BusinessHoursService/*')
global with sharing class BusinessHoursService {

    @HttpGet
    global static DateTime getNextBusinessHour() {
        //RestRequest req = RestContext.request;
        //RestResponse res = RestContext.response;
        // Get the default business hours
        List<BusinessHours> bhList = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        // Create current Datetime in the local timezone.
        Datetime targetTime = Datetime.now();
        // Starting from the targetTime, find the next date when business hours reopens.
        // Return the target time if it is within the business hours. The returned time will be in the local time zone
        Datetime nextStart = BusinessHours.nextStartDate(bhList[0].Id, targetTime);
        return nextStart;
    }

}