({
    getDataFromServer: function (component) {
        const action = component.get('c.getUserPermissionsData');

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                // DEBUGGING
                console.log('getDataFromServer result: ', result);

                if (!result.hasErrors) {
                    component.set('v.userRecords', result.userRecords);
                    component.set('v.composerServiceRecords', result.composerServiceRecords);
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

    showUserPermissionsModal: function(component, userId) {
        const helper = this;
        const userRecord = component.get('v.userRecords').find(u => u.Id === userId);

        const config = 

        $A.createComponent('c:CCCUserPermissionsModal', {
            saveClicked: component.getReference('v.confirmSaveClicked'),
            composerServiceRecords: component.get('v.composerServiceRecords'),
            userRecord: userRecord
        }, (modalCmp, status) => {
                if (status === 'SUCCESS') {
                    component.getSuper().find('overlayLib').showCustomModal({
                        header: 'Edit ' + userRecord.Name + ' (' + userRecord.Username + ')',
                        body: modalCmp,
                        showClosebutton: true,
                        cssClass: 'slds-modal_small',
                        closeCallback: $A.getCallback(() => {
                            if (component.get('v.confirmSaveClicked')) {
                                helper.getDataFromServer(component);
                            }
                        })
                    });
                }
            }
        );

    }
})