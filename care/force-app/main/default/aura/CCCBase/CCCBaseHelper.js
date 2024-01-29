({
    showSpinner: function (component) {
        component.set('v.showSpinner', true);
    },

    hideSpinner: function (component) {
        component.set('v.showSpinner', false);
    },

    showToast: function (toastType, title, message, mode) {
        let toastEvent = $A.get('e.force:showToast');
        // if mode is not set and the toastType is 'error' set the mode to 'sticky'
        mode = mode ? mode : (toastType === 'error' ? 'sticky' : 'dismissible')
        if (toastEvent) {
            toastEvent.setParams({
                'mode': mode || 'dismissible', //'dismissible','pester','sticky' (default: 'dismissible')
                'title': title,
                'message': message,
                'type': toastType || 'other' // 'error','warning','success','info' (Default: 'other')
            });
            toastEvent.fire();
        }
    },

    showConfirmModal: function (component, config, callback) {
        config.okClicked = component.getReference('v.confirmOkClicked');
        $A.createComponent('c:CCCConfirmationModal', config,
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    const overlayLib = component.find('overlayLib') || component.getSuper().find('overlayLib') || component.getSuper().getSuper().find('overlayLib');
                    overlayLib.showCustomModal({
                        'header': null,
                        'body': modalCmp,
                        'closeCallback': function () {
                            if (callback) {
                                callback(component.get('v.confirmOkClicked'));
                            }
                        }
                    });
                }
            }
        );
    },

    closeModal: function (component) {
        const overlayLib = component.find('overlayLib') || component.getSuper().find('overlayLib') || component.getSuper().getSuper().find('overlayLib');
        overlayLib.notifyClose();
    },

    scrollToTop: function () {
        const scrollOptions = {
            'left': 0,
            'top': 0,
            'behavior': 'smooth'
        }
        window.scrollTo(scrollOptions);
    },

    validateComponent: function (component, auraId) {
        var comp = component.find(auraId);

        // Error out if we can't find this component
        if ($A.util.isEmpty(comp)) return false;

        if (typeof comp.reportValidity !== 'undefined') {
            comp.reportValidity();
        } else {
            comp.showHelpMessageIfInvalid();
        }

        return comp.checkValidity();
    },

    getOverlayLib: function(component) {
        return component.find('overlayLib') || component.getSuper().find('overlayLib') || component.getSuper().getSuper().find('overlayLib') || component.getSuper().getSuper().getSuper().find('overlayLib');
    }
})