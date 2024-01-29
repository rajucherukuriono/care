({
    selectRecord: function (component, event, helper) {
        const selectedRecord = component.get('v.oRecord');
        const compEvent = component.getEvent('recordSelectedEvent');
        compEvent.setParams({
            'selectedRecord': selectedRecord
        });
        compEvent.fire();
    }
})