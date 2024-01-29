({
    init: function(component) {
        this.addMessageHandler(component);

        // Default to showing the map tab if the location already exists


        let selectedTabId = 'address';
        let locationRecord = component.get('v.locationRecord');
        if (locationRecord && locationRecord.Id && locationRecord.Geolocation_Coordinates__Longitude__s) {
            selectedTabId = 'map';
            component.set('v.centerLat', locationRecord.Geolocation_Coordinates__Latitude__s);
            component.set('v.centerLng', locationRecord.Geolocation_Coordinates__Longitude__s);
        }
        component.set('v.selectedTabId', selectedTabId);

        component.set('v.selectedComposerServiceRecordIds', locationRecord.selectedComposerServiceRecordIds);
    },

    getDataFromServer: function(component) {
        let locationRecord = component.get('v.locationRecord');

        // Pass location record to map
        this.sendMessageToVF(component, {
            messageType: 'loadInitialData',
            message: {
                locationRecord: locationRecord
            }
        });
    },

    saveLocationOnServer: function(component) {
        let locationRecord = component.get('v.locationRecord');
        locationRecord.Opportunity__c = component.get('v.opportunityId');
        const action = component.get('c.saveLocationRecord');

        action.setParams({
            locationRecord: component.get('v.locationRecord'),
            selectedComposerServiceRecordIds: component.get('v.selectedComposerServiceRecordIds'),
            copyServiceSpecificFields: false
        });

        action.setCallback(this, function(response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {
                    this.publishDataSavedMessage(component);
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while saving Location information: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while saving Location information: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while saving Location information');
                }
            }
            this.publishDataSavedMessage(component);
            this.hideSpinner(component);
            this.closeModal(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    validateAddressFields: function(component) {
        let inputAddress = component.find('inputAddress');
        let valid = inputAddress.checkValidity();
        inputAddress.reportValidity();
        //sforce-5252
         let locationRecord = component.get('v.locationRecord');
         let isValidZip = this.isZipCodeValid(locationRecord.Postal_Code__c);
            if (locationRecord.Postal_Code__c.length <5) {
                this.showToast('error', 'postal code invalid', 'Please provide min 5 digits');
                valid = false;
            } else if (!isValidZip) {
                this.showToast('error', 'postal code invalid', 'Please provide valid postal code');
                valid = false;
            }

        if (!this.validateComponent(component, 'inputPhone') || $A.util.isEmpty(locationRecord.Phone__c)){
            valid = false;
            this.showToast('error', 'Invalid Phone Number', `Please enter a 10 digit phone number, without formatting`);
        }
        return valid;
    },

    isZipCodeValid: function(zipCode){
        return /(^\d{5}$)|(^\d{5}-\d{4}$)/.test(zipCode);
    },

    findGeolocationOnServer: function(component) {
        let locationRecord = component.get('v.locationRecord');

        // Concatenate the location record address fields into one field
        let search = ['Street__c','City__c','State__c','Postal_Code__c'].reduce((accum, field) => {
            return accum + (locationRecord[field] ? locationRecord[field] + ',' : '');
        }, '');

        const action = component.get('c.findGeolocation');

        action.setParams({
            search: search
        });

        action.setCallback(this, function(response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {

                    // Set the geolocation field to the api results
                    let locationRecord = component.get('v.locationRecord');
                    locationRecord.Geolocation_Coordinates__Longitude__s = result.coordinates[0].toFixed(4);;
                    locationRecord.Geolocation_Coordinates__Latitude__s = result.coordinates[1].toFixed(4);
                    component.set('v.locationRecord', locationRecord);

                    // Send a message to the map to center on the coordinates
                    // Note: if the map hasn't loaded yet this message won't get handled
                    //       but the map will received the coordinates through the v.mapUrl
                    try {
                        this.sendMessageToVF(component, {
                            messageType: 'setCenter',
                            message: {
                                locationRecord: locationRecord
                            }
                        });
                    } catch(err) {}

                    // Switch to the map tab
                    component.set('v.selectedTabId', 'map');

                } else {
                    this.showToast('error', 'Error', 'The following error occurred while finding geolocation information: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while finding geolocation information: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while finding geolocation information');
                }
            }
            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    handleUpdateSelectedPostalCodes: function(component, message) {
        let locationRecord = component.get('v.locationRecord');
        locationRecord.Postal_Codes__c = message.postalCodes.join(', ');
        component.set('v.locationRecord', locationRecord);
    },

    addMessageHandler: function(component) {
        window.addEventListener('message', $A.getCallback(e => {
            if (e.data && e.data.channel == component.get('v.channel')) {
                var messageType = e.data.messageType;
                var message = e.data.message;
                switch (messageType) {
                    case 'getDataFromServer':
                        this.getDataFromServer(component);
                        break;
                    case 'updateselectedPostalCodes':
                        this.handleUpdateSelectedPostalCodes(component, message);
                        break;
                    default:
                        console.log('message type not handled:', messageType);
                        break;
                }
            }
        }), false);
    },

    sendMessageToVF: function(component, message) {
        message.origin = window.location.hostname;
        try {
            var vfWindow = component.find('vfFrame').getElement().contentWindow;
            vfWindow.postMessage(message, '*');
        } catch(error) {
            console.log('=========== sendMessageToVF() ERROR:', error);
        }
    },

    validate: function(component) {
        let isValid = true;
        const locationRecord = component.get('v.locationRecord');
         let isValidZip = this.isZipCodeValid(locationRecord.Postal_Code__c);

        if ($A.util.isEmpty(locationRecord.Name)) {
            isValid = false;
        }

        if (!(locationRecord.Postal_Codes__c && locationRecord.Postal_Codes__c.length > 0)) {
            isValid = false;
            this.showToast('error', 'No postal codes selected', 'Please select at least one postal code');
        }
        //sforce-5252
        if (locationRecord.Postal_Code__c.length <5) {
                this.showToast('error', 'Postal code invalid', 'Please provide min 5 digits');
                isValid = false;
        } else if (!isValidZip) {
                this.showToast('error', 'postal code invalid', 'Please provide valid postal code');
                isValid = false;
        }

        if (locationRecord.Postal_Codes__c) {
            let postalCodes = locationRecord.Postal_Codes__c.split(', ');
            if (postalCodes.length > component.get('v.maxPostalCodes')) {
                isValid = false;
                this.showToast('error', 'Too many postal codes selected', `The maximum number of selected postal codes is ${component.get('v.maxPostalCodes')}`);
            }
        }

        if (!this.validateComponent(component, 'inputPhone') || $A.util.isEmpty(locationRecord.Phone__c)){
            isValid = false;
            this.showToast('error', 'Invalid Phone Number', `Please enter a 10 digit phone number, without formatting`);
        }

        return isValid;
    }
})