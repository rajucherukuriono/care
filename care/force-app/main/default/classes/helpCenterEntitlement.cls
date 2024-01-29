public with sharing class helpCenterEntitlement {
    public static String ChatEntitlementType = 'SUPPORT_CHAT_ALL';
    public static String EntitlementEnabledState = 'ENABLED';

    // This class that defines the object that is returned to LWC
    public class Entitlement {
        @AuraEnabled public Boolean canChatWithCSR { get; set; }
        @AuraEnabled public String errors { get; set; }
    }

    // This class defines the GraphQL client input
    public class EntitlementInput {
        public String memberId { get; set; }
        public String types { get; set; }
        public String flow { get; set; }
    }

    // The following classes define the structure of the GraphQL response
    public class data {
        public listEntitlements listEntitlements { get; set; }
    }

    public class listEntitlements {
        public String seekerId { get; set; }
        public List<entitlements> entitlements { get; set; }
    }

    public class entitlements {
        public String type { get; set; }
        public String state { get; set; }
    }
    
    @AuraEnabled(cacheable=true)
    public static Entitlement getHelpCenterEntitlement(String externalMemberId, String memberUUID, String locale) {
        return getHelpCenterEntitlement(externalMemberId, memberUUID, locale, '', null, null);
    }
    
    @AuraEnabled(cacheable=true)
    public static Entitlement getHelpCenterEntitlement(String externalMemberId, String memberUUID, String locale, String chatEntitlementFlow) {
        return getHelpCenterEntitlement(externalMemberId, memberUUID, locale, '', null, chatEntitlementFlow);
    }

    public static Entitlement getHelpCenterEntitlement(String externalMemberId, String memberUUID, String locale, String testUseCase, data testData, String chatEntitlementFlow) {
        Entitlement ent = new Entitlement();

        Sterling_Country_Setting__mdt cmd = CountryLocaleMapHelper.getSettingByLocale(locale);
        if (cmd == null){ // Handle missing CMD error
            ent.errors = 'Unable to get CMD (Locale: ' + locale + ')';
            return ent;
        }

        //Query using string.
        String query = 
            'query ListEntitlements($input: ListEntitlementsInput!) {' + 
            '    listEntitlements(input: $input) {' + 
            '    ... on ListEntitlementsSuccess {' + 
            '    memberId' + 
            '    entitlements {' + 
            '    type' + 
            '    state' + 
            '    }' + 
            '    }' + 
            '    }' + 
            '    }';

        EntitlementInput eInput = new EntitlementInput();
        eInput.memberId = memberUUID; // only UUID is supported
        eInput.types = ChatEntitlementType;
        if (chatEntitlementFlow != '') eInput.flow = chatEntitlementFlow; // Endpoint doesn't like empty strings

        GraphQLRequest request = new GraphQLRequest(query).withVariable('input', eInput);

        GraphQLHttpClient client = GraphQLHttpClientHelper();
        GraphQLResponse response = (!Test.isRunningTest()) ? client.send(request) : GraphQLResponse.parse(Test_helpCenterEntitlement.getResponseBody(TestUseCase));
        
        if (response.hasErrors()) {
            ent.errors = 'GraphQL Error: ' + response.getErrors().get(0).message;
            
        } else {               
            data data = (!Test.isRunningTest()) ? (data) response.getDataAs(data.class) : testData;
            if (data != null && data.listEntitlements != null){
                for (entitlements entitlement : data.listEntitlements.entitlements){
                    if (entitlement.type == ChatEntitlementType){
                        ent.canChatWithCSR = (entitlement.state == EntitlementEnabledState) ? true : false;
                    }
                }
            }
        }
        return ent;
    }

    public static data getTestData() {
        // This method generates test data for use by unit tests
        entitlements entitlements = new entitlements();
        entitlements.type = ChatEntitlementType;
        entitlements.state = EntitlementEnabledState;
        data data = new data();
        data.listEntitlements = new listEntitlements();
        data.listEntitlements.seekerId = 'c0d213b7-d221-4984-a4fe-efe322baf576';
        data.listEntitlements.entitlements = new List<entitlements>{entitlements};
        return data;
    }

    public static GraphQLHttpClient GraphQLHttpClientHelper(){
        String URLRoot = ''; 
        String URLPath = '/api/graphql'; 
        if (CareDotComUtil.runningInASandbox()){ // setup connection when connecting to stage environments
            URLRoot = 'callout:US_Platform_Stage';
        } else {
            URLRoot = 'callout:US_Platform_Production';
        }
        return new GraphQLHttpClient(URLRoot + URLPath);
    }

}