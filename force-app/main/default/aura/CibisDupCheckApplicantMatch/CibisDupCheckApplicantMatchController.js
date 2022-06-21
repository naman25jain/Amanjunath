({
    init: function(component, event, helper){
        helper.initializeCibisSearch(component, helper, component.get("v.recordId"));
    },
    
    /*recordUpdate: function(component, event, helper) {
        if($A.get("$SObjectType.CurrentUser.Id") == component.get("v.caseRecord").OwnerId) {
            component.set('v.isCaseClaimed', true);
            component.set('v.isCaseClaimedError', '');
            helper.initializeCibisSearch(component, helper, component.get("v.recordId"));
        }
        else {
             component.set('v.isCaseClaimed', false);
            component.set('v.isCaseClaimedError', 'Please claim the case.');
        }
    }, */
    
    candidateRowOnSelect : function(component, event, helper){
        var selectedRows = event.getParam("selectedRows");
        var changeElement = component.find("btnGrp");
            if(selectedRows && selectedRows.length == 1){        
            component.set("v.selectedCIBISDupCheckContact", selectedRows[0]);
            component.set("v.showCandidateButton", true);
            component.set('v.disabled',false);  
        }
        
        if(selectedRows && selectedRows.length > 1)
        {            
           component.set('v.disabled',true);
            
          var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": "Only one row can be selected",
                "type" : "warning",
                "mode" : "pester",
                duration:'5000',
             });
            toastEvent.fire();
        }
        if(selectedRows == 0){
               component.set("v.showCandidateButton", false);       
           }        
     
    },
   /* unSelect: function(component, event, helper){
        helper.initializeCibisSearch(component, helper, component.get("v.recordId"));
    },*/
    handleSort: function(cmp, event, helper) {
        helper.handleSort(cmp, event);
    },
    
    proceedWithCibisDupCheck: function(component, event, helper){
        helper.updateCaseContact(component, event, helper, 'Confirm');     
        component.set("v.showModal", false);
    },
    
    
    noConfirmProcess : function(component, event, helper){
  
        helper.getModalinfofromContentManager(component, event, helper, 'CIBISNoConfirmMatchPopMessage');
        component.set("v.showModal", true);  
        
    },
    
    closeModel : function(component, event, helper){
        component.set("v.showModal", false);
    },
    
    procedNoConfirmProcess :  function(component, event, helper){
        helper.updateCaseContact(component, event, helper, 'noConfirm'); 
        
    },
    
    selectedCandidate : function(component, event, helper){
        helper.getModalinfofromContentManager(component, event, helper, 'CIBISConfirmMatchPopMessage');
        
        component.set("v.showModal", true);
    },
    
    onFirst: function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.setPageDataAsPerPagination(component);
    },
    
    onPrev: function(component, event, helper) {        
        let pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber - 1);
        helper.setPageDataAsPerPagination(component);
    },
    
    onNext: function(component, event, helper) {        
        let pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber + 1);
        helper.setPageDataAsPerPagination(component);
    },
    
    
    onLast: function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.setPageDataAsPerPagination(component);
    },
    
})