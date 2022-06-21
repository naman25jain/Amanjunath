trigger CreateApplicantBatchLog on Applicant_Batch_Event__e (After Insert){
  ApplicantEventHandler EventHandler = new ApplicantEventHandler();
  If(Trigger.isAfter && Trigger.IsInsert){
    EventHandler.onAfterInsert(Trigger.New, Trigger.NewMap);
  }
}