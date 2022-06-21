({
    doInit :  function(component, event, helper){
          console.log(component.get("v.privacyText"))
//          var allText = component.get("v.privacyText");
////          var paragraphs = allText.split("<p><br></p><p>By checking this box");
//          var paragraphs = allText.split(/(?=By checking this box)/g)
//          var individualParagraphs = [];
//          for (var i = 0; i < paragraphs.length; ++i) {
//              individualParagraphs[i] = paragraphs[i];
//          }
//          component.set("v.privacyParagraph", individualParagraphs[0])
//          component.set("v.privacyParagraph2", individualParagraphs[1])
//          component.set("v.privacyParagraph3", individualParagraphs[2])
//          component.set("v.privacyParagraph4", individualParagraphs[3])
//          component.set("v.privacyParagraph5", individualParagraphs[4])

     },
    submit : function(component, event, helper){
        helper.submitTCs(component, helper);
    }
})