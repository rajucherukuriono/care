/**
 * @description       : Check the agent availability based on chat button and deployment name
 * @author            : Abbas Jafry (NeuraFlash LLC)
 * @group             :
 * @last modified on  : 08-16-2023
 * @last modified by  : Abbas Jafry (NeuraFlash LLC)
 * **/
public with sharing class NF_AgentAvailabilityCheck {
    public class Input {
        @InvocableVariable(required=false)
        public String sChatButtonName;

        @InvocableVariable(required=false)
        public String sChatDeploymentName;
    }
    public class Output {
        @InvocableVariable(required=true)
        public Boolean bAgentAvailability;
    }

    /*
    * @description invocable method called from bot
    * @param params list of input params
    * @return output containing agent availability
    */
    @InvocableMethod(label='Neuraflash - Check Agent Availability')
    public static List<Output> checkAgentAvailability(List<Input> params) {
        Output output = new Output();
        output.bAgentAvailability = false;

        if(params.isEmpty() || (params.size() > 0 && String.isEmpty(params[0].sChatButtonName))) {
            params[0].sChatButtonName = System.label.NF_Availability_Check_Button;
        }

        if(params.isEmpty() || (params.size() > 0 && String.isEmpty(params[0].sChatDeploymentName))) {
            params[0].sChatButtonName = System.label.NF_Availability_Check_Deployment;
        }

        // output.bAgentAvailability = getButtonAvailability(params[0].sChatButtonName, params[0].sChatDeploymentName);
        output.bAgentAvailability = getButtonAvailability(System.label.NF_Availability_Check_Button, System.label.NF_Availability_Check_Deployment);
        return new List<Output>{ output };
    }

    /*******************************************************************************************************
    * @description Returns boolean indicating agent availability
    * @param botTransferbutton the name of the button to check for availability
    * @param botDeployment the name of the chat deployment to check for availability
    * @return boolean value indicating agent availability
    */
    public static boolean getButtonAvailability(String botTransferbutton, String botDeployment) {
        Boolean isAvailable = false;
        try {
            List<LiveChatButton> chatButtonIdList = [
                SELECT Id
                FROM LiveChatButton
                WHERE MasterLabel = :botTransferbutton
                LIMIT 1
            ];

            List<LiveChatDeployment> deploymentList = [
                SELECT Id
                FROM LiveChatDeployment
                WHERE MasterLabel = :botDeployment
                LIMIT 1
            ];
            String botTransferbuttonId = chatButtonIdList[0].Id;
            botTransferbuttonId = botTransferbuttonId.substring(0, 15);
            String botDeploymentId = deploymentList[0].Id;
            botDeploymentId = botDeploymentId.substring(0, 15);
            String botOrgId = UserInfo.getOrganizationId().substring(0, 15);
            botOrgId = botOrgId.substring(0, 15);

            //callout to live chat rest api to check button availability
            //https://developer.salesforce.com/docs/atlas.en-us.live_agent_rest.meta/live_agent_rest/live_agent_rest_Availability.htm
            String sPath =
                'callout:Live_Chat_Agent_Availability/chat/rest/Visitor/Availability?Availability.ids=' +
                botTransferbuttonId +
                '&deployment_id=' +
                botDeploymentId +
                '&org_id=' +
                botOrgId;

            HttpRequest request = new HttpRequest();
            request.setEndpoint(sPath);
            request.setMethod('GET');
            request.setHeader('X-LIVEAGENT-API-VERSION', '55');

            Http http = new Http();
            HttpResponse response = http.send(request);

            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() == 200) {
                JSONParser parser = JSON.createParser(response.getBody());
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'isAvailable')) {
                        // Get the value.
                        parser.nextToken();
                        isAvailable = parser.getBooleanValue() != null ? parser.getBooleanValue() : false;
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e);
        }

        return isAvailable;
    }
}