({
	openFullModal : function(component, event, helper){
		component.set("v.showFullModal", true);
	},

	closeFullModal : function(component, event, helper){
		component.set("v.showFullModal", false);
	},


	/*
	    MP: Refactored to not show results until typing has started. Also shows same results of lost focus then
	        gains focus and search query hasn't changed.
	*/
	onfocus : function(component, event, helper){
    	var getInputkeyWord = component.get("v.searchInput");
        if (getInputkeyWord && getInputkeyWord.length > 0 ) {
            $A.util.addClass(component.find("mySpinner"), "slds-show");
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
			$A.util.removeClass(forOpen, 'slds-is-close');
			helper.searchHelper(component, event, getInputkeyWord);
      }
	},
   
    
    
    onblur : function(component, event, helper){  
        component.set("v.searchResults", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    
    keyPressController : function(component, event, helper) {
    	var getInputkeyWord = component.get("v.searchInput");
        if (getInputkeyWord.length > 0 ) {
			var forOpen = component.find("searchRes");
			$A.util.addClass(forOpen, 'slds-is-open');
			$A.util.removeClass(forOpen, 'slds-is-close');
			helper.searchHelper(component, event, getInputkeyWord);
        }
         else {  
			component.set("v.searchResults", null ); 
			var forclose = component.find("searchRes");
			$A.util.addClass(forclose, 'slds-is-close');
			$A.util.removeClass(forclose, 'slds-is-open');
        }
	},
    
    clear :function(component, event, helper) {
        //debugger;
         helper.clear(component, event, helper) ;
    },
    
    handleRecordSelect : function(component, event, helper) {

        //debugger;

        console.log("EQRWIOUPEQRWIOPUEQRWIOPU");

    	var record = event.getParam("LightningSearchRecord");
    	component.set("v.selectedRecord", record); 
    	
    	var primaryField = component.get("v.primaryDisplayField");
    	var primaryFieldValue = record[primaryField];
    	component.set("v.selectedRecordLabel", primaryFieldValue);
       
		var forclose = component.find("lookup-pill");
		$A.util.addClass(forclose, 'slds-show');
		$A.util.removeClass(forclose, 'slds-hide');
	  
		var forclose = component.find("searchRes");
		$A.util.addClass(forclose, 'slds-is-close');
		$A.util.removeClass(forclose, 'slds-is-open');
	        
		var lookUpTarget = component.find("lookupField");
		$A.util.addClass(lookUpTarget, 'slds-hide');
		$A.util.removeClass(lookUpTarget, 'slds-show');  
		
		var searchIcon = component.find("searchIcon");
		$A.util.addClass(searchIcon, 'slds-hide');
		$A.util.removeClass(searchIcon, 'slds-show');
		 
		component.set("v.showFullModal", false);
	},

	handleNewButtonOnClick : function(component, event, helper) {
	    var newEvent = $A.get("e.c:LightningSearchNew");
	    newEvent.setParam("Data", component.get("v.passthroughData"));
	    newEvent.fire();
	},
})