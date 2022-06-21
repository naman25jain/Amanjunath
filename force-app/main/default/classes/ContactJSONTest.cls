@isTest
public class ContactJSONTest{
    static testmethod void testContactJSON(){
        String jsonString = '[{'+
		''+
		'"APIName": "apiName",'+
		''+
		'"label": "apiCheck",'+
		''+
		'"dateValue": "2001-11-13T00:00:00+00:00",'+
		''+
		'"value": "John",'+
		''+
		'"fieldType": "text",'+
		''+
		'"isDate": true,'+
		''+
		'"isPicklist": true,'+
		''+
		'"isReference": true,'+
		''+
		'"isString": true,'+
		''+
		'"isRequired": true,'+
		''+
		'"pickListVal": ["Pending Review","In Review"]'+
		'}]';
    	List<ContactJSON> returnVal = new List<ContactJSON>();
        returnVal = ContactJSON.parse(jsonString); 
        System.assertNotEquals(returnVal, NULL, 'Value returned is Null.');
    }
}