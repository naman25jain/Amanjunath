({
      openModel : function(component, event, helper) {
          component.set("v.isOpen", true);
       },
       closeModel : function(component, event, helper) {
          component.set("v.isOpen", false);
       },
       navigateNext : function(component, event, helper) {
             component.set("v.duplicatesSelected", false);
             var navigate = component.get("v.navigateFlow");
             navigate("NEXT");
        },
        doInit : function(component, event, helper) {
            var caseId = component.get("v.componentCaseId");
            var componentContactId = component.get("v.componentContactId");
            console.log(caseId);
            console.log(componentContactId);
            console.log( component.get("v.currentComponentContactIdOutput"))
            console.log( component.get("v.currentComponentContactFirstNameOutput"))
            console.log( component.get("v.currentComponentContactLastNameOutput"))
            console.log( component.get("v.currentComponentContactEmailOutput"))


                var contactrecord = {
                    Id: componentContactId
                }
                //Set the local record with the contact record
                component.set("v.contactObject", contactrecord);

                var c = component.get('c.getContactDuplicates'); ///// calling function below
                $A.enqueueAction(c);

       //}
    },

    getContactDuplicates : function(component) {
		var action = component.get("c.getDuplicateMatchesById");
		var componentContactId = component.get("v.componentContactId");
		var caseId = component.get("v.componentCaseId");

        action.setParams({
            "contactId": componentContactId,
            "caseId": caseId,
        });
        action.setCallback(this, function(response) {
            var thisContactRecord;
			var state = response.getState();
			if (state === "SUCCESS") {
			var storeResponse = response.getReturnValue();
			console.log(storeResponse);

               for (var i = 0; i < storeResponse.length; i++){
                         if (storeResponse[i].Id === componentContactId) {

                                component.set("v.currentCaseContactObject", storeResponse[i]);
                                thisContactRecord = storeResponse[i];
                            }
//                            /////// remove the record if it is an Registered User record
//                            if (storeResponse[i].RecordType.DeveloperName == 'Registered_User'){
//                                console.log(storeResponse[i]);
//                               // storeResponse.splice(storeResponse[i], 1);
//
//                            }
               };
            console.log(thisContactRecord);
            console.log(thisContactRecord.RecordType.DeveloperName);
			var applicantRecords =  storeResponse.filter(function(resp) {
            	return resp.RecordType.DeveloperName == 'Applicant';
            });
            console.log(applicantRecords)

               var index = applicantRecords.indexOf(thisContactRecord);
                 if (index > -1) {
                   applicantRecords.splice(index, 1);  //// remove the record that is associated with this case
                 }
                /////// need to make sure that Current Record is accounted for if its is record type = registered user
                if (applicantRecords.length < 1) {
                         component.set("v.areNoDupes", true);
                        component.find("selectBtn").set("v.disabled", true);
                    } else {
                        component.set("v.areNoDupes", false);
                    }

                console.log(storeResponse);
				component.set("v.duplicatelist", applicantRecords);
               // var getdupelist = component.get("v.duplicatelist");

			}
		});
        $A.enqueueAction(action);
	},
	contactSelected : function(component, event) {

	    console.log(event.getSource().get("v.value"))
//	    console.log(event.getSource().get("v.name")) ///// get selected Account ID to move
        var newAccount = event.getSource().get("v.id");
         component.set("v.selectedAccountId", newAccount); ////// this is to set the account Id for the contact to be transferred to.
	    var selectedId = event.getSource().get("v.value");
	    component.set("v.selectedComponentContactIdOutput", selectedId);  //// sending the Contact Id to the flow
	    component.set("v.selectedContact", selectedId);
           var otherButton = component.find('selectButton');
           otherButton.set('v.disabled',false);
       },

    selectRecord : function(component, event) {
       var selectedContactId = component.get('v.selectedContact');
       var caseVar = component.get('v.componentCaseId');

       var componentContactId = component.get("v.componentContactId");  //// current contact ID -needs to be deactivated


        var action = component.get("c.selectDuplicates");
               action.setParams({"contactRecord" : componentContactId});
               action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state)
                  if (state === "SUCCESS") {
                        var currentContact = component.get("v.currentComponentContactIdOutput");
                        component.set("v.currentComponentContactIdOutput", currentContact);

                           //////// actions for flow /////////////
                               component.set("v.duplicatesSelected", true);

                               var navigate = component.get("v.navigateFlow");
                               navigate("NEXT");
                           /////// end flow Navigation////////////
                        component.set("v.isOpen", false);
                   }  else if (state === "ERROR"){
                    console.log('error')
                   }
            });
         $A.enqueueAction(action);
      }


})