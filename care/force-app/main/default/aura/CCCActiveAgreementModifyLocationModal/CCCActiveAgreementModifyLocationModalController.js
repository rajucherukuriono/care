({
    onCloseButtonClicked: function (component, event, helper) {
        const locationRecord = component.get('v.locationRecord');

        // Validations
        let validationErrors = component.get('v.validationErrors');
        validationErrors = [];

        // At least one Service must be active
        if (!locationRecord.offerings.some(offering => offering.active)) {
            validationErrors.push('At least one Service must be active.');
        }

        component.set('v.validationErrors', validationErrors);

        if (!$A.util.isEmpty(validationErrors)) return;

        component.set('v.closeButtonDisabled', true);
        component.set('v.showSpinner', true);

        helper.closeModal(component);
    },

    onOfferingActiveToggled: function (component, event, helper) {
        const offeringId = event.getSource().get('v.value');
        const locationRecord = component.get('v.locationRecord');
        const offeringRecord = locationRecord.offerings.find(off => off.uuid === offeringId);

        // Reset errors
        component.find('toggleCmps').forEach(toggleCmp => {
            toggleCmp.setCustomValidity('');
            toggleCmp.reportValidity();
        });

        // At least one Service must be active
        if (locationRecord.offerings.every(offering => !offering.active)) {
            event.getSource().set('v.checked', true);

            event.getSource().setCustomValidity('At least one Service must be active.');
            event.getSource().reportValidity();
            return;
        }

        // Proceed to call the API update
        helper.updateOfferingToServer(component, offeringRecord);
    },

    onLocationActiveToggled: function (component, event, helper) {
        const locationRecord = component.get('v.locationRecord');

        if (locationRecord.active === true) locationRecord.ads_status = 'active';
        if (locationRecord.active !== true) locationRecord.ads_status = 'paused';

        // Proceed to call the API update
        helper.updateLocationToServer(component, locationRecord);
    }
})