({
    getDataFromServer: function (component) {
        const action = component.get('c.getActiveAgreementData');

        action.setParams({
            'accountId': component.get('v.recordId')
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                // DEBUGGING
                // console.log('getDataFromServer result: ', result);

                if (!result.hasErrors) {
                    this.processAgreementResponse(component, result);

                } else {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Active Agreements: ' + result.message, 'sticky');
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error(s) occurred while retrieving Active Agreements: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while retrieving Active Agreements');
                }
            }
            this.hideSpinner(component);
        });

        this.showSpinner(component);
        $A.enqueueAction(action);
    },

    cancelAgreementToServer: function (component) {
        const action = component.get('c.cancelAgreement');
        const config = {
            'accountId': component.get('v.recordId'),
            'salesContractId': component.get('v.businessRecord.sales_contract_uuid')
        }

        action.setParams(config);

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {

                    // DEBUGGING
                    // console.log('cancelAgreementToServer result: ', result);
                    this.processAgreementResponse(component, result);

                    this.showToast('success', 'Success', 'Agreement cancelled successfully.');

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

    processAgreementResponse: function (component, result) {

        // If we have Locations
        if (!$A.util.isEmpty(result.businessRecord) && !$A.util.isEmpty(result.businessRecord.locations)) {

            // Sort Locations A-Z by Location Name
            result.businessRecord.locations.sort((a, b) => (a.name > b.name) ? 1 : -1);

            // Logic for all Locations
            result.businessRecord.locations.forEach(location => {

                // Create a active boolean from the ads_status enum values
                // location.active = false; // covers: 'unknown', 'inactive' and 'paused'
                // if (location.ads_status === 'active') location.active = true; // covers: 'active'

                if (location.offerings) {
                    if (location.offerings.some(o => o.care_type)) {
                        // Collapse the offerings care_type array into a comma seperated list of care types
                        location.offeringNames = location.offerings.map(o =>
                            o.care_type ? o.care_type.replaceAll('_', ' ') : ''
                        ).join(', ');

                        // Sort the location offerings by Care Type
                        // location.offerings.sort((a,b) => (a.care_type > b.care_type) ? 1 : -1);
                    } else if (location.offerings.some(o => o.service)) {
                        // Collape the service array into a comma seperated list of Services
                        location.offeringNames = location.offerings.map(o =>
                            o.service ? o.service.replaceAll('_', ' ') : ''
                        ).join(', ');

                        // Sort the location offerings by Service
                        // location.offerings.sort((a,b) => (a.service > b.service) ? 1 : -1);
                    }
                }

            });
        }

        // If we have Reviews
        if (!$A.util.isEmpty(result.businessRecord) && !$A.util.isEmpty(result.businessRecord.reviews)) {

            // Sort Reviews A-Z by Location Name
            result.businessRecord.reviews.sort((a, b) => (a.last_name > b.last_name) ? 1 : -1);
        }

        component.set('v.accountRecord', result.accountRecord);
        component.set('v.businessRecord', result.businessRecord);
        component.set('v.showCancelAgreementButton', result.showCancelAgreementButton);
        component.set('v.showModifyLocationButton', result.showModifyLocationButton);

        if (!$A.util.isEmpty(result.businessRecord)) {
            component.set('v.locationRecords', result.businessRecord.locations);
            component.set('v.reviewRecords', result.businessRecord.reviews);
        }

        // Reset modal save attributes
        component.set('v.confirmSaveLocationClicked', false);
        component.set('v.confirmOkClicked', false);
        component.set('v.locationRecord', null);
    },

    showModifyLocationModal: function (component, config, callback) {
        component.set('v.confirmSaveClicked', false);
        config.saveClicked = component.getReference('v.confirmSaveClicked');

        $A.createComponent('c:CCCActiveAgreementModifyLocationModal', config,
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    const overlayLib = component.find('overlayLib') || component.getSuper().find('overlayLib') || component.getSuper().getSuper().find('overlayLib');
                    overlayLib.showCustomModal({
                        'header': null,
                        'body': modalCmp,
                        'closeCallback': function () {
                            if (callback) {
                                callback(component.get('v.confirmSaveClicked'));
                            }
                        }
                    });
                }
            }
        );
    },

    showCancellationConfirmModal: function (component, config, callback) {
        config.okClicked = component.getReference('v.confirmCancelClicked');
        $A.createComponent('c:CCCCancellationConfirmationModal', config,
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    const overlayLib = component.find('overlayLib') || component.getSuper().find('overlayLib') || component.getSuper().getSuper().find('overlayLib');
                    overlayLib.showCustomModal({
                        'header': null,
                        'body': modalCmp,
                        'closeCallback': function () {
                            if (callback) {
                                callback(component.get('v.confirmCancelClicked'));
                            }
                        }
                    });
                }
            }
        );
    },

    updateAgreementToServer: function (component, agreementType) {
        const action = component.get('c.updateAgreement');
        action.setParams({
            'accountId': component.get('v.recordId'),
            'businessRecordJSON': JSON.stringify(component.get('v.businessRecord'))
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {

                    // DEBUGGING
                    // console.log('updateAgreementToServer result: ', result);

                    this.processAgreementResponse(component, result);

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

    showReviewModal: function (component, config, callback) {
        component.set('v.confirmSaveClicked', false);
        config.saveClicked = component.getReference('v.confirmSaveClicked');

        $A.createComponent('c:CCCActiveAgreementModifyReviewModal', config,

            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    const overlayLib = component.find('overlayLib') || component.getSuper().find('overlayLib') || component.getSuper().getSuper().find('overlayLib');

                    overlayLib.showCustomModal({
                        'header': config.header,
                        'body': modalCmp,
                        'showClosebutton': true,
                        'cssClass': '',
                        'closeCallback': function () {
                            if (callback) {
                                callback(component.get('v.confirmSaveClicked'));
                            }
                        }
                    });
                }
            }
        );
    }
})