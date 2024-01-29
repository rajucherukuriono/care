({
    onInit: function (component, event, helper) {
        helper.getDataFromServer(component);
    },

    onComposerServiceChange: function (component, event, helper) {
        // Return early if in readonly mode
        if (!component.get('v.allowEdit')) return;

        const opportunityRecord = component.get('v.opportunityRecord');
        const composerServiceRecordId = event.getSource().get('v.value');

        // No changes, return early
        if (!$A.util.isEmpty(opportunityRecord.Composer_Service__c) && opportunityRecord.Composer_Service__c === composerServiceRecordId) return;

        // Update our selected Composer Service Record Id
        component.set('v.opportunityRecord.Composer_Service__c', composerServiceRecordId);

        helper.saveDataToServer(component);
    }
})