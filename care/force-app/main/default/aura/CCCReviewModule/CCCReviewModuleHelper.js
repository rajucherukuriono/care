({
    getDataFromServer: function (component) {
        const action = component.get('c.getReviewData');

        action.setParams({
            opportunityId: component.get('v.recordId')
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {
                    const result = response.getReturnValue();

                    component.set('v.reviewRecords', result.reviewRecords);
                    component.set('v.locationRecords', result.locationRecords);
                    component.set('v.opportunityRecord', result.opportunityRecord);

                } else {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Review information: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Review information: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while retrieving Review information');
                }
            }

            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    showReviewModal: function (component, config, callback) {
        config.saveClicked = component.getReference('v.confirmSaveClicked');

        $A.createComponent('c:CCCReviewModal', config,
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    const overlayLib = component.find('overlayLib') || component.getSuper().find('overlayLib') || component.getSuper().getSuper().find('overlayLib');
                    overlayLib.showCustomModal({
                        header: $A.util.isEmpty(config.reviewRecord.Id) ? 'Add Review' : 'Modify Review',
                        body: modalCmp,
                        showClosebutton: true,
                        cssClass: '',
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