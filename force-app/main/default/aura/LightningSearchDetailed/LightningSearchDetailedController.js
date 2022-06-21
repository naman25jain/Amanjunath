({
	doInit : function(component, event, helper) {
    	var primaryDisplayField = component.get("v.primaryDisplayField");
    	var SOQL_Filter = component.get("v.SOQL_Filter");
    	var SOQL_Limit = component.get("v.SOQL_Limit");
    	var searchInput = component.get("v.searchInput");
    	var targetObject = component.get("v.targetObject");
    	var label = component.get("v.label");
    	var primaryDisplayField = component.get("v.primaryDisplayField");
    	var targetFields = primaryDisplayField + "," + component.get("v.targetFieldsDetail");
    	var targetFieldsDetail = component.get("v.targetFieldsDetail");
    	var fieldList = targetFields.split(',');
    	component.set("v.fieldList", fieldList);
/*    	console.log("-------Detail Init---------");
    	console.log(primaryDisplayField);
    	console.log(SOQL_Filter);
    	console.log(SOQL_Limit);
    	console.log(targetFields);
    	console.log(searchInput);
    	console.log(targetObject);
    	console.log(label);
    	console.log(primaryDisplayField);
    	console.log(fieldList);
    	console.log("-------Detail Init---------");*/
    	
		var action = component.get("c.getResults");
		action.setParams({
			'inputText': searchInput, 
			'targetObject' : targetObject, 
			"primaryField" : primaryDisplayField,
			'targetFields' : targetFieldsDetail,
			'filter' :SOQL_Filter,
			'SOQL_Limit' : SOQL_Limit
		});
		action.setCallback(this, function(response) {
			if (response.getState() === "SUCCESS") {
				component.set("v.searchResults", response.getReturnValue());
				
				var tableL = [];
				var resultL = response.getReturnValue();
				for(var x=0; x<resultL.length; x++) {
					var rec = new Object();
					rec.Id = resultL[x].Id;
					var fieldL = [];
					for (var y=0; y<fieldList.length; y++) {
						var field = new Object();
						field.name = fieldList[y];
						var val = (resultL[x])[fieldList[y]];
						if (val == undefined)
							val = "";
						field.value = val;
						fieldL.push(field);
					}
					rec.fields = fieldL;
					tableL.push(rec);
				}
				component.set("v.tableList", tableL);
			}
		});
		$A.enqueueAction(action);
	},
	
	selectRecord : function(component, event, helper){
		var target = event.target;
		while(target && !target.dataset.rowIndex) {
			target = target.parentNode;
		}
		if(target) {
		    
            var selectedRecord = helper.getSelectedRec(component, target.dataset.rowIndex);

            // fire the component event
            var selectCompEvent = component.getEvent("lightningSearchSelectCE");
            selectCompEvent.setParams({"LightningSearchRecord" : selectedRecord});
            selectCompEvent.fire();

            // fire the app event for components not in the component hierarchy
            var selectAppEvent = $A.get("e.c:LightningSearchSelectAE");
            selectAppEvent.setParam("LightningSearchRecord", selectedRecord);
            selectAppEvent.setParam("Data", component.get("v.passthroughData"));
            selectAppEvent.fire();
		}
	},
	
})