({
    onInit: function(component, event, helper) {
        helper.updateMinMaxAgeValues(component);
        helper.determineVerticalType(component);
    },

    onRecordFormLoad: function (component, event, helper) {
        component.set('v.isLoaded', true);
    },

    handleCopyLocationChanged: function(component, event, helper) {
        component.set('v.copyServiceSpecificFields', event.getSource().get('v.checked'));
    },

    handleMinAgeChange: function(component, event, helper) {
        helper.validateMinMaxAgeSlider(component, 'minAge');
    },

    handleMaxAgeChange: function(component, event, helper) {
        helper.validateMinMaxAgeSlider(component, 'maxAge');
    },
    
    handleSaveClicked: function (component, event, helper) {
        //let serviceSpecificFields = component.find('serviceSpecificFieldsElement');
        //let locationRecord = component.get('v.locationRecord');

        //console.log(serviceSpecificFields);
        //console.log('serviceSpecificFields');
        helper.serviceSpecificFields(component);

        if (helper.validate(component)) {

            /*if (!$A.util.isEmpty(serviceSpecificFields)) {
                // If component.find doesn't return an array, make it an array of 1
                if (!$A.util.isArray(serviceSpecificFields)) {
                    serviceSpecificFields = new Array(serviceSpecificFields);
                }

                serviceSpecificFields.forEach(serviceSpecificField => {
                    locationRecord[serviceSpecificField.get('v.fieldName')] = serviceSpecificField.get('v.value');
                });

                // Re-assign values for Service Specific fields back to the service Area Record
                component.set('v.locationRecord', locationRecord);
            }*/

            component.set('v.saveClicked', true);
            component.set('v.saveDisabled', true);
            component.set('v.showSpinner', true);

            helper.saveLocationOnServer(component);
        }
    },

    handleCancelClicked: function(component, event, helper) {
        component.set('v.saveClicked', false);
        component.set('v.saveDisabled', true);
        component.set('v.showSpinner', true);

        helper.closeModal(component);
    },

    handleAdjustAgeRangeClick: function(component, event, helper) {
        let sourceId = event.getSource().getLocalId();
        let fieldName = sourceId.includes('min') ? 'Minimum_Age__c' : 'Maximum_Age__c';
        let value = component.get('v.locationRecord.' + fieldName);

        if (sourceId.includes('add')) {
            value++;
        } else {
            value--;
        }

        component.set('v.locationRecord.' + fieldName, value);
        component.find('ageRangeSlider').updateSlider();
    },

    onModifyTuitionDiscountClicked: function(component, event, helper) {
        helper.showTuitionDiscountModal(component, event);
    },

    onRegisteredEntitySectionToggle: function(component, event, helper) {
        component.set('v.registeredEntitySectionIsCollapsed', !component.get('v.registeredEntitySectionIsCollapsed'));
    }
})