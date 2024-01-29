@isTest
public with sharing class KnowledgeArticleController_Test {

    public static ID createArticle(){
        ID knowledgeArticleId;
        Profile p = [SELECT Id from Profile WHERE Name='System Administrator'];
        User u = new User(alias = 'testalia', email='test@care.com',
                emailencodingkey='UTF-8',
                lastname='testLastName',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id,
                timezonesidkey='America/Los_Angeles',
                username='test@care.com.nextcaseunittest',
                //Platform__c = 'International',
                //Tier__c = '3',
                Language__c = 'Dutch; German; French; English; Finnish; Danish; Swedish',
                UserPermissionsKnowledgeUser = true
        );
        insert u;

        System.runAs(u){
            //  method to help create data
            US_Knowledge__kav knowledgeArticle = new US_Knowledge__kav(Title='Unit test',Body__c='Sample Body',URLName='sampleurl2');
            insert knowledgeArticle;

            US_Knowledge__kav obj1 = [SELECT Id, KnowledgeArticleId FROM US_Knowledge__kav WHERE Id =: knowledgeArticle.Id];

            US_Knowledge__DataCategorySelection dc = new US_Knowledge__DataCategorySelection();
            dc.parentId = knowledgeArticle.id;
            dc.DataCategoryGroupName = 'Topic';
            dc.DataCategoryName = 'Trust_Safety';
            insert dc;
            KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true); //PublishStatus = online

            knowledgeArticleId = knowledgeArticle.id;
        }

        return knowledgeArticleId;

    }

    @isTest static void testGetCaseType() {
        ID knowledgeArticleId = KnowledgeArticleController_Test.createArticle();
        String memberType = 'Seeker';

        Test.startTest();
        Topic_Map__mdt topicMap = KnowledgeArticleController.getTopicMap(knowledgeArticleId, memberType);
        String orgId = KnowledgeArticleController.getOrgId();
        Test.stopTest();

        System.assertNotEquals(null, topicMap.Case_Type__c, 'Returned Case Type should not be null');
        System.assertEquals('Trust & Safety', topicMap.Topic__c, 'Returned topic should have Trust & Safety');
        System.assertNotEquals(null, topicMap.Button_Id__c, 'Returned Button Id should not be null');
        System.assertEquals(UserInfo.getOrganizationId(), orgId, 'These values should have matched!');

    }

    @isTest static void testGetArticle() {
        ID knowledgeArticleId = KnowledgeArticleController_Test.createArticle();

        Test.startTest();
		Map<String, String> article = KnowledgeArticleController.getArticle(knowledgeArticleId);
        Test.stopTest();

        System.assertEquals('Unit test', article.get('Title'), 'Returned Title should have been Unit Test');
        System.assertEquals('Sample Body', article.get('Body__c'), 'Returned Body should have been Sample Body');
    }

}