({
    getDataFromServer: function (component) {
        const action = component.get('c.getLocationData');

        action.setParams({
            'opportunityId': component.get('v.recordId')
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {
                    const result = response.getReturnValue();

                    // locationServiceRecords contains all location_Service_Records__c
                    if (result.locationRecords && result.locationServiceRecords) {
                        result.locationRecords.forEach(l => {
                            // Get the location service records for this location record
                            let tempLocationServiceRecords = result.locationServiceRecords.filter(r => r.Opportunity_Service_Area__c === l.Id);
                            if ($A.util.isArray(tempLocationServiceRecords) && tempLocationServiceRecords.length > 0) {
                                // Create an array of only the Composer Service Id
                                // And attach it to the location record
                                l.selectedComposerServiceRecordIds = tempLocationServiceRecords.map(r => r.Composer_Service__c);

                                // Create a comma-separated list of Additional Service Names for displaying in GUI
                                l.additionalServiceNames = result.composerServiceRecords
                                    .filter(r => l.selectedComposerServiceRecordIds.includes(r.Id))
                                    .map(r => r.License_Level__c)
                                    .join(', ');
                            }
                        })
                    }

                    component.set('v.opportunityRecord', result.opportunityRecord);
                    component.set('v.accountRecord', result.accountRecord);
                    component.set('v.locationRecords', result.locationRecords);
                    component.set('v.composerServiceRecords', result.composerServiceRecords);
                    component.set('v.primaryServiceVerticalName', result.primaryServiceVerticalName);

                    if(result.primaryServiceVerticalName == "Recruiting Solutions" || result.opportunityRecord.Composer_Service__r.License_Level__c == 'Camps & Activities'){
                        component.set('v.addLocationLock', true)
                    } else{
                        component.set('v.addLocationLock', false);
                    } 
                     
                    component.set('v.mapBoxApiKey', result.mapBoxApiKey);
                    component.set('v.provinceOptions', result.provinceOptions.map(o => { return { label: o, value: o } }));
                    component.set('v.enableAdditionalServices', result.enableAdditionalServices);
                    
                    // State Name abbreviations map
                    let stateAbbreviationMap = {};
                    result.stateAbbreviations.forEach(s => stateAbbreviationMap[s.Abbreviation__c] = s.Full_Name__c);
                    component.set('v.stateAbbreviationMap', stateAbbreviationMap);

                    if (!component.get('v.allowEdit')) {
                        component.set('v.addLocationEnabled', false);
                    } else {
                        component.set('v.addLocationEnabled', result.locationRecords.length < result.maxLocations);
                    }

                } else {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Location information: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Location information: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while retrieving Location information');
                }
            }

            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    showLocationModal: function (component, config, callback) {
        config.saveClicked = component.getReference('v.confirmSaveClicked');

        $A.createComponent('c:CCCLocationMapModal', config,
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    const overlayLib = component.find('overlayLib') || component.getSuper().find('overlayLib') || component.getSuper().getSuper().find('overlayLib');
                    overlayLib.showCustomModal({
                        header: 'Location',
                        body: modalCmp,
                        showClosebutton: true,
                        cssClass: 'slds-modal_small',
                        closeCallback: function () {
                            if (callback) {
                                callback(component.get('v.confirmSaveClicked'));
                            }
                        }
                    });
                }
            }
        );
    },

    deleteLocationOnServer: function (component, locationRecordId) {
        const action = component.get('c.deleteLocationRecord');

        action.setParams({
            locationRecordId: locationRecordId
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {
                    this.getDataFromServer(component);
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while deleting Location: ' + result.message);
                    this.hideSpinner(component);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while deleting Location: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while deleting Location');
                }
            }

            this.hideSpinner(component);
            this.publishDataSavedMessage(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    }

})