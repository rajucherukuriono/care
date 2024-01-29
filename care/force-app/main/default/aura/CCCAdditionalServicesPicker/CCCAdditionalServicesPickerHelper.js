({
    init: function(component) {
        let composerServiceRecords = component.get('v.composerServiceRecords');
        let selectedComposerServiceRecordIds = component.get('v.selectedComposerServiceRecordIds') || [];
        let primaryServiceVerticalName = component.get('v.primaryServiceVerticalName');

        let verticalNames = new Set();
        composerServiceRecords.forEach(r => verticalNames.add(r.Vertical__c));

        let verticals = [];
        verticalNames.forEach(verticalName => {
            verticals.push({
                name: verticalName,
                services: composerServiceRecords.filter(r => r.Vertical__c === verticalName).map(r => {
                    return {
                        licenseLevel: r.License_Level__c,
                        id: r.Id,
                        checked: selectedComposerServiceRecordIds.includes(r.Id)
                    };
                }),
                expanded: verticalName === primaryServiceVerticalName
            });
        });
        component.set('v.verticals', verticals);
        component.set('v.allowEdit', true); // TODO: why do I have to set this manually here?
    },

    onComposerServiceChange: function(component, event) {
        let selectedComposerServiceRecordIdSet = new Set(component.get('v.selectedComposerServiceRecordIds'));

        // Add or remove the changed record in the selected composer service record ids
        if (event.getSource().get('v.checked')) {
            selectedComposerServiceRecordIdSet.add(event.getSource().get('v.value'));
        } else {
            selectedComposerServiceRecordIdSet.delete(event.getSource().get('v.value'));
        }

        component.set('v.selectedComposerServiceRecordIds', [...selectedComposerServiceRecordIdSet]);
    },

    handleChevronClick: function(component, event) {
        let verticals = component.get('v.verticals');
        let vertical = verticals.find(v => v.name === event.getSource().get('v.value'));
        vertical.expanded = !vertical.expanded;
        component.set('v.verticals', verticals);
    }

})