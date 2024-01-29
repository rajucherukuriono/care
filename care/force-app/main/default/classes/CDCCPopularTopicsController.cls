public without sharing class CDCCPopularTopicsController {
    public class PopularTopic {
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String urlName { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static List<PopularTopic> getTopicInfo(List<String> recordIds) {
        if (recordIds == null || recordIds.size() == 0) {
            return null;
        }
        System.debug('Input: ' + recordIds);
        Set<Id> articleIds = new Set<Id>();
        Set<Id> topicIds = new Set<Id>();
        List<PopularTopic> topics = new List<PopularTopic>();
        for (String recordId : recordIds) {
            Id id = Id.valueOf(recordId);
            if (Schema.US_Knowledge__kav.SObjectType == id.getSObjectType()) {
                articleIds.add(id);
                PopularTopic topic = new PopularTopic();
                topic.type = 'article';
                topic.id = id;
                topics.add(topic);
            } else if (Schema.Topic.SObjectType == id.getSObjectType()) {
                topicIds.add(id);
                PopularTopic topic = new PopularTopic();
                topic.type = 'topic';
                topic.id = id;
                topics.add(topic);
            }
        }

        Map<Id, US_Knowledge__kav> articleMap;
        if (articleIds.size() > 0) {
            articleMap = new Map<Id, US_Knowledge__kav>([
            SELECT Id, Title, UrlName
                FROM US_Knowledge__kav
                WHERE Id IN :articleIds
            ]);
        }

        Map<Id, Topic> topicMap;
        if (topicIds.size() > 0) {
            topicMap = new Map<Id, Topic>([
                SELECT Id, Name
                FROM Topic
                WHERE Id IN :topicIds
            ]);
        }

        for (PopularTopic topic : topics) {
            if (topic.type == 'article') {
                US_Knowledge__kav article = articleMap.get(topic.id);
                if (article != null) {
                    topic.title = article.Title;
                    topic.urlName = article.UrlName;
                }
            } else if (topic.type == 'topic') {
                Topic t = topicMap.get(topic.id);
                if (t != null) {
                    topic.title = t.Name;
                }
            }
        }

        return topics;
    }
}