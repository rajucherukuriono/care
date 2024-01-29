({
    onInit: function (component, event, helper) {
        helper.getDataFromServer(component, event, helper);
    },

    onModifyTuitionDiscountClicked: function (component, event, helper) {
        helper.showTuitionDiscountModal(component, event);
    },

    onAddContactClicked: function (component, event, helper) {

        // Return early if in readonly mode
        if (!component.get('v.allowEdit')) return;

        const opportunityRecord = component.get('v.opportunityRecord');

        let contactRecord = {
            'AccountId': opportunityRecord.AccountId
        };

        // Store our contact as an aura attribute so that we can pass by reference to the modal component and get it's changes
        component.set('v.contactRecord', contactRecord);

        const config = {
            'title': 'Add Contact',
            'contactRecord': component.getReference('v.contactRecord'),
            'provinceOptions': component.get('v.provinceOptions')
        };

        helper.showContactModal(component, config,
            $A.getCallback(function (saveClicked) {
                if (saveClicked) {
                    helper.saveContactToServer(component, component.get('v.contactRecord'));
                }
            })
        );
    },

    onModifyContactClicked: function (component, event, helper) {
        const contactRecordId = event.getSource().get('v.value');
        const contactRecords = component.get('v.contactRecords');
        let contactRecord;

        // Return early if in readonly mode
        if (!component.get('v.allowEdit')) return;

        contactRecord = contactRecords.find(contact => contact.Id === contactRecordId);

        if (!$A.util.isEmpty(contactRecord)) {

            // Store our grant contact as a aura attribute so that we can pass by reference to the modal component and get it's changes
            component.set('v.contactRecord', contactRecord);

            const config = {
                'title': 'Modify Contact',
                'contactRecord': component.getReference('v.contactRecord'),
                'provinceOptions': component.get('v.provinceOptions')
            };

            helper.showContactModal(component, config,
                $A.getCallback(function (saveClicked) {
                    if (saveClicked) {
                        helper.saveContactToServer(component, component.get('v.contactRecord'));
                    }
                })
            );
        }
    },

    // Handle when a different Primary Contact is selected in the Table
    onPrimaryContactChange: function (component, event, helper) {

        // Return early if in readonly mode
        if (!component.get('v.allowEdit')) return;

        const primaryContactId = component.get('v.primaryContactId');
        const candidateContactId = event.getSource().get('v.value');

        // No changes, return early
        if (primaryContactId === candidateContactId) return;

        // Validate selected contact
        if (!helper.validatePrimaryContact(component, candidateContactId)) {

            // If the selected Contact is not viable, revert the radials back to the previous selection
            let matchedComponents = [];

            if ($A.util.isArray(component.find('contact'))) {
                matchedComponents = component.find('contact');
            } else {
                matchedComponents = [component.find('contact')];
            }

            matchedComponents.forEach(comp => {
                if (comp.get('v.value') === primaryContactId) {
                    comp.set('v.checked', true);
                } else {
                    comp.set('v.checked', false);
                }
            });

            return;
        }

        // Update our Primary Contact Id
        component.set('v.primaryContactId', candidateContactId);

        helper.savePrimaryContactToServer(component);
    },

    onSortContacts: function (component, event, helper) {
        const newSortField = event.getParam('sortField');
        const currentSortField = component.get('v.contactSortField');
        const currentSortDirection = component.get('v.contactSortDirection');
        let sortDirection;
        if (newSortField !== currentSortField) {
            sortDirection = 'ascending';
            component.set('v.contactSortField', newSortField);
        } else {
            sortDirection = currentSortDirection === 'ascending' ? 'descending' : 'ascending'
        }
        component.set('v.contactSortDirection', sortDirection);
        component.set('v.contactRecords', helper.sortContacts(component, component.get('v.contactRecords')));
    },

    handlePlatformFeeWaivedChanged: function(component, event, helper) {
        helper.updatePlatformFeeWaivedToServer(component);
    }
})