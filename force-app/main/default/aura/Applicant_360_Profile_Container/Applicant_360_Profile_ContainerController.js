({
     makeUnsavedChanges: function(cmp, evt, helper) {
         var unsaved = cmp.find("unsaved");
         unsaved.setUnsavedChanges(true, { label: 'My component name' });
     },
     
     clearUnsavedChanges: function(cmp, evt, helper) {
         var unsaved = cmp.find("unsaved");
         unsaved.setUnsavedChanges(false);
     },
     
     handleSave: function(cmp, evt, helper) {
         // When the custom save logic has completed the setUnsavedChanges method
         // must be called again to return control to the lightning UI
         var unsaved = cmp.find("unsaved");
         if (true) {
           // return control to the lightning UI while indicating that the content is still unsaved, preventing it from being dismissed
           unsaved.setUnsavedChanges(true);
         }
         else {
           // return control to the lightning UI while indicating that the content is saved
           unsaved.setUnsavedChanges(false);
         }
     },
     
     handleDiscard: function(cmp, evt, helper) {
        // similar to the handleSave method, but for discarding changes
     }
})