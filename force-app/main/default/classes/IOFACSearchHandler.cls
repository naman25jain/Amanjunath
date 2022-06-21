public interface IOFACSearchHandler {

    OFACSearchRequest.Party buildCase (Contact contacts);
    OFACSearchRequest.Party buildAccountCase(Account account);
    OFACSearchRequest.Party buildAkaCase(aka_Names__c akaName);

    Boolean updateContacts (List<Contact> contacts);
    Boolean updateAccounts (List<Account> accounts);
    Boolean updateAkaNames (List<aka_Names__c> akaList);
    
    Boolean logMessage(String message);

}