@isTest
public class FindDuplicateApplicantsControllerTest {
    static testMethod void contactDuplicateTesting() {
        date birthdate1 = date.valueOf('2000-01-01');
        date birthdate2 = date.valueOf('2000-01-02');
        Contact c1 = new Contact(Firstname='First1',Lastname='Last2',Birthdate=birthdate1);
        insert c1;
        Case case1 = new Case(contactId = c1.Id);
        insert case1;
        System.assert(case1.Id != NULL, 'Case Created');
        FindDuplicateApplicantsController.getDuplicateMatchesById(c1.Id, case1.Id);
    }
    static testMethod void getDuplicateMatchesByObjectTest() {
        list<contact> lc = new list<contact>();
        date birthdate1 = date.valueOf('2000-01-01');
        Contact c1 = new Contact(Firstname='First',Lastname='Last',Birthdate=birthdate1);
        lc.add(c1);
        insert lc;
        Case case1 = new Case(contactId = c1.Id);
        insert case1;
        System.assert(case1.Id != NULL, 'Case Created');
        FindDuplicateApplicantsController.getDuplicateMatchesByObject(c1, case1.Id);
    }
    static testMethod void selectDuplicatesTest(){
        User usr = [Select Id, IsActive, ContactId, IsPortalEnabled FROM User WHERE ContactId != NULL Limit 1];
        FindDuplicateApplicantsController.selectDuplicates(usr.ContactId);
    }
}