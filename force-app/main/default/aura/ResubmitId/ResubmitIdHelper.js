({

    /*
        Move common validations into helper function.
        Returns true if valid; false if invalid.
    */
    validate : function(component, event, helper) {
        var allValid = [true];

        var i = 1;
        allValid.push(component.find("fieldToValidate").reduce(function (validSoFar, cmp) {
            cmp.reportValidity();
            return validSoFar && cmp.checkValidity();
        }, true));

        var dateOfBirth = helper.findComponentByName("fieldToValidate", "dateOfBirth", component);
        if(Date.parse(dateOfBirth.get("v.value")) > (new Date())) {
            dateOfBirth.setCustomValidity("Date of Birth must be in the past.");
            dateOfBirth.reportValidity();
            allValid.push(false);
        } else {
            dateOfBirth.setCustomValidity("");
        }

        var passportIssueDate = helper.findComponentByName("fieldToValidate", "passportIssueDate", component);
        //Bug fix#13526
        if(Date.parse(passportIssueDate.get("v.value")) > (new Date())) {
            passportIssueDate.setCustomValidity("Passport Issue Date must be in the past.");
            passportIssueDate.reportValidity();
            allValid.push(false);
        } else {
            passportIssueDate.setCustomValidity("");
        }

        var passportExpiration = helper.findComponentByName("fieldToValidate", "passportExpiration", component);
        if(Date.parse(passportExpiration.get("v.value")) <= (new Date())) {
            passportExpiration.setCustomValidity("Passport Expiration Date must be in the future.");
            passportExpiration.reportValidity();
            allValid.push(false);
        } else {
            passportExpiration.setCustomValidity("");
        }

        var distinctValid = Array.from(new Set(allValid));

        if(distinctValid.length == 1 && distinctValid[0] == true) {
            return true;
        } else {
            passportIssueDate.setCustomValidity("");
            return false;
        }

    },

    /*
        This will search all components having the same id and return the first one maching the name specified.
    */
    findComponentByName : function(id, name, component)  {
        var cmps = component.find(id);
        for(var i = 0; i < cmps.length; i++) {
            if(cmps[i].get("v.name") == name) {
                return cmps[i];
            }
        }
    },

})