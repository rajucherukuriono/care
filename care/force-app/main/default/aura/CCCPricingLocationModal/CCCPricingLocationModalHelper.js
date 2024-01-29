({
    validatePricingTierPickers: function(component, event) {
        let pricingTierPickers = component.find('pricingTierPicker');
        if (!$A.util.isArray(pricingTierPickers)) {
            pricingTierPickers = new Array(pricingTierPickers);
        }
        return pricingTierPickers.every(p => p.getValidity());
    }
})