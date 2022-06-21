/**
 * Sampath Karnati 
 * * Interface with Notary Transaction Response Event Contract Methods
 * ? Exposed as Public
 */
public interface INotaryTransactionResponseEventHandler {

    void handleResponseEventPayload(string payload);
}