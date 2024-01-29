({
    // Retrieve the Scoreboard metrics from our Apex class
    getDataFromServer: function (component) {
        const action = component.get('c.getScoreboardData');

        action.setParams({
            'recordId': component.get('v.recordId'),
            'forcePointsRecalculate': false
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {

                    // DEBUGGING
                    //console.log('getScoreboardData result: ', result);

                    // Common fields for all Record Types
                    component.set('v.advertisingBudgetTotalAmount', result.advertisingBudgetTotalAmount);
                    let totalPlatformFee = result.totalPlatformFee;
                    if (result.platformFeeWaived <= (result.initialPlatformFee + result.additionalLocationPlatformFee)) {
                        totalPlatformFee -= result.platformFeeWaived;
                    }
                    component.set('v.totalPlatformFee', totalPlatformFee);
                    component.set('v.numLocations', result.numLocations);
                    component.set('v.ofLocations', result.ofLocations);

                    // Fields for use in SO (Sales Origination) Record Types (according to Custom Metadata Settings)
                    if (component.get('v.recordType') === 'SO') {
                        component.set('v.basePoints', result.basePoints);
                        component.set('v.bonusPoints', result.bonusPoints);
                        component.set('v.totalPoints', result.basePoints + result.bonusPoints);
                    }
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Scoreboard Information: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Scoreboard information: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while retrieving Scoreboard information');
                }
            }

            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    }
})