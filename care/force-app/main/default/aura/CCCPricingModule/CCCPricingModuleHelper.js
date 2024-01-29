({
    getDataFromServer: function (component) {
        const action = component.get('c.getPricingData');

        action.setParams({
            'opportunityId': component.get('v.recordId')
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                // DEBUGGING
                //console.log('getPricingData result: ', result); 

                if (!result.hasErrors) {
                    component.set('v.locations', this.sumLocationAndServiceValues(result.locations));
                    component.set('v.opportunityRecord', result.opportunityRecord);
                    component.set('v.primaryContactId', result.primaryContactId);
                    component.set('v.contactRecords', result.contactRecords);
                    
                    // Set userCanWaivePlatformFee flag
                    component.set('v.userCanWaivePlatformFee', result.userCanWaivePlatformFee);

                    // Platform Fee Waived
                    component.set('v.platformFeeWaived', result.opportunityRecord.Platform_Fee_Waived__c);
                    component.set('v.maxPlatformFeeWaived', result.maxPlatformFeeWaived);

                    // Province options
                    component.set('v.provinceOptions', result.provinceOptions.map(o => { return { label: o, value: o } }));
                    
                    //Determine if modifications are allowed     
                    component.set('v.composerServiceRecord', result.composerServiceRecord);

                    component.set('v.showModifyButton', true);   
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Pricing information: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving Pricing information: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while retrieving Pricing information');
                }
            }
            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    sumLocationAndServiceValues: function(locations) {
        // Sums up monthlyAdBudget and bonus points for the location
        // and all additional services
        if (locations) {
            console.log('Locations');
            console.log(locations);
            locations.forEach(location => {
                location.totalMonthlyAdBudget = location.primaryService.amount;
                location.totalBonusPoints = location.primaryService.bonusPoints;
                if (location.additionalServices) {
                    location.additionalServices.forEach(serv => {
                        location.totalMonthlyAdBudget += serv.amount || 0;
                        location.totalBonusPoints += serv.bonusPoints || 0;
                    });
                    // Create comma separated string of additional service names
                    location.additionalServicesSummarized = location.additionalServices.map(s => s.name).join(', ');
                }
            });
        }

        return locations;
    },

    showPricingLocationModal: function (component, config, callback) {
        config.saveClicked = component.getReference('v.saveClicked');

        $A.createComponent('c:CCCPricingLocationModal', config,
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    const overlayLib = component.find('overlayLib') || component.getSuper().find('overlayLib') || component.getSuper().getSuper().find('overlayLib');
                    overlayLib.showCustomModal({
                        header: config.header,
                        body: modalCmp,
                        showClosebutton: true,
                        cssClass: 'slds-modal_small',
                        closeCallback: function () {
                            if (callback) {
                                callback(component.get('v.saveClicked'));
                            }
                        }
                    });
                }
            }
        );
    },

    savePricingDataToServer: function (component, location) {
        const action = component.get('c.savePricingData');

        action.setParams({
            opportunityId: component.get('v.recordId'),
            locationRecordJSON: JSON.stringify(location)
        });

        action.setCallback(this, function (response) {

            const state = response.getState();
            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                // DEBUGGING
                //console.log('savePricingToServer result: ', result);

                if (!result.hasErrors) {
                    component.set('v.locations', this.sumLocationAndServiceValues(result.locations));

                    this.showToast('success', 'Success', 'Pricing saved successfully.');
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while saving Pricing: ' + result.message);
                }

            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while saving the Pricing: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while retrieving information');
                }
            }

            this.publishDataSavedMessage(component);
            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    saveContactToServer: function (component, contactRecord, isNewContact) {
        const opportunityRecord = component.get('v.opportunityRecord');

        // Keep only necessary fields in contact object
        const contact = {
            Id: contactRecord.Id,
            AccountId: opportunityRecord.AccountId,
            FirstName: contactRecord.FirstName,
            Middle_Name__c: contactRecord.Middle_Name__c,
            LastName: contactRecord.LastName,
            Suffix__c: contactRecord.Suffix__c,
            Salutation: contactRecord.Salutation,
            Phone: contactRecord.Phone,
            Email: contactRecord.Email,
            MailingStreet: contactRecord.MailingStreet,
            MailingCity: contactRecord.MailingCity,
            MailingState: contactRecord.MailingState,
            MailingCountry: contactRecord.MailingCountry,
            MailingPostalCode: contactRecord.MailingPostalCode
        };

        // Set this contact as the primary contact if it is new and it passes validation
        let setAsPrimary = false;
        if (isNewContact && this.validatePrimaryContact(component, contact) === '') {
            setAsPrimary = true;
        }

        const recordId = component.get('v.recordId');
        const action = component.get('c.saveContact');
        const config = {
            'recordId': recordId,
            'contactRecordJSON': JSON.stringify(contact),
            'setAsPrimary': setAsPrimary
        };

        action.setParams(config);
        action.setCallback(this, function (response) {

            const state = response.getState();
            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                // DEBUGGING
                //console.log('saveContactToServer result: ', result);

                if (!result.hasErrors) {
                    component.set('v.contactRecords', result.contactRecords);
                    component.set('v.primaryContactId', result.primaryContactId);

                    this.showToast('success', 'Success', 'Contact saved successfully.');
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while saving the Contact: ' + result.message);
                }

            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while saving the Contact: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while retrieving information');
                }
            }

            this.publishDataSavedMessage(component);
            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    showContactModal: function (component, config, callback) {
        config.saveClicked = component.getReference('v.confirmSaveClicked');

        $A.createComponent('c:CCCAdministrationContactModal', config,
            function (modalCmp, status) {
                if (status === 'SUCCESS') {
                    const overlayLib = component.find('overlayLib') || component.getSuper().find('overlayLib') || component.getSuper().getSuper().find('overlayLib');
                    overlayLib.showCustomModal({
                        'header': config.header,
                        'body': modalCmp,
                        'showClosebutton': true,
                        'cssClass': 'slds-modal_small',
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

    validatePrimaryContact: function(component, contact) {
        let message = '';

        if ($A.util.isEmpty(contact)) {
            message = 'Unable to identify the selected Primary Contact.';
            return;
        }

        if (!contact.FirstName || !contact.LastName) {
            message = 'The Primary Contact must have both the First and Last Name fields populated.';
            return;
        }

        if (!contact.Email) {
            message = 'The Primary Contact must have the Email field populated.';
            return;
        }

        // if (!contact.MailingStreet || !contact.MailingCity || !contact.MailingState || !contact.MailingPostalCode) {
        //     message = 'The Primary Contact must have the Address fields (Street, City, Province, Postal Code) populated.';
        //     return;
        // }

        return message;
    },

    // Validate the selected Contact's data to verify that it contains the needed information for BGC
    validatePrimaryContact_old: function (component, contactId) {
        const contactRecords = component.get('v.contactRecords');
        let candidateContact;

        candidateContact = contactRecords.find(contact => contact.Id === contactId);

        if ($A.util.isEmpty(candidateContact)) {
            this.showToast('error', 'Error', 'Unable to identify the selected Primary Contact.');
            return false;
        }

        if (!candidateContact.FirstName || !candidateContact.LastName) {
            this.showToast('error', 'Error', 'The Primary Contact must have both the First and Last Name fields populated.');
            return false;
        }

        // if (!candidateContact.Birthdate) {
        //     this.showToast('error', 'Error', 'The Primary Contact must have the Birth Date field populated.');
        //     return false;
        // }

        // Verify that the Primary Contact is at least 18 years of age
        // Used from https://stackoverflow.com/questions/4076321/javascript-age-calculation
        // Should handle leap years
        // const birthDate = new Date(candidateContact.Birthdate);
        // const todayDate = new Date($A.localizationService.formatDate(new Date(), 'YYYY-MM-DD'));
        // let years = (todayDate.getFullYear() - birthDate.getFullYear());

        // if (todayDate.getMonth() < birthDate.getMonth() ||
        //     todayDate.getMonth() === birthDate.getMonth() && todayDate.getDate() < birthDate.getDate()) {
        //     years--;
        // }

        // if (years < 18) {
        //     this.showToast('error', 'Error', 'The Primary Contact must be 18 years old in order to be submitted for a background check');
        //     return false;
        // }


        if (!candidateContact.Email) {
            this.showToast('error', 'Error', 'The Primary Contact must have the Email field populated.');
            return false;
        }

        if (!candidateContact.MailingStreet || !candidateContact.MailingCity || !candidateContact.MailingState || !candidateContact.MailingPostalCode) {
            this.showToast('error', 'Error', 'The Primary Contact must have the Address fields (Street, City, Province, Postal Code) populated.');
            return false;
        }

        return true;
    },

    sortContacts: function (component, contacts) {
        const sortField = component.get('v.contactSortField');
        const sortDirection = component.get('v.contactSortDirection');
        return contacts.sort(this.getSortFunc(sortField, sortDirection));
    },

    getSortFunc: function (sortField, sortDirection) {
        if (sortDirection === 'ascending') {
            return (a, b) => {
                const x = a[sortField] !== undefined ? a[sortField].toString().toLowerCase() : '';
                const y = b[sortField] !== undefined ? b[sortField].toString().toLowerCase() : '';
                if (x < y) return -1;
                if (x > y) return 1;
                return 0;
            };
        } else {
            return (a, b) => {
                const x = b[sortField] !== undefined ? b[sortField].toString().toLowerCase() : '';
                const y = a[sortField] !== undefined ? a[sortField].toString().toLowerCase() : '';
                if (x < y) return -1;
                if (x > y) return 1;
                return 0;
            };
        }
    },

    savePrimaryContactToServer: function (component) {
        const recordId = component.get('v.recordId');
        const primaryContactId = component.get('v.primaryContactId');

        const action = component.get('c.savePrimaryContact');
        action.setParams({
            'recordId': recordId,
            'contactId': primaryContactId
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                // DEBUGGING
                //console.log('saveBGCData result: ', result);

                if (!result.hasErrors) {
                    component.set('v.contactRecords', result.contactRecords);
                    component.set('v.primaryContactId', result.primaryContactId);
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while saving the Background Check Information: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while saving the Background Check Information: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while saving information');
                }
            }

            this.publishDataSavedMessage(component);
            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    updatePlatformFeeWaivedToServer: function(component) {
        const maxPlatformFeeWaived = component.get('v.maxPlatformFeeWaived') || 0;
        const platformFeeWaived = component.get('v.platformFeeWaived') || 0;
        if (platformFeeWaived > maxPlatformFeeWaived) {
            this.showToast('error', 'Error', 'The Platform Fee Waived cannot be greater than the Total Platform Fee of $' + maxPlatformFeeWaived);
            return;
        }

        const action = component.get('c.updatePlatformFeeWaived');
        action.setParams({
            opportunityId: component.get('v.recordId'),
            platformFeeWaived: component.get('v.platformFeeWaived')
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                if (!result.hasErrors) {
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while updating the Platform Fee Waived: ' + result.message);
                }
            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while updating the Platform Fee Waived: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while saving information');
                }
            }

            this.publishDataSavedMessage(component);
            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    }
});