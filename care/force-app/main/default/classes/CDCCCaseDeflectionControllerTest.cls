@IsTest
private without sharing class CDCCCaseDeflectionControllerTest {
    @TestSetup
    private static void setup() {
        US_Knowledge__kav article1 = new US_Knowledge__kav(
            Title = 'Article1',
            UrlName = 'article1'
        );
        US_Knowledge__kav article2 = new US_Knowledge__kav(
            Title = 'Article2',
            UrlName = 'article2'
        );
        insert new List<US_Knowledge__kav>{article1, article2};

        Id networkId = [SELECT Id FROM Network WHERE UrlPathPrefix = 'families' LIMIT 1].Id;

        Topic topic1 = new Topic(
            Name = 'Topic1',
            NetworkId = networkId
        );
        insert topic1;

        TopicAssignment topicAssignment1 = new TopicAssignment(
            TopicId = topic1.Id,
            EntityId = article1.Id,
            NetworkId = networkId
        );
        TopicAssignment topicAssignment2 = new TopicAssignment(
            TopicId = topic1.Id,
            EntityId = article2.Id,
            NetworkId = networkId
        );
        insert new List<TopicAssignment>{topicAssignment1, topicAssignment2};

        Set<Id> articleIds = new Set<Id>{article1.Id, article2.Id};
        Map<Id, US_Knowledge__kav> articlesMap = new Map<id, US_Knowledge__kav>([
            SELECT Id, KnowledgeArticleId FROM US_Knowledge__kav WHERE Id IN :articleIds
        ]);

        KbManagement.PublishingService.publishArticle(articlesMap.get(article1.Id).KnowledgeArticleId, true);
        KbManagement.PublishingService.publishArticle(articlesMap.get(article2.Id).KnowledgeArticleId, true);
    }

    @IsTest
    private static void getArticlesTest() {
        Id articleId = [SELECT Id FROM KnowledgeArticleVersion WHERE UrlName = 'article1'].Id;
        Test.startTest();
        List<CDCCCaseDeflectionController.Article> articles = CDCCCaseDeflectionController.getArticles(articleId, 5, UserInfo.getLocale());
        Test.stopTest();
        System.assertEquals(1, articles.size());
        System.assert(String.isNotBlank(articles[0].id));
        System.assertEquals('Article2', articles[0].title);
        System.assertEquals('article2', articles[0].urlName);
    }

    @IsTest
    private static void createVotingRecordTest() {
        Id articleId = [SELECT Id FROM KnowledgeArticleVersion WHERE UrlName = 'article1'].Id;
        Test.startTest();
        CDCCCaseDeflectionController.createVotingRecord(articleId, '007', 'PREMIUM', 'Yes');
        Test.stopTest();
        Article_Voting_Stat__c vote = [
            SELECT Knowledge_Article__c, Care_ID__c, Member_Type__c, Did_you_get_the_help_you_needed__c
            FROM Article_Voting_Stat__c
            LIMIT 1
        ];
        System.assertEquals(articleId, vote.Knowledge_Article__c);
        System.assertEquals('007', vote.Care_ID__c);
        System.assertEquals('PREMIUM', vote.Member_Type__c);
        System.assertEquals('Yes', vote.Did_you_get_the_help_you_needed__c);
    }
}