({
    onInit: function(component, event, helper) {
        helper.getDataFromServer(component);
    },

    handleModifyUserClicked: function(component, event, helper) {
        helper.showUserPermissionsModal(component, event.getSource().get('v.value'));
    }
})