({
    init: function(component) {
        const userRecord = component.get('v.userRecord');
        let permittedVerticals = userRecord.Contract_Composer_Permitted_Verticals__c;
        let permittedVerticalsSet = new Set();
        if (userRecord.Contract_Composer_Permitted_Verticals__c) {
            permittedVerticalsSet = new Set(permittedVerticals.split(','));
        }

        let composerServiceRecords = component.get('v.composerServiceRecords');
        composerServiceRecords.forEach(c => c.checked = permittedVerticalsSet.has(c.Vertical__c));
        component.set('v.composerServiceRecords', composerServiceRecords);
    },

    updateUserPermissions: function(component) {
        const userRecord = component.get('v.userRecord');

        const action = component.get('c.updateUserPermittedVerticals');
        action.setParams({
            userId: userRecord.Id,
            permittedVerticals: userRecord.Contract_Composer_Permitted_Verticals__c
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                // DEBUGGING
                console.log('getDataFromServer result: ', result);

                if (!result.hasErrors) {
                    component.set('v.saveClicked', true);
                    this.closeModal(component);
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving User Permissions Data: ' + result.message, 'sticky');
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error(s) occurred while retrieving User Permissions Data: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while retrieving User Permissions Data');
                }
            }
            this.hideSpinner(component);
        });

        this.showSpinner(component);
        $A.enqueueAction(action);
    },

    updateSelectedVerticals: function(component, composerServiceId, checked) {
        let userRecord = component.get('v.userRecord');
        let composerServiceRecord = component.get('v.composerServiceRecords').find(c => c.Id === composerServiceId);
        let permittedVerticals = userRecord.Contract_Composer_Permitted_Verticals__c;
        let permittedVerticalsSet = new Set();
        if (userRecord.Contract_Composer_Permitted_Verticals__c) {
            permittedVerticalsSet = new Set(permittedVerticals.split(','));
        }

        if (checked) {
            permittedVerticalsSet.add(composerServiceRecord.Vertical__c);
        } else {
            permittedVerticalsSet.delete(composerServiceRecord.Vertical__c);
        }

        // Join verticals back into a comma-separated-value and assign it back to the userRecord
        userRecord.Contract_Composer_Permitted_Verticals__c = [...permittedVerticalsSet].join(',');

        component.set('v.userRecord', userRecord);
    }
})