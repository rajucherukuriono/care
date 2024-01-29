({
    onInit: function(component, event, helper) {
        helper.onInit(component);
    },

    handleSaveClicked: function (component, event, helper) {
        if (helper.validate(component)) {

            component.set('v.saveClicked', true);
            component.set('v.saveDisabled', true);
            component.set('v.showSpinner', true);

            helper.saveReviewOnServer(component);
        }
    },

    handleCancelClicked: function (component, event, helper) {
        component.set('v.saveClicked', false);
        component.set('v.saveDisabled', true);
        component.set('v.showSpinner', true);

        helper.closeModal(component);
    }
})