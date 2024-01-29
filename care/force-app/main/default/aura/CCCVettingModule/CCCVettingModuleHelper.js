({
    getDataFromServer: function (component) {
        const action = component.get('c.getVettingData');

        action.setParams({
            'recordId': component.get('v.recordId')
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                // DEBUGGING
                //console.log('getVettingData result: ', result);

                if (!result.hasErrors) {
                    component.set('v.opportunityRecord', result.opportunityRecord);
                    component.set('v.locationRecords', result.locationRecords);
                    component.set('v.composerServiceRecord', result.composerServiceRecord);
                    component.set('v.provinceOptions', result.provinceOptions.map(o => { return { label: o, value: o } }));
                    component.set('v.showLocationStatusFields', !['In Progress','Prospecting'].includes(result.opportunityRecord.StageName));
                    component.set('v.displayLocationSpecificContactInfo', result.displayLocationSpecificContactInfo);
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Vetting Information: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Vetting Information: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while retrieving information');
                }
            }

            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    showLocationModal: function (component, config, callback) {
        config.saveClicked = component.getReference('v.confirmSaveClicked');

        $A.createComponent('c:CCCLocationDetailsModal', config,
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    const overlayLib = component.find('overlayLib') || component.getSuper().find('overlayLib') || component.getSuper().getSuper().find('overlayLib');
                    overlayLib.showCustomModal({
                        'header': 'Location',
                        'body': modalCmp,
                        'showClosebutton': true,
                        'cssClass': 'slds-modal_small',
                        closeCallback: function () {
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