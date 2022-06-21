/**
 * Sampath Karnati 
 * * Interface with Notary Transaction Request Event Contract Methods
 * ? Exposed as Public
 */
public interface INotaryTransactionRequestEventHandler {

    String buildRequestEventPayload(Id caseId);

    boolean publishEvent(String payLoad);

    boolean publishEvent(Id caseId);

}