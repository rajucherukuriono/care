({
    onInit: function (component, event, helper) {
        component.set('v.salutationOptions', helper.getSalutationOptions());
        component.set('v.countryOptions', helper.getCountryOptions());
    },

    onSaveClicked: function (component, event, helper) {
        if (helper.validate(component)) {

            component.set('v.saveClicked', true);
            component.set('v.saveDisabled', true);
            component.set('v.showSpinner', true);

            helper.closeModal(component);
        }
    },

    onCancelClicked: function (component, event, helper) {
        component.set('v.saveClicked', false);
        component.set('v.saveDisabled', true);
        component.set('v.showSpinner', true);

        helper.closeModal(component);
    },

    validateName: function (component, event, helper) {
        const contactRecord = component.get('v.contactRecord');
        const inputNameCmp = component.find('inputName');
        inputNameCmp.setCustomValidityForField('', 'lastName');
        inputNameCmp.setCustomValidityForField('', 'firstName');
        inputNameCmp.reportValidity();

        // Validate LastName
        helper.validateComponent(component, 'inputName');

        // Validate FirstName
        if ($A.util.isEmpty(contactRecord.FirstName)) {
            inputNameCmp.setCustomValidityForField('Complete this field.', 'firstName');
            inputNameCmp.reportValidity();
        }
    }
})