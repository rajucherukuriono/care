({
    handleTabEvents: function (component, event, helper) {
        const params = event.getParam('arguments');

        if (params && params.events) {
            params.events.forEach(evt => {
                if (evt.type === 'dataSaved') {
                    this.getDataFromServer(component);
                }
            });
        }

        if (this.handleTabFocus) {
            this.handleTabFocus(component);
        }
    },

    publishDataSavedMessage: function (component) {
        // Fire off an event to the CCC Message Channel
        const CCCEvent = {
            'eventType': 'dataSaved',
            'payload': {'sourceName': component.getName()}
        };

        component.getSuper().find('CCCMessageChannel').publish(CCCEvent);
    }
})