public abstract class ECFMGTestFactoryObject extends ECFMGTestFactory {
	// Overridable "make" method
    public virtual sObject make(sObject sourceObject) {

        // Process the custom create method
        sObject rec = (sObject) defaults();

        // Merge default values into passed object
        // - Fields set on the inbound sourceObject record will be preserved
        sourceObject = mergeFields(rec, sourceObject);

        // Add to the Templates's list of records created and return the result for this record
        add(sourceObject);

        return sourceObject;
    }

    // Mandatory implementation "default" method
    abstract sObject defaults();

    /**
    * Access default value method without committing to the list
    **/
    public sObject getDefaults() {
        return (sObject) defaults();
    }

    /**
    * Store each sObject created 
    **/
    sObject[] data = new List<sObject>();

    // Getters and setters to access and manage the stored sObjects

    public void add(sObject objectToAdd) {
        data.add(objectToAdd);
    }
    public sObject[] get() {
        return data;
    }
    public sObject pop() {
        return data.size() > 0 ? data[data.size() - 1] : null;
    }
    public void clear() {
        System.debug(LoggingLevel.INFO, '@@ Clear data');
        this.data = new List<sObject>();
    }


    /**
    * Utility methods 
    **/
    // Incorporate fields into passed object
    public static sObject mergeFields (sObject source, sObject destination) {
        return mergeFields(source, destination, false);
    }

    public static sObject mergeFields(sObject source, sObject destination, boolean overwrite) {
        if (destination == null) {
            destination = source;
            return destination;
        }
        Map<String, Object> fieldsToValue = source.getPopulatedFieldsAsMap();
        for (String fieldName : fieldsToValue.keySet()) {
            if (overwrite || !overwrite && destination.get(fieldName) == null) {
                destination.put(FieldName, source.get(FieldName));
            }
        }
        return destination;
    }
    
    // Get Profile -  common for user creation. Use sparringly due to DML; results are cached for the transaction.
    public static String profileIdByName(String profileName) {
        if(!profilesByName.containsKey(profileName)) {
            for(Profile p : [SELECT Id, Name FROM Profile limit 999]) {
                profilesByName.put(p.Name, p.Id);
            }
        }
        return profilesByName.get(profileName);
    }
    static map<String, Id> profilesByName = new Map<String, Id>();

    // Get Role -  common for user creation. Use sparringly due to DML; results are cached for the transaction.
    public static String roleIdByName(String developerName) {
        if(!rolesByName.containsKey(developerName)) {
            UserRole[] r = [select Id from UserRole where DeveloperName = :developerName];
            if (r!=null && !r.IsEmpty())
                rolesByName.put(developerName,r[0].Id);
        }
        return rolesByName.get(developerName);
    }
    static map<String, Id> rolesByName = new Map<String, Id>();


    /**
    * Exception Class 
    **/
    public class TestFactoryBaseException extends Exception {
    }
}