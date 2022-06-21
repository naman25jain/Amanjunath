({
    handleUrlParams : function(component, event, helper) {
        // TODO: Make generic param handler, without hard-coding specific param(s).
        var parsedUrl = new URL(window.location.href);
        var serviceName = parsedUrl.searchParams.get("service");
        component.set("v.service", serviceName);
    },
})