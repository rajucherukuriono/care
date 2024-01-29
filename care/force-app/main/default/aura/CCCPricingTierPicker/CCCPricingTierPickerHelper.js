({
    handleTierChanged: function(component, event) {
        const pricingTierName = event.getSource().get('v.value');
        const selectedPricingTier = this.updateSelectedPricingTier(component, pricingTierName);

        if (!$A.util.isEmpty(selectedPricingTier)) {
            this.updateCustomInputEnablement(component, selectedPricingTier);
        }
    },

    handleFlateRateBudgetChange: function(component, event) {
        const amount = component.get('v.flatRateBudgetAmount');
        component.set('v.amount', amount);
    },

    updateSelectedPricingTier: function(component, pricingTierName) {
        const selectedPricingTier = component.get('v.pricingTiers').find(pt => pt.name === pricingTierName);

        if (!$A.util.isEmpty(selectedPricingTier)) {
            component.set('v.name', selectedPricingTier.name);
            component.set('v.amount', selectedPricingTier.amount);
            component.set('v.bonusPoints', selectedPricingTier.bonusPoints);
        }

        return selectedPricingTier;
    },

    updateCustomInputEnablement: function(component, selectedPricingTier) {
        let customInput;

        if ($A.util.isArray(component.find('custom_input'))) {
            customInput = component.find('custom_input')[0];
        } else {
            customInput = component.find('custom_input');
        }

        // If we found a Custom input field, set required/disabled attributes
        if (!$A.util.isEmpty(customInput)) {

            if (selectedPricingTier.name === 'Custom') {
                // If we clicked the Custom Pricing tier, mark this field as required, and mark it not disabled
                customInput.set('v.required', true);
                customInput.set('v.disabled', false);
            } else {
                // If we clicked a different tier, make this field disabled and mark it not readonly
                customInput.set('v.required', false);
                customInput.set('v.disabled', true);
            }
        }
    },

    handleCustomAmountChanged: function(component, event) {
        if (event.getParam('oldValue') === event.getParam('value')) return;

        if (!this.validate(component)) return;

        const pricingTierName = component.get('v.name');
        const helper = this;
        this.debounce(component, () => helper.updateSelectedPricingTier(component, pricingTierName), 200)();
    },

    validate: function(component) {
        const isFlatRate = component.get('v.isFlatRate');
        const budgetAmount = component.get('v.flatRateBudgetAmount');
        const pricingTierName = component.get('v.name');
        const errorMessages = [];
        const tierCustomThreshold = component.get('v.tierCustomThreshold');

        // Create our currency formatter.
        const currencyFormatter = new Intl.NumberFormat('en-US', {
            'style': 'currency',
            'currency': 'USD',
            'minimumFractionDigits': 2,
            // the default value for minimumFractionDigits depends on the currency
            // and is usually already 2
        });

        // Custom Amount Validation
        if (pricingTierName === 'Custom') {

            const customPricingTier = component.get('v.pricingTiers').find(pt => pt.name === 'Custom');

            if ($A.util.isEmpty(customPricingTier)) return false;

            // Validate - Custom Pricing Individual Minimum Amount
            if ($A.util.isEmpty(customPricingTier.amount)) {
                errorMessages.push('The custom price range must be at least ' + currencyFormatter.format(parseFloat(tierCustomThreshold)));
            }

            // Validate - Custom Pricing Individual Minimum Amount
            if (parseFloat(customPricingTier.amount) < parseFloat(tierCustomThreshold)) {
                errorMessages.push('The custom price range must be at least ' + currencyFormatter.format(parseFloat(tierCustomThreshold)));
            }
        }

        if(isFlatRate && (parseFloat(budgetAmount) < parseFloat(tierCustomThreshold))){ 
            errorMessages.push('The monthly budget must be at least ' + currencyFormatter.format(parseFloat(tierCustomThreshold)));
        }

        component.set('v.customAmountErrors', errorMessages);

        return errorMessages.length === 0;
    },

    updateBillingCadence: function(component, event) {
        const billingCadence = component.get('v.flatRateBudgetCadence');
        /*if(billingCadence == 'Monthly'){
            const tier1 = component.get('v.pricingTiers').find(pt => pt.name === 'Tier 1');
            component.set('v.tierCustomThreshold', tier1.amount);
            component.set('v.bonusPoints', tier1.bonusPoints);
            component.set('v.flatRateBudgetAmount', tier1.amount);
            component.set('v.amount',  tier1.amount);
        } else*/ 
        if (billingCadence == 'Monthly'){
            billingCadence = 'Quarterly';
            component.set('v.flatRateBudgetCadence', 'Quarterly');
        }
        
        if (billingCadence == 'Quarterly'){
            const tier2 = component.get('v.pricingTiers').find(pt => pt.name === 'Tier 2');
            component.set('v.tierCustomThreshold', tier2.amount);
            component.set('v.bonusPoints', tier2.bonusPoints);
            component.set('v.flatRateBudgetAmount', tier2.amount);
            component.set('v.amount',  tier2.amount);
        } else if (billingCadence == 'Annually'){
            const tier3 = component.get('v.pricingTiers').find(pt => pt.name === 'Tier 3');
            component.set('v.tierCustomThreshold', tier3.amount);
            component.set('v.bonusPoints', tier3.bonusPoints);
            component.set('v.flatRateBudgetAmount', tier3.amount);
            component.set('v.amount',  tier3.amount);
        }
    },

    debounce: function(component, callback, delay) {
        return (...args) => {
            clearTimeout(component.get('v.debounceTimeoutId'));
            let timeoutId = setTimeout(() => callback(...args), delay);
            component.set('v.debounceTimeoutId', timeoutId);
        }
    }

})