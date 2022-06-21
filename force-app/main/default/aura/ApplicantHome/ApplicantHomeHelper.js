({
    apex : function(component, helper, apexAction, params) {
	    var p = new Promise( $A.getCallback( function( resolve , reject ) {
	        var action = component.get("c." + apexAction + "");
	        if(params) action.setParams(params);
	        action.setCallback( this , function(callbackResult) {
	            if(callbackResult.getState() == "SUCCESS") {
	                resolve( callbackResult.getReturnValue() );
	            }
	            else {
	                helper.handleError(callbackResult);
	                reject(callbackResult);
	            }
	        });
	        $A.enqueueAction( action );
	    }));
        return p;
    },
})