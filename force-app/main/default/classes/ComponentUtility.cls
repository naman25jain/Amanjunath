/*
    This class encompasses common lightning component server methods useful across internal applications, communities,
    and various business domains.

    Consolidate your common component server code in this class.
 */

public class ComponentUtility {

    /*
        Returns a select option list of Gender for use with lightning:combobox.
        See: https://help.salesforce.com/articleView?id=000212327&type=1
     */
    public static List<SelectOption> getGenderPicklistEntries() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Contact.Gender__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        return options;
    }


    /*
        Returns a select option list of Gender for use with lightning:combobox.
        See: https://help.salesforce.com/articleView?id=000212327&type=1
     */
    public static List<SelectOption> getGenerationalSuffixPicklistEntries() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Contact.Generational_Suffix__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        return options;
    }

    /*
         User Story#7211- Code Added by Shailaja. Following retrieves values from Global value set Months  
    */

    @AuraEnabled
    public static List<SelectOption> getMonthPicklistEntries() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Contact_Association_Type__c.Start_Month__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        return options;
    }

}