/**
 * Sampath Karnati
 * * Schedule Case Printing
 * ? Exposed as Public
 */
public class CasePrintHandlerScheduler implements Schedulable {
    public void execute(SchedulableContext ctx) {
        Map<String, Object> params = new Map<String, Object>();
        Flow.Interview.Bulk_Print_Case_Assets flow = new Flow.Interview.Bulk_Print_Case_Assets(params);     
        flow.start();
    }
}