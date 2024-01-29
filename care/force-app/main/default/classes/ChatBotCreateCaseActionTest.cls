@IsTest
public class ChatBotCreateCaseActionTest {
	@IsTest
    public static void testActionWithYes(){
        Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                Web_External_Member_ID__c = 'testMemberId',
                Member_Account_Type__c = 'Seeker',
                Member_Type__c = 'testMemberType',
                Article_ID__c = '',
                Subject = 'testSubject',
                Origin = 'Web'
            );
            insert c;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.CaseId = c.Id;
        lct.LiveChatVisitorId = lcv.Id;
        insert lct;
        
        List<ChatBotCreateCaseAction.Requests> requests = new List<ChatBotCreateCaseAction.Requests>();
        ChatBotCreateCaseAction.Requests req = new ChatBotCreateCaseAction.Requests();
        requests.add(req);
        
        req.routeCase = 'Yes';
        req.transcriptId = lct.Id;
        List<String> results = ChatBotCreateCaseAction.execute(requests);
        
        Case updatedCase = [SELECT Id, Chat_Case__c FROM Case WHERE Id = :c.Id ];
        system.assertEquals(updatedCase.Chat_Case__c,'No');
    }
    
    @IsTest
    public static void testActionWithNo(){
        Case c = new Case(
                SuppliedName = 'testName',
                SuppliedEmail = 'testEmail@testEmail.com',
                Article_Topic__c = 'Using your account',
                Description = 'testDescription',
                Web_External_Member_ID__c = 'testMemberId',
                Member_Account_Type__c = 'Seeker',
                Member_Type__c = 'testMemberType',
                Article_ID__c = '',
                Subject = 'testSubject',
                Origin = 'Web'
            );
            insert c;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.CaseId = c.Id;
        lct.LiveChatVisitorId = lcv.Id;
        insert lct;
        
        List<ChatBotCreateCaseAction.Requests> requests = new List<ChatBotCreateCaseAction.Requests>();
        ChatBotCreateCaseAction.Requests req = new ChatBotCreateCaseAction.Requests();
        requests.add(req);
        
        req.routeCase = 'No';
        req.transcriptId = lct.Id;
        List<String> results = ChatBotCreateCaseAction.execute(requests);
        
        Case updatedCase = [SELECT Id, IsClosed, Status FROM Case WHERE Id = :c.Id ];
        system.assertEquals(updatedCase.IsClosed,true);
        system.assertEquals(updatedCase.Status,'Auto-Closed');
    }
}