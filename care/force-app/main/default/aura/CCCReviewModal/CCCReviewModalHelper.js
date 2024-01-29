({
    onInit: function(component) {
        // Add a 'none' option to the location selections
        let locationRecords = component.get('v.locationRecords');
        if (locationRecords.length > 0) {
            locationRecords.unshift({
                Id: null,
                Name: '-- None --'
            });
            component.set('v.locationRecords', locationRecords);
        }
    },

    saveReviewOnServer: function (component) {
        const action = component.get('c.saveReviewRecord');

        action.setParams({
            'reviewRecord': component.get('v.reviewRecord'),
            'businessId': component.get('v.businessId')
        });
        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (result.hasErrors) {
                    this.showToast('error', 'Error', 'The following error occurred while saving Review information: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while saving Review information: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while saving Review information');
                }
            }
            //this.publishDataSavedMessage(component);
            this.hideSpinner(component);
            this.closeModal(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    validate: function (component) {
        let isValid = true;
        const reviewRecord = component.get('v.reviewRecord');

        // Validate - First Name
        if (!this.validateComponent(component, 'inputFirstName') ||
            $A.util.isEmpty(reviewRecord.First_Name__c)) {

            isValid = false;
        }

        // Validate - Last Name
        if (!this.validateComponent(component, 'inputLastName') ||
            $A.util.isEmpty(reviewRecord.Last_Name__c)) {

            isValid = false;
        }

        // Validate - Email
        // if (!this.validateComponent(component, 'inputEmail') ||
        //     $A.util.isEmpty(reviewRecord.Email__c)) {

        //     isValid = false;
        // }

        // Validate - Phone
        if (!this.validateComponent(component, 'inputPhone') ||
            $A.util.isEmpty(reviewRecord.Phone__c)) {

            isValid = false;
        }

        // 2021-01-12 - AO - Make Location optional
        // // Validate - Location
        // if (!this.validateComponent(component, 'inputLocation') ||
        //     $A.util.isEmpty(reviewRecord.Location__c)) {

        //     isValid = false;
        // }

        return isValid;
    }
})