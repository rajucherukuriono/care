({
    onInit: function (component, event, helper) {
        helper.getDataFromServer(component);
    },

    handleModifyLocationClicked: function (component, event, helper) {
        const locationRecordId = event.getSource().get('v.value');
        const locationRecords = component.get('v.locationRecords');
        const composerServiceRecord = component.get('v.composerServiceRecord');
        let locationRecord;
        let serviceSpecificFields = [];

        // Return early if in readonly mode
        if (!component.get('v.allowEdit')) return;

        locationRecord = locationRecords.find(record => record.Id === locationRecordId);

        if (!$A.util.isEmpty(locationRecord)) {

            // Store our Opportunity Service Area record as a aura attribute so that we can pass by reference to the modal component and get it's changes
            component.set('v.locationRecord', locationRecord);

            // If we have Service_Specific_Fields populated for the related Composer Service record, need to build out a map of those fields, and current values to send to the modal
            if (!$A.util.isEmpty(composerServiceRecord) && !$A.util.isEmpty(composerServiceRecord.Service_Specific_Fields__c)) {
                let serviceSpecificFieldNames = composerServiceRecord.Service_Specific_Fields__c.split(',');
                serviceSpecificFieldNames = serviceSpecificFieldNames.map(serviceSpecificField => serviceSpecificField.trim());

                serviceSpecificFieldNames.forEach(fieldName => {
                    serviceSpecificFields.push({
                        'fieldName': fieldName,
                        'value': $A.util.isEmpty(locationRecord[fieldName]) ? null : locationRecord[fieldName]
                    });
                });
            }

            const config = {
                'header': 'Modify Location: ' + locationRecord.Name,
                'locationRecord': component.getReference('v.locationRecord'),
                'composerServiceRecord': component.get('v.composerServiceRecord'),
                'opportunityId': component.get('v.recordId'),
                'locationRecordId': locationRecord.Id,
                'serviceSpecificFields': serviceSpecificFields,
                'provinceOptions': component.get('v.provinceOptions'),
                'displayLocationSpecificContactInfo': component.get('v.displayLocationSpecificContactInfo'),
                'minTuitionDiscountDollar': null,
                'minTuitionDiscountPercent': null
            };

            helper.showLocationModal(component, config,
                $A.getCallback(saveClicked => {
                    if (saveClicked) {
                        helper.getDataFromServer(component);
                    }
                })
            );
        }
    }
})