({
    initialize : function (component, helper) {
        var recId = component.get("v.recordId");
        if (recId != null &&  recId != "") {
            helper.apex(component, helper, "getChatterPosts", {"recordId":recId})
            .then(
                (result) => {
                    console.log(result);
                    for(var x=0; x<result.length; x++) {
                        debugger;
                        //result[x].CreatedDate = result[x].CreatedDate.replace("T", " ");
                        //result[x].CreatedDate = result[x].CreatedDate.replace(".000Z", "");
                        //console.log(result[x].CreatedDate);
                        //result[x].CreatedDate = Date.parse(result[x].CreatedDate).toLocaleDateString();
                    }
                    component.set("v.chatterPosts", result);
                    component.set("v.pageReady", true);
            });
        }
    },
})