({
    onInit: function (component) {
        // Add a 'none' option to the location selections if we have any
        const locationRecords = component.get('v.locationRecords');
        let locationOptions = [];

        if (!$A.util.isEmpty(locationRecords)) {
            locationOptions.push({
                'label': '-- None --',
                'value': 'none'
            });

            locationRecords.forEach(location => {
                locationOptions.push({
                    'label': location.name,
                    'value': location.name
                });
            });
        }

        component.set('v.locationOptions', locationOptions);
    },

    createReviewToServer: function (component, reviewRecord) {
        const action = component.get('c.createReview');

        action.setParams({
            'reviewRecordJSON': JSON.stringify(reviewRecord)
        });
        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {
                    this.showToast('success', 'Success', 'Review created successfully.');
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while creating the Review: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while creating the Review: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while creating the Review');
                }
            }

            this.hideSpinner(component);
            this.closeModal(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    updateReviewToServer: function (component, reviewRecord) {
        const action = component.get('c.updateReview');

        action.setParams({
            'reviewId': reviewRecord.uuid,
            'reviewRecordJSON': JSON.stringify(reviewRecord)
        });
        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {
                    this.showToast('success', 'Success', 'Review updated successfully.');
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while updating the Review: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while updating the Review: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while updating the Review');
                }
            }

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
            $A.util.isEmpty(reviewRecord.first_name)) {

            isValid = false;
        }

        // Validate - Last Name
        if (!this.validateComponent(component, 'inputLastName') ||
            $A.util.isEmpty(reviewRecord.last_name)) {

            isValid = false;
        }

        // Validate - Email
        if (!this.validateComponent(component, 'inputEmail') ||
            $A.util.isEmpty(reviewRecord.email)) {

            isValid = false;
        }

        // Validate - Phone
        if (!this.validateComponent(component, 'inputPhone') ||
            $A.util.isEmpty(reviewRecord.phone)) {

            isValid = false;
        }

        // 2021-01-12 - AO - Make Location optional
        // // Validate - Location
        // if (!this.validateComponent(component, 'inputLocation') ||
        //     $A.util.isEmpty(reviewRecord.location_name)) {

        //     isValid = false;
        // }

        return isValid;
    }
})