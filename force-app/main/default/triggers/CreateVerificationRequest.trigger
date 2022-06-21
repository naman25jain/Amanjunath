trigger CreateVerificationRequest on PAE_request__e (After Insert) {
PAE_RequestEventHandler EventHandler = new PAE_RequestEventHandler();
If(Trigger.isAfter && Trigger.IsInsert){
   EventHandler.onAfterInsert(Trigger.New, Trigger.NewMap);
  }
}