import { LightningElement, track, api } from 'lwc';
import getReportYears from '@salesforce/apex/AggregatePerformanceReport.getReportYear';
import generateAggregateReport from '@salesforce/apex/AggregatePerformanceReport.generateAggregateReport';
import deleteAggregateReport from '@salesforce/apex/AggregatePerformanceReport.deleteAggregateReport';
import getApdRecord from '@salesforce/apex/AggregatePerformanceReport.getApdRecord';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class FaimerReportGeneration extends LightningElement{
    @track reportType;
    @track optionsYear;
    @track reportYearValue = '';
    @track showReportSelection = false;
    @track showSubmitButton = false;
    @track showSecondary = false;
    @api recordId;
    @track yearValue = '';
    get options() {
        return[
            {label: 'Aggregate Report', value: 'Aggregate Report'},
            {label: 'Special Report', value: 'Special Report'},
        ];
    }
    handleChangeType(event) {
        this.showSecondary = false;
        const selectedReport = event.detail.value;
        this.reportType = selectedReport;
        this.showSubmitButton = false;
        getReportYears({
            selectedReportValue: this.reportType,
            entityId: this.recordId
        })
            .then(result =>{
                if(result !== undefined){
                    let dataList = [];
                    if(result !== ''){
                        let tempVal = [];
                        dataList = result;
                        for(var key in dataList){
                            let tempTcRecord = {label: result[key], value: result[key]}
                            tempVal.push(tempTcRecord);
                        }
                        this.optionsYear = tempVal;
                    }
                    this.showSecondary = true;
                }
            })
    }
    handleChangeYear(event){
        let reportYear = event.detail.value;
        if(reportYear != undefined){
            this.showSubmitButton = true;
            this.yearValue = reportYear;
        }
    }
    generateReport(event){
        this.showReportSelection = true;
        this.showSubmitButton = false;
    }

    nextButton() {
        if (this.reportType === 'Aggregate Report') {
            generateAggregateReport({
                yearValue: this.yearValue,
                entityId: this.recordId
            }).then(result => {
                if (result !== 'No document created') {
                    var str = result;
                    var arr = [];
                    arr = str.split("/");
                    var new_window = window.open(result, "");
                    if(!new_window) {
                        const errorStep1 = new ShowToastEvent({
                            title: "Error",
                            message: "A popup blocker may be preventing the application from opening the page. Select 'Always allow pop-ups' to download the report.",
                            variant: "error"
                        });
                        this.dispatchEvent(errorStep1);
                    } else {
                        var timer = setInterval(function() {
                            if(new_window.closed) {
                                clearInterval(timer);
                                deleteAggregateReport({ cvId: arr[5] });
                            }
                        }, 1000);
                        const successMsg = new ShowToastEvent({
                            title: "Success",
                            message: "Your report is generating and will be downloaded shortly",
                            variant: "success"
                        });
                        this.dispatchEvent(successMsg);
                    }
                } else {
                    const errorStep1 = new ShowToastEvent({
                        title: "Error",
                        message: "There is no matching report for this medical school for the year selected.",
                        variant: "error"
                    });
                    this.dispatchEvent(errorStep1);
                }
            });
        }
        if (this.reportType === 'Special Report') {
            getApdRecord({
                yearValue: this.yearValue,
                entityId: this.recordId
            })
                .then(result =>{
                    if(result){
                        var str = result;
                        var arr = [];
                        arr = str.split("/");
                        var new_window = window.open(result, "");
                        var timer = setInterval(function() {
                            if(new_window.closed) {
                                clearInterval(timer);
                                deleteAggregateReport({ cvId: arr[5] });
                            }
                        }, 1000);
                        const successMsg = new ShowToastEvent({
                            title: "Success",
                            message: "Your report is generating and will be downloaded shortly",
                            variant: "success"
                        });
                        this.dispatchEvent(successMsg);
                    }else{
                        console.log("error" + result);
                    }
                })
        }
        this.showReportSelection = false;
        this.optionsYear = '';
    }
    cancelButton(){
        this.showReportSelection = false;
        this.optionsYear = '';
    }
}