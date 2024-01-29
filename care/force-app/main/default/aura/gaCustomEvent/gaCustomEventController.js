({
    fireGAEvent : function(component, message) {
        //console.log('fireGAEvent')
        var messageStr;
        var memberTypeStr;
        var action = 'Click'; 

        if (message && message.getParam('message')) {
            messageStr = message.getParam('message');
            //console.log('messageStr: ' + messageStr);
            //console.log('action (before): ' + action);

            memberTypeStr = message.getParam('memberType');
            //console.log('memberTypeStr: ' + memberTypeStr);

            if (memberTypeStr != null){
                if (memberTypeStr.toLowerCase() == 'premium'){
                    action = 'PremiumClick';
                } else if (memberTypeStr.toLowerCase() == 'basic'){
                    action = 'BasicClick';
                }
                //console.log('action (after): ' + action);
            }
                

            if (messageStr !== undefined){
                var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
                analyticsInteraction.setParams({
                    hitType : 'event',
                    eventCategory : 'Button',
                    eventAction : action,
                    eventLabel : messageStr
                });
                analyticsInteraction.fire();
    
            }
        }
    }

})