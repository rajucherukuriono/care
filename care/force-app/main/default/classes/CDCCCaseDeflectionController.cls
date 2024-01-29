public without sharing class CDCCCaseDeflectionController {
    public class Article {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String urlName { get; set; }
        public Article(String id, String title, String urlName) {
            this.id = id;
            this.title = title;
            this.urlName = urlName;
        }
    }

    @AuraEnabled
    public static List<Article> getArticles(String articleId, Integer numArticles, String language) {
        if (language == null ) language = 'en_US';

        try {
            List<Article> articles = new List<Article>();
            Set<Id> topicIds = getTopics(articleId);
            List<KnowledgeArticleVersion> kavs = getArticlesByTopicIds(articleId, topicIds, numArticles, language);
            for (KnowledgeArticleVersion kav : kavs) {
                articles.add(new Article(kav.Id, kav.Title, kav.UrlName));
            }
            return articles;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void createVotingRecord(String articleId, String memberId, String memberType, String isArticleHelpful){
        try {
            Article_Voting_Stat__c vote = new Article_Voting_Stat__c(
                Knowledge_Article__c = articleId,
                Care_ID__c = memberId,
                Member_Type__c = memberType,
                Did_you_get_the_help_you_needed__c = isArticleHelpful
            );
            insert vote;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Set<Id> getTopics(String articleId) {
        Set<Id> topicIds = new Set<Id>();
        if (String.isBlank(articleId)) {
            return topicIds;
        }
        Id networkId = Test.isRunningTest() ? [SELECT Id FROM Network WHERE UrlPathPrefix = 'families' LIMIT 1].Id : Network.getNetworkId();
        List<AggregateResult> results = [
            SELECT TopicId 
            FROM TopicAssignment 
            WHERE EntityId = :articleId AND EntityType = 'US_Knowledge__kav' AND NetworkId = :networkId
            GROUP BY TopicId
        ];
        for (AggregateResult result : results) {
            topicIds.add((Id)result.get('TopicId'));
        }
        return topicIds;
    }

    private static List<KnowledgeArticleVersion> getArticlesByTopicIds(String articleId,  Set<Id> topicIds, Integer numArticles, String language) {
        List<KnowledgeArticleVersion> kavs = new List<KnowledgeArticleVersion>();
        if (topicIds.size() == 0) {
            return kavs;
        }
        if (numArticles == null || numArticles <= 0) {
            numArticles = 1;
        }
        Id networkId = Test.isRunningTest() ? [SELECT Id FROM Network WHERE UrlPathPrefix = 'families' LIMIT 1].Id : Network.getNetworkId();
        List<TopicAssignment> topicAssignments = [
            SELECT EntityId
            FROM TopicAssignment
            WHERE TopicId IN :topicIds AND EntityType = 'US_Knowledge__kav' AND EntityId != :articleId AND NetworkId = :networkId
        ];
        if (topicAssignments.size() > 0) {
            Set<Id> articleIds = new Set<Id>();
            for (TopicAssignment ta : topicAssignments) {
                articleIds.add(ta.EntityId);
            }
            kavs = [
                SELECT Id, Title, UrlName
                FROM KnowledgeArticleVersion
                WHERE Id IN :articleIds AND IsLatestVersion = true AND PublishStatus = 'Online'  AND Language = :language
                ORDER BY ArticleTotalViewCount DESC
                LIMIT :numArticles
            ];
        }
        return kavs;
    }
}