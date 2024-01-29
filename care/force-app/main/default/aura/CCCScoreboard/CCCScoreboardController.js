({
    // Code to execute when component initializes
    onInit: function (component, event, helper) {
        helper.getDataFromServer(component);
    },

    onCCCMessageEvent: function (component, message, helper) {
        if (!$A.util.isEmpty(message) && !$A.util.isEmpty(message.getParam('eventType'))) {
            const eventType = message.getParam('eventType');

            if (eventType === 'dataSaved') {
                helper.getDataFromServer(component);
            }
        }
    }
})