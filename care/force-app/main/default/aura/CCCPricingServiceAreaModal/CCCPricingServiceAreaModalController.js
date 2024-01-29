({
    handleSaveClicked: function (component, event, helper) {
        if (helper.validate(component)) {

            component.set('v.saveClicked', true);
            component.set('v.saveDisabled', true);
            component.set('v.showSpinner', true);

            helper.closeModal(component);
        }
    },

    handleCancelClicked: function (component, event, helper) {
        component.set('v.saveClicked', false);
        component.set('v.saveDisabled', true);
        component.set('v.showSpinner', true);

        helper.closeModal(component);
    },

    onCustomAmountChange: function (component, event, helper) {
        if (event.getParam('oldValue') === event.getParam('value')) return;

        if (!helper.validate(component)) return;

        // The timeout logic keeps the update logic from being called every keystroke
        let timeoutReference = component.get('v.timeoutReference');

        clearTimeout(timeoutReference);

        timeoutReference = setTimeout($A.getCallback(function () {

            helper.updateCustomField(component);

            clearTimeout(timeoutReference);
            component.set('v.timeoutReference', null);
        }), 200);

        component.set('v.timeoutReference', timeoutReference);
    },

    onTierChange: function (component, event, helper) {

        // Update the locationRecord with the Tier we have selected.
        const locationRecord = component.get('v.locationRecord');
        let customInput;

        if ($A.util.isArray(component.find('custom_input'))) {
            customInput = component.find('custom_input')[0];
        } else {
            customInput = component.find('custom_input');
        }

        const selectedPricingTier = locationRecord.pricingTierRecords.filter(pricingTier => pricingTier.tier === event.getSource().get('v.value'))[0];

        if (!$A.util.isEmpty(selectedPricingTier)) {
            locationRecord.pricingTier = selectedPricingTier.tier;
            locationRecord.amount = selectedPricingTier.amount;
            locationRecord.bonusPoints = selectedPricingTier.bonusPoints;

            component.set('v.locationRecord', locationRecord);

            // If we found a Custom input field, set required/disabled attributes
            if (!$A.util.isEmpty(customInput)) {

                if (selectedPricingTier.tier === 'Custom') {

                    // If we clicked the Custom Pricing tier, mark this field as required, and mark it not disabled
                    customInput.set('v.required', true);
                    customInput.set('v.disabled', false);

                    //helper.updateCustomField(component);
                } else {

                    // If we clicked a different tier, make this field disabled and mark it not readonly
                    customInput.set('v.required', false);
                    customInput.set('v.disabled', true);
                }
            }
        }
    },

    onShowCustomPricingPopover: function (component, event, helper) {
        helper.showPopover(component, component.get('v.popoverBodyCustomPricing'), component.get('v.popoverReferenceCustomPricing'), 'v.popoverPromiseCustomPricing');
    }
})