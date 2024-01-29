({
    scriptsLoaded: function(component, event, helper) {
        helper.initSlider(component);
    },

    handleMinimumAgeChange: function(component, event, helper) {
        helper.updateSliderValues(component, event);
    },

    handleUpdateSlider: function(component, event, helper) {
        helper.updateSliderValues(component, event);
    }
})