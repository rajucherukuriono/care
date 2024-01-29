({
    setColumnHeaderState: function (component, active) {
        var colHeader = component.find('title');
        if (active) {
            $A.util.addClass(colHeader, 'active');
            $A.util.removeClass(colHeader, 'inactive');
        } else {
            $A.util.addClass(colHeader, 'inactive');
            $A.util.removeClass(colHeader, 'active');
        }
    }
})