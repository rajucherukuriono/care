/***************************************************************************************************
   Name        : BUCAccountRestService_Test
   Created By  : John Wrightsman, Revelant Technologies
   Email       : john.wrightsman@revtec360.com
   Created Date: 04/24/2022
   Description : Unit test class for BUCAccountRestService

   Changes     :
******************************************************************************************************/
@isTest
private class BUCAccountRestService_Test {

    @testSetup static void setup() {
        Account accountRecord = new Account(Name = 'test');
        insert accountRecord;

        insert new Business_Representative__c(
            Account__c = accountRecord.Id,
            Galore_uuid__c = 'busrepuuid',
            First_Name__c = 'first_name',
            Last_Name__c = 'last_name',
            Birthdate__c = Date.valueOf('2000-10-10'),
            State__c = 'CA',
            Zip_Postal_Code__c = '90210'
        );

        insert new Contact(
            AccountId = accountRecord.Id,
            Galore_uuid__c = 'contactuuid',
            FirstName = 'test',
            LastName = 'test',
            Email = 'test@example.com',
            Phone = '800-588-2300',
            BUC_Contact_Type__c = 'test'
        );
    }

    @isTest static void postAndPatchAccount_successful() {
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];

        RestRequest req = new RestRequest();
        // req.requestUri = '/' + accountRecord.Galore_Business_Id__c;
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Set request values
        BUCAccountRestService.AccountRequest accountReq = new BUCAccountRestService.AccountRequest();
        accountReq.uuid = 'test_uuid';
        accountReq.parent_account_id = accountRecord.Id;
        // accountReq.opportunity_service_area_id = null;
        accountReq.business = new BUCAccountRestService.BusinessObject();
        accountReq.business.name = 'New BUC Account';
        BUCAccountRestService.BusinessRepresentativeObject busRepObj = new BUCAccountRestService.BusinessRepresentativeObject();
        busRepObj.uuid = 'bus_rep_uuid';
        busRepObj.first_name = 'test';
        busRepObj.last_name = 'test';
        busRepObj.dob = '2000-10-10';
        busRepObj.state = 'Indiana';
        busRepObj.zip = '46256';
        accountReq.utilization = 1.0;
        accountReq.phone = '8005551234';
        accountReq.buc_status = null;
        accountReq.business.business_representatives = new List<BUCAccountRestService.BusinessRepresentativeObject>{ busRepObj };
        accountReq.address = new BUCAccountRestService.AddressObject();
        accountReq.address.line1 = '123 any street';
        accountReq.address.line2 = 'apt z';
        accountReq.address.city = 'Indianapolis';
        accountReq.address.state = 'Indiana';
        accountReq.address.postal_code = '46250';
        BUCAccountRestService.ContactObject contactObject = new BUCAccountRestService.ContactObject();
        contactObject.uuid = 'contact_uuid';
        contactObject.first_name = 'test';
        contactObject.last_name = 'test';
        contactObject.email = 'test@example.com';
        contactObject.phone = '8005559292';
        contactObject.type = 'test';
        accountReq.contacts = new List<BUCAccountRestService.ContactObject>{ contactObject };
        BUCAccountRestService.OfferingObject offeringObject = new BUCAccountRestService.OfferingObject();
        offeringObject.uuid = 'offering_uuid';
        offeringObject.active = true;
        offeringObject.capacity = 1;
        offeringObject.min_months = 1;
        offeringObject.max_months = 1;
        offeringObject.service = 'unknown';
        offeringObject.vertical = 'senior_care';
        offeringObject.care_type = 'child_care_infant';
        offeringObject.hourly_price = '10.00';
        offeringObject.daily_price = '80.00';
        accountReq.offerings = new List<BUCAccountRestService.OfferingObject>{ offeringObject };
        BUCAccountRestService.AddressObject address = new BUCAccountRestService.AddressObject();
        address.line1 = '123 any street';
        address.line2 = 'apt z';
        address.city = 'Indianapolis';
        address.state = 'Indiana';
        address.postal_code = '46250';
        accountReq.license = new BUCAccountRestService.LicenseObject();
        accountReq.license.address = address;
        accountReq.license.uuid = 'test_license_uuid';
        accountReq.license.status = null;
        accountReq.license.license_number = 'test';
        accountReq.license.business_entity_name = 'test';
        accountReq.license.edit_license_url = 'http://www.example.com/123';
        accountReq.insurance = new BUCAccountRestService.InsuranceObject();
        accountReq.insurance.uuid = 'insurance_uuid';
        accountReq.insurance.url = 'http://www.example.com/';
        accountReq.insurance.uploaded = 1650855325;
        accountReq.insurance.expires = 1650855325;
        accountReq.insurance.status = null;

        BUCAccountRestService.postAccount(accountReq);

        String responseBodyText = RestContext.response.responseBody == null ? '' : RestContext.response.responseBody.toString();

        // Should be successful
        System.assertEquals('', responseBodyText, 'Expected empty response body but received:' + responseBodyText);
        System.assertEquals(200, RestContext.response.statusCode);

        // Should hit duplicate logic
        responseBodyText = RestContext.response.responseBody == null ? '' : RestContext.response.responseBody.toString();
        System.assertEquals('', responseBodyText, 'Expected empty response body but received:' + responseBodyText);
        System.assertEquals(200, RestContext.response.statusCode);

        Account bucAccountRecord = [SELECT Id FROM Account WHERE Name = 'New BUC Account'];
        System.assertNotEquals(null, bucAccountRecord);

        // test Patch account
        req = new RestRequest();
        req.requestUri = '/' + bucAccountRecord.Id;
        req.httpMethod = 'PATCH';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;

        res = new RestResponse();
        RestContext.response = res;

        BUCAccountRestService.patchAccount(accountReq);

        responseBodyText = RestContext.response.responseBody == null ? '' : RestContext.response.responseBody.toString();

        // Should be successful
        System.assertEquals('', responseBodyText, 'Expected empty response body but received:' + responseBodyText);
        System.assertEquals(200, RestContext.response.statusCode); 
    }

    // @isTest static void postAccount_invalid_galore_business_id() {
    //     String galoreBusId = 'invalid galore business id';

    //     RestRequest req = new RestRequest();
    //     req.requestUri = '/' + galoreBusId;
    //     req.httpMethod = 'POST';
    //     req.addHeader('Content-Type', 'application/json');
    //     RestContext.request = req;

    //     RestResponse res = new RestResponse();
    //     RestContext.response = res;

    //     // Set request values
    //     CCCRESTServiceAccount.PostAccountRequest accountRequest = new CCCRESTServiceAccount.PostAccountRequest();
    //     accountRequest.status = 'test';

    //     User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

    //     Test.startTest();
    //     System.runAs(u) {
    //         CCCRESTServiceAccount.postAccount(accountRequest);
    //     }
    //     Test.stopTest();

    //     // Should fail
    //     System.assertEquals(404, RestContext.response.statusCode);
    //     System.assertNotEquals(null, RestContext.response.responseBody);
    // }

    // @isTest static void postAccount_fail_no_galore_business_id() {
    //     RestRequest req = new RestRequest();
    //     req.requestUri = '/';
    //     req.httpMethod = 'POST';
    //     req.addHeader('Content-Type', 'application/json');
    //     RestContext.request = req;

    //     RestResponse res = new RestResponse();
    //     RestContext.response = res;

    //     // Set request values
    //     CCCRESTServiceAccount.PostAccountRequest accountRequest = new CCCRESTServiceAccount.PostAccountRequest();
    //     accountRequest.status = 'test';

    //     User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

    //     Test.startTest();
    //     System.runAs(u) {
    //         CCCRESTServiceAccount.postAccount(accountRequest);
    //     }
    //     Test.stopTest();

    //     // Should fail
    //     System.assertEquals(404, RestContext.response.statusCode);
    //     System.assertNotEquals(null, RestContext.response.responseBody);
    // }

    // @isTest static void postAccount_fail_throwRootExceptionFail() {
    //     String galoreBusId = 'test';

    //     RestRequest req = new RestRequest();
    //     req.requestUri = '/' + galoreBusId;
    //     req.httpMethod = 'POST';
    //     req.addHeader('Content-Type', 'application/json');
    //     RestContext.request = req;

    //     RestResponse res = new RestResponse();
    //     RestContext.response = res;

    //     // Set request values
    //     CCCRESTServiceAccount.PostAccountRequest accountRequest = new CCCRESTServiceAccount.PostAccountRequest();
    //     accountRequest.status = 'test';

    //     User u = [SELECT Id FROM User WHERE UserName = 'test_ccapi_profile@caredotcom.com'];

    //     CCCUtils.UnitTestFlags flags = new CCCUtils.UnitTestFlags();
    //     flags.throwRootExceptionFail = true;

    //     Test.startTest();
    //     System.runAs(u) {
    //         CCCRESTServiceAccount.postAccount(accountRequest, flags);
    //     }
    //     Test.stopTest();

    //     // Should fail
    //     System.assertEquals(500, RestContext.response.statusCode);
    //     System.assertNotEquals(null, RestContext.response.responseBody);
    // }

}