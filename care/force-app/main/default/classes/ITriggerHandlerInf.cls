public interface ITriggerHandlerInf {
    void beforeInsert(List<Case> newList, List<Case> oldList, Map<id, Case> newItems, Map<id, Case> oldItems, Boolean isInsert,Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter);
    void beforeUpdate(List<Case> newList, List<Case> oldList, Map<id, Case> newItems, Map<id, Case> oldItems, Boolean isInsert,Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter);
    void afterInsert(List<Case> newList, List<Case> oldList, Map<id, Case> newItems, Map<id, Case> oldItems, Boolean isInsert,Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter);
    void afterUpdate(List<Case> newList, List<Case> oldList, Map<id, Case> newItems, Map<id, Case> oldItems, Boolean isInsert,Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter);
    void beforeDelete(List<Case> newList, List<Case> oldList, Map<id, Case> newItems, Map<id, Case> oldItems, Boolean isInsert,Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter);
    void afterDelete(List<Case> newList, List<Case> oldList, Map<id, Case> newItems, Map<id, Case> oldItems, Boolean isInsert,Boolean isUpdate, Boolean isDelete, Boolean isBefore, Boolean isAfter);
}