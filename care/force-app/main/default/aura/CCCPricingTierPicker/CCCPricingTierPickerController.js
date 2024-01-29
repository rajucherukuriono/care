({
    handleSaveClicked: function(component, event, helper) {
        if (helper.validate(component)) {

            component.set('v.saveClicked', true);
            component.set('v.saveDisabled', true);
            component.set('v.showSpinner', true);

            helper.closeModal(component);
        }
    },

    handleCancelClicked: function(component, event, helper) {
        component.set('v.saveClicked', false);
        component.set('v.saveDisabled', true);
        component.set('v.showSpinner', true);

        helper.closeModal(component);
    },

    onCustomAmountChange: function(component, event, helper) {
        helper.handleCustomAmountChanged(component, event);
    },

    onTierChange: function(component, event, helper) {
        helper.handleTierChanged(component, event);
    },

    getValidity: function(component, event, helper) {
        return helper.validate(component);
    },

    onFlatRateAmountChange: function(component, event, helper) {
        helper.handleFlateRateBudgetChange(component, event);
    },

    onBillingCadenceChange: function(component, event, helper) {
        helper.updateBillingCadence(component, event);
    },
    
})