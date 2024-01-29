({
    onInit: function (component, event, helper) {
        helper.getDataFromServer(component, event, helper);
    },

    onPublishAgreementClick: function (component, event, helper) {
        helper.showConfirmModal(component, {
            'title': 'Publish Agreement Confirmation',
            'message': `Are you sure you wish to send this agreement to ${component.get('v.primaryContactRecord').Email}?`,
            'iconName': 'utility:warning',
            'iconVariant': 'warning',
            'okButtonLabel': 'Confirm'
        }, $A.getCallback(function (okClicked) {
            if (okClicked) {
                helper.publishAgreementToServer(component);
            }
        }));
    },

    onVoidAgreementClick: function (component, event, helper) {
        helper.showConfirmModal(component, {
            'title': 'Void Agreement Confirmation',
            'message': 'Are you sure you wish to void this agreement, preventing it from being able to be signed by the service provider? You will be able to edit this opportunity and re-publish after confirmation.',
            'iconName': 'utility:warning',
            'iconVariant': 'warning',
            'okButtonLabel': 'Confirm'
        }, $A.getCallback(function (okClicked) {
            if (okClicked) {
                helper.voidAgreementToServer(component);
            }
        }));
    }
})