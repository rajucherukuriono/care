public with sharing class TopicResultsController {

    @AuraEnabled(cacheable=true)
    public static List<US_Knowledge__kav> GetArticlesByTopic(String topicId, integer queryLimit, integer queryOffset, String language) {
    
        TopicAssignment[] tas = [SELECT EntityId FROM TopicAssignment WHERE TopicId = :topicId LIMIT 1000];  // Guest users can only query 1k tas
        List<Id> taIds = new List<Id>();
        for (TopicAssignment ta : tas) taIds.add(ta.EntityId);

        return [SELECT Id, Title, URLName, (SELECT Id, TopicId, Topic.Name FROM TopicAssignments) FROM US_Knowledge__kav 
            WHERE id IN :taIds AND Language = :language AND PublishStatus = 'Online' LIMIT :queryLimit OFFSET :queryOffset
            ];
    }

}