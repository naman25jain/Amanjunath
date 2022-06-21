import { LightningElement, api } from 'lwc';
import { passDataToParent } from "c/util";

export default class VtEachNewSitePrediction extends LightningElement {
    @api sitePrediction;


    handlePredictionSelect() {
        passDataToParent("predictionselect", true, { placeId: this.sitePrediction.place_id, placeName: this.sitePrediction.main_text }, this);
    }
}