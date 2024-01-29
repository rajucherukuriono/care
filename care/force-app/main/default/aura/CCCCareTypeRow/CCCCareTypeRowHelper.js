({
    init: function(component) {
        const locationRecord = component.get('v.locationRecord');
        const checkboxFieldName = component.get('v.checkboxFieldName');
        const currencyFieldName = component.get('v.currencyFieldName');
        const numberFieldName = component.get('v.numberFieldName');
        component.set('v.checkboxValue', locationRecord[checkboxFieldName]);
        component.set('v.currencyValue', locationRecord[currencyFieldName]);
        component.set('v.numberValue', locationRecord[numberFieldName]);
    },

    updateLocationRecord: function(component, event) {
        let locationRecord = component.get('v.locationRecord');
        const fieldType = event.getSource().get('v.type');
        const formatter = event.getSource().get('v.formatter');
        const checkboxFieldName = component.get('v.checkboxFieldName');
        const currencyFieldName = component.get('v.currencyFieldName');
        const numberFieldName = component.get('v.numberFieldName');

        if (fieldType === 'checkbox') {
            const checked = event.getParam('checked');
            locationRecord[checkboxFieldName] = checked;

            // Remove currency and number value if checkbox is not checked
            if (!checked) {
                component.set('v.currencyValue', undefined);
                component.set('v.numberValue', undefined);
                locationRecord[currencyFieldName] = '';
                locationRecord[numberFieldName] = '';
            }
        }

        if (fieldType === 'number') {
            if (formatter === 'currency') {
                locationRecord[currencyFieldName] = parseFloat(event.getParam('value'));
            } else {
                locationRecord[numberFieldName] = parseInt(event.getParam('value'));
            }
        }

        component.set('v.locationRecord', locationRecord);
    }
})