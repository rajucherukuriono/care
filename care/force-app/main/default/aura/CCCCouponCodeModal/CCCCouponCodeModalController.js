({
    onInit: function (component, event, helper) {
        helper.onInit(component, event);
    },

    handleSave: function (component, event, helper) {
        if (!helper.checkValidity(component)) {
            return;
        }

        helper.saveCouponCodeToServer(component);
    },

    handleCancel: function (component, event, helper) {
        helper.closeModal(component);
    },

    updateResult: function (component, event, helper) {
        helper.updateResult(component, event, helper);
    },

    updateCouponCodeSelection: function (component, event, helper) {
        helper.updateResult(component, event, helper);
    },

    validate: function (component, event, helper) {
        helper.checkValidity(component);
    },

    clearErrors: function (component, event, helper) {
        event.getSource().setCustomValidity('');
    }
})