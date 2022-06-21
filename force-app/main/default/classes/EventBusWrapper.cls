/**
 * Sampath Karnati 
 * * Wrapper to publish platform events, wrapper is a best practice for testing platform events
 * ? Exposed as Public
 */
public class EventBusWrapper {    
    @testVisible private static List<SObject> eventList = new List<SObject>();
    public static Database.SaveResult publish(SObject event) {
        eventList.add(event);
        return EventBus.publish(event);
       }
}