/**
    * @author: Femi 
    * @name: ScoreWithheldCheckTrigger
    * @description: User Story : 3662 update score withheld flag for exam registration records
 **/
trigger ScoreWithheldCheckTrigger on NBME_Score_Update_Event__e (after insert) {
    
    ScoreWithheldHelper.updateScoreWithheld(Trigger.new);
}