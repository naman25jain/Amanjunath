({
    initializeCibisSearch: function(component, helper, caseId) {
        component.get("v.pageSize");
        component.get("v.pageNumber");
        component.set("v.selectedcandidateRows", []);
        component.set("v.showCandidateButton", false);
        component.set('v.candidateColumns', [
            {
                label: 'Overall Match',
                fieldName: 'Cibis_Overall_Match__c',
                type: 'text',
                sortable: true              
            },
            {
                label: 'Last Name',
                fieldName: 'Cibis_Last_Name__c',
                type: 'text',
                sortable: true
            },
            {
                label: 'Rest of Name',
                fieldName: 'Cibis_First_Name__c',
                type: 'text',
                sortable: true
            },
            {
                label: 'Birth Date',
                fieldName: 'CibisBirthDate__c',
                type: 'text'
            },
            {
                label: 'Usmle Id',
                fieldName: 'CIBIS_USMLE_ID__c',
                type: 'text',
                sortable: true
            },
            {
                label: 'Gender',
                fieldName: 'CIBIS_GENDER_CODE__c',
                type: 'text',
                sortable: true
            },
            {
                label: 'Medschool Code',
                fieldName: 'CibisMedicalSchoolCode__c',
                type: 'text',
                sortable: true
            },
        ]);

        component.set("v.candidateSectionLabel", helper.format(component.get("v.candidateSectionTemplate"), component.get("v.candidateMatchCount")));
        component.set("v.linkedCandidate", component.get("v.linkedPlaceholder"));
        helper.getCibisCandidateMatches(component, helper, caseId);
        helper.getContactRecord(component,helper,caseId);
    },
    getCibisCandidateMatches: function(component, helper, caseId) {
        var params = {
            caseId: caseId
        };

        return this.callAction(component)
            .then(
                $A.getCallback(candidateData => {
                    component.set("v.pageReady", true);
                    component.get("v.candidateColumns")[3].type = "date-local";
                    component.set("v.candidateMatchCount", candidateData.length);
                    component.set("v.candidateSectionLabel", helper.format(component.get("v.candidateSectionTemplate"), component.get("v.candidateMatchCount")));
                    component.find("candidateTable").set("v.hideCheckboxColumn", false);
                    component.set("v.selectedcandidateRows", []);
                    component.set('v.allData', candidateData);
                    component.set('v.filteredData', candidateData);
                    this.preparePagination(component, candidateData);
                })
            )
            .catch(
                $A.getCallback(errors => {
                    if (errors && errors.length > 0) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "CIBIS Contacts",
                            "message": "No Records found",
                            "type": "info"
                        });
                        toastEvent.fire();
                    }
                })
            );
    },


    callAction: function(component) {
        return new Promise(
            $A.getCallback((resolve, reject) => {
                const action = component.get("c.cibisCandResponse");
                action.setParams({
                    caseId: component.get("v.recordId")
                });
                action.setCallback(this, response => {
                    const state = response.getState();
                    if (state === "SUCCESS") {
                        return resolve(response.getReturnValue());
                    } else if (state === "ERROR") {
                        return reject(response.getError());
                    }
                    return null;
                });
                $A.enqueueAction(action);
            })
        );
    },


    preparePagination: function(component, candidateData) {
        console.log('in side preparePagination ');
        let countTotalPage = Math.ceil(candidateData.length / component.get("v.pageSize"));

        let totalPage = countTotalPage > 0 ? countTotalPage : 1;
        component.set("v.totalPages", totalPage);
        component.set("v.currentPageNumber", 1);
        this.setPageDataAsPerPagination(component);
    },

    setPageDataAsPerPagination: function(component) {
        let data = [];
        let pageNumber = component.get("v.currentPageNumber");
        let pageSize = component.get("v.pageSize");
        let filteredData = component.get('v.filteredData');
       
        let x = (pageNumber - 1) * pageSize;
        for (; x < (pageNumber) * pageSize; x++) {
            if (filteredData[x]) {
                data.push(filteredData[x]);
            }
        }
        component.set("v.candidateData", data);
        
    },
        sortBy: function(field, reverse, primer) {
        var key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },

    handleSort: function(cmp, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
               
        var cloneData = cmp.get('v.candidateData').slice(0);
     
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        
        cmp.set('v.candidateData', cloneData);
        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
    },


    updateCaseContact: function(component, event, helper, confirmType) {
       component.set('v.pageReady', false);
   
        var obj=component.get("v.selectedCIBISDupCheckContact");
        let action = (confirmType == 'Confirm' ? component.get('c.updatecaseContactWithConfirm') : component.get('c.updatecaseContactNotConfirm'));
        if (confirmType == 'Confirm') {
                 console.log('inside if'+component.get("v.selectedCIBISDupCheckContact"));
            action.setParams({
                cibisContact: component.get("v.selectedCIBISDupCheckContact")
            });
        } else {
            action.setParams({
                strCaseId: component.get("v.recordId")
            });
        }


        action.setCallback(this, (response) => {
            if (response.getState() == 'SUCCESS') {
                console.log('success ===> ' + response.getReturnValue());
            	component.set("v.showCandidateModal", false);
               var toastEvent = $A.get("e.force:showToast");
               toastEvent.setParams({
                            "message": 'Success!',
                            "type": "success"
                });
               toastEvent.fire();
              component.set("v.pageReady", true);
        	 component.set("v.showModal", false);
        	  $A.get('e.force:refreshView').fire();
              }
            else if(response.getState() == 'ERROR'){
                console.log('error => '+response.getError().getMessage());
                component.set("v.pageReady", false);
            let error = response.getError();
                component.set("v.showCandidateModal", false);
               var toastEvent = $A.get("e.force:showToast");
               toastEvent.setParams({
                            "title": "CIBIS Contacts",
                            "message": JSON.stringify(error.getMessage()),
                            "type": "error"
                });
               toastEvent.fire();
            }

        });

        $A.enqueueAction(action);

    },
    
        getModalinfofromContentManager: function(component, event, helper, confirmType) {
            let action = component.get('c.getContentManagerInfo');
            action.setParams({
                strConfirmType : confirmType 
            });
            
            action.setCallback(this, (response) => {
                if(response.getState() === 'SUCCESS') {
                
                let obj = response.getReturnValue();
                    if(obj) {
                    	obj.Content__c = obj.Content__c.replace(/<(.|\n)*?>/g, '');
                    }
                	component.set('v.modalMessage', obj.Content__c);
            	}
            });
            
            $A.enqueueAction(action);
        },

        getContactRecord: function(component, helper, caseId){
            var action = component.get("c.getContactDetails");
            action.setParams({ CaseId : caseId });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // Alert the user with the value returned 
                    // from the server
                    component.set('v.contactData',response.getReturnValue());
    
                    // You would typically fire a event here to trigger 
                    // client-side notification that the server-side 
                    // action is complete
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                     errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
});