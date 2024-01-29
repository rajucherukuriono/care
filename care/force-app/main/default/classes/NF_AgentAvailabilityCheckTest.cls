/**
 * @description       : Check the agent availability based on chat button and deployment name
 * @author            : Abbas Jafry (NeuraFlash LLC)
 * @group             :
 * @last modified on  : 08-16-2023
 * @last modified by  : Abbas Jafry (NeuraFlash LLC)
 * **/
@IsTest
private class NF_AgentAvailabilityCheckTest {
    @isTest
    static void testAgentAvailabilityCheck() {
        List<LiveChatDeployment> deploymentList = [SELECT Id FROM LiveChatDeployment];
        List<LiveChatButton> chatButtonIdList = [SELECT Id FROM LiveChatButton];
        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockLiveAgentResponse());

        NF_AgentAvailabilityCheck.Input input = new NF_AgentAvailabilityCheck.Input();

        input.sChatButtonName = 'Help Center Chat Availability Check';
        input.sChatDeploymentName = 'Chat Setup Flow';
        List<NF_AgentAvailabilityCheck.Input> inputList = new List<NF_AgentAvailabilityCheck.Input>{ input };

        System.assert(NF_AgentAvailabilityCheck.checkAgentAvailability(inputList) != null, 'should not be nulls');
        Test.stopTest();
    }

    public class MockLiveAgentResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{"results":{"type":"array","description":"List of ids and their availability",' +
                    '"items":{"name":"result","type":"object","properties":' +
                    '{"isAvailable":{"type":"boolean","description":"Whether or not the entity is available for chat",' +
                    '"required":true,"version":29.0}}},"required":true}}'
            );
            res.setStatusCode(200);
            return res;
        }
    }
}