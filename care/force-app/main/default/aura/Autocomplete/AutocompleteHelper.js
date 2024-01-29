({
    // Determines if a search needs to be done and which search method should be used
    searchHelper: function (component, event, helper) {
        const inputKeyword = component.get('v.searchKeyword');

        if (inputKeyword && inputKeyword.trim().length > 0) {
            const forOpen = component.find('searchRes');
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');

            // The timeout logic keeps the search functions from being called every keystroke
            const timeoutReference = component.get('v.timeoutReference');
            clearTimeout(timeoutReference);
            timeoutReference = setTimeout($A.getCallback(function () {

                if (component.get('v.dataSource') != null) {
                    helper.searchViaDataSource(component, event, inputKeyword);
                } else {
                    helper.searchViaApex(component, event, inputKeyword);
                }

                clearTimeout(timeoutReference);
                component.set('v.timeoutReference', null);
            }), 200);
            component.set('v.timeoutReference', timeoutReference);

        } else {
            component.set('v.searchResultRecords', null);
            const forclose = component.find('searchRes');
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    // Search using the Apex controller
    searchViaApex: function (component, event, keyword) {
        const action = component.get('c.fetchLookUpValues');

        action.setParams({
            'searchKeyword': keyword,
            'objectName': component.get('v.objectAPIName'),
            'fieldName': component.get('v.fieldAPIName'),
            'wildcardPosition': component.get('v.wildcardPosition')
        });

        action.setCallback(this, function (response) {
            $A.util.removeClass(component.find('theSpinner'), 'slds-show');
            const state = response.getState();

            if (state === 'SUCCESS') {
                const storeResponse = response.getReturnValue();
                component.set('v.Message', '');

                // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set('v.Message', 'No Result Found...');
                } else {
                    const fieldAPIName = component.get('v.fieldAPIName');
                    if (fieldAPIName !== 'Name') {
                        storeResponse.forEach(item => item['Name'] = item[fieldAPIName]);
                    }
                }

                // set searchResult list with return value from server.
                component.set('v.searchResultRecords', storeResponse);

                // reset highlightedIndex
                component.set('v.highlightedIndex', -1);
            }
        });

        // enqueue the Action
        $A.enqueueAction(action);
    },

    // Search using dataSource attribute
    searchViaDataSource: function (component, event, keyword) {
        const keywordLower = keyword.toLowerCase();
        const fieldAPIName = component.get('v.fieldAPIName');
        const results = component.get('v.dataSource')
            .filter(item => item[fieldAPIName].toLowerCase().includes(keywordLower))
            .slice(0, 5);

        component.set('v.Message', '');

        if (results.length == 0) {
            component.set('v.Message', 'No Result Found...');
        }
        component.set('v.searchResultRecords', results);

        component.set('v.highlightedIndex', -1);
    },

    // Close the drop down of search results
    closeSearchResults: function (component, event, helper) {
        component.set('v.searchResultRecords', null);
        const forclose = component.find('searchRes');
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        component.set('v.highlightedIndex', -1);
    },

    // Set the selected record and display pill containing record name
    setSelectedRecord: function (component, selectedRecord) {
        component.set('v.selectedRecord', selectedRecord);

        const lookupPill = component.find('lookup-pill');
        $A.util.addClass(lookupPill, 'slds-show');
        $A.util.removeClass(lookupPill, 'slds-hide');

        const searchRes = component.find('searchRes');
        $A.util.addClass(searchRes, 'slds-is-close');
        $A.util.removeClass(searchRes, 'slds-is-open');

        const lookupField = component.find('lookupField');
        $A.util.addClass(lookupField, 'slds-hide');
        $A.util.removeClass(lookupField, 'slds-show');
    },

    // Handle keyUp event codes to allow navigation/selection of records via keyboard
    handleKeyEvents: function (component, event, helper) {
        let keyUpEventHandled = false;
        const records = component.get('v.searchResultRecords');

        if (records != null && records.length > 0) {
            const highlightedIndex = component.get('v.highlightedIndex');

            switch (event.code) {
                case 'Enter':
                    if (highlightedIndex > -1) {
                        helper.setSelectedRecord(component, records[highlightedIndex]);
                    }
                    keyUpEventHandled = true;
                    break;
                case 'ArrowDown':
                    highlightedIndex++;
                    if (highlightedIndex > (records.length - 1)) {
                        highlightedIndex = (records.length - 1);
                    }
                    component.set('v.highlightedIndex', highlightedIndex);
                    keyUpEventHandled = true;
                    break;
                case 'ArrowUp':
                    highlightedIndex--;
                    if (highlightedIndex < 0) {
                        highlightedIndex = 0;
                    }
                    component.set('v.highlightedIndex', highlightedIndex);
                    keyUpEventHandled = true;
                    break;
                case 'Escape':
                    helper.closeSearchResults(component, event, helper);
                    keyUpEventHandled = true;
                    break;
                case 'Tab':
                    helper.closeSearchResults(component, event, helper);
                    keyUpEventHandled = true;
                    break;
            }
        }

        return keyUpEventHandled;
    },

    setCustomValidity: function (component, message) {
        component.set('v.errorMessage', message);
        const inputContainer = component.find('searchInputElementContainer').getElement();
        const errorContainer = component.find('errorMessageContainer').getElement();
        if (message.trim().length > 0) {
            $A.util.addClass(inputContainer, 'slds-has-error');
            $A.util.addClass(inputContainer, 'slds-m-top_medium');
            $A.util.removeClass(errorContainer, 'slds-hide');
        } else {
            $A.util.removeClass(inputContainer, 'slds-has-error');
            $A.util.removeClass(inputContainer, 'slds-m-top_medium');
            $A.util.addClass(errorContainer, 'slds-hide');
        }
    }
})