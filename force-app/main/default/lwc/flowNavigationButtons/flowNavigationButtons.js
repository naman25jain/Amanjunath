import { LightningElement, api} from 'lwc';


export default class FlowNavigationButtons extends LightningElement {
    @api isPrevious;
    @api isNext;
    @api isFinish;

    handleAction(event) {

        if (event.target.name == 'Next') {
            this.dispatchEvent(new CustomEvent('next', {detail :'Next'}));
        }
        else if (event.target.name == 'Previous'){
            this.dispatchEvent(new CustomEvent('previous', {detail :'Previous'}));
        }
        else if (event.target.name == 'Finish'){
            this.dispatchEvent(new CustomEvent('finish', {detail :'Finish'}));
        }
    }
}