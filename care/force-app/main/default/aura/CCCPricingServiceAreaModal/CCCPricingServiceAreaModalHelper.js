({
    updateCustomField: function (component) {
        const locationRecord = component.get('v.locationRecord');
        const selectedPricingTier = locationRecord.pricingTierRecords.filter(pricingTier => pricingTier.tier === locationRecord.pricingTier)[0];

        if (!$A.util.isEmpty(selectedPricingTier)) {

            // Update the amount on the Category Group
            locationRecord.amount = selectedPricingTier.amount;
            locationRecord.bonusPoints = selectedPricingTier.bonusPoints;
            component.set('v.locationRecord', locationRecord);
        }
    },

    clearErrors: function (component) {
        component.set('v.customAmountErrors', []);
    },

    validate: function (component) {
        const locationRecord = component.get('v.locationRecord');
        const errorMessages = [];
        const customPricingIndividualMinAmount = component.get('v.customPricingIndividualMinAmount');

        // Create our currency formatter.
        const currencyFormatter = new Intl.NumberFormat('en-US', {
            'style': 'currency',
            'currency': 'USD',
            'minimumFractionDigits': 2,
            // the default value for minimumFractionDigits depends on the currency
            // and is usually already 2
        });

        // Custom Amount Validation
        if (locationRecord.pricingTier === 'Custom') {

            const customPricingTier = locationRecord.pricingTierRecords.filter(pricingTier => pricingTier.tier === 'Custom')[0];

            if ($A.util.isEmpty(customPricingTier)) return false;

            // Validate - Custom Pricing Individual Minimum Amount
            if ($A.util.isEmpty(customPricingTier.amount)) {
                errorMessages.push('The custom price range for this location must be at least ' + currencyFormatter.format(parseFloat(customPricingIndividualMinAmount)));
            }

            // Validate - Custom Pricing Individual Minimum Amount
            if (parseFloat(customPricingTier.amount) < parseFloat(customPricingIndividualMinAmount)) {
                errorMessages.push('The custom price range for this location must be at least ' + currencyFormatter.format(parseFloat(customPricingIndividualMinAmount)));
            }
        }

        component.set('v.customAmountErrors', errorMessages);

        return errorMessages.length === 0;
    },

    showPopover: function (component, bodyText, reference, promiseAttr) {

        // Don't show the popover if one is already showing
        if (!$A.util.isEmpty(component.get(promiseAttr))) return;

        const popoverPromise = component.getSuper().getSuper().find('overlayLib').showCustomPopover({
            'body': bodyText,
            'referenceSelector': '.' + reference,
            'cssClass': 'slds-popover,slds-popover_small,slds-p-around_small,slds-popover__body_scrollable'
        });

        component.set(promiseAttr, popoverPromise);

        popoverPromise.then(popover =>
            setTimeout($A.getCallback(() => {
                this.hidePopover(component, promiseAttr);
            }), 1000)
        );
    },

    hidePopover: function (component, promiseAttr) {
        if ($A.util.isEmpty(component.get(promiseAttr))) return;

        component
            .get(promiseAttr)
            .then(popover => {
                (popover ? popover.close() : null);
            });

        component.set(promiseAttr, null); // Clear out the promise so we can show another popover
    }
})