trigger CreateGDPRequestTrigger on Account (after Update)
{
    public static Map<id,AccountHistory> accountHistoryMap;
    public static Map<id,List<AccountHistory>> accIdAccountHistoryListMap;
    public static List<AccountHistory> deleteAccountHistoryList=new List<AccountHistory>();
    public static Map<id,accountFeed> accountFeedMap;
    public static Map<id,List<accountFeed>> accIdaccountFeedListMap;
    public static List<AccountFeed> deleteAccountFeedList=new List<AccountFeed>();
    public static List<CaseHistory> deleteCaseHistoryList=new List<CaseHistory>();
    public static Map<id,List<CaseFeed>> caseIdCaseFeedListMap=new Map <id,List<CaseFeed>>();
    public static Map<id,List<CaseHistory>> caseIdCaseHistoryListMap=new Map <id,List<CaseHistory>>();
    public static List<CaseFeed> deleteCaseFeedList=new List<CaseFeed>();
    public static List<Case> caseList=new List<Case>();
    Map<String,Account> gmAccMap=new Map<String,Account>();
    List<Account> rtbfAnonymizeAccList=new List<Account>();
    for(Account accObj:Trigger.new){
        if(accObj.Global_Member_id__c!=null)
            gmAccMap.put(accObj.Global_Member_id__c,accObj);
    }
    Map<id,Request_Data__c> gdprMap=new Map<id,Request_Data__c>([select id,account_id__c,Global_Member_id__c,Status__c from Request_Data__c where global_Member_id__c=:gmAccMap.keySet()]);
    Map<String,Request_Data__c> gmGdprMap=new Map<String,Request_Data__c>();
    for(Request_Data__c gdprObj:gdprMap.values()){
        gmGdprMap.put(gdprObj.Global_Member_id__c,gdprObj);
    }
    List<Request_Data__c> insertNewGdprList=new List<Request_Data__c>();
    List<Request_Data__c> updateNewGdprList=new List<Request_Data__c>();
    for(Account accObj:Trigger.new)
    {
        if(accObj.GDPR_Request__c=='RTBF Anonymize')
        {
            rtbfAnonymizeAccList.add(accObj);
        }
        // Should not consider the records =>  accObj.GDPR_Request__c=='RTBF Do Not Process'
        else if(accObj.GDPR_Request__c=='Retention' || accObj.GDPR_Request__c=='RTBF')
        {
            if(!gmGdprMap.containsKey(accObj.Global_Member_id__c))
            {
                Id acc18DigitId=(String.valueOf(accObj.id).length()==15?CareDotComUtil.convertId(String.valueOf(accObj.id)):accObj.id);
                Request_Data__c gdprObj=new Request_Data__c(account_id__c=acc18DigitId,Global_Member_id__c=accObj.Global_Member_id__c,Status__c='New',Request_Type__c=accObj.GDPR_Request__c);
                insertNewGdprList.add(gdprObj);
            }
        }
        else if(accObj.GDPR_Request__c=='RTBF Fix' || accObj.GDPR_Request__c=='RTBF Override')
        {
            if(gmGdprMap.containsKey(accObj.Global_Member_id__c))
            {
                Id acc18DigitId=(String.valueOf(accObj.id).length()==15?CareDotComUtil.convertId(String.valueOf(accObj.id)):accObj.id);
                Request_Data__c gdprObj=gmGdprMap.get(accObj.Global_Member_id__c);
                gdprObj.Request_Type__c=accObj.GDPR_Request__c;
                updateNewGdprList.add(gdprObj);
            }
        }
        else if(accObj.GDPR_Request__c=='RTBF Do Not Process')
        {
            if(gmGdprMap.containsKey(accObj.Global_Member_id__c))
            {
                Id acc18DigitId=(String.valueOf(accObj.id).length()==15?CareDotComUtil.convertId(String.valueOf(accObj.id)):accObj.id);
                Request_Data__c gdprObj=gmGdprMap.get(accObj.Global_Member_id__c);
                gdprObj.Request_Type__c=accObj.GDPR_Request__c;
                gdprObj.status__c=accObj.GDPR_Request__c;
                gdprObj.Response_Date__c=Datetime.now().date();  
                updateNewGdprList.add(gdprObj);
            }
        }
    }
    if(!insertNewGdprList.isEmpty() && AvoidRecursion.runOnce())
    {
        insert insertNewGdprList;
    }
    if(!updateNewGdprList.isEmpty() && AvoidRecursion.runOnce())
    {
        update updateNewGdprList;
    }
    if(!rtbfAnonymizeAccList.isEmpty())
    {
        caseList=[select id from Case where accountid=:rtbfAnonymizeAccList];  
        accountHistoryMap=new Map<id,AccountHistory>([SELECT ID,ACCOUNTID FROM AccountHistory WHERE accountId=:rtbfAnonymizeAccList]);
        accIdAccountHistoryListMap=new Map <id,List<AccountHistory>>();
        for(AccountHistory AccountHistoryObj:accountHistoryMap.values())
        {
            if(accIdAccountHistoryListMap.get(AccountHistoryObj.accountId)==null)
            {
                accIdAccountHistoryListMap.put(AccountHistoryObj.accountId,new List<AccountHistory>{AccountHistoryObj});
            }
            else
            {
                accIdAccountHistoryListMap.get(AccountHistoryObj.accountId).add(AccountHistoryObj);
            }
        }
        accountFeedMap=new Map<id,accountFeed>([SELECT ID,PARENTID FROM accountFeed WHERE parentId=:rtbfAnonymizeAccList]);
        accIdaccountFeedListMap=new Map <id,List<accountFeed>>();
        for(accountFeed accountFeedObj:accountFeedMap.values())
        {
            if(accIdaccountFeedListMap.get(accountFeedObj.parentId)==null)
            {
                accIdaccountFeedListMap.put(accountFeedObj.parentId,new List<accountFeed>{accountFeedObj});
            }
            else
            {
                accIdaccountFeedListMap.get(accountFeedObj.parentId).add(accountFeedObj);
            }
        }
        Map<id,CaseFeed> caseFeedMap=new Map<id,CaseFeed>([SELECT ID,parentId FROM caseFeed WHERE parentId=:caseList]);
        Map<id,CaseHistory> caseHistoryMap=new Map<id,CaseHistory>([SELECT ID,caseId FROM caseHistory WHERE CASEID=:caseList]);
      
        if(caseFeedMap.size()>0) {Database.delete(caseFeedMap.values(),false);Database.emptyRecycleBin(caseFeedMap.values());  }
        if(caseHistoryMap.size()>0) {Database.delete(caseHistoryMap.values(),false);Database.emptyRecycleBin(caseHistoryMap.values());  }
        if(accountHistoryMap.size()>0) {Database.delete(accountHistoryMap.values(),false);Database.emptyRecycleBin(accountHistoryMap.values());  }
        if(accountFeedMap.size()>0) {Database.delete(accountFeedMap.values(),false);Database.emptyRecycleBin(accountFeedMap.values());  }
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        for(Account accObj:rtbfAnonymizeAccList){
            postMessageToFeed(accObj.id,accObj.ownerId,accObj.Gdpr_Request__c,batchInputs);
        }
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
        //ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
        //batchInputs.add(batchInput);
        // postFeedElement(communityId, subjectId, feedElementType, text)
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), accountId, ConnectApi.FeedElementType.FeedItem, 'Account is successfully processed for '+requestType+'.');
    }
}