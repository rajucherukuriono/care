@IsTest
private without sharing class CDCCPopularTopicsControllerTest {
    @TestSetup
    private static void setup() {
        US_Knowledge__kav article1 = new US_Knowledge__kav(
            Title = 'Article1',
            UrlName = 'article1'
        );
        insert article1;

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
        insert topicAssignment1;

        article1 = [SELECT Id, KnowledgeArticleId FROM US_Knowledge__kav WHERE Id = :article1.Id];
        KbManagement.PublishingService.publishArticle(article1.KnowledgeArticleId, true);
    }

    @IsTest
    private static void getTopicInfoTest() {
        KnowledgeArticleVersion kav = [SELECT Id, Title, UrlName FROM KnowledgeArticleVersion LIMIT 1];
        Topic t = [SELECT Id, Name FROM Topic LIMIT 1];
        
        Test.startTest();
        List<CDCCPopularTopicsController.PopularTopic> pts = CDCCPopularTopicsController.getTopicInfo(new List<String>{kav.Id, t.Id});
        Test.stopTest();

        System.assertEquals('article', pts[0].type);
        System.assertEquals(kav.Id, pts[0].id);
        System.assertEquals(kav.Title, pts[0].title);
        System.assertEquals(kav.UrlName, pts[0].urlName);
        System.assertEquals('topic', pts[1].type);
        System.assertEquals(t.Id, pts[1].id);
        System.assertEquals(t.Name, pts[1].title);
        System.assertEquals(null, pts[1].urlName);        
    }
}