({
    createTabContent: function (component, tabId) {
        const tab = component.get('v.tabs').filter(tab => tab.id == tabId)[0];

        // Create the module first
        $A.createComponent('c:' + tab.moduleName, {
            'id': tab.moduleName,
            'recordId': component.get('v.recordId'),
            'allowEdit': component.getReference('v.allowEdit'),
            'recordType': component.getReference('v.recordType'),
            'oppType': component.getReference('v.oppType'),
            'opportunityRecord': component.getReference('v.opportunityRecord'),
            'sObjectName': component.get('v.sObjectName')
        }, function (newCmp, status, errorMessage) {

            if (status === 'SUCCESS') {

                // Next create the containing div
                $A.createComponent('aura:html', {
                    'tag': 'div',
                    'body': newCmp,
                    'HTMLAttributes': {
                        'id': tab.moduleName + 'Tab',
                        'aura:id': tab.moduleName + 'Tab',
                        'class': 'slds-tabs_scoped__content slds-show',
                        'role': 'tabpanel',
                        'aria-labelledby': tabId
                    }
                }, function (newDiv, status, errorMessage) {
                    if (status === 'SUCCESS') {
                        const tabContentContainer = component.get('v.tabContentContainer');
                        tabContentContainer.push(newDiv);
                        component.set('v.tabContentContainer', tabContentContainer);
                    } else if (status === 'INCOMPLETE') {
                        console.log('No response from server or client is offline.')
                    } else if (status === 'ERROR') {
                        console.log('Error: ' + errorMessage);
                    }
                });

            } else if (status === 'INCOMPLETE') {
                console.log('No response from server or client is offline.')
            } else if (status === 'ERROR') {
                console.log('Error: ' + errorMessage);
            }
        });
    },

    findTabContentWrapper: function (component, tabId) {
        let result = null;
        const container = component.get('v.tabContentContainer');

        if (!$A.util.isUndefinedOrNull(container) && !$A.util.isUndefinedOrNull(container.length)) {
            // loop through tabContentContainer items to find the div with the id that matches the tabId
            const items = container.filter(item => item.get('v.HTMLAttributes.id') == tabId);
            if (items.length > 0) {
                result = items[0];
            }
        }
        return result;
    },

    hideTabContent: function (component, tabContentWrapper) {
        $A.util.removeClass(tabContentWrapper, 'slds-show');
        $A.util.addClass(tabContentWrapper, 'slds-hide');
    },

    showTabContent: function (component, tabContentWrapper) {
        $A.util.removeClass(tabContentWrapper, 'slds-hide');
        $A.util.addClass(tabContentWrapper, 'slds-show');
    },

    getAllowEditFromServer: function (component) {
        const action = component.get('c.getAllowEditWrapper');

        action.setParams({
            'recordId': component.get('v.recordId')
        });

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                // DEBUGGING
                //console.log('getAllowEditFromServer result: ', result);

                if (!result.hasErrors) {
                    component.set('v.allowEdit', result.allowEdit);
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving information: ' + result.message);
                }

            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving information: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while retrieving information');
                }
            }

            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    },

    getInitialDataFromServer: function (component) {
        const action = component.get('c.getInitialData');
        action.setParams({
            'recordId': component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const result = response.getReturnValue();

                // DEBUGGING
                //console.log('getInitialDataFromServer result: ', result);

                if (!result.hasErrors) {

                    component.set('v.recordType', result.recordType);
                    component.set('v.oppType', result.oppType);

                    // Initialize tabs
                    const tabDefinitions = [
                        'serviceTab|Service|CCCServiceModule',
                        'locationsTab|Locations|CCCLocationModule',
                        'vettingTab|Vetting|CCCVettingModule',
                        'pricingTab|Budget|CCCPricingModule',
                        // 'administrationTab|Administration|CCCAdministrationModule',
                        'reviewTab|References|CCCReviewModule',
                        'summaryTab|Summary|CCCSummaryModule'
                    ];

                    const tabs = [];
                    tabDefinitions.forEach(tabDefinition => {
                        const tabDefinitionArray = tabDefinition.split('|');
                        tabs.push({
                            'id': tabDefinitionArray[0],
                            'label': tabDefinitionArray[1],
                            'moduleName': tabDefinitionArray[2],
                            'active': false
                        });
                    });

                    component.set('v.tabs', tabs);

                    // Initialize storedEvents
                    const storedEvents = {};
                    tabs.forEach(tab => storedEvents[tab.moduleName] = []);
                    component.set('v.storedEvents', storedEvents);

                    // Create the first tab container and module
                    const tab = tabs[0]; // grab the first tab
                    //tab.active = true;  // AO - Unnecessary, handleCurrentModuleNameChange will create this for us and set to active
                    //this.createTabContent(component, tab.id); // AO - Unnecessary, handleCurrentModuleNameChange will create this for us
                    component.set('v.currentModuleName', tab.moduleName);

                    // Initialize v.loadedModules
                    component.set('v.loadedModules', [tab.moduleName]);
                } else {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving information: ' + result.message);
                }

            } else {
                const errors = response.getError();

                if (!$A.util.isEmpty(errors) && !$A.util.isEmpty(errors[0]) && !$A.util.isEmpty(errors[0].message)) {
                    this.showToast('error', 'Error', 'The following error occurred while retrieving information: ' + errors[0].message);
                } else {
                    this.showToast('error', 'Error', 'An unknown error occured while retrieving information');
                }
            }

            this.hideSpinner(component);
        });

        $A.enqueueAction(action);
        this.showSpinner(component);
    }
})