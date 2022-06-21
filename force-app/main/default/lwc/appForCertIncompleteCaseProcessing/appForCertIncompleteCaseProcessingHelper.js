import createAssetForIncompleteCaseProcessingNew from '@salesforce/apex/AppForCertHelper.createAssetForInc';
import cancelIncomAsset from '@salesforce/apex/AppForCertHelper.cancelIncomAsset';
import degreeIssueDateGreaterThanEndDate from '@salesforce/label/c.Degree_Issue_date_always_greater_than_End_date';
import graduationDateGreaterThanEndDate from '@salesforce/label/c.Graduation_Date_always_greater_than_End_Date';
import gradYearValidLabel from '@salesforce/label/c.Graduation_Year_Validation';
import blankStatusLabel from '@salesforce/label/c.Blank_Status_Validation_Message';
import blankDegMedSchoolLabel from '@salesforce/label/c.Degree_Medical_School_Blank_Validation';
import degMedSchoolValidNameLabel from '@salesforce/label/c.Degree_Medical_School_Name_Validation';
import blankEndDateLabel from '@salesforce/label/c.Blank_End_Date_Label';
import endDateGreaterThanStartDate from '@salesforce/label/c.End_date_always_greater_than_Start_date';
import blankDegTitleLabel from '@salesforce/label/c.Degree_Title_Blank_Validation';
import degreeTitleValidNameLabel from '@salesforce/label/c.Degree_Title_Name_Validation';
import blankGradYearMonthLabel from '@salesforce/label/c.Graduation_Year_Blank_Validation';
import blankDegIssueDateLabel from '@salesforce/label/c.Blank_Degree_Issue_Date_Validation';
import newDateValidation from '@salesforce/label/c.Student_newDate_validation';
import newDateValidationMessage from '@salesforce/label/c.Start_and_End_date_validation';
export function validateTransferCreditGradeInputHelper(event) {
    // prevent letter e which is considered as exponential in number field, minus symbol and hyphen
    if (event.which === 69 || event.which === 109 || event.which === 189) {
        event.preventDefault();
    }
    //prevent extra decimal points
    if (event.which === 110 && event.target.value.includes(".")) {
        event.preventDefault();
    }
    if (event.target.value.includes(".")) {
        // prevent more than 5 characters if it's a decimal number i.e. xx.xx format; but allow backspace/tab
        if (event.target.value.length === 5 && event.which !== 8 && event.which !== 9) {
            event.preventDefault();
        }
    } else {
        // prevent more than 2 characters if it's a non-decimal number i.e. xx format; but allow backspace/tab or decimal
        if (event.target.value.length === 2 && event.which !== 8 && event.which !== 9 && event.which !== 110 && event.which !== 190) {
            event.preventDefault();
        }
    }
} 
export function handleUploadTCTHelper(event,getOtherInstitutionData) {
let assetId = JSON.stringify(event.detail);   
   if(assetId){      
    createAssetForIncompleteCaseProcessingNew({
       assetId:assetId,key: 'Transfer Credit Transcript Document'     
    })
    .then(result => {      
            let assetDetails = result;
            for(const key in getOtherInstitutionData){
                if(getOtherInstitutionData.hasOwnProperty(key)){
                    let ele = getOtherInstitutionData[key];     
                    for(const assKey in assetDetails){
                        if(assetDetails.hasOwnProperty(assKey)){
                            if(ele.Id===assKey) {
                                let assEle = assetDetails[assKey];                                  
                                    ele.tctId = assEle.assetId;
                                    ele.tctFileName = assEle.fileName;
                                    ele.tctFileType = assEle.fileType;
                                    ele.tctFile = assEle.fileUrl;
                                    ele.tctName =assEle.assetNameDoc;
                                    ele.showtctFileDetails= true;
                                    let tempPayload = JSON.parse(ele.tctPayload);
                                    tempPayload.assetId = assEle.assetId;                                   
                                    ele.tctPayload = JSON.stringify(tempPayload);                                                                 
                                    if(assEle.assetNameDocDifferent === 'Yes'){
                                        ele.isTctNameDiff = true;
                                    }
                                    if(assEle.assetNameDocDifferent === 'No'){
                                        ele.isTctNameDiff = false;
                                    }
                                    if(assEle.assetNameDocnotinEnglish === 'Yes'){
                                        ele.isTctTrans = true;
                                    }
                                    if(assEle.assetNameDocnotinEnglish === 'No'){
                                        ele.isTctTrans = false;
                                    } 
                                }
                        }
                    }
                }
            }    
    })
    .catch(error =>{
        console.error('eror'+JSON.stringify(error));
    })  
    }   
}
export function handleUploadTCTNameHelper(event,getOtherInstitutionData) {  
    let assetId = JSON.stringify(event.detail);   
    if(assetId){      
        createAssetForIncompleteCaseProcessingNew({
        assetId:assetId,key: 'Transfer Credit Transcript Name Document'     
     })
         .then(result => {         
                 let assetDetails = result;
                 for(const key in getOtherInstitutionData){
                     if(getOtherInstitutionData.hasOwnProperty(key)){
                         let ele = getOtherInstitutionData[key];          
                         for(const assKey in assetDetails){
                             if(assetDetails.hasOwnProperty(assKey)){
                                 if(ele.Id===assKey) {                                    
                                     let assEle = assetDetails[assKey];
                                         ele.tctNameId = assEle.assetId;
                                         ele.tctNameDocName = assEle.fileName;
                                         ele.tctNameDocType = assEle.fileType;
                                         ele.tctNameDoc = assEle.fileUrl; 
                                         ele.showtctNameDocDetails = true;
                                         let tempPayload = JSON.parse(ele.tctNamePayload);
                                         tempPayload.assetId = assEle.assetId;                                   
                                         ele.tctNamePayload = JSON.stringify(tempPayload);                                                                                                                                                            
                                 }
                             }
                         }
                     }
                 }
         })
         .catch()  
         } 
}
export function handleUploadTCTTransHelper(event,getOtherInstitutionData){
     let assetId = JSON.stringify(event.detail);   
     if(assetId){      
        createAssetForIncompleteCaseProcessingNew({
         assetId:assetId,key: 'Transfer Credit Transcript Translation Document'     
      })
     .then(result => {            
             let assetDetails = result;
             for(const key in getOtherInstitutionData){
                 if(getOtherInstitutionData.hasOwnProperty(key)){
                     let ele = getOtherInstitutionData[key];          
                     for(const assKey in assetDetails){
                         if(assetDetails.hasOwnProperty(assKey)){
                             if(ele.Id===assKey) {
                                 let assEle = assetDetails[assKey];
                                     ele.tctTransId = assEle.assetId;
                                     ele.tctTransFileName = assEle.fileName;
                                     ele.tctTransFileType = assEle.fileType;
                                     ele.tctTransFile = assEle.fileUrl;
                                     ele.tctTransName =assEle.assetNameDoc;
                                     ele.showtctTransFileDetails = true;
                                     let tempPayload = JSON.parse(ele.tctTrnPayload);
                                     tempPayload.assetId = assEle.assetId;                                   
                                     ele.tctTrnPayload = JSON.stringify(tempPayload);                                       
                                     if(assEle.assetNameDocDifferent === 'Yes'){
                                         ele.isTctTransNameDiff = true;
                                     }
                                     if(assEle.assetNameDocDifferent === 'No'){
                                         ele.isTctTransNameDiff = false;
                                     }                                                                                                                        
                             }
                         }
                     }
                 }
             }         
     })
     .catch() 
     }
}
export function handleUploadPremedHelper(event,getOtherInstitutionData){
    let assetId = JSON.stringify(event.detail);   
    if(assetId){      
       createAssetForIncompleteCaseProcessingNew({
        assetId:assetId,key: 'Pre-Med Letter Document'     
     })
     .then(result => {         
        let assetDetails = result;
             for(const key in getOtherInstitutionData){
                 if(getOtherInstitutionData.hasOwnProperty(key)){
                     let ele = getOtherInstitutionData[key];      
                     for(const assKey in assetDetails){
                         if(assetDetails.hasOwnProperty(assKey)){
                             if(ele.Id===assKey) {
                                 let assEle = assetDetails[assKey];
                                     ele.pmlId = assEle.assetId;
                                     ele.pmlFileName = assEle.fileName;
                                     ele.pmlFileType = assEle.fileType;
                                     ele.pmlFile = assEle.fileUrl;
                                     ele.pmlName =assEle.assetNameDoc;
                                     ele.showpmlFileDetails = true;
                                     let tempPayload = JSON.parse(ele.pmlPayload);
                                     tempPayload.assetId = assEle.assetId;                                   
                                     ele.pmlPayload = JSON.stringify(tempPayload);     
                                     if(assEle.assetNameDocDifferent === 'Yes'){
                                         ele.ispmlNameDiff= true;
                                     }
                                     if(assEle.assetNameDocDifferent === 'No'){
                                         ele.ispmlNameDiff = false;
                                     }
                                     if(assEle.assetNameDocnotinEnglish === 'Yes'){
                                         ele.ispmlTrans = true;
                                     }
                                     if(assEle.assetNameDocnotinEnglish === 'No'){
                                         ele.ispmlTrans = false;
                                     }                                                                                     
                             }
                         }
                     }
                 }
             }         
     })
     .catch() 
     }
 } 
 export function handleUploadPremedNameHelper(event,getOtherInstitutionData){   
     let assetId = JSON.stringify(event.detail);   
     if(assetId){      
        createAssetForIncompleteCaseProcessingNew({
         assetId:assetId,key: 'Pre-Med Letter Name Document'     
      })
     .then(result => {      
             let assetDetails = result;
             for(const key in getOtherInstitutionData){
                 if(getOtherInstitutionData.hasOwnProperty(key)){
                     let ele = getOtherInstitutionData[key];      
                     for(const assKey in assetDetails){
                         if(assetDetails.hasOwnProperty(assKey)){
                             if(ele.Id===assKey) {                                
                                 let assEle = assetDetails[assKey];
                                     ele.pmlNameId = assEle.assetId;
                                     ele.pmlNameDocName = assEle.fileName;
                                     ele.pmlNameDocType = assEle.fileType;
                                     ele.pmlNameDoc = assEle.fileUrl;  
                                     ele.showpmlNameDocDetails = true;  
                                     let tempPayload = JSON.parse(ele.pmlNamePayload);
                                     tempPayload.assetId = assEle.assetId;                                   
                                     ele.pmlNamePayload = JSON.stringify(tempPayload);   
                             }
                         }
                     }
                 }
             }
     })
     .catch()  
     }
}
export function handleUploadPremedTransHelper(event,getOtherInstitutionData){   
     let assetId = JSON.stringify(event.detail);   
     if(assetId){      
        createAssetForIncompleteCaseProcessingNew({
         assetId:assetId,key: 'Pre-Med Letter Translation Document'     
      })
     .then(result => {           
             let assetDetails = result;
             for(const key in getOtherInstitutionData){
                 if(getOtherInstitutionData.hasOwnProperty(key)){
                     let ele = getOtherInstitutionData[key];          
                     for(const assKey in assetDetails){
                         if(assetDetails.hasOwnProperty(assKey)){
                             if(ele.Id===assKey) {
                                 let assEle = assetDetails[assKey];
                                     ele.pmlTransId = assEle.assetId;
                                     ele.pmlTransFileName = assEle.fileName;
                                     ele.pmlTransFileType = assEle.fileType;
                                     ele.pmlTransFile = assEle.fileUrl;
                                     ele.pmlTransName =assEle.assetNameDoc;
                                     ele.showpmlTransFileDetails = true;
                                     let tempPayload = JSON.parse(ele.pmlTrnPayload);
                                     tempPayload.assetId = assEle.assetId;                                   
                                     ele.pmlTrnPayload = JSON.stringify(tempPayload); 
                                     if(assEle.assetNameDocDifferent === 'Yes'){
                                         ele.ispmlTransNameDiff = true;
                                     }
                                     if(assEle.assetNameDocDifferent === 'No'){
                                         ele.ispmlTransNameDiff = false;
                                     }                                                                                                                        
                             }
                         }
                     }
                 }
             }         
     })
     .catch() 
     }
} 
export function handleUploadfmdHelper(event,getOtherInstitutionData){
    let assetId = JSON.stringify(event.detail);   
    if(assetId){      
     createAssetForIncompleteCaseProcessingNew({
        assetId:assetId,key: 'Diploma Document'     
     })
     .then(result => {
             let assetDetails = result;
             for(const key in getOtherInstitutionData){
                 if(getOtherInstitutionData.hasOwnProperty(key)){
                     let ele = getOtherInstitutionData[key];     
                     for(const assKey in assetDetails){
                         if(assetDetails.hasOwnProperty(assKey)){
                             if(ele.Id===assKey) {
                                 let assEle = assetDetails[assKey];                                  
                                     ele.fmdId = assEle.assetId;
                                     ele.fmdFileName = assEle.fileName;
                                     ele.fmdFileType = assEle.fileType;
                                     ele.fmdFile = assEle.fileUrl;
                                     ele.fmdName =assEle.assetNameDoc;
                                     ele.showfmdFileDetails= true;
                                     let tempPayload = JSON.parse(ele.fmdPayload);
                                     tempPayload.assetId = assEle.assetId;                                   
                                     ele.tctPayload = JSON.stringify(tempPayload);                                                                 
                                     if(assEle.assetNameDocDifferent === 'Yes'){
                                         ele.isFmdNameDiff = true;
                                     }
                                     if(assEle.assetNameDocDifferent === 'No'){
                                         ele.isFmdNameDiff = false;
                                     }
                                     if(assEle.assetNameDocnotinEnglish === 'Yes'){
                                         ele.isFmdTrans = true;
                                     }
                                     if(assEle.assetNameDocnotinEnglish === 'No'){
                                         ele.isFmdTrans = false;
                                     } 
                                 }
                         }
                     }
                 }
             }    
     })
     .catch(error =>{
        console.error('eror'+JSON.stringify(error));
     })  
     }   
  } 
 export function handleUploadfmdNameHelper(event,getOtherInstitutionData){
     let assetId = JSON.stringify(event.detail);   
     if(assetId){      
         createAssetForIncompleteCaseProcessingNew({
         assetId:assetId,key: 'Diploma Name Document'     
      })
          .then(result => {         
                  let assetDetails = result;
                  for(const key in getOtherInstitutionData){
                      if(getOtherInstitutionData.hasOwnProperty(key)){
                          let ele = getOtherInstitutionData[key];          
                          for(const assKey in assetDetails){
                              if(assetDetails.hasOwnProperty(assKey)){
                                  if(ele.Id===assKey) {                                    
                                      let assEle = assetDetails[assKey];
                                          ele.fmdNameId = assEle.assetId;
                                          ele.fmdNameDocName = assEle.fileName;
                                          ele.fmdNameDocType = assEle.fileType;
                                          ele.fmdNameDoc = assEle.fileUrl; 
                                          ele.showfmdNameDocDetails = true;
                                          let tempPayload = JSON.parse(ele.fmdNamePayload);
                                          tempPayload.assetId = assEle.assetId;                                   
                                          ele.fmdNamePayload = JSON.stringify(tempPayload);                                                                                                                                                            
                                  }
                              }
                          }
                      }
                  }
          })
          .catch()  
          } 
 }
export function handleUploadfmdTransHelper(event,getOtherInstitutionData){
     let assetId = JSON.stringify(event.detail);   
      if(assetId){      
         createAssetForIncompleteCaseProcessingNew({
          assetId:assetId,key: 'Diploma Translation Document'     
       })
      .then(result => {            
              let assetDetails = result;
              for(const key in getOtherInstitutionData){
                  if(getOtherInstitutionData.hasOwnProperty(key)){
                      let ele = getOtherInstitutionData[key];          
                      for(const assKey in assetDetails){
                          if(assetDetails.hasOwnProperty(assKey)){
                              if(ele.Id===assKey) {
                                  let assEle = assetDetails[assKey];
                                      ele.fmdTransId = assEle.assetId;
                                      ele.fmdTransFileName = assEle.fileName;
                                      ele.fmdTransFileType = assEle.fileType;
                                      ele.fmdTransFile = assEle.fileUrl;
                                      ele.fmdTransName =assEle.assetNameDoc;
                                      ele.showfmdTransFileDetails = true;
                                      let tempPayload = JSON.parse(ele.fmdTrnPayload);
                                      tempPayload.assetId = assEle.assetId;                                   
                                      ele.fmdTrnPayload = JSON.stringify(tempPayload);                                       
                                      if(assEle.assetNameDocDifferent === 'Yes'){
                                          ele.isFmdTransNameDiff = true;
                                      }
                                      if(assEle.assetNameDocDifferent === 'No'){
                                          ele.isFmdTransNameDiff = false;
                                      }                                                                                                                        
                              }
                          }
                      }
                  }
              }         
      })
      .catch() 
      }
 }
export function handleUploaddlHelper(event,getOtherInstitutionData){   
    let assetId = JSON.stringify(event.detail);   
    if(assetId){      
       createAssetForIncompleteCaseProcessingNew({
        assetId:assetId,key: 'DEAN LETTER DOCUMENT'     
     })   
    .then(result => {               
            let assetDetails = result;
             for(const key in getOtherInstitutionData){
                 if(getOtherInstitutionData.hasOwnProperty(key)){
                     let ele = getOtherInstitutionData[key];      
                     for(const assKey in assetDetails){
                         if(assetDetails.hasOwnProperty(assKey)){
                             if(ele.Id===assKey) {
                                 let assEle = assetDetails[assKey];
                                     ele.dlId = assEle.assetId;
                                     ele.dlFileName = assEle.fileName;
                                     ele.dlFileType = assEle.fileType;
                                     ele.dlFile = assEle.fileUrl;
                                     ele.dlName =assEle.assetNameDoc;
                                     ele.showdlFileDetails =true;
                                     let tempPayload = JSON.parse(ele.dlPayload);
                                     tempPayload.assetId = assEle.assetId;                                   
                                     ele.dlPayload = JSON.stringify(tempPayload); 
                                     if(assEle.assetNameDocDifferent === 'Yes'){
                                         ele.isdlNameDiff = true;
                                     }
                                     if(assEle.assetNameDocDifferent === 'No'){
                                         ele.isdlNameDiff = false;
                                     }
                                     if(assEle.assetNameDocnotinEnglish === 'Yes'){
                                         ele.isdlTrans = true;
                                     }
                                     if(assEle.assetNameDocnotinEnglish === 'No'){
                                         ele.isdlTrans = false;
                                     }                                                                                      
                                }
                         }
                     }
                 }
            }         
     })
     .catch()  
    }
 }
 export function handleUploaddlNameHelper(event,getOtherInstitutionData){
     let assetId = JSON.stringify(event.detail);   
     if(assetId){      
        createAssetForIncompleteCaseProcessingNew({
         assetId:assetId,key: 'DEAN LETTER NAME DOCUMENT'     
      })
     .then(result => {                                              
         let assetDetails = result;
             for(const key in getOtherInstitutionData){
                 if(getOtherInstitutionData.hasOwnProperty(key)){
                     let ele = getOtherInstitutionData[key];
                     for(const assKey in assetDetails){
                         if(assetDetails.hasOwnProperty(assKey)){
                             if(ele.Id===assKey) {                                
                                 let assEle = assetDetails[assKey];
                                     ele.dlNameId = assEle.assetId;
                                     ele.dlNameDocName = assEle.fileName;
                                     ele.dlNameDocType = assEle.fileType;
                                     ele.dlNameDoc =assEle.fileUrl; 
                                     ele.showdlNameDocDetails = true; 
                                     let tempPayload = JSON.parse(ele.dlPayload);
                                     tempPayload.assetId = assEle.assetId;                                   
                                     ele.dlPayload = JSON.stringify(tempPayload);                                                                                                                        
                             }
                         }
                     }
                 }
            }         
     })
     .catch() 
    }
}
export function handleUploaddlTransHelper(event,getOtherInstitutionData){
     let assetId = JSON.stringify(event.detail);   
     if(assetId){      
        createAssetForIncompleteCaseProcessingNew({
         assetId:assetId,key: 'DEAN LETTER TRANSLATION DOCUMENT'     
      })
     .then(result => { 
             let assetDetails = result;
             for(const key in getOtherInstitutionData){
                 if(getOtherInstitutionData.hasOwnProperty(key)){
                     let ele = getOtherInstitutionData[key];          
                     for(const assKey in assetDetails){
                         if(assetDetails.hasOwnProperty(assKey)){
                             if(ele.Id===assKey) {
                                 let assEle = assetDetails[assKey];
                                     ele.dlTransId = assEle.assetId;
                                     ele.dlTransFileName = assEle.fileName;
                                     ele.dlTransFileType = assEle.fileType;
                                     ele.dlTransFile = assEle.fileUrl;
                                     ele.dlTransName =assEle.assetNameDoc;
                                     ele.showdlTransFileDetails = true;
                                     let tempPayload = JSON.parse(ele.dlPayload);
                                     tempPayload.assetId = assEle.assetId;                                   
                                     ele.dlPayload = JSON.stringify(tempPayload); 
                                     if(assEle.assetNameDocDifferent === 'Yes'){
                                         ele.isdlTransNameDiff = true;
                                     }
                                     if(assEle.assetNameDocDifferent === 'No'){
                                         ele.isdlTransNameDiff = false;
                                     }
                             }
                         }
                     }
                 }
             }
     })
     .catch()  
    }
}
export function handleUploadftHelper(event,getOtherInstitutionData){
    let assetId = JSON.stringify(event.detail);   
    if(assetId){      
     createAssetForIncompleteCaseProcessingNew({
        assetId:assetId,key: 'Final Medical School Transcript'     
     })
     .then(result => {      
             let assetDetails = result;
             for(const key in getOtherInstitutionData){
                 if(getOtherInstitutionData.hasOwnProperty(key)){
                     let ele = getOtherInstitutionData[key];     
                     for(const assKey in assetDetails){
                         if(assetDetails.hasOwnProperty(assKey)){
                             if(ele.Id===assKey) {
                                 let assEle = assetDetails[assKey];                                  
                                     ele.ftId = assEle.assetId;
                                     ele.ftFileName = assEle.fileName;
                                     ele.ftFileType = assEle.fileType;
                                     ele.ftFile = assEle.fileUrl;
                                     ele.ftName =assEle.assetNameDoc;
                                     ele.showftFileDetails= true;
                                     let tempPayload = JSON.parse(ele.ftPayload);
                                     tempPayload.assetId = assEle.assetId;                                   
                                     ele.ftPayload = JSON.stringify(tempPayload);                                                                 
                                     if(assEle.assetNameDocDifferent === 'Yes'){
                                         ele.isFtNameDiff = true;
                                     }
                                     if(assEle.assetNameDocDifferent === 'No'){
                                         ele.isFtNameDiff = false;
                                     }
                                     if(assEle.assetNameDocnotinEnglish === 'Yes'){
                                         ele.isFtTrans = true;
                                     }
                                     if(assEle.assetNameDocnotinEnglish === 'No'){
                                         ele.isFtTrans = false;
                                     } 
                                 }
                         }
                     }
                 }
             }    
     })
     .catch(error =>{
         console.error('eror'+JSON.stringify(error));
     })  
     }
  }
  export function handleUploadftNameHelper(event,getOtherInstitutionData){
     let assetId = JSON.stringify(event.detail);   
     if(assetId){      
         createAssetForIncompleteCaseProcessingNew({
         assetId:assetId,key: 'Final Transcript Name Document'     
      })
          .then(result => {         
                  let assetDetails = result;
                  for(const key in getOtherInstitutionData){
                      if(getOtherInstitutionData.hasOwnProperty(key)){
                          let ele = getOtherInstitutionData[key];          
                          for(const assKey in assetDetails){
                              if(assetDetails.hasOwnProperty(assKey)){
                                  if(ele.Id===assKey) {                                    
                                      let assEle = assetDetails[assKey];
                                          ele.ftNameId = assEle.assetId;
                                          ele.ftNameDocName = assEle.fileName;
                                          ele.ftNameDocType = assEle.fileType;
                                          ele.ftNameDoc = assEle.fileUrl; 
                                          ele.showftNameDocDetails = true;
                                          let tempPayload = JSON.parse(ele.ftNamePayload);
                                          tempPayload.assetId = assEle.assetId;                                   
                                          ele.ftNamePayload = JSON.stringify(tempPayload);
                                     }
                              }
                          }
                      }
                  }
          })
          .catch()  
          } 
  }
  export function handleUploadftTransHelper(event,getOtherInstitutionData){
      let assetId = JSON.stringify(event.detail);   
      if(assetId){      
         createAssetForIncompleteCaseProcessingNew({
          assetId:assetId,key: 'Final Transcript Translation'     
       })
      .then(result => {            
              let assetDetails = result;
              for(const key in getOtherInstitutionData){
                  if(getOtherInstitutionData.hasOwnProperty(key)){
                      let ele = getOtherInstitutionData[key];          
                      for(const assKey in assetDetails){
                          if(assetDetails.hasOwnProperty(assKey)){
                              if(ele.Id===assKey) {
                                  let assEle = assetDetails[assKey];
                                      ele.ftTransId = assEle.assetId;
                                      ele.ftTransFileName = assEle.fileName;
                                      ele.ftTransFileType = assEle.fileType;
                                      ele.ftTransFile = assEle.fileUrl;
                                      ele.ftTransName =assEle.assetNameDoc;
                                      ele.showftTransFileDetails = true;
                                      let tempPayload = JSON.parse(ele.ftTrnPayload);
                                      tempPayload.assetId = assEle.assetId;                                   
                                      ele.ftTrnPayload = JSON.stringify(tempPayload);                                       
                                      if(assEle.assetNameDocDifferent === 'Yes'){
                                          ele.isFtTransNameDiff = true;
                                      }
                                      if(assEle.assetNameDocDifferent === 'No'){
                                          ele.isFtTransNameDiff = false;
                                      }                                                                                                                        
                              }
                          }
                      }
                  }
              }         
      })
      .catch() 
      }
  }
 export function handleChangeTCTNameHelper(event,getOtherInstitutionData,instAssetsList) {       
    let targetId = event.target.dataset.stagingId;
    for(const key in getOtherInstitutionData){
       if(getOtherInstitutionData.hasOwnProperty(key)){
           let ele = getOtherInstitutionData[key];
           for(const assKey in instAssetsList){
               if(instAssetsList.hasOwnProperty(assKey)){
                   if(ele.Id===assKey && ele.Id === targetId) {                                               
                       ele.tctNameCond = event.target.checked;                                                    
                   }
               }
           }
       }
   }
}
export function handleChangeTCTTransHelper(event,getOtherInstitutionData,instAssetsList) {       
    let targetId = event.target.dataset.stagingId;
    for(const key in getOtherInstitutionData){
       if(getOtherInstitutionData.hasOwnProperty(key)){
           let ele = getOtherInstitutionData[key];
           for(const assKey in instAssetsList){
               if(instAssetsList.hasOwnProperty(assKey)){
                   if(ele.Id===assKey && ele.Id === targetId) {                                                           
                       ele.tctTransCond = event.target.checked;                                                   
                   }
               }
           }
       }
   }
}
export function handleChangePreNameHelper(event,getOtherInstitutionData,instAssetsList) {       
   let targetId = event.target.dataset.stagingId;
   for(const key in getOtherInstitutionData){
      if(getOtherInstitutionData.hasOwnProperty(key)){
          let ele = getOtherInstitutionData[key];
          for(const assKey in instAssetsList){
              if(instAssetsList.hasOwnProperty(assKey)){
                  if(ele.Id===assKey && ele.Id === targetId) {                                                            
                      ele.pmlNameCond = event.target.checked;                                                  
                  }
              }
          }
      }
  }
}
export function handleChangePreTransHelper(event,getOtherInstitutionData,instAssetsList) {       
   let targetId = event.target.dataset.stagingId;
   for(const key in getOtherInstitutionData){
      if(getOtherInstitutionData.hasOwnProperty(key)){
          let ele = getOtherInstitutionData[key];
          for(const assKey in instAssetsList){
              if(instAssetsList.hasOwnProperty(assKey)){
                  if(ele.Id===assKey && ele.Id === targetId) {                          
                      ele.pmlTransCond = event.target.checked;
                  }
              }
          }
      }
  }
}
export function handleChangefmdNameHelper(event,getOtherInstitutionData,instAssetsList) {       
   let targetId = event.target.dataset.stagingId;
   for(const key in getOtherInstitutionData){
      if(getOtherInstitutionData.hasOwnProperty(key)){
          let ele = getOtherInstitutionData[key];
          for(const assKey in instAssetsList){
              if(instAssetsList.hasOwnProperty(assKey)){
                  if(ele.Id===assKey && ele.Id === targetId) {                                             
                      ele.fmdNameCond = event.target.checked;                                                    
                  }
              }
          }
      }
  }
}
export function handleChangefmdTransHelper(event,getOtherInstitutionData,instAssetsList) {       
    let targetId = event.target.dataset.stagingId;
    for(const key in getOtherInstitutionData){
       if(getOtherInstitutionData.hasOwnProperty(key)){
           let ele = getOtherInstitutionData[key];
           for(const assKey in instAssetsList){
               if(instAssetsList.hasOwnProperty(assKey)){
                   if(ele.Id===assKey && ele.Id === targetId) {                                                           
                       ele.fmdTransCond = event.target.checked;                                                   
                   }
               }
           }
       }
   }
}
export function handleChangeftNameHelper(event,getOtherInstitutionData,instAssetsList) {       
   let targetId = event.target.dataset.stagingId;
   for(const key in getOtherInstitutionData){
      if(getOtherInstitutionData.hasOwnProperty(key)){
          let ele = getOtherInstitutionData[key];
          for(const assKey in instAssetsList){
              if(instAssetsList.hasOwnProperty(assKey)){
                  if(ele.Id===assKey && ele.Id === targetId) {                                              
                      ele.ftNameCond = event.target.checked;                                                   
                  }
              }
          }
      }
  }
}
export function handleChangeftTransHelper(event,getOtherInstitutionData,instAssetsList) {       
    let targetId = event.target.dataset.stagingId;
    for(const key in getOtherInstitutionData){
       if(getOtherInstitutionData.hasOwnProperty(key)){
           let ele = getOtherInstitutionData[key];
           for(const assKey in instAssetsList){
               if(instAssetsList.hasOwnProperty(assKey)){
                   if(ele.Id===assKey && ele.Id === targetId) {                                                           
                       ele.ftTransCond = event.target.checked;                                                   
                   }
               }
           }
       }
   }
}
export function handleChangedlNameHelper(event,getOtherInstitutionData,instAssetsList) {       
   let targetId = event.target.dataset.stagingId;
   for(const key in getOtherInstitutionData){
      if(getOtherInstitutionData.hasOwnProperty(key)){
          let ele = getOtherInstitutionData[key];
          for(const assKey in instAssetsList){
              if(instAssetsList.hasOwnProperty(assKey)){
                  if(ele.Id===assKey && ele.Id === targetId) {                                              
                      ele.dlNameCond = event.target.checked;                                                   
                  }
              }
          }
      }
  }
}
export function handleChangedlTransHelper(event,getOtherInstitutionData,instAssetsList) {       
    let targetId = event.target.dataset.stagingId;
    for(const key in getOtherInstitutionData){
       if(getOtherInstitutionData.hasOwnProperty(key)){
           let ele = getOtherInstitutionData[key];
           for(const assKey in instAssetsList){
               if(instAssetsList.hasOwnProperty(assKey)){
                   if(ele.Id===assKey && ele.Id === targetId) {                                                           
                       ele.dlTransCond = event.target.checked;                                                   
                   }
               }
           }
       }
   }  
}
export function navHel(caseId){
    cancelIncomAsset({caseId: caseId})
    .then();		
}
export function showDelbtn(getOtherInstitutionData){
    for(const key in getOtherInstitutionData){
        if(getOtherInstitutionData.hasOwnProperty(key)){        
        let ele = getOtherInstitutionData[key];
            if(ele.showCourse === true){
                let tccourse = ele.Transfer_Credits__r;                    
                for(var i=0;i<tccourse.length;i++){ 
                    tccourse[i].showTCAdd = true;                       
                    if(tccourse.length > 1){                            
                        tccourse[i].showTCDel = true;
                    }
                    else{
                        tccourse[i].showTCDel = false;
                    }
                }
            }
        }
    }
}
export function checkDegreeDateHelper(template){
        let elem = document.createElement("div");
        elem.id = 'degDateErrorNew';
        elem.textContent = degreeIssueDateGreaterThanEndDate;
        elem.style = 'color:#ff0000; clear:both;';
        template.querySelector('.degree-date-error').appendChild(elem);
}
export function newDateValHel(template){
    let elem = document.createElement("div");
    elem.id = 'endDatefutureError';
    elem.textContent = newDateValidationMessage;
    elem.style = 'color:#ff0000; clear:both;';
    template.querySelector('.start-date-error').appendChild(elem);
}
export function valErrorHel(template){
    let elem = document.createElement("div");
    elem.id = 'startEndDateError';
    elem.textContent = endDateGreaterThanStartDate;
    elem.style = 'color:#ff0000; clear:both;';
    template.querySelector('.end-date-error').appendChild(elem);
}
export function degTitleErrHel(template){
    let elem = document.createElement("div");
    elem.id = 'degTitleError';
    elem.textContent = blankDegTitleLabel;
    elem.style = 'color:#ff0000; clear:both;';
    template.querySelector('input.degreeRecord').classList.add('slds-has-error');
    template.querySelector('input.degreeRecord').parentNode.insertBefore(elem, template.querySelector('input.degreeRecord').nextSibling);
}
export function degTitleErrHel2(template){
    let elem2 = document.createElement("div");
    elem2.id = 'degTitleError';
    elem2.textContent = degreeTitleValidNameLabel;
    elem2.style = 'color:#ff0000; clear:both;';
    template.querySelector('input.degreeRecord').classList.add('slds-has-error');
    template.querySelector('input.degreeRecord').parentNode.insertBefore(elem2, template.querySelector('input.degreeRecord').nextSibling);
}
export function blankDegDateErr(template){
    let elemDeg = document.createElement("div");
    elemDeg.id = 'degDateError';
    elemDeg.textContent = blankDegIssueDateLabel;
    elemDeg.style = 'color:#ff0000; clear:both;';
    template.querySelector('.degree-date-error').appendChild(elemDeg);
}
export function endDateFutErrHel(template){
    let elem = document.createElement("div");
    elem.id = 'endDatefutureErrorStudent';
    elem.textContent = newDateValidation;
    elem.style = 'color:#ff0000; clear:both;';
    template.querySelector('.start-date-error').appendChild(elem);
}
export function gradDateErrHel(template){
    let elem = document.createElement("div");
    elem.id = 'gradDateError';
    elem.textContent = blankGradYearMonthLabel;
    elem.style = 'color:#ff0000; clear:both;';
    template.querySelector('.gradMonthRecord').classList.add('slds-has-error');
    template.querySelector('.gradYearRecord').classList.add('slds-has-error');
    template.querySelector('.grad-date-error').appendChild(elem); // insertBefore(elem, this.template.querySelector('input.schoolRecord').nextSibling);
}
export function endDateErrHel(template){
    let elem = document.createElement("div");
    elem.id = 'endDateError';
    elem.textContent = blankEndDateLabel;
    elem.style = 'color:#ff0000; clear:both;';
    template.querySelector('.end-date-error').appendChild(elem);
}
export function degMedNameErr(template){
    let elem2 = document.createElement("div");
    elem2.id = 'degMedSchoolError';
    elem2.textContent = degMedSchoolValidNameLabel;
    elem2.style = 'color:#ff0000; clear:both;';
    template.querySelector('input.schoolRecord').classList.add('slds-has-error');
    template.querySelector('input.schoolRecord').parentNode.insertBefore(elem2, template.querySelector('input.schoolRecord').nextSibling);
}
export function degMedSchl(template){
    let elem = document.createElement("div");
    elem.id = 'degMedSchoolError';
    elem.textContent = blankDegMedSchoolLabel;
    elem.style = 'color:#ff0000; clear:both;';
    template.querySelector('input.schoolRecord').classList.add('slds-has-error');
    template.querySelector('input.schoolRecord').parentNode.insertBefore(elem, template.querySelector('input.schoolRecord').nextSibling);
}
export function statusErrHel(template){
    let elem = document.createElement("div");
                    elem.id = 'statusError';
                    elem.textContent = blankStatusLabel;
                    elem.style = 'color:#ff0000; clear:both;';
                    template.querySelector('[data-radiogroup]').classList.add('slds-has-error');
                    template.querySelector('[data-radiogroup]').parentNode.insertBefore(elem, template.querySelector('[data-radiogroup]').nextSibling);
}
export function createGradDateHel(template){
    let elem2 = document.createElement("div");
    elem2.id = 'gradDateError';
    elem2.textContent = graduationDateGreaterThanEndDate;
    elem2.style = 'color:#ff0000; clear:both;';
    template.querySelector('.gradYearRecord').classList.add('slds-has-error');
    template.querySelector('.gradMonthRecord').classList.add('slds-has-error');
    template.querySelector('.grad-date-error').appendChild(elem2); // insertBefore(elem, this.template.querySelector('input.schoolRecord').nextSibling);
}
export function gradDateHelper(template){
    let elem2 = document.createElement("div");
    elem2.id = 'gradDateError';
    elem2.textContent = gradYearValidLabel;
    elem2.style = 'color:#ff0000; clear:both;';
    template.querySelector('.gradYearRecord').classList.add('slds-has-error');
    template.querySelector('.gradMonthRecord').classList.add('slds-has-error');
    template.querySelector('.grad-date-error').appendChild(elem2); // insertBefore(elem, this.template.querySelector('input.schoolRecord').nextSibling);
}
export function calculateMonthValHelper(monthVar){
    let monthVal = 0;
    if (monthVar === 'January') {
        monthVal = 1;
    } else if (monthVar === 'February') {
        monthVal = 2;
    } else if (monthVar === 'March') {
        monthVal = 3;
    } else if (monthVar === 'April') {
        monthVal = 4;
    } else if (monthVar === 'May') {
        monthVal = 5;
    } else if (monthVar === 'June') {
        monthVal = 6;
    } else if (monthVar === 'July') {
        monthVal = 7;
    } else if (monthVar === 'August') {
        monthVal = 8;
    } else if (monthVar === 'September') {
        monthVal = 9;
    } else if (monthVar === 'October') {
        monthVal = 10;
    } else if (monthVar === 'November') {
        monthVal = 11;
    } else if (monthVar === 'December') {
        monthVal = 12;
    }
    return monthVal;
}
export function updateSave(getOtherInstitutionData,fileNameReqMap){
        for (const key in getOtherInstitutionData) {
        if (getOtherInstitutionData.hasOwnProperty(key)) {
            let ele = getOtherInstitutionData[key];
            for (const mpkey in fileNameReqMap) {
                if (fileNameReqMap.hasOwnProperty(mpkey)) {
                    let mp = fileNameReqMap[mpkey];
                    if (mp.keyd === ele.Id) {
                        ele.tctNameErrorFlag = mp.tctNameReqVal;
                        ele.pmlNameErrorFlag = mp.pmlNameReqVal;
                        ele.fmdNameErrorFlag = mp.fmdNameReqVal;
                        ele.ftNameErrorFlag = mp.ftNameReqVal;
                        ele.dlNameErrorFlag = mp.dlNameReqVal;
                        ele.tctFileErrorFlag = mp.tctFileReqVal;
                        ele.tctTransFileErrorFlag = mp.tctTransFileReqVal;
                        ele.pmlFileErrorFlag = mp.pmlFileReqVal;
                        ele.pmlTransFileErrorFlag = mp.pmlTransFileReqVal;
                        ele.fmdFileErrorFlag = mp.fmdFileReqVal;
                        ele.fmdTransFileErrorFlag = mp.fmdTransFileReqVal;
                        ele.ftTransFileErrorFlag = mp.ftTransFileReqVal;
                        ele.dlFileErrorFlag = mp.dlFileReqVal;
                        ele.dlTransFileErrorFlag = mp.dlTransFileReqVal;
                        ele.dlDateErrorFlag = mp.dlDateReqVal;
                        ele.tcCourseTitErrorFlag = mp.tcCourseTitVal;
                        ele.tcCourseNumErrorFlag = mp.tcCourseNumVal;
                        ele.tcCourseOutErrorFlag = mp.tcCourseOutVal;
                        ele.tcCourseMonErrorFlag = mp.tcCourseMonVal;
                        ele.tcCourseYrErrorFlag = mp.tcCourseYrVal;
                        if (mp.tcCourseNameReq.length > 0) {
                            let tccourse = ele.Transfer_Credits__r;
                            for (var l = 0; l < mp.tcCourseNameReq.length; l++) {
                                tccourse[mp.tcCourseNameReq[l].indexcounter].showErrorCourse = mp.tcCourseNameReq[l].tcCourseChecker;
                            }
                        }
                    }
                }
            }
        }
    }
} 
export function loadPayload(assEle,ele,caseId){
    let oldtctFilePayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "Transfer Credit Transcript",
        "assetRecordType": "Credential",
        "createOrReplace": "null",
        "assetStatus": "null",
        "assetCreationRequired": "null",
        "assetId": assEle.tctId
    };
    ele.oldtctFilePayload = JSON.stringify(oldtctFilePayloadJson);
    ele.oldtctNameDocId = assEle.tctNameId;
    let oldtctNamePayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "Name Document",
        "assetRecordType": "Identity",
        "createOrReplace": "null",
        "assetStatus": "null ",
        "assetCreationRequired": "null",
        "assetId": ele.oldtctNameDocId
    };
    ele.oldtctNamePayload = JSON.stringify(oldtctNamePayloadJson);
    ele.oldtctTransId = assEle.tctTransId;
    let oldtctTrnPayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "TCT Translation",
        "assetRecordType": "Credential",
        "createOrReplace": "null",
        "assetStatus": "null",
        "assetCreationRequired": "null",
        "assetId": ele.oldtctTransId
    };
    ele.oldtctTrnPayload = JSON.stringify(oldtctTrnPayloadJson);
    let tctPayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "Transfer Credit Transcript",
        "assetRecordType": "Credential",
        "createOrReplace": "Create",
        "assetStatus": "In Progress",
        "assetCreationRequired": "true",
        "assetId": "null"
    };
    ele.tctPayload = JSON.stringify(tctPayloadJson);
    let tctNamePayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "Name Document",
        "assetRecordType": "Identity",
        "createOrReplace": "Create",
        "assetStatus": "In Progress",
        "assetCreationRequired": "true",
        "assetId": "null"
    };
    ele.tctNamePayload = JSON.stringify(tctNamePayloadJson);
    let tctTrnPayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": 'TCT Translation',
        "assetRecordType": 'Credential',
        "createOrReplace": "Create",
        "assetStatus": "In Progress",
        "assetCreationRequired": "true",
        "assetId": "null"
    };
    ele.tctTrnPayload = JSON.stringify(tctTrnPayloadJson);
    let oldpmlFilePayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "Pre-Med Letter",
        "assetRecordType": "Credential",
        "createOrReplace": "null",
        "assetStatus": "null",
        "assetCreationRequired": "null",
        "assetId": assEle.pmlId
    };
    ele.oldpmlFilePayload = JSON.stringify(oldpmlFilePayloadJson);
    ele.oldpmlNameDocId = assEle.pmlNameId;
    let oldpmlNamePayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "Name Document",
        "assetRecordType": "Identity",
        "createOrReplace": "null",
        "assetStatus": "null ",
        "assetCreationRequired": "null",
        "assetId": ele.oldpmlNameDocId
    };
    ele.oldpmlNamePayload = JSON.stringify(oldpmlNamePayloadJson);
    ele.oldpmlTransId = assEle.pmlTransId;
    let oldpmlTrnPayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "Pre-Med Letter Translation",
        "assetRecordType": "Credential",
        "createOrReplace": "null",
        "assetStatus": "null",
        "assetCreationRequired": "null",
        "assetId": ele.oldpmlTransId
    };
    ele.oldpmlTrnPayload = JSON.stringify(oldpmlTrnPayloadJson);
    let pmlPayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "Pre-Med Letter",
        "assetRecordType": "Credential",
        "createOrReplace": "Create",
        "assetStatus": "In Progress",
        "assetCreationRequired": "true",
        "assetId": "null"
    };
    ele.pmlPayload = JSON.stringify(pmlPayloadJson);
    let pmlNamePayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "Name Document",
        "assetRecordType": "Identity",
        "createOrReplace": "Create",
        "assetStatus": "In Progress",
        "assetCreationRequired": "true",
        "assetId": "null"
    };
    ele.pmlNamePayload = JSON.stringify(pmlNamePayloadJson);
    let pmlTrnPayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": 'Pre-Med Letter Translation',
        "assetRecordType": 'Credential',
        "createOrReplace": "Create",
        "assetStatus": "In Progress",
        "assetCreationRequired": "true",
        "assetId": "null"
    };
    ele.pmlTrnPayload = JSON.stringify(pmlTrnPayloadJson);   
    let olddlFilePayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "Letter from Dean",
        "assetRecordType": "Credential",
        "createOrReplace": "null",
        "assetStatus": "null",
        "assetCreationRequired": "null",
        "assetId": assEle.dlId
    };
    ele.olddlFilePayload = JSON.stringify(olddlFilePayloadJson);
    ele.olddlNameDocId = assEle.dlNameId;
    let olddlNamePayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "Name Document",
        "assetRecordType": "Identity",
        "createOrReplace": "null",
        "assetStatus": "null ",
        "assetCreationRequired": "null",
        "assetId": ele.olddlNameDocId
    };
    ele.olddlNamePayload = JSON.stringify(olddlNamePayloadJson);
    ele.olddlTransId = assEle.dlTransId;
    let olddlTrnPayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "Letter from Dean Translation",
        "assetRecordType": "Credential",
        "createOrReplace": "null",
        "assetStatus": "null",
        "assetCreationRequired": "null",
        "assetId": ele.olddlTransId
    };
    ele.olddlTrnPayload = JSON.stringify(olddlTrnPayloadJson);
    let dlPayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "Letter from Dean",
        "assetRecordType": "Credential",
        "createOrReplace": "Create",
        "assetStatus": "In Progress",
        "assetCreationRequired": "true",
        "assetId": "null"
    };
    ele.dlPayload = JSON.stringify(dlPayloadJson);
    let dlNamePayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": "Name Document",
        "assetRecordType": "Identity",
        "createOrReplace": "Create",
        "assetStatus": "In Progress",
        "assetCreationRequired": "true",
        "assetId": "null"
    };
    ele.dlNamePayload = JSON.stringify(dlNamePayloadJson);
    let dlTrnPayloadJson = {
        "contactId": ele.Contact__c,
        "caseId": String(caseId),
        "catId": ele.Id,
        "documentType": 'Letter from Dean Translation',
        "assetRecordType": 'Credential',
        "createOrReplace": "Create",
        "assetStatus": "In Progress",
        "assetCreationRequired": "true",
        "assetId": "null"
    };
    ele.dlTrnPayload = JSON.stringify(dlTrnPayloadJson);   
    }