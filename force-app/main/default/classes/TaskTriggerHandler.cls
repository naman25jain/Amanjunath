public with sharing class TaskTriggerHandler {
    public static void afterInsert(List<Task> newTasks) {
        TaskTriggerHelper.afterInsertHelper(newTasks);
    }

    public static void afterUpdate(List<Task> newTasks, Map<Id, Task> oldTasksMap) {
        TaskTriggerHelper.afterUpdateHelper(newTasks, oldTasksMap);
    }
}