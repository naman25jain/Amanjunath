({
    initialize : function (component, helper) {
        console.log(component.get("v.recordId"));
        helper.apex(component, helper, "getCaseDetails", { "caseId" : component.get("v.recordId") })
            .then((result) => {
                    component.set("v.case", result);
                    component.set("v.pageReady", true);
            });
    },
})