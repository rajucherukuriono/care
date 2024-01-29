({
    onInit: function (component, event, helper) {
        helper.getDataFromServer(component);
    },

    onModifyLocationClicked: function (component, event, helper) {
        const businessRecord = component.get('v.businessRecord');
        const locationId = event.getSource().get('v.value');
        const locationRecord = businessRecord.locations.find(l => l.uuid === locationId);

        if (!$A.util.isEmpty(locationRecord)) {

            const config = {
                'locationRecord': JSON.parse(JSON.stringify(locationRecord))
            };

            helper.showModifyLocationModal(component, config,
                $A.getCallback(function (saveClicked) {

                    if (saveClicked) {

                        // Get fresh API data
                        helper.getDataFromServer(component);
                    }
                })
            );
        }
    },

    onCancelLeadsClick: function (component, event, helper) {
        helper.showConfirmModal(component, {
            'title': 'Cancel Lead Confirmation',
            'message': 'Are you sure you wish to cancel leads for all locations associated with this business?',
            'iconName': 'utility:warning',
            'okButtonLabel': 'Confirm',
            'cancelButtonLabel': 'Nevermind'
        }, $A.getCallback(function (okClicked) {
            if (okClicked) {
                helper.cancelAgreementToServer(component);
            }
        }));
    },

    onAddReviewClicked: function (component, event, helper) {
        const businessRecord = component.get('v.businessRecord');
        const reviewRecord = {
            'business_id': businessRecord.business_id,
            'first_name': null,
            'last_name': null,
            'email': null,
            'phone': null,
            'location_name': null,
        };

        const config = {
            'title': 'Add Reference',
            'reviewRecord': reviewRecord,
            'locationRecords': component.get('v.locationRecords')
        };

        helper.showReviewModal(component, config,
            $A.getCallback(saveClicked => {
                if (saveClicked) {
                    helper.getDataFromServer(component);
                }
            })
        );
    },

    onModifyReviewClicked: function (component, event, helper) {
        const reviewId = event.getSource().get('v.value');
        const reviewRecord = component.get('v.reviewRecords').find(r => r.uuid === reviewId);

        const config = {
            'title': 'Modify Reference',
            'reviewRecord': reviewRecord,
            'locationRecords': component.get('v.locationRecords'),
        }

        helper.showReviewModal(component, config, $A.getCallback(saveClicked => {
            if (saveClicked) {
                helper.getDataFromServer(component);
            }
        }));
    }
})