import {LightningElement, track} from 'lwc';
//import required apex methods
import getEPExExams from '@salesforce/apex/EPExController.getEPExExams';
import createEPExCase from '@salesforce/apex/EPExController.createEPExCase';
import validateEPExRequest from '@salesforce/apex/EPExController.validateEPExRequest';
export default class EPExForm extends LightningElement{
    @track recordsList =[];
    @track btnDisabled;
    @track certification;
    @track spinner;
    @track clickedButton;
    @track selectedExams = [];
    @track instructionsContent = ''+
    '<body>'+
    '<!-- Draw the header -->'+
    ''+
    '<table width="765px" border="0px" cellspacing="0px" cellpadding="0px">'+
    '	<tbody>'+
    '	<tr><td width="5%"> </td>'+
    '		<td class="pagedetail" width="90%" align="left"><br>'+
    '			'+
    'If you are unable to take USMLE Step 1 and/or Step 2 CK during the eligibility period assigned to you, you may request a one-time extension. You may extend your eligibility period only through the next eligibility period that does not overlap with your assigned eligibility period.'+
    '<br><br>'+
    'Please note that if you do not take the exam during your original or extended eligibility period or if you are unable to extend your eligibility period, you must reapply by submitting a new USMLE application and fee(s), if you wish to take the exam.'+
    '<br><br>'+
    ''+
    '<b>Number and Timing of Your Request</b><br>'+
    'You may request an extension of your eligibility period only once for each exam registration and only after your original eligibility period has begun. The processing of your request must be completed by the published deadline (refer to the table below), or your request will be rejected. The time needed to complete the processing of your request may be contingent upon your medical school\'s response to ECFMG\'s enrollment verification request.'+
    '<br><br>'+
    'If you are requesting an extension of the eligibility periods for both Step 1 and Step 2 CK at the same time and the eligibility periods are different, the processing of your request must be completed by the deadline for the earlier eligibility period. For specific information on the timing of your request, refer to the table below.'+
    ''+
    '		</td>'+
    '		<td width="5%"> </td>'+
    '	</tr>'+
    '	<tr><td> </td>'+
    '		<td align="center">'+
    '		</td>'+
    '	</tr>	'+
    '</tbody></table>'+
    '<table border="0px" cellspacing="0px" cellpadding="0px">'+
    '	<tbody>'+
    '	<tr>'+
    '	    <th width="5%"> </th>'+
    '		<th class="pagedetail" width="28%" align="left"><b>Original Eligibility Period</b></th>'+
    '	    <th width="5%" width="5%"> </th>'+
    '		<th class="pagedetail" width="29%" align="left"><b>Extended Eligibility Period</b></th>'+
    '	    <th width="5%"> </th>'+
    '		<th class="pagedetail" width="28%" align="left"><b>Deadline</b></th>'+
    '	    <th width="5%"> </th>'+
    '	</tr>'+
    '	<tr>'+
    '	    <td width="5%"> </td>'+
    '		<td class="pagedetail" width="28%" align="left">Apr 1, 2021 – Jun 30, 2021</td>'+
    '	    <td width="5%" width="5%"> </td>'+
    '		<td class="pagedetail" width="29%" align="left">Apr 1, 2021 – Sep 30, 2021</td>'+
    '	    <td width="5%"> </td>'+
    '		<td class="pagedetail" width="28%" align="left">Monday, Jul 26, 2021</td>'+
    '	    <td width="5%"> </td>'+
    '	</tr>'+
    '	<tr>'+
    '	    <td width="5%"> </td>'+
    '		<td class="pagedetail" width="28%" align="left">May 1, 2021 – Jul 31, 2021</td>'+
    '	    <td width="5%" width="5%"> </td>'+
    '		<td class="pagedetail" width="29%" align="left">May 1, 2021 – Oct 31, 2021</td>'+
    '	    <td width="5%"> </td>'+
    '		<td class="pagedetail" width="28%" align="left">Wednesday, Aug 25, 2021</td>'+
    '	    <td width="5%"> </td>'+
    '	</tr>'+
    '	<tr>'+
    '	    <td width="5%"> </td>'+
    '		<td class="pagedetail" width="28%" align="left">Jun 1, 2021 – Aug 31, 2021</td>'+
    '	    <td width="5%" width="5%"> </td>'+
    '		<td class="pagedetail" width="29%" align="left">Jun 1, 2021 – Nov 30, 2021</td>'+
    '	    <td width="5%"> </td>'+
    '		<td class="pagedetail" width="28%" align="left">Monday, Sep 27, 2021</td>'+
    '	    <td width="5%"> </td>'+
    '	</tr>'+
    '	<tr>'+
    '	    <td width="5%"> </td>'+
    '		<td class="pagedetail" width="28%" align="left">Jul 1, 2021 – Sep 30, 2021</td>'+
    '	    <td width="5%" width="5%"> </td>'+
    '		<td class="pagedetail" width="29%" align="left">Jul 1, 2021 – Dec 31, 2021</td>'+
    '	    <td width="5%"> </td>'+
    '		<td class="pagedetail" width="28%" align="left">Monday, Oct 25, 2021 </td>'+
    '	    <td width="5%"> </td>'+
    '	</tr>'+
    '</tbody></table>'+
    '<table width="765px" border="0px" cellspacing="0px" cellpadding="0px">'+
    '	<tbody>'+
    '	<tr><td width="5%"> </td>'+
    '		<td class="pagedetail" width="90%" align="left"><br><br>'+
    ''+
    '<b>Eligibility</b><br>'+
    'You must continue to be eligible to take the exam during the extended eligibility period. You must either a) be a student officially enrolled in a medical school located outside of the United States and Canada that is listed in the <i>World Directory of Medical Schools</i> (<i>World Directory</i>) with an ECFMG note stating it meets eligibility requirements for its students and graduates to apply to ECFMG for ECFMG Certification and examination, and the "Graduation Years" for your medical school must be listed as "Current"; or b) be a graduate of such a medical school and your graduation year must be included in the school\'s ECFMG note on the Sponsor Notes tab of the medical school\'s <i>World Directory</i> listing. Refer to <i>Eligibility for Examination</i> in the <a href=\'http://www.ecfmg.org/resources/publications.html#ib\' target=\'_blank\'>ECFMG <i>Information Booklet</i></a>.'+
    '<br><br>'+
    ''+
    '<b>Enrollment Verification </b><br>'+
    'In order to process your request for an eligibility period extension, ECFMG must verify your eligibility for examination, as described above. If you were registered for this examination as a graduate, your status was confirmed prior to registration and no additional action is required. If you were registered for this examination as a student, ECFMG will request enrollment verification from your medical school via the school\'s preferred method, either through MyIntealth or a paper form. If your medical school verifies enrollment through MyIntealth, your record will be made available to your medical school after you submit your eligibility period extension request. If your medical school completes enrollment verification requests via paper form, you will be provided with the form and instructions after you submit your eligibility period extension request.'+
    '<br><br>'+
    'If you were registered for this exam as a student, ECFMG must receive verification of your enrollment from your medical school and process your request by the published deadline (see above), or your eligibility period extension request will be rejected. '+
    ''+
    '<br><br>'+
    ''+
    '<b>Canceling/Rescheduling a Testing Appointment</b><br>'+
    'If you have a scheduled testing appointment during your original eligibility period and need to cancel and reschedule the appointment for your extended eligibility period, you must contact Prometric to cancel or reschedule that appointment. Requesting an extension of your eligibility period does not cancel a scheduled appointment. '+
    '<br><br>'+
    '<b>Important Note:</b> Depending on the date you change (reschedule, cancel, or change your test center location) your appointment, a rescheduling fee may apply. Refer to the USMLE website for details on Prometric\'s rescheduling fees. If you cancel your appointment or do not test as scheduled, you may need to call Prometric and pay a fee to reinstate your eligibility record before you submit your request for an eligibility period extension. Refer to your scheduling permit for details.'+
    '<br><br>'+
    'If your eligibility period is extended, a revised scheduling permit reflecting the extension will be issued. ECFMG will notify you when your revised scheduling permit is available. You must present the revised scheduling permit at the test center on your exam date.'+
    '<br><br>'+
    '		</td>'+
    '		<td width="5%"> </td>'+
    '	</tr>'+
    '	<tr><td> </td>'+
    '		<td align="center">'+
    '		</td>'+
    '	</tr>	'+
    '</tbody></table>'+
    ''+
    ''+
    '</body>';
    connectedCallback(){
        this.btnDisabled = true;
        this.certification =false;
        getEPExExams().then(data=>{
            if(data !== undefined){
                if(data.length>0){
                    for(let key in data){
                        if(data.hasOwnProperty(key)){
                            let tempRecord ={
                                epStartDate: data[key].epStartDate,
                                epEndDate: data[key].epEndDate,
                                type: data[key].type,
                                case: data[key].caseId,
                                extendedStartDate: data[key].extendedStartDate,
                                extendedEndDate: data[key].extendedEndDate,
                                deadline: data[key].deadline,
                                check: data[key].check
                            }
                            if(data[key].check){
                                this.selectedExams = [...this.selectedExams, data[key].caseId];
                            }
                            if(this.recordsList.length > 0){
                                this.recordsList = [...this.recordsList, tempRecord];
                            }else{
                                this.recordsList = [tempRecord];
                            }
                        }
                    }
                }
            }
        })
    }
    calculateDeadLine(endDate){
        var endDateJs = new Date(endDate);
        var lastDay = new Date(endDateJs.getFullYear(), endDateJs.getMonth() + 1, 1);
        var now_utc = new Date(lastDay.toUTCString().slice(0, -4));
        now_utc.setDate(lastDay.getDate()+23);
        now_utc.setFullYear(lastDay.getFullYear());
        now_utc.setMonth(lastDay.getMonth());
        return now_utc;
    }
    calculateExtendedEndDate(endDate){
        var endDateJs = new Date(endDate);
        var lastDay = new Date(endDateJs.getFullYear(), endDateJs.getMonth() + 4, 0);
        var now_utc = new Date(lastDay.toUTCString().slice(0, -4));
        now_utc.setDate(lastDay.getDate());
        now_utc.setFullYear(lastDay.getFullYear());
        now_utc.setMonth(lastDay.getMonth());
        return now_utc;
    }
    handleChange(event){
        let caseId = event.target.value;
        if(event.target.checked){
            if(!this.selectedExams.includes(caseId)){
                this.selectedExams= [...this.selectedExams, caseId];
            }
        }else{
            if(this.selectedExams.includes(caseId)){
                this.selectedExams = this.selectedExams.filter(pick => pick !== caseId);
            }
        }
        if(this.selectedExams.length>0 && this.certification ===true){
            this.btnDisabled = false;
        }else{
            this.btnDisabled = true;
        }
        this.spinner = true;
        this.checkDateValidations();
        if(!this.selectedExams.length>0){
            this.spinner=false;
        }
    }
    checkDateValidations(currentCheckboxElement){
        this.template.querySelectorAll('#dateError').forEach(element => element.remove());
        this.template.querySelectorAll('#requestError').forEach(element => element.remove());
        let textcontent = '';
        let today = new Date();
        let startDate;
        let deadLine;
        let type;
        for(let key in this.recordsList){
            if(this.recordsList.hasOwnProperty(key)){
                if(this.selectedExams.includes(this.recordsList[key].case)){
                    startDate = new Date(this.recordsList[key].epStartDate);
                    deadLine = new Date(this.recordsList[key].deadline);
                    type = this.recordsList[key].type;
                    let caseNumber = this.recordsList[key].case;

                    if(startDate > today || today > deadLine){
                        if(startDate > today){
                            textcontent ='Eligibility Period should be started to apply for Extension of Period';
                        }else{
                            textcontent ='Eligibility Period extension cannot be applied after deadline';
                        }
                        let elem = document.createElement("div");
                        elem.id = 'dateError';
                        elem.textContent = textcontent;
                        elem.style = 'color:#ff0000; clear:both;';
                        this.template
                        .querySelectorAll(".checkbox-float")
                        .forEach(elemc => {
                            if(elemc.value === caseNumber){
                                elemc.classList.add('slds-has-error');
                                elemc.parentNode.insertBefore(elem, elemc.nextSibling);

                            }
                        });

                    }
                        validateEPExRequest({examType:type, caseId:caseNumber}).then(data=>{
                            if(data){
                                let elem = document.createElement("div");
                                elem.id = 'requestError';
                                elem.textContent = 'You either already have a pending request to extend the eligibility period for this exam, or you have already been granted the one-time eligibility period extension for this exam.';
                                elem.style = 'color:#ff0000; clear:both;';
                                this.template
                                .querySelectorAll(".checkbox-float")
                                .forEach(elemc => {
                                    if(elemc.value === caseNumber){
                                        elemc.classList.add('slds-has-error');
                                        elemc.parentNode.insertBefore(elem, elemc.nextSibling);

                                    }
                                });
                            }
                            this.spinner = false;
                        });
                }
            }
        }

    }
    handleCheckboxChange(event){
        if(event.target.checked){
            this.certification =true;
            if(this.selectedExams.length>0){
                this.btnDisabled = false;
            }else{
                this.btnDisabled = true;
            }
        }else{
            this.btnDisabled = true;
            this.certification =false;
        }
    }
    saveChanges(){
        let blockSave = false;
        if(this.template.querySelector('#dateError') !==null || this.template.querySelector('#requestError') !==null){
            blockSave = true;
            if(this.template.querySelector('#dateError') !==null){
                this.template.querySelector('#dateError').scrollIntoView();
            }else{
                this.template.querySelector('#requestError').scrollIntoView();
            }
        }
        if(!blockSave){
            this.spinner =true;
            createEPExCase({
                selectedList: JSON.stringify(this.selectedExams)
            }).then(data=>{
                if(data){
                    if(this.clickedButton=== 'next'){
                        this.spinner= false;
                        const selectEvent = new CustomEvent('nextevent', {detail:{caserecordidepex:data}});
                        this.dispatchEvent(selectEvent);
                    }
                }
            })
        }
    }
    displayModalClass(){
        this.template.querySelector('[data-id="modalExisting"]').show();
    }
    closeButton(){
        this.template.querySelector('[data-id="modalExisting"]').hide();
    }

    cancelButtonToOpen(){
        this.template.querySelector('[data-id="newModalAlert"]').show();
    }
    closeModal(){
        this.template.querySelector('[data-id="newModalAlert"]').hide();
    }

    prevButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('previousevent', {});
        this.dispatchEvent(selectEvent);
    }

    nextButton(event) {
        event.preventDefault();
        this.clickedButton = 'next';
        this.saveChanges();
    }

    cancelButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }
}