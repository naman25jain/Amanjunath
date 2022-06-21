// Interface class for Case Trigger
public Interface CaseTriggerHandlerInterface{
    // Calls before insert method from the respective record type's class
    void beforeInsert(List<Case> newCases);
    // Calls before update method from the respective record type's class
    void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap);
    // Calls after insert method from the respective record type's class
    void afterInsert(Map<Id,Case> newCasesMap);
    // Calls after update method from the respective record type's class
    void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap);
}