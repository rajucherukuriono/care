({
    handleSaveClicked: function (component, event, helper) {
        if (helper.validatePricingTierPickers(component)) {
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
    }

})