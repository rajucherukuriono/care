({
    couponCodeOptions: [
        {
            label: '% off as Care.com benefit',
            value: 'fixedPercent'
        },
        {
            label: '$ off as Care.com benefit',
            value: 'fixedAmount'
        },
        {
            label: 'None',
            value: '--None--'
        },
    ],

    getCouponCodeType: function(couponCodeText) {
        let couponCodeType = '--None--';
        if (couponCodeText.startsWith('$')){
            couponCodeType = 'fixedAmount';
        } else if (couponCodeText.includes('%')) {
            couponCodeType = 'fixedPercent';
        }
        return couponCodeType;
    },

    getCouponCodeValue: function(couponCodeText) {
        let couponCodeValue = '';
        // Extract numeric value from coupon code text
        if (couponCodeText !== '') {
            couponCodeValue = couponCodeText.match(/[0-9\.]+/)[0];
        }
        return couponCodeValue;
    },

    onInit: function (component, event, helper) {
        var key = component.get('v.key');
        component.set('v.couponCodeOptions', this.couponCodeOptions);

        // Set default selected couponCodeSelection radio and default value
        let couponCodeText = component.get('v.result') || '';
        let couponCodeType = this.getCouponCodeType(couponCodeText);
        let couponCodeValue = this.getCouponCodeValue(couponCodeText);
        component.set('v.couponCodeSelection', couponCodeType);
        component.set('v.' + couponCodeType, couponCodeValue);
    },

    checkValidity: function (component) {
        let isValid = true;
        let couponCode = component.get('v.couponCodeSelection');
        let couponCodeDiscountDollarAmountLimit = parseFloat(component.get('v.couponCodeDiscountDollarAmountLimit'));

        // Validation - Coupon Code Selection
        let couponCodeCmp = component.find('couponCodeSelection');
        couponCodeCmp.setCustomValidity('');
        if (!couponCodeCmp.get('v.validity').valid || couponCodeCmp.get('v.value').valid) {
            couponCodeCmp.setCustomValidity('Please select a valid Web Ad Coupon Radio Button and populate the necessary information.');
            couponCodeCmp.reportValidity();
            isValid = false;
        }

        // Validation - Fixed Percent
        let fixedPercent = component.get('v.fixedPercent');
        if (couponCode === 'fixedPercent') {
            let fixedPercentCmp = component.find('fixedPercent');
            fixedPercentCmp.setCustomValidity('');

            let minTuitionDiscountPercent = component.get('v.minTuitionDiscountPercent') || 0;
            if ($A.util.isEmpty(fixedPercent) || parseFloat(fixedPercent) < minTuitionDiscountPercent || parseFloat(fixedPercent) > 100 || parseFloat(fixedPercent) % 1 != 0) {
                fixedPercentCmp.setCustomValidity(`Value must be greater than ${minTuitionDiscountPercent}, less than 100 and a whole number only.`)
                fixedPercentCmp.reportValidity();
                isValid = false;
            }
        }

        // Validation - Fixed Amount
        let fixedAmount = component.get('v.fixedAmount');
        if (couponCode === 'fixedAmount') {
            let fixedAmountCmp = component.find('fixedAmount');
            fixedAmountCmp.setCustomValidity('');

            let minTuitionDiscountDollar = component.get('v.minTuitionDiscountDollar');
            if ($A.util.isEmpty(fixedAmount) || parseFloat(fixedAmount) < minTuitionDiscountDollar || parseFloat(fixedAmount) > parseFloat(couponCodeDiscountDollarAmountLimit) || parseFloat(fixedAmount) % 1 != 0) {
                fixedAmountCmp.setCustomValidity(`Value must be greater than ${minTuitionDiscountDollar}, less than or equal to 5,000 and a whole number only.`);
                fixedAmountCmp.reportValidity();
                isValid = false;
            }
        }

        return isValid;
    },

    updateResult: function (component, event, helper) {
        var selection = component.get('v.couponCodeSelection');

        switch (selection) {
            case 'fixedPercent':
                var fixedPercentValue = component.get('v.fixedPercent');

                if (fixedPercentValue && fixedPercentValue > 0 && fixedPercentValue < 101) {
                    component.set('v.result', fixedPercentValue + '% off as Care.com benefit');
                } else {
                    component.set('v.result', '');
                }
                break;
            case 'fixedAmount':
                var fixedAmountValue = component.get('v.fixedAmount');

                if (fixedAmountValue && fixedAmountValue > 0) {
                    component.set('v.result', '$' + fixedAmountValue + ' off as Care.com benefit');
                } else {
                    component.set('v.result', '');
                }
                break;
            case '--None--':
                component.set('v.result', '');
                break;
        }
    },

    saveCouponCodeToServer: function (component) {
        const action = component.get('c.saveCouponCode');
        const locationId = component.get('v.locationId');
        const opportunityId = component.get('v.opportunityId');

        action.setParams({
            locationId: locationId,
            opportunityId: opportunityId,
            couponCode: component.get('v.result'),
            exclusions: component.get('v.exclusions'),
            copyToAllLocations: component.get('v.copyToAllLocations')
        });

        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                const result = response.getReturnValue();
                if (!result.hasErrors) {

                } else {
                    this.showToast('error', 'Error', 'The following error occurred while saving Coupon Code: ' + result.message);
                }
            } else {
                const errors = response.getError();
                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while saving Coupon Code: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while saving Coupon Code');
                }
            }
            this.hideSpinner(component);
            this.closeModal(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    }

})