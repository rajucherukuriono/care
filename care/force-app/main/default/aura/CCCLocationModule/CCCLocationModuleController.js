({
    onInit: function(component, event, helper) {
        helper.getDataFromServer(component);
    },

    handleAddLocationClicked: function(component, event, helper) {

        helper.showLocationModal(component, {
            opportunityId: component.get('v.recordId'),
            accountRecord: component.get('v.accountRecord'),
            composerServiceRecords: component.get('v.composerServiceRecords'),
            mapBoxApiKey: component.get('v.mapBoxApiKey'),
            provinceOptions: component.get('v.provinceOptions'),
            stateAbbreviationMap: component.get('v.stateAbbreviationMap')
        }, $A.getCallback(saveClicked => {
                if (saveClicked) {
                    helper.getDataFromServer(component);
                }
            })
        );

    },

    handleSortLocations: function(component, event, helper) {

    },

    handleModifyLocationClicked: function(component, event, helper) {
        let locationId =  event.getSource().get('v.value');
        let locationRecords = component.get('v.locationRecords')

        helper.showLocationModal(component, {
            opportunityId: component.get('v.recordId'),
            accountRecord: component.get('v.accountRecord'),
            locationRecordId: event.getSource().get('v.value'),
            locationRecord: locationRecords.find(l => l.Id === locationId),
            composerServiceRecords: component.get('v.composerServiceRecords'),
            primaryServiceVerticalName: component.get('v.primaryServiceVerticalName'),
            mapBoxApiKey: component.get('v.mapBoxApiKey'),
            provinceOptions: component.get('v.provinceOptions'),
            enableAdditionalServices: component.get('v.enableAdditionalServices'),
            stateAbbreviationMap: component.get('v.stateAbbreviationMap')
        }, $A.getCallback(saveClicked => {
                if (saveClicked) {
                    helper.getDataFromServer(component);
                }
            })
        );

    },

    handleDeleteLocationClicked: function(component, event, helper) {
        let locationRecordId = event.getSource().get('v.value');

        helper.showConfirmModal(component, {
            'title': 'Delete Location',
            'message': 'Are you sure you would like to delete this Location?',
            'iconName': 'utility:question_mark',
            'okButtonLabel': 'Delete'
        }, $A.getCallback(function(okClicked) {
            if (okClicked) {
                helper.deleteLocationOnServer(component, locationRecordId);
            }
        }));
    },

    test: function(component, event, helper) {
        debugger;
    }
})