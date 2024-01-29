@isTest
public with sharing class TopicResultsController_Test {

    public static Topic createTopic(Id networkId){
        Topic topic = new Topic(
            Name = 'Topic1',
            NetworkId = networkId
        );
        return topic;
    }

    public static TopicAssignment createTopicAssignment(Topic topic, Id articleId, Id networkId){
        TopicAssignment ta = new TopicAssignment(
            TopicId = topic.Id,
            EntityId = articleId,
            NetworkId = networkId
        );
        return ta;
    }


    @isTest static void testGetArticleByTopic() {
        ID knowledgeArticleId = KnowledgeArticleController_Test.createArticle();

        Id networkId = CDCCPreChatController.getNetworkId();

        Topic topic = createTopic(networkId);
        insert topic;

        TopicAssignment ta = createTopicAssignment(topic,knowledgeArticleId,networkId);
        insert ta;

        Test.startTest();
		LIST<US_Knowledge__kav> articles = TopicResultsController.GetArticlesByTopic(topic.id,10,0,'en_US');
        Test.stopTest();

        System.assertEquals(1, articles.size(), 'Method must return 1 article');

        for (US_Knowledge__kav article : articles){
            System.assertEquals('Unit test', article.Title, 'Returned Title should have been Unit Test');
            for (TopicAssignment rta : article.TopicAssignments){
                System.assertEquals(rta.id, ta.id, 'Returned TopicAssignment should match previous created one');
            }
        }

        // check tas
    }
}