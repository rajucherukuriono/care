({
    onInit: function (component, event, helper) {
        helper.getDataFromServer(component);
    },

    handleAddReviewClicked: function (component, event, helper) {
        const account = component.get('v.opportunityRecord').Account;

        const reviewRecord = {
            Id: null,
            Account__c: component.get('v.opportunityRecord').AccountId,
            Email__c: null,
            First_Name__c: null,
            Last_Name__c: null,
            Location__c: null,
            Phone__c: null,
        };

        component.set('v.reviewRecord', reviewRecord);

        helper.showReviewModal(component, {
            reviewRecord: component.getReference('v.reviewRecord'),
            locationRecords: component.get('v.locationRecords'),
            businessId: account.Galore_Business_Id__c
        }, $A.getCallback(saveClicked => {
            if (saveClicked) {
                helper.getDataFromServer(component);
            }
        }));

    },

    onModifyClicked: function(component, event, helper) {
        const reviewId = event.getSource().get('v.value');
        const reviewRecord = component.get('v.reviewRecords').find(r => r.Id === reviewId);
        const account = component.get('v.opportunityRecord').Account;

        component.set('v.reviewRecord', reviewRecord);

        helper.showReviewModal(component, {
            reviewRecord: component.getReference('v.reviewRecord'),
            locationRecords: component.get('v.locationRecords'),
            businessId: account.Galore_Business_Id__c
        }, $A.getCallback(saveClicked => {
            if (saveClicked) {
                helper.getDataFromServer(component);
            }
        }));

    }
})