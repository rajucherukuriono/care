({
    onInit: function (component, event, helper) {
        var colActive = component.get('v.sortField') === component.get('v.field');
        helper.setColumnHeaderState(component, colActive);
    },

    sortHandler: function (component, event, helper) {
        var evt = component.getEvent('onsort');
        evt.setParams({
            'sortField': component.get('v.field')
        });
        evt.fire();
    },

    sortFieldChangeHandler: function (component, event, helper) {
        var colActive = component.get('v.sortField') === component.get('v.field');
        helper.setColumnHeaderState(component, colActive);
        component.set('v.isHovered', false);
        component.set('v.ariaSort', colActive ? component.get('v.sortDirection') : 'none');
    },

    mouseoverHandler: function (component, event, helper) {
        var colActive = component.get('v.sortField') === component.get('v.field');
        if (!colActive) {
            helper.setColumnHeaderState(component, true);
            component.set('v.isHovered', true);
        }
    },

    mouseoutHandler: function (component, event, helper) {
        var colActive = component.get('v.sortField') === component.get('v.field');
        if (!colActive) {
            helper.setColumnHeaderState(component, false);
            component.set('v.isHovered', false);
        }
    }
})