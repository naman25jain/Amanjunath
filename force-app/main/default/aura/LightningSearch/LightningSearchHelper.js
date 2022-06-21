({
	searchHelper : function(component,event,getInputkeyWord) {
		var action = component.get("c.getSchoolRecords");
		var limit = component.get("v.SOQL_Limit");
		var targetFields = component.get("v.targetFields");
		component.set("v.overLimit", false);
		component.set("v.searchResults", null);
        var currentRecordType = component.get("v.selectedRecordType");
		action.setParams({
			'recType': currentRecordType,
            'inputText': getInputkeyWord
		});
		action.setCallback(this, function(response) {
			$A.util.removeClass(component.find("mySpinner"), "slds-show");
			var state = response.getState();
			if (state === "SUCCESS") {
				var storeResponse = response.getReturnValue();
                var limit = 100;
                
				if (storeResponse.length == 0) {
					component.set("v.Message", 'No Records Found...');
				} 
                else if (storeResponse.length == (parseInt(limit)+1)) {
					component.set("v.overLimit", true);
					component.set("v.Message", '');
					storeResponse.pop(); //Remove last array item that will be replaced with "Show More" option
				} 
                else {
					component.set("v.Message", '');
				} 
				component.set("v.searchResults", storeResponse);
			}
			
		});
		$A.enqueueAction(action);
	},
 
	clear : function(component, event, helper){

        //debugger;

         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField");

         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');

         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');

         component.set("v.searchInput", null);
         component.set("v.searchResults", null );
         component.set("v.selectedRecord", {} );
    },
})