public without sharing class ContactRedirectController {


    @RemoteAction
    public static String redirect(){
        User currentUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        system.debug('Current User: ' + currentUser);

        return '/contact/' + currentUser.ContactId + '/';
    }
}