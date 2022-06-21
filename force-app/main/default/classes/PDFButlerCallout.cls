public class PDFButlerCallout implements Queueable,Database.AllowsCallouts{
    private Id docConfigIdTemplate;
    private Id newCaseId;    
    public PDFButlerCallout(Id docConfigIdTemplateId,Id caseId) {
        this.docConfigIdTemplate = docConfigIdTemplateId;
        this.newCaseId = caseId;
    }    
    public void execute(QueueableContext context) {
        cadmus_core.ConvertController.ConvertDataModel cdm = new cadmus_core.ConvertController.ConvertDataModel();
        cdm.docConfigId = docConfigIdTemplate;
        cdm.objectId = newCaseId;
        system.debug('docConfigId'+cdm.docConfigId);
        system.debug('objectId'+cdm.objectId);
        system.debug('cdm'+cdm);
        // Call PDF Butler
        if(!test.isRunningTest()) {
            cadmus_core.ConvertController.convertWithWrapper(cdm);    
        }  
    }
}