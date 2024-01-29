({
    updateOfferingToServer: function (component, offeringRecord) {
        console.log('updateOfferingToServer called');

        const action = component.get('c.updateOffering');
        action.setParams({
            'offeringId': offeringRecord.uuid,
            'offeringRecordJSON': JSON.stringify(offeringRecord)
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {

                    // DEBUGGING
                    //console.log('updateOfferingToServer result: ', result);
                    this.showToast('success', 'Success', 'Offering saved');
                    component.set('v.saveClicked', true);

                } else {
                    this.showToast('error', 'Error', 'The following error occurred while processing the request: ' + result.message, 'sticky');
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'TThe following error(s) occurred while processing the request: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while processing the request');
                }
            }

            this.hideSpinner(component);
        });

        this.showSpinner(component);
        $A.enqueueAction(action);
    },

    updateLocationToServer: function (component, locationRecord) {
        console.log('updateLocationToServer called');

        const action = component.get('c.updateProvider');
        action.setParams({
            'providerId': locationRecord.uuid,
            'providerRecordJSON': JSON.stringify(locationRecord)
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {

                    // DEBUGGING
                    //console.log('updateLocationToServer result: ', result);
                    this.showToast('success', 'Success', 'Location saved');
                    component.set('v.saveClicked', true);

                } else {
                    this.showToast('error', 'Error', 'The following error occurred while processing the request: ' + result.message, 'sticky');
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'TThe following error(s) occurred while processing the request: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while processing the request');
                }
            }

            this.hideSpinner(component);
        });

        this.showSpinner(component);
        $A.enqueueAction(action);
    }
})