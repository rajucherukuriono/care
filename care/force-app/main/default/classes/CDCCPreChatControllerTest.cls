@IsTest
private without sharing class CDCCPreChatControllerTest {
    @IsTest
    public static void getCommunitySettingsTest() {
        User siteGuestUser = [SELECT Id FROM User WHERE Name = 'FAQ for Marketing Solutions Site Guest User'];
        System.runAs(siteGuestUser) {
            Test.startTest();
            CDCCPreChatController.CommunitySettings settings = CDCCPreChatController.getCommunitySettings();
            Test.stopTest();
            // not testing any values, because null are valid values
        }
    }

    @IsTest
    public static void createCaseTest() {
        Test.startTest();
        CDCCPreChatController.createCase('First Last', 'first.last@gearscrm.test', '(631) 760-8507', 'Trust & Safety', 'Help!', '007', 'c0d213b7-d221-4984-a4fe-efe322baf576','PREMIUM', 'Seeker', null, 'Home Page Case','en_GB');
        Test.stopTest();
        Case c = [
            SELECT SuppliedName, SuppliedEmail, SuppliedPhone, Origin, Article_Topic__c, Description, Web_External_Member_ID__c, Web_Member_UUID__c, Member_Account_Type__c, Member_Type__c, Article_Id__c, Subject
            FROM Case
            LIMIT 1
        ];
        System.assertEquals('First Last', c.SuppliedName);
        System.assertEquals('first.last@gearscrm.test', c.SuppliedEmail);
        System.assertEquals('(631) 760-8507', c.SuppliedPhone);
        System.assertEquals('Web', c.Origin);
        System.assertEquals('Trust & Safety', c.Article_Topic__c);
        System.assertEquals('Help!', c.Description);
        System.assertEquals('007', c.Web_External_Member_ID__c);
        System.assertEquals('c0d213b7-d221-4984-a4fe-efe322baf576', c.Web_Member_UUID__c);
        System.assertEquals('PREMIUM', c.Member_Account_Type__c);
        System.assertEquals('Seeker', c.Member_Type__c);
        System.assertEquals(null, c.Article_Id__c);
        System.assertEquals('Home Page Case', c.Subject);
    }

    @IsTest
    public static void getArticleTopicTest() {
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
        List<US_Knowledge__kav> articles = [
            SELECT Id, KnowledgeArticleId FROM US_Knowledge__kav WHERE Id = :article1.Id
        ];
        KbManagement.PublishingService.publishArticle(articles[0].KnowledgeArticleId, true);      
        Test.startTest();
        CDCCPreChatController.ArticleTopic topicInfo = CDCCPreChatController.getArticleTopic('article1', UserInfo.getLocale());
        Test.stopTest();
        System.assertEquals(String.valueOf(article1.Id), topicInfo.id);
        System.assertEquals(article1.Title, topicInfo.title);
        System.assertEquals('Using Your Account', topicInfo.topicName);
    }

    @IsTest
    public static void sendMemberInfoToODSTest() {
        Map<String, Object> responseMap = new Map<String, Object>{
            'batch' => new Map<String, Object>{
                String.valueOf(TestUtil.PremiumSeekerMemberId) + '@care.com' => new Map<String, Object>{
                    'memberId' => String.valueOf(TestUtil.PremiumSeekerMemberId),
                    'salesforceId' => null,
                    'email' => 'test@gearscrm.com',
                    'firstName' => 'Test',
                    'lastName' => 'GearsCRM',
                    'blacklisted' => false
                }
            }
        };
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse_USPlatform());
        MockHTTPResponse_USPlatform.responseMap = responseMap;
        Map<String, String> preChatCaseResponseMap = CDCCPreChatController.sendMemberInfoToODS(String.valueOf(TestUtil.PremiumSeekerMemberId), '','Seeker','en_US');
        Test.stopTest();
        System.assertNotEquals(null, preChatCaseResponseMap.get('AccountId'), 'AccountId Id should not be null');
    }
}