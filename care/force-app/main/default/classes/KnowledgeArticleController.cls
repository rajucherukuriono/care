public with sharing class KnowledgeArticleController {

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getArticle(ID knowledgeArticleId){
        // Given an article id, it returns the content of the article, it's topic data category, topic id & others
        String articleTopic = '';
        Map<String, String> articleMap = new Map<String, String>();
        List<US_Knowledge__DataCategorySelection> dcs = new List<US_Knowledge__DataCategorySelection>();

        US_Knowledge__kav article = [SELECT Id, Title, Body__c, LastPublishedDate, MasterVersionId, isMasterLanguage, (SELECT Id,DataCategoryGroupName, DataCategoryName FROM DataCategorySelections) FROM US_Knowledge__kav WHERE id = :knowledgeArticleId UPDATE VIEWSTAT];
        articleMap.put('Id',article.Id);
        articleMap.put('Title',article.Title);
        articleMap.put('Body__c',article.Body__c);
        articleMap.put('LastPublishedDate',article.LastPublishedDate.format('MM/dd/yyyy'));
        dcs = Article.DataCategorySelections;

        // Data Categories are only stored in the master version of ther article
        // So if this article is not the master version, I query for the data categories in the master version
        if (!article.isMasterLanguage){
            US_Knowledge__kav masterArticle = [SELECT Id, (SELECT Id,DataCategoryGroupName, DataCategoryName FROM DataCategorySelections) FROM US_Knowledge__kav WHERE id = :article.MasterVersionId ];
            dcs = masterArticle.DataCategorySelections;
        }

        for (US_Knowledge__DataCategorySelection dc : dcs){
            if (dc.DataCategoryGroupName == 'Topic'){
                articleTopic = dc.DataCategoryName;
            }
        }
        articleMap.put('TopicDeveloperName',articleTopic);

        if (articleTopic != ''){
            for (Topic topic : [SELECT Id, Name, ManagedTopicType FROM Topic WHERE networkid = :Network.getNetworkId()]){
                if (convertLabelToApiSafeName(topic.Name) == articleMap.get('TopicDeveloperName')){
                    articleMap.put('TopicId',topic.Id);
                    articleMap.put('TopicName',topic.Name);
                    articleMap.put('TopicURLSafeName',convertLabelToURLSafeName(topic.Name));
                    break;
                }
            }
        }

        Community_Setting__mdt cmd = CDCCPreChatController.getCommunitySettingsForInternalUse();
        articleMap.put('CommunityName', cmd.DeveloperName);
        articleMap.put('CommunityLabel', cmd.MasterLabel);

//        System.debug('articleMap on getarticle: ' + articleMap);
        return articleMap;
    }


    @AuraEnabled(cacheable=true)
    public static String getOrgId() {
        return UserInfo.getOrganizationId();
    }

    public static string convertLabelToApiSafeName(string label){
        String apiSafeName = '';
        apiSafeName = label.remove('&').remove('\'').normalizeSpace().replace('-','_').replace(' ', '_');
        return apiSafeName;
    }

    public static string convertLabelToURLSafeName(string label){
        String urlSafeName = '';
        urlSafeName = label.remove('&').remove('\'').normalizeSpace().replace(' ', '-').toLowerCase();
        return urlSafeName;
    }

    @AuraEnabled(cacheable=true)
    public static Topic_Map__mdt getTopicMap(ID knowledgeArticleId, string memberType) {
        Topic_Map__mdt topicMapToBeReturned;

        // Get Member Type from community
        // Query Article Categories to get Topic
        String articleTopic = '';
        for (US_Knowledge__kav article : [SELECT Id, Title, (SELECT Id,DataCategoryGroupName, DataCategoryName FROM DataCategorySelections) FROM US_Knowledge__kav WHERE id = :knowledgeArticleId]){
            for (US_Knowledge__DataCategorySelection dc : Article.DataCategorySelections){
                if (dc.DataCategoryGroupName == 'Topic'){
                    articleTopic = dc.DataCategoryName;
                }
            }
        }

        // Query for Topic Map (Metadata) for record that matches Topic & Member Type
        for (Topic_Map__mdt topicMap : [SELECT id,Case_Type__c,Topic__c,Button_Id__c FROM Topic_Map__mdt WHERE Member_Type__c = :memberType]){
            if (convertLabelToApiSafeName(topicMap.Topic__c) == articleTopic){
                topicMapToBeReturned = topicMap;
                break;
            }
        }

        return topicMapToBeReturned;
    }

}