({
    onInit: function (component, event, helper) {
        helper.getInitialDataFromServer(component);
    },

    // Process what happens when we attempt to navigate to another tab
    onTabClick: function (component, event, helper) {
        const currentModuleName = component.get('v.currentModuleName');
        const newTab = component.get('v.tabs').filter(tab => tab.id === event.target.dataset.tabId)[0];

        // No need to navigate to the current tab
        if (currentModuleName === newTab.moduleName) return;

        // Store module name in loadedModules attribute
        let loadedModulesSet = new Set(component.get('v.loadedModules'));
        loadedModulesSet.add(newTab.moduleName);
        component.set('v.loadedModules', [...loadedModulesSet]);

        // Update the new current module
        component.set('v.currentModuleName', newTab.moduleName);
        return;
    },

    // Processes what needs to happen when switching to a new module
    handleCurrentModuleNameChange: function (component, event, helper) {
        const oldModuleName = event.getParam('oldValue');
        const newModuleName = event.getParam('value');
        const newTab = component.get('v.tabs').filter(tab => tab.moduleName === newModuleName)[0];

        if (!$A.util.isUndefinedOrNull(oldModuleName)) {
            // Hide current tab
            helper.hideTabContent(component, helper.findTabContentWrapper(component, oldModuleName + 'Tab'));
        }

        // Show corresponding tab content if it exists -- otherwise create tab content
        let tabContentWrapper = helper.findTabContentWrapper(component, newModuleName + 'Tab');
        if (tabContentWrapper) {
            helper.showTabContent(component, tabContentWrapper);
        } else {
            helper.createTabContent(component, newTab.id);
            tabContentWrapper = helper.findTabContentWrapper(component, newModuleName + 'Tab');
        }

        // Send any stored events for the active tab's module
        const moduleReference = tabContentWrapper.get('v.body')[0]; // the module is the only element in the wrapper div
        let storedEvents = component.get('v.storedEvents');
        const events = storedEvents[newModuleName];

        // Ask the tab's module to handle any store events
        moduleReference.handleTabEvents(events);

        // Clear out any stored events for that tab module
        storedEvents[newModuleName] = [];
        component.set('v.storedEvents', storedEvents);

        // Highlight tab corresponding w/new module
        let tabs = component.get('v.tabs');
        tabs.forEach(tab => tab.active = tab.moduleName === newModuleName);
        component.set('v.tabs', tabs);
    },

    onCCCMessageEvent: function (component, message, helper) {
        if (!$A.util.isEmpty(message) && !$A.util.isEmpty(message.getParam('eventType'))) {
            const eventType = message.getParam('eventType');

            if (eventType === 'dataSaved') {

                const payload = message.getParam('payload');
                const sourceName = payload.sourceName.substring(1); // Strips off lowercase 'c' from beginning of component name

                const loadedModules = component.get('v.loadedModules'); // Only store events for modules that have been loaded
                let storedEvents = component.get('v.storedEvents');

                Object.keys(storedEvents).filter(cmp => cmp != sourceName && loadedModules.includes(cmp)).forEach(cmp => { // Loop through tab components and store a copy of the event for each component
                    //const newEvent = Object.assign(message); // get a copy of the event params
                    const newEvent = {
                        'type': eventType,
                        'message': payload
                    };
                    storedEvents[cmp] = storedEvents[cmp].filter(e => !(e.type == newEvent.type && e.message == newEvent.message)); // filter out events that match the current event so we don't store duplicates
                    storedEvents[cmp].push(newEvent);
                });

                component.set('v.storedEvents', storedEvents);
            }
        }
    },

    // Handler for Lightning Data Service changes for Opportunity.
    // The allowEdit attribute is changed in the helper if the Opportunity.StageName
    // is not one of the publishable stages (controlled by custom metadata setting)
    handleOpportunityRecordChange: function (component, event, helper) {
        const changeType = event.getParams().changeType;
        if (changeType === 'LOADED' || changeType === 'CHANGED') {
            helper.getAllowEditFromServer(component);
        }
    }
})