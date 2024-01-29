@isTest
public with sharing class Test_helpCenterEntitlement {
    @isTest
    public static void EntitlementSuccess() {
        // Generic success request
        helpCenterEntitlement.data data = helpCenterEntitlement.getTestData();
        helpCenterEntitlement.Entitlement ent = helpCenterEntitlement.getHelpCenterEntitlement(null,null,'en_US', 'GraphQLResponse_NoErrors_OneNode', data,null);

        System.assertEquals(true, ent.canChatWithCSR, 'Chat Entitlement should have been true');

    }

    @isTest
    public static void EntitlementFailOnResponse() {
        // Pass error response from GraphQL library
        helpCenterEntitlement.data data = helpCenterEntitlement.getTestData();
        helpCenterEntitlement.Entitlement ent = helpCenterEntitlement.getHelpCenterEntitlement(null,null,'en_US','GraphQLResponse_OneError_OneNode',data,null);
    }

    @isTest
    public static void EntitlementFailCMD() {
        // passing null locale to cause code to fail to find CMD
        helpCenterEntitlement.data data = helpCenterEntitlement.getTestData();
        helpCenterEntitlement.Entitlement ent = helpCenterEntitlement.getHelpCenterEntitlement(null,null,null,'GraphQLResponse_OneError_OneNode',data,null);
    }

    public static String getResponseBody(String fileName) {
        // this is is a clone of GraphQLResponseTest.getResponseBody, which for some reason is private

        List<StaticResource> resources = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :fileName
            LIMIT 1
        ];
        if (resources.isEmpty()) {
            throw new QueryException(
                'Query Exception Error: ' + fileName
//                Label.NoTestJsonLoadedError.replace(CommonConstants.FIRST_FORMAT_PARAM, fileName)
            );
        }
        return resources.get(0).Body.toString();
    }

}