({
    onInit: function(component, event, helper) {
        helper.init(component);
    },

    handleFieldUpdate: function(component, event, helper) {
        helper.updateLocationRecord(component, event);
    }
})