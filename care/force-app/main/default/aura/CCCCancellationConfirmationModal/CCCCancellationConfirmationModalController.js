({
    onInit: function (component, event, helper) {
        component.set('v.okClicked', false);
    },

    handleCancelClicked: function (component, event, helper) {
        component.getSuper().find('overlayLib').notifyClose();
    },

    handleOKClicked: function (component, event, helper) {
        if (!helper.validate(component)) return;

        component.set('v.okClicked', true);
        component.getSuper().find('overlayLib').notifyClose();
    }
})