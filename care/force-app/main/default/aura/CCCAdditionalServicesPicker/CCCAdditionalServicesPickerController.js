({
    onInit: function(component, event, helper) {
        helper.init(component);
    },

    onComposerServiceChange: function(component, event, helper) {
        helper.onComposerServiceChange(component, event);
    },

    handleChevronClick: function(component, event, helper) {
        helper.handleChevronClick(component, event);
    }
})