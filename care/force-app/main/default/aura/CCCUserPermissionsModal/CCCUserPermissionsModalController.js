({
    onInit: function(component, event, helper) {
        helper.init(component);
    },

    onComposerServiceChange: function(component, event, helper) {
        const composerServiceId = event.getSource().get('v.value');
        const checked = event.getParam('checked');
        helper.updateSelectedVerticals(component, composerServiceId, checked);
    },

    handleCancelClicked: function(component, event, helper) {
        component.set('v.saveClicked', false);
        helper.closeModal(component);
    },

    handleSaveClicked: function(component, event, helper) {
        helper.updateUserPermissions(component);
    }
})