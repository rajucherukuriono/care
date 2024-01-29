({
    getDataFromServer: function (component) {
        const action = component.get('c.getServiceData');

        action.setParams({
            'recordId': component.get('v.recordId')
        });

        action.setCallback(this, $A.getCallback(function(response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {
                    component.set('v.opportunityRecord', result.opportunityRecord);
                    component.set('v.composerServiceRecords', this.configureComposerServiceRecords(component, result));
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Service information: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Service information: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while retrieving Service information');
                }
            }

            this.hideSpinner(component);
        }));

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    configureComposerServiceRecords: function(component, result) {
        let composerServiceRecords = result.composerServiceRecords || [];
        let permittedComposerServiceRecords = [];
        let currentVertical = result.opportunityRecord.Composer_Service__r ? result.opportunityRecord.Composer_Service__r.Vertical__c : undefined;

        if (result.permittedVerticals === undefined) {
            permittedComposerServiceRecords = composerServiceRecords;
        } else {
            // Loop through composer service records and see whether
            // the current user has permission to select the service
            composerServiceRecords.forEach(r => {
                if (result.permittedVerticals.find(v => v === r.Vertical__c) !== undefined) {
                    permittedComposerServiceRecords.push(r);
                }
            });

            // Block editing of opportunity if the opportunity already has a
            // Composer Service vertical and the user doesn't have permission
            // for that vertical
            if (currentVertical !== undefined && result.permittedVerticals.find(v => v === currentVertical) === undefined) {
                component.set('v.allowEdit', false);
                permittedComposerServiceRecords = [];
                this.showToast('error', 'Error', 'You do not have permission to edit ' + currentVertical + ' services.');
            }
        }

        return permittedComposerServiceRecords;
    },

    // Persist the selected Composer Service to the Opportunity
    saveDataToServer: function (component) {
        const recordId = component.get('v.recordId');
        const composerServiceRecordId = component.get('v.opportunityRecord.Composer_Service__c');

        const action = component.get('c.saveComposerServiceData');

        const config = {
            'recordId': recordId,
            'composerServiceRecordId': composerServiceRecordId
        };

        action.setParams(config);

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                // DEBUGGING
                //console.log('saveBGCData result: ', result);

                if (!result.hasErrors) {
                    component.set('v.opportunityRecord', result.opportunityRecord);

                    // this.showToast('success', 'Success', 'Background Check Information saved successfully.');
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while saving Composer Service: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while saving Composer Service: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while saving Composer Service');
                }
            }

            this.publishDataSavedMessage(component);
            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    }
})