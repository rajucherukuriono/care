trigger ProcessMemberGDPRequestTgr on Request_Data__c (before insert,before update) {
    System.debug('Inside ProcessMemberGDPRequestTgr 1 ===>:');
    List<Request_Data__c> reqListToUpdate=new List<Request_Data__c>();
    public List<id> caseFeedList;
    public GDPR_Settings__mdt rtbfSettings=[select id,DeveloperName,Stop_Fail_Over_Notification_To_Sterling__c,Stop_Sending_Notification_To_Sterling__c,Scope_Size__c,Fail_Over_Retrial_Limit__c,Process_RTBF_Retention_Request_Type__c,MasterLabel,Data_Batch_Size__c,Feed_Data_Batch_Size__c,History_Data_Batch_Size__c,Override_Account_Record_Type__c,Override_Employer_Program__c,Override_Premium__c,Override_Safety_Case__c,RTBF_Retention__c,Schedule_Mode__c,Status_To_Process__c,Time_To_Schedule_SSMMHH__c from GDPR_Settings__mdt where RTBF_Retention__c='RTBF'];
    for(Request_Data__c reqObj:Trigger.new)
    {
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) && (reqObj.Request_Type__c=='RTBF' || reqObj.Request_Type__c=='RTBF Fix' || reqObj.Request_Type__c=='RTBF Override' || reqObj.Request_Type__c=='RTBF Do Not Process'))
        {
            System.debug('Inside ProcessMemberGDPRequestTgr 2 ===>:');
            reqListToUpdate.add(reqObj);
        }
    }
    if(!reqListToUpdate.isEmpty() )
    {
        Map<String,Account> gmIdAccMap = ProcessMemberGDPInstantRequest.ProcessMemberGDPInstantRequest(reqListToUpdate,'anonymize',caseFeedList);
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        for(Request_Data__c reqObj:reqListToUpdate)
        {
            Account accObj=gmIdAccMap.get(reqObj.Global_Member_Id__c);
            postMessageToFeed(accObj.id,accObj.ownerId,reqObj.Request_Type__c,batchInputs);
        }
        //ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        if(rtbfSettings.Stop_Sending_Notification_To_Sterling__c)
        {NotifyInstantGDPRequestToSterling.notifyInstantGDPRequestToSterling(reqListToUpdate,gmIdAccMap);}
    }
    public static void postMessageToFeed(Id accountId,ID accountOwnerId,String requestType,List<ConnectApi.BatchInput> batchInputs){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        textSegmentInput.text = 'Account is successfully processed for '+requestType+'.';
        messageBodyInput.messageSegments.add(textSegmentInput);
        // Mention case owner (or case closer)
        mentionSegmentInput.id = accountOwnerId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        // Use a record ID for the subject ID.
        feedItemInput.subjectId = accountId;
        try{
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), accountId, ConnectApi.FeedElementType.FeedItem, 'Account is successfully processed for '+requestType+'.');
        }catch(Exception e){}
    }
}