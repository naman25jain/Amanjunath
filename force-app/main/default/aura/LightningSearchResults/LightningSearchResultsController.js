({
	doInit : function(component, event, helper){
		//console.log("RHERE1");
		var displayVal = component.get("v.record." + component.get("v.displayFieldAPIName"));
		component.set("v.displayField", displayVal);
		
		var targetFields = component.get("v.targetFields");
		var record = component.get("v.record");
		var fieldL = targetFields.split(",");
		//console.log(fieldL);
		var displayDetails = [];
		for(var x=0; x<fieldL.length; x++) {
			var field = new Object();
			field.name = fieldL[x];
			field.value = record[fieldL[x]];
			displayDetails.push(field);
		}
		component.set("v.displayDetails", displayDetails);
	},
	
	selectRecord : function(component, event, helper){      
		console.log("RHERE2");
        //debugger;
		var selectedRecord = component.get("v.record");

		// fire the component event
		var selectCompEvent = component.getEvent("lightningSearchResultsSelectCE");
		selectCompEvent.setParams({"LightningSearchRecord" : selectedRecord});
		selectCompEvent.fire();

		// fire the app event for components not in the component hierarchy
        var selectAppEvent = $A.get("e.c:LightningSearchSelectAE");
        selectAppEvent.setParam("LightningSearchRecord", selectedRecord);
        selectAppEvent.setParam("Data", component.get("v.passthroughData"));
        selectAppEvent.fire();
	},
})