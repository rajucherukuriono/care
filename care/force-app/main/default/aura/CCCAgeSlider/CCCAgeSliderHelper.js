({
    initSlider: function(component) {
        let helper = this;
        let slider = component.find('slider').getElement();
        let minimumAge = component.get('v.minimumAge');
        let maximumAge = component.get('v.maximumAge');

        noUiSlider.create(slider, {
            'start': [minimumAge, maximumAge],
            'connect': true,
            'step': 1,
            'range': {
                'min': 0,
                'max': 216
            },
            // tooltips: [this.format, this.format],
            'pips': {
                'mode': 'steps',
                'density': 1,
                'filter': this.filterPips
            }
        });

        slider.noUiSlider.on('set', (values, handle, unencoded, tap, positions, noUiSlider) => {
            if (handle === 0) {
                component.set('v.minimumAge', values[0]);
            }
            if (handle === 1) {
                component.set('v.maximumAge', values[1]);
            }
            helper.updateFormattedAgeValues(component, helper);
        });

        helper.updateFormattedAgeValues(component, helper);
    },

    updateFormattedAgeValues: function(component, helper) {
        component.set('v.formattedMinimumAge', `${helper.formatAge(component.get('v.minimumAge'))}`);
        component.set('v.formattedMaximumAge', `${helper.formatAge(component.get('v.maximumAge'))}`);
    },

    formatAge: function(value) {
        value = Math.trunc(value);
        let yearString = '', monthString = '';
        let years = Math.floor(value / 12);
        let months = value % 12;

        // Build years output
        if (years > 0) {
            if (years === 1) {
                yearString = '1 Year';
            } else {
                yearString = years + ' Years';
            }
        }

        // Build months output
        if (months === 1) {
            monthString = '1 Month';
        } else {
            monthString = months + ' Months';
        }

        return yearString + ' ' + monthString;
    },

    filterPips: function(value, type) {
        if (value % 12 === 0) {
            return 1; // big pip
        }
        if (value % 6 === 0 || type === 1) {
            return 2; // small pip
        }
        return -1; // no pip
    },

    format: {
        // 'to' the formatted value. Receives a number.
        to: function (value) {
            value = Math.trunc(value);
            let yearString = '', monthString = '';
            let years = Math.floor(value / 12);
            let months = value % 12;

            // Build years output
            if (years > 0) {
                if (years === 1) {
                    yearString = '1 Year';
                } else {
                    yearString = years + ' Years';
                }
            }

            // Build months output
            if (months === 1) {
                monthString = '1 Month';
            } else {
                monthString = months + ' Months';
            }

            return yearString + ' ' + monthString;
        },
        // 'from' the formatted value.
        // Receives a string, should return a number.
        from: function (value) {
            return Number(value.replace(',-', ''));
        }
    },

    updateSliderValues: function(component, event) {
        let slider = component.find('slider').getElement();
        //console.log('@@@ updateSliderValues slider:', slider);
        slider.noUiSlider.set([component.get('v.minimumAge'), component.get('v.maximumAge')]);
    }

})