({
	getSelectedRec : function(component, recordId) {
		var recordL = component.get("v.searchResults");
		for (var x=0; x<recordL.length; x++) {
			if (recordL[x].Id == recordId) {
				console.log(recordL[x]);
				return recordL[x]; 
			}
		}
		return null;
	}
})