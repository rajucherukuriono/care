({
    onInit: function (component, event, helper) {
        component.set('v.okClicked', false);
    },

    handleCancelClicked: function (component, event, helper) {
        component.find('overlayLibModal').notifyClose();
    },

    handleOKClicked: function (component, event, helper) {
        component.set('v.okClicked', true);
        component.find('overlayLibModal').notifyClose();
    }
})