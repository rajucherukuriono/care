({
    onInit: function(component, event, helper) {
        helper.init(component);
    },

    handleSaveClicked: function(component, event, helper) {
        if (helper.validate(component)) {
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

    handleNextClicked: function(component, event, helper) {
        component.find('inputName').reportValidity();

        if (helper.validateAddressFields(component)) {
            helper.findGeolocationOnServer(component);
        }
    },

    handleUseAccountAddressClick: function(component, event, helper) {
        const accountRecord = component.get('v.accountRecord');
        const stateAbbreviationMap = component.get('v.stateAbbreviationMap') || {};
        const stateName = stateAbbreviationMap[accountRecord.BillingState];
        let locationRecord = component.get('v.locationRecord');

        locationRecord.Name = accountRecord.Name;
        locationRecord.City__c = accountRecord.BillingCity;
        locationRecord.Postal_Code__c = accountRecord.BillingPostalCode;
        locationRecord.State__c = stateName;
        locationRecord.Street__c = accountRecord.BillingStreet;
        locationRecord.License_Number__c = accountRecord.Licensing_Number__c;
        locationRecord.Capacity__c = accountRecord.Capacity_MS__c;
        locationRecord.Phone__c = accountRecord.Phone;

        component.set('v.locationRecord', locationRecord);
    }
})