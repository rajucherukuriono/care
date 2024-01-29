({
    onInit: function (component, event, helper) {
        let discountRecords = component.get('v.discountRecords');
        const discountRecord = component.get('v.discountRecord');

        const noneRecord = {
            'Id': null,
            'Name': 'None'
        };

        if ($A.util.isEmpty(discountRecords)) {
            discountRecords = [];
        }

        // Add a None record
        discountRecords.unshift(noneRecord);

        component.set('v.discountRecords', discountRecords);

        if ($A.util.isEmpty(discountRecord)) {
            component.set('v.selectedDiscountRecord', discountRecords[0]);
        } else {
            component.set('v.selectedDiscountRecord', JSON.parse(JSON.stringify(discountRecord)));
        }
    },

    onSaveButtonClicked: function (component, event, helper) {
        const selectedDiscountRecord = component.get('v.selectedDiscountRecord');

        if (!$A.util.isEmpty(selectedDiscountRecord)) {
            component.set('v.discountRecord', selectedDiscountRecord);
        }

        component.set('v.saveClicked', true);
        component.set('v.saveDisabled', true);
        component.set('v.showSpinner', true);

        helper.closeModal(component);

    },

    onCancelButtonClicked: function (component, event, helper) {
        component.set('v.saveClicked', false);
        component.set('v.saveDisabled', true);
        component.set('v.showSpinner', true);

        helper.closeModal(component);
    },

    onDiscountRecordChange: function (component, event, helper) {
        const discountRecord = event.getSource().get('v.value');
        component.set('v.selectedDiscountRecord', discountRecord);
    }
})