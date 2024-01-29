({
    // Province/State list of options for inputAddress Lightning Component
    countryMap: [{
        'label': 'United States',
        'value': 'United States'
    }],

    // Salutation list of options for inputName Lightning Component
    salutationOptions: [{
            'label': 'None',
            'value': 'None'
        },
        {
            'label': 'Mr.',
            'value': 'Mr.'
        },
        {
            'label': 'Ms.',
            'value': 'Ms.'
        },
        {
            'label': 'Mrs.',
            'value': 'Mrs.'
        },
        {
            'label': 'Dr.',
            'value': 'Dr.'
        },
        {
            'label': 'Prof.',
            'value': 'Prof.'
        },
    ],

    // Returns the Country Map back to the controller
    getCountryOptions: function () {
        return this.countryMap;
    },

    // Returns the Salutation Map back to the controller
    getSalutationOptions: function () {
        return this.salutationOptions;
    },

    validate: function (component) {
        let isValid = true;
        const contactRecord = component.get('v.contactRecord');

        const inputNameCmp = component.find('inputName');
        inputNameCmp.setCustomValidityForField('', 'firstName');
        inputNameCmp.reportValidity();

        // Name - FirstName
        if ($A.util.isEmpty(contactRecord.FirstName)) {
            inputNameCmp.setCustomValidityForField('Complete this field.', 'firstName');
            inputNameCmp.reportValidity();

            isValid = false;
        }

        // Name - LastName
        if (!this.validateComponent(component, 'inputName') ||
            $A.util.isEmpty(contactRecord.LastName)) {

            isValid = false;
        }

        // Phone
        if (!this.validateComponent(component, 'inputPhone') || $A.util.isEmpty(contactRecord.Phone)) isValid = false;

        // Email
        if (!this.validateComponent(component, 'inputEmail') || $A.util.isEmpty(contactRecord.Email)) isValid = false;

        return isValid;
    }
})