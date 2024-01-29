({
    onInit: function (component, event, helper) {
        helper.onInit(component);
    },

    onSaveButtonClicked: function (component, event, helper) {
        const reviewRecord = component.get('v.reviewRecord');

        if ($A.util.isEmpty(reviewRecord.location_name)) reviewRecord.location_name = '';

        if (helper.validate(component)) {

            component.set('v.saveClicked', true);
            component.set('v.saveDisabled', true);
            component.set('v.showSpinner', true);

            if ($A.util.isEmpty(reviewRecord.uuid)) {
                helper.createReviewToServer(component, reviewRecord);
            } else {
                helper.updateReviewToServer(component, reviewRecord);
            }
        }
    },

    onCancelButtonClicked: function (component, event, helper) {
        component.set('v.saveClicked', false);
        component.set('v.saveDisabled', true);
        component.set('v.showSpinner', true);

        helper.closeModal(component);
    }
})