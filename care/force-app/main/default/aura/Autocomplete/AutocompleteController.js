({
    // Initilizaton logic
    onInit: function (component, event, helper) {
        const selectedRecord = component.get('v.selectedRecord');

        // Show the pill if we already have a value present for selectedRecord
        if (selectedRecord && selectedRecord.Id) {
            const compEvent = component.getEvent("recordSelectedEvent");
            compEvent.setParams({
                "selectedRecord": selectedRecord
            });
            compEvent.fire();
        }
    },

    // Click handler - calls search helper in case there is currently text in the search input element
    onSearchInputClick: function (component, event, helper) {
        $A.util.addClass(component.find('theSpinner'), 'slds-show');
        const forOpen = component.find('searchRes');
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        helper.searchHelper(component, event, helper);
    },

    onMouseEnter: function (component, event, helper) {
        component.set('v.hasMouseFocus', true);
    },

    // Hides search results when component loses focus
    onMouseLeave: function (component, event, helper) {
        component.set('v.hasMouseFocus', false);
        helper.closeSearchResults(component, event, helper);
    },

    // Handle onblur event on searchInputElement
    onSearchInputBlur: function (component, event, helper) {
        // only close search results if mouse isn't over the autocomplete component
        if (!component.get('v.hasMouseFocus')) {
            helper.closeSearchResults(component, event, helper);
        }
    },

    // onKeyup handler for searchInputElement
    onSearchInputKeyUp: function (component, event, helper) {
        // First handle key events 'ArrowDown', 'ArrowUp', etc.
        if (helper.handleKeyEvents(component, event, helper)) {
            return;
        }

        const previousKeyword = component.get('v.searchKeyword');
        const inputKeyword = event.target.value;
        if (inputKeyword === previousKeyword) {
            return;
        }
        component.set('v.searchKeyword', inputKeyword);

        helper.searchHelper(component, event, helper);
    },

    // Handler for the "x" button on the selected record pill
    onSelectedRecordRemove: function (component, event, helper) {
        component.set('v.selectedRecord', {});
        component.set('v.searchKeyword', null);
        component.set('v.searchResultRecords', null);
    },

    // Handles the event fired that indicates a record has been selected
    onRecordSelectedEvent: function (component, event, helper) {
        const selectedRecord = event.getParam('selectedRecord');
        helper.setSelectedRecord(component, selectedRecord);
    },

    // When the highlightedIndex attribute changes, loop through the records
    // to highlight or unhighlight the elements
    onHighlightedIndexChanged: function (component, event, helper) {
        const highlightedIndex = component.get('v.highlightedIndex');
        let resultContainer = component.find('resultContainer');

        // Force resultContainer to be an array even when only a single element is returned
        if (resultContainer) {
            if (!component.find('resultContainer').length) {
                resultContainer = [resultContainer];
            }

            resultContainer.forEach((container, index) => {
                if (index === highlightedIndex) {
                    $A.util.addClass(container, 'highlighted');
                } else {
                    $A.util.removeClass(container, 'highlighted');
                }
            });
        }
    },

    // Handler for selectedRecord on change
    // When the selected record changes (either by a record being selected or removed),
    // we need to make sure the search input is reset to blank as well as the searchKeyword
    onSelectedRecordChanged: function (component, event, helper) {
        // If the input element hasn't been created yet, ignore this event
        if (!component.find('searchInputElement').getElement()) {
            return;
        }

        // clear out value in the search input element
        component.find('searchInputElement').getElement().value = '';
        // clear out the search keyword
        component.set('v.searchKeyword', null);

        // If the object in the selected value doesn't have an Id that means it is empty
        // so we need to remove the pill
        if (event.getParam('value') && !event.getParam('value').Id) {
            const pillTarget = component.find('lookup-pill');
            const lookUpTarget = component.find('lookupField');

            $A.util.addClass(pillTarget, 'slds-hide');
            $A.util.removeClass(pillTarget, 'slds-show');

            $A.util.addClass(lookUpTarget, 'slds-show');
            $A.util.removeClass(lookUpTarget, 'slds-hide');
        }
    },

    // Handler for searchResultRecords on change
    onSearchResultRecordsChanged: function (component, event, helper) {
        const searchResultRecords = event.getParam("value");
        if (searchResultRecords != null) {
            // clear out error message so that there is no gap between the input element and the list of search results
            helper.setCustomValidity(component, '');
        }
    },

    // Allows you to set or remove the error message
    setCustomValidity: function (component, event, helper) {
        const params = event.getParam('arguments');
        if (params) {
            helper.setCustomValidity(component, params.message);
        }
    },

    setFocusOnInput: function (component, event, helper) {
        component.find('searchInputElement').getElement().focus();
    }
})