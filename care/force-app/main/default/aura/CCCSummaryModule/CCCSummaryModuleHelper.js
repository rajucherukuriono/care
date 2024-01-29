({
    // Retrieve Summary Metrics
    getDataFromServer: function (component) {
        const action = component.get('c.getSummaryData');

        action.setParams({
            'recordId': component.get('v.recordId')
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {

                    // DEBUGGING
                    //console.log('getSummaryData result: ', result);

                    component.set('v.opportunityRecord', result.opportunityRecord);
                    component.set('v.locationRecords', this.buildLocationRecords(result.locationRecords, result.locationServiceRecordsMap));
                    component.set('v.primaryContactRecord', result.primaryContactRecord);

                    // Button Management
                    component.set('v.publishAgreementDisablementReasons', result.publishAgreementDisablementReasons);
                    component.set('v.showPublishAgreementButton', result.showPublishAgreementButton);
                    component.set('v.showVoidAgreementButton', result.showVoidAgreementButton);
                    component.set('v.voidAgreementDisablementReasons', result.voidAgreementDisablementReasons);

                    const disablePublishAgreementButton = !$A.util.isEmpty(result.opportunityRecord.Agreement_Id__c) || result.publishAgreementDisablementReasons.length > 0;
                    component.set('v.disablePublishAgreementButton', disablePublishAgreementButton);

                    // Calculated Amounts
                    component.set('v.agreementTotalAmount', result.agreementTotalAmount);
                    component.set('v.advertisingBudgetTotalAmount', result.advertisingBudgetTotalAmount);
                    component.set('v.additionalLocationPlatformFee', result.additionalLocationPlatformFee);
                    component.set('v.initialPlatformFee', result.initialPlatformFee);
                    component.set('v.platformFeeWaived', result.platformFeeWaived);
                    let totalPlatformFee = result.totalPlatformFee;
                    if (result.platformFeeWaived <= (result.initialPlatformFee + result.additionalLocationPlatformFee)) {
                        totalPlatformFee -= result.platformFeeWaived;
                    }
                    component.set('v.totalPlatformFee', totalPlatformFee);

                } else {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Summary Information: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Summary information: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while retrieving Summary information');
                }
            }

            this.publishDataSavedMessage(component);
            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    // Unbundle the locationServiceRecordsMap so that each location
    // has it's own additional service records
    buildLocationRecords: function (locationRecords, locationServiceRecordsMap) {
        if (locationRecords && locationServiceRecordsMap) {
            locationRecords.forEach(loc => loc.locationServiceRecords = locationServiceRecordsMap[loc.Id]);
        }
        return locationRecords;
    },

    publishAgreementToServer: function (component) {
        const action = component.get('c.publishAgreement');

        action.setParams({
            'recordId': component.get('v.recordId')
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {

                    // DEBUGGING
                    //console.log('publishAgreement result: ', result);

                    component.set('v.opportunityRecord', result.opportunityRecord);

                    // Button Management
                    component.set('v.publishAgreementDisablementReasons', result.publishAgreementDisablementReasons);
                    component.set('v.showPublishAgreementButton', result.showPublishAgreementButton);
                    component.set('v.showVoidAgreementButton', result.showVoidAgreementButton);
                    component.set('v.voidAgreementDisablementReasons', result.voidAgreementDisablementReasons);

                    const disablePublishAgreementButton = !$A.util.isEmpty(result.opportunityRecord.Agreement_Id__c) || result.publishAgreementDisablementReasons.length > 0;
                    component.set('v.disablePublishAgreementButton', disablePublishAgreementButton);

                    this.publishDataSavedMessage(component);
                    this.showToast('success', 'Success', 'Your agreement has been published.');

                    $A.get('e.force:refreshView').fire();
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while publishing the Agreement: ' + result.message, 'sticky');
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while publishing the Agreement: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while publishing the Agreement');
                }
            }

            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    voidAgreementToServer: function (component) {
        const action = component.get('c.voidAgreement');

        action.setParams({
            'recordId': component.get('v.recordId')
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {

                    // DEBUGGING
                    //console.log('voidAgreement result: ', result);

                    component.set('v.opportunityRecord', result.opportunityRecord);

                    // Button Management
                    component.set('v.publishAgreementDisablementReasons', result.publishAgreementDisablementReasons);
                    component.set('v.showPublishAgreementButton', result.showPublishAgreementButton);
                    component.set('v.showVoidAgreementButton', result.showVoidAgreementButton);
                    component.set('v.voidAgreementDisablementReasons', result.voidAgreementDisablementReasons);

                    const disablePublishAgreementButton = !$A.util.isEmpty(result.opportunityRecord.Agreement_Id__c) || result.publishAgreementDisablementReasons.length > 0;
                    component.set('v.disablePublishAgreementButton', disablePublishAgreementButton);

                    this.publishDataSavedMessage(component);
                    this.showToast('success', 'Success', 'Your agreement has been voided.');

                    $A.get('e.force:refreshView').fire();
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while voiding the Agreement: ' + result.message, 'sticky');
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while voiding the Agreement: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while voiding the Agreement');
                }
            }

            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    }
})