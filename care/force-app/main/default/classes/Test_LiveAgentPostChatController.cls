@isTest
public class Test_LiveAgentPostChatController {

    @isTest static void TestWithValidChatDetails(){
		String ChatDetails = '{"prechatDetails":[],"geoLocation":{"organization":"Lightower Fiber Networks","region":"MA","city":"Boston","countryName":"United States","latitude":42.3496,"countryCode":"US","longitude":-71.0746},"visitorId":"a30abf90-c0e0-463b-86ba-0a5c4bc565f4","customDetails":[{"value":"jane@doe.com","entityMaps":[],"displayToAgent":true,"label":"Contact E-mail","transcriptFields":[]},{"value":"Jane","entityMaps":[],"displayToAgent":true,"label":"First Name","transcriptFields":[]},{"value":"Doe","entityMaps":[],"displayToAgent":true,"label":"Last Name","transcriptFields":[]},{"value":"123456","entityMaps":[],"displayToAgent":true,"label":"Member Id","transcriptFields":[]},{"value":"User Initiated Chat from Care.com","entityMaps":[],"displayToAgent":false,"label":"Case Subject","transcriptFields":[]},{"value":"New","entityMaps":[],"displayToAgent":false,"label":"Case Status","transcriptFields":[]},{"value":"01270000000Dq7EAAS","entityMaps":[],"displayToAgent":false,"label":"Record Type","transcriptFields":[]},{"value":"Chat","entityMaps":[],"displayToAgent":false,"label":"Case Origin","transcriptFields":[]}],"agent":{"userId":"00570000002KXRN","agentName":"Jessica F","transfer":0}}';  
        PageReference myVfPage = Page.LiveAgentPostChat;
        Test.setCurrentPage(myVfPage);
        
        ApexPages.currentPage().getParameters().put('chatDetails',ChatDetails);
        ApexPages.currentPage().getParameters().put('transcript','Sample transcript here');
        
        LiveAgentPostChatController con = new LiveAgentPostChatController();
        
        con.save(); // executed for improved coverage, but doesn't really do anything
        
        String ChatDetailsPostController = ApexPages.currentPage().getParameters().get('chatDetails');
		System.assertEquals(ChatDetails, ChatDetailsPostController, 'Chat details are not the same');
        
		System.assertEquals('Jessica F', con.AgentName, 'Agent name should be Jeissica F');
    }


    @isTest static void TestWithInvalidChatDetails(){
		String ChatDetails = '{"prechatDetails":[],"geoLocation":{"organization":"Lightower Fiber Networks","region":"MA","city":"Boston","countryName":"United States","latitude":42.3496,"countryCode":"US","longitude":-71.0746},"visitorId":"a30abf90-c0e0-463b-86ba-0a5c4bc565f4","customDetails":[{"value":"jane@doe.com","entityMaps":[],"displayToAgent":true,"label":"Contact E-mail","transcriptFields":[]},{"value":"Jane","entityMaps":[],"displayToAgent":true,"label":"First Name","transcriptFields":[]},{"value":"Doe","entityMaps":[],"displayToAgent":true,"label":"Last Name","transcriptFields":[]},{"value":"123456","entityMaps":[],"displayToAgent":true,"label":"Member Id","transcriptFields":[]},{"value":"User Initiated Chat from Care.com","entityMaps":[],"displayToAgent":false,"label":"Case Subject","transcriptFields":[]},{"value":"New","entityMaps":[],"displayToAgent":false,"label":"Case Status","transcriptFields":[]},{"value":"01270000000Dq7EAAS","entityMaps":[],"displayToAgent":false,"label":"Record Type","transcriptFields":[]},{"value":"Chat","entityMaps":[],"displayToAgent":false,"label":"Case Origin","transcriptFields":[]}]}';          PageReference myVfPage = Page.LiveAgentPostChat;
        Test.setCurrentPage(myVfPage);
        
        ApexPages.currentPage().getParameters().put('chatDetails',ChatDetails);
        ApexPages.currentPage().getParameters().put('transcript','Sample transcript here');
        
        LiveAgentPostChatController con = new LiveAgentPostChatController();
        
        String ChatDetailsPostController = ApexPages.currentPage().getParameters().get('chatDetails');
		System.assertEquals(ChatDetails, ChatDetailsPostController, 'Chat details are not the same');
        
		System.assertEquals('Agent', con.AgentName, 'Agent name should be Agent');
    }
}