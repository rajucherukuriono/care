({
    // getDataFromServer: function(component) {
    //     let locationRecordId = component.get('v.locationRecordId');
    //     const action = component.get('c.getLocationRecord');

    //     action.setParams({
    //         locationRecordId: locationRecordId
    //     });

    //     action.setCallback(this, function(response) {
    //         const state = response.getState();

    //         if (state === 'SUCCESS') {
    //             const result = response.getReturnValue();

    //             if (!result.hasErrors) {
    //                 const result = response.getReturnValue();

    //                 component.set('v.locationRecord', result.locationRecord);

    //             } else {
    //                 this.showToast('error', 'Error', 'The following error occurred while retrieving Location information: ' + result.message);
    //             }
    //         } else {
    //             const errors = response.getError();

    //             if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
    //                 this.showToast('error', 'Error', 'The following error occurred while retrieving Location information: ' + errors[0].message);
    //             } else {
    //                 this.showToast('error', 'Error', 'An unknown error occured while retrieving Location information');
    //             }
    //         }

    //         this.hideSpinner(component);
    //     });

    //     $A.enqueueAction(action);
    //     this.showSpinner(component);
    // },
    copyServiceSpecificFieldsOnServer: function(component) {
        const action = component.get('c.copyServiceSpecificFields');

        action.setParams({
            opportunityId: component.get('v.opportunityId'),
            locationRecordId: component.get('v.locationRecordId')
        });

        action.setCallback(this, function(response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {
                    this.showToast('success', 'Success', 'Service Specific Fields copied successfully.');
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while copying Service Specific Fields: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while copying Service Specific Fields: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while copying Service Specific Fields');
                }
            }
            this.publishDataSavedMessage(component);
            this.hideSpinner(component);
            this.closeModal(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    validateMinMaxAgeSlider: function(component, source) {
        let locationRecord = component.get('v.locationRecord');
        let minAge = parseInt(locationRecord.Minimum_Age__c);
        let maxAge = parseInt(locationRecord.Maximum_Age__c);

        if (source === 'minAge') {
            if (minAge >= maxAge) {
                maxAge = minAge + 1;
            }
        } else {
            if (maxAge <= minAge) {
                minAge = maxAge - 1;
            }
        }

        locationRecord.Minimum_Age__c = minAge > 0 ? minAge : 0;
        locationRecord.Maximum_Age__c = maxAge > 0 ? maxAge : 0;

        component.set('v.locationRecord', locationRecord);
        this.updateMinMaxAgeValues(component);
    },

    updateMinMaxAgeValues: function(component) {
        let locationRecord = component.get('v.locationRecord');
        let minAge = parseInt(locationRecord.Minimum_Age__c);
        let maxAge = parseInt(locationRecord.Maximum_Age__c);
        component.set('v.minAgeInYearsMonths', this.convertMonthsToYearsMonths(minAge));
        component.set('v.maxAgeInYearsMonths', this.convertMonthsToYearsMonths(maxAge));
    },
    
    determineVerticalType: function(component) {
     	let verticalFull = component.get('v.composerServiceRecord.Vertical__c');
		let verticalTruncated = verticalFull.split(/\b\s+/)[0];
        
        if(verticalTruncated == 'Childcare'){
            component.set('v.isChildCare', true);
        } else if(verticalTruncated == 'Senior'){
            component.set('v.isSeniorCare', true);
        }
    },

    convertMonthsToYearsMonths: function(ageInMonths) {
        let yearString = '', monthString = '';
        let years = Math.floor(ageInMonths / 12);
        let months = ageInMonths % 12;

        if (years > 0) {
            if (years === 1) {
                yearString = '1 Year';
            } else {
                yearString = years + ' Years';
            }
        }

        if (months === 1) {
            monthString = '1 Month';
        } else {
            monthString = months + ' Months';
        }

        return yearString + ' ' + monthString;
    },

    saveLocationOnServer: function(component) {
        const action = component.get('c.saveLocationRecord');

        action.setParams({
            locationRecord: component.get('v.locationRecord'),
            selectedComposerServiceRecordIds: null,
            copyServiceSpecificFields: component.get('v.copyServiceSpecificFields') || false
        });

        action.setCallback(this, function(response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (result.hasErrors) {
                    this.showToast('error', 'Error', 'The following error occurred while saving Location information: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while saving Location information: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while saving Location information');
                }
            }
            this.publishDataSavedMessage(component);
            this.hideSpinner(component);
            this.closeModal(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    serviceSpecificFields: function(component) {
        let serviceSpecificFields = component.find('serviceSpecificFieldsElement');
        let locationRecord = component.get('v.locationRecord');

        if (!$A.util.isEmpty(serviceSpecificFields)) {
            // If component.find doesn't return an array, make it an array of 1
            if (!$A.util.isArray(serviceSpecificFields)) {
                serviceSpecificFields = new Array(serviceSpecificFields);
            }

            serviceSpecificFields.forEach(serviceSpecificField => {
                locationRecord[serviceSpecificField.get('v.fieldName')] = serviceSpecificField.get('v.value');
            });

            // Re-assign values for Service Specific fields back to the service Area Record
            component.set('v.locationRecord', locationRecord);
        }
    },

    validate: function (component) {
        let isValid = true;
        let locationRecord = component.get('v.locationRecord');
        let isValidZip = /(^\d{5}$)|(^\d{5}-\d{4}$)/.test(locationRecord.Postal_Code__c);

        if (locationRecord.Postal_Code__c.length <5) {
                this.showToast('error', 'Postal code invalid', 'Please provide min 5 digits');
                isValid = false;
        } else if (!isValidZip) {
                this.showToast('error', 'postal code invalid', 'Please provide valid postal code');
                isValid = false;
        }

        if ($A.util.isEmpty(locationRecord.Name)) {
            isValid = false;
        }

        let careTypeFields = [];
        const composerServiceRecord = component.get('v.composerServiceRecord');
        switch(composerServiceRecord.Vertical__c) {
            case 'Childcare':
                careTypeFields = ['Child_Care_Infant__c', 'Child_Care_Toddler__c', 'Child_Care_Pre_School__c', 'Child_Care_School_Aged__c', 'Child_Care_Pre_Teens_Teens__c'];
                break;
            case 'Senior Care':
                careTypeFields = ['Senior_Care_Independent_Living__c', 'Senior_Care_Memory_Care__c', 'Senior_Care_Assisted_Living__c'];
                break;
        }

        if (composerServiceRecord.Show_Care_Types__c && careTypeFields.length > 0 && !careTypeFields.some(f => locationRecord[f])) {
            this.showToast('error', 'Error', 'At least one Care Type must be selected.');
            isValid = false;
        }

        if(!this.validateNumberFields(component)) isValid = false;

        return isValid;
    },

    validateNumberFields: function(component){
        let isValid = true;
        let displayErrorMessage = false;
        let locationRecord = component.get('v.locationRecord');

        let allCareTypes = ['Child_Care_Infant__c', 'Child_Care_Toddler__c', 'Child_Care_Pre_School__c', 'Child_Care_School_Aged__c', 'Child_Care_Pre_Teens_Teens__c',
                            'Senior_Care_Independent_Living__c', 'Senior_Care_Memory_Care__c', 'Senior_Care_Assisted_Living__c'];

        allCareTypes.forEach( function(careTypeField) {
            let fieldBase = careTypeField.substring(0, careTypeField.length-3);
            let fieldCapacity = fieldBase + '_Capacity__c';
            let fieldStartingRent = fieldBase + '_Starting_Rent__c';

            if(locationRecord[careTypeField]){
                if(locationRecord[fieldCapacity] < 0 || locationRecord[fieldStartingRent] < 0){
                    isValid = false;
                    displayErrorMessage = true;
                }
            }
        });

        if (locationRecord['Capacity__c'] < 0){
            isValid = false;
            displayErrorMessage = true;
        }

        if (displayErrorMessage) this.showToast('error', 'Negative Number Entered', 'Values must be positive.');

        return isValid;
    },

    showTuitionDiscountModal: function (component, event) {

        // Assign values to the aura:attributes that we will pass as reference to the coupon modal
        let locationRecord = component.get('v.locationRecord')
        component.set('v.couponCode', locationRecord.Tuition_Discount_Text__c);
        component.set('v.exclusions', locationRecord.Tuition_Discount_Exclusions__c);

        let composerServiceRecord = component.get('v.composerServiceRecord');

        const helper = this;
        var config = {
            'locationId': component.get('v.locationRecordId'),
            'opportunityId': component.get('v.opportunityId'),
            'result': component.getReference('v.couponCode'),
            'exclusions': component.getReference('v.exclusions'),
            'minTuitionDiscountDollar': component.get('v.minTuitionDiscountDollar'),
            'minTuitionDiscountPercent': component.get('v.minTuitionDiscountPercent'),
            'tuitionDiscountBonusPoints': composerServiceRecord.Tuition_Discount_Bonus_Points__c
        };

        $A.createComponent('c:CCCCouponCodeModal', config,
            (modalCmp, status) => {
                if (status === 'SUCCESS') {
                    const overlayLib = component.find('overlayLib') || component.getSuper().find('overlayLib') || component.getSuper().getSuper().find('overlayLib');
                    overlayLib.showCustomModal({
                        'header': 'Tuition Discount',
                        'body': modalCmp,
                        'showCloseButton': true,
                        'closeCallback': $A.getCallback(e => {
                            helper.publishDataSavedMessage(component);

                            // Reassign changed values back to the location record in memory
                            let locationRecord = component.get('v.locationRecord');
                            locationRecord.Tuition_Discount_Text__c = component.get('v.couponCode');
                            locationRecord.Tuition_Discount_Exclusions__c = component.get('v.exclusions');
                            component.set('v.locationRecord', locationRecord);
                        })
                    });
                }
            }
        );
    },

})