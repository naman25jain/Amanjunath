public inherited sharing class RunTestClassesJobScheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
      Database.executeBatch(new RunTestClassesJob(), 100);
  }
}