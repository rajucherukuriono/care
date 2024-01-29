({
    validate: function (component) {
        const cancelChoice = component.get('v.cancelChoice');
        const cancelDate = component.get('v.cancelDate');

        if (!this.validateComponent(component, 'cancelChoice') || $A.util.isEmpty(cancelChoice)) return false;

        if (cancelChoice === 'customDate') {
            if (!this.validateComponent(component, 'cancelDate') || $A.util.isEmpty(cancelDate)) return false;
        }

        // Everything checks out
        return true;
    }
})