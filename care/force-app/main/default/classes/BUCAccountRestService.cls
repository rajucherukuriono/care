/*****************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 3/14/2022
Description: REST Service for creating new BUC Accounts
Comments:

********************************************************************************************/
@RestResource(urlMapping='/BUCAccount/*')
global class BUCAccountRestService {
    static private final String CLASS_NAME = 'BUCAccountRestService';
    static private Id parentAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Marketing Solutions').getRecordTypeId();
    static private Id childAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('BUC Network Center').getRecordTypeId();
    static private Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('BUC Contact').getRecordTypeId();
    static private Map<String, String> galoreToPicklistValueMap = new Map<String, String>();

    public class CustomException extends Exception {}

    public class UnitTestFlags {
        // public Boolean throwNoUsersException { get; set; }
        // public Boolean throwHttp500Status { get; set; }
        // public Boolean throwUnableToCreateAccount { get; set; }

        public UnitTestFlags() {
            // this.throwNoUsersException = false;
            // this.throwHttp500Status = false;
            // this.throwUnableToCreateAccount = false;
        }
    }

    global class AccountRequest {
        public String uuid { get; set; }
        public String parent_account_id { get; set; }
        public String opportunity_service_area_id { get; set; }
        public String name { get; set; }
        public BusinessObject business { get; set; }
        public Decimal utilization { get; set; }
        public AddressObject address { get; set; }
        public String phone { get; set; }
        public List<ContactObject> contacts { get; set; }
        public List<OfferingObject> offerings { get; set; }
        public LicenseObject license { get; set; }
        public InsuranceObject insurance { get; set; }
        public String buc_status { get; set; }
    }

    global class BusinessObject {
        public String name { get; set; }
        public List<BusinessRepresentativeObject> business_representatives { get; set; }
    }

    global class AddressObject {
        public string line1 { get; set; }
        public string line2 { get; set; }
        public string city { get; set; }
        public string state { get; set; }
        public string postal_code { get; set; }
    }

    global class BusinessRepresentativeObject {
        public String uuid { get; set; }
        public String first_name { get; set; }
        public String last_name { get; set; }
        public String dob { get; set; }
        public String state { get; set; }
        public String zip { get; set; }
    }

    global class ContactObject {
        public String uuid { get; set; }
        public String first_name { get; set; }
        public String last_name { get; set; }
        public String email { get; set; }
        public String phone { get; set; }
        public String type { get; set; }
    }

    global class LicenseObject {
        public String uuid { get; set; }
        public String status { get; set; }
        public String license_number { get; set; }
        public String business_entity_name { get; set; } // Billing_Entity_Name__c ??
        public String edit_license_url { get; set; }
        public AddressObject address { get; set; }
    }

    global class InsuranceObject {
        public String uuid { get; set; }
        public String url { get; set; }
        public Integer uploaded { get; set; }
        public Integer expires { get; set; }
        public String status { get; set; }
    }

    global class OfferingObject {
        public String uuid { get; set; }
        public Boolean active { get; set; }
        public Integer capacity { get; set; }
        public Integer min_months { get; set; }
        public Integer max_months { get; set; }
        public String service { get; set; }      // string: "unknown, centers, nanny_agencies, fccs, camps, activities, home_care, housing, special_needs, adult_day_care, kindergarten, preschool, memory_care
        public String vertical { get; set; }     // string: "default", "child_care", or "senior_care"
        public String care_type { get; set; }    // string: child_care_infant child_care_toddler child_care_pre_school child_care_school_aged child_care_pre_teens_and_teens senior_care_assisted_living senior_care_independent_living senior_care_memory_care"
        public String hourly_price { get; set; } // dollar string, e.g. "14.00" is $14. can be nil
        public String daily_price { get; set; }  // dollar string, e.g. "14.00" is $14. can be nil
    }

    global class AccountResponse {
        public String parent_account_id { get; set; }
        public String account_id { get; set; }
        public Boolean is_duplicate { get; set; }
        public List<String> errors { get; set; }

        public AccountResponse() {
            this.errors = new List<String>();
        }
    }

    // Helper method that returns a string value parsed to decimal. If the value doesn't parse it returns null
    private static Decimal getSafeDecimalValue(String value) {
        Decimal result = null;
        try { result = Decimal.valueOf(value); } catch(Exception e) {}
        return result;
    }

    @HttpPost
    global static AccountResponse postAccount(AccountRequest account) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.statusCode = 200;

        return postAccountInternal(account, req, res, new UnitTestFlags());
    }

    @HttpPatch
    global static AccountResponse patchAccount(AccountRequest account) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.statusCode = 200;

        return patchAccountInternal(account, req, res, new UnitTestFlags());
    }

    // Used for creating new account
    @TestVisible
    private static AccountResponse postAccountInternal(AccountRequest accountReq, RestRequest req, RestResponse res, UnitTestFlags utFlags) {
        final String METHOD_NAME = 'postAccountInternal';

        AccountResponse response = new AccountResponse();

        // Variables used for logging
        String url;
        Integer httpStatus = 200;
        String requestBody = '';
        String responseBody = '';

        try {
            // Capture request body and url for logging
            requestBody = JSON.serialize(accountReq);
            url = req.requestURI;

            // Validation
            response = validatePostRequest(accountReq);

            response.parent_account_id = accountReq.parent_account_id;

            // If opportunity_service_area_id is passed, we need to make the new Account a child of the Opportunity's parent Account
            if (String.isNotBlank(accountReq.opportunity_service_area_id)) {
                Id tempParentAccountId = [SELECT Opportunity__r.AccountId FROM Opportunity_Service_Area__c WHERE Id = :accountReq.opportunity_service_area_id]?.Opportunity__r.AccountId;
                if (tempParentAccountId != null) {
                    response.parent_account_id = tempParentAccountId;
                }
            }

            if (response.errors.size() == 0) {
                Account accountRecord = buildAccountFromRequest(accountReq, new Account());

                if (String.isNotBlank(response.parent_account_id)) {
                    accountRecord.ParentId = response.parent_account_id;
                }

                // New accounts should be assigned a record type id
                if (accountRecord.Id == null) {
                    // Assign accounts w/Parent account ids the childAccountRecordTypeId
                    if (String.isNotBlank(response.parent_account_id)) {
                        accountRecord.RecordTypeId = childAccountRecordTypeId;
                    } else {
                        accountRecord.RecordTypeId = parentAccountRecordTypeId;
                    }
                }

                Database.SaveResult saveResult = Database.insert(accountRecord, false);

                // If it's not successful due to duplicate, get the duplicate record and return the id
                if (saveResult.isSuccess()) {
                    response.account_id = saveResult.getId();
                } else {
                    for (Database.Error error : saveResult.getErrors()) {
                        // If one of the errors is a duplicate error, set the is_duplicate flag in the response
                        response.is_duplicate = response.is_duplicate == null ? error instanceof Database.DuplicateError : null;
                        // Add to the resonse errors
                        response.errors.add('Error inserting Account - Status Code: ' + error.getStatusCode() + ' Message: ' + error.getMessage() + ' Fields: ' + String.join(error.getFields(), ','));
                    }
                }

                // Add Business Representatives
                if (response.errors.size() == 0 && accountReq.business != null && accountReq.business.business_representatives != null && accountReq.business.business_representatives.size() > 0) {
                    createOrUpdateBusinessRepresentatives(accountReq.business.business_representatives, response.account_id);
                }

                // Add Contacts
                if (response.errors.size() == 0 && accountReq.contacts != null && accountReq.contacts.size() > 0) {
                    createOrUpdateContacts(accountReq.contacts, response.account_id);
                }

                // Add Offerings
                if (response.errors.size() == 0 && accountReq.offerings != null && accountReq.offerings.size() > 0) {
                    createOrUpdateOfferings(accountReq.offerings, response.account_id);
                }

                // If opportunity_service_area_id is passed, update the Opportunity_Service_Area with the new Account Id
                if (response.errors.size() == 0 && String.isNotBlank(accountReq.opportunity_service_area_id)) {
                    update new Opportunity_Service_Area__c(Id = accountReq.opportunity_service_area_id, Location_Account__c = response.account_id);
                }

                // Update the parent Account's number of locations
                if (String.isNotBlank(response.parent_account_id)) {
                    Integer locationCount = database.countQuery('SELECT count() FROM Account WHERE ParentId = \'' + response.parent_account_id + '\'');
                    update new Account(Id = response.parent_account_id, of_locations__c = locationCount);
                }
            }
        } catch (Exception e) {
            httpStatus = 500;
            responseBody = e.getMessage() + '; ' + e.getStackTraceString();
            res.statusCode = httpStatus;
            System.debug('@@@ error: ' + CLASS_NAME + '.' + METHOD_NAME + '(Line Number: ' + e.getLineNumber() + '): ' + e.getMessage());
            response.errors.add(CLASS_NAME + '.' + METHOD_NAME + '(Line Number: ' + e.getLineNumber() + '): ' + e.getMessage());
        }

        logRestServiceCall(url, requestBody, responseBody, httpStatus);

        return response;
    }

    // Used for updating existing account
    @TestVisible
    private static AccountResponse patchAccountInternal(AccountRequest accountReq, RestRequest req, RestResponse res, UnitTestFlags utFlags) {
        final String METHOD_NAME = 'patchAccountInternal';

        AccountResponse response = new AccountResponse();

        try {
            // Grab the Account Id from the request URL and validate that it is not blank
            String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            if (String.isBlank(accountId)) {
                throw new CustomException('A Salesforce Account Id is required at the end of the URL');
            }

            // Validation
            response = validatePatchRequest(accountReq);

            if (response.errors.size() == 0) {
                Account accountRecord = buildAccountFromRequest(accountReq, new Account(Id = accountId));

                Database.SaveResult saveResult = Database.update(accountRecord, false);

                if (saveResult.isSuccess()) {
                    response.account_id = saveResult.getId();
                } else {
                    for (Database.Error error : saveResult.getErrors()) {
                        // If one of the errors is a duplicate error, set the is_duplicate flag in the response
                        response.is_duplicate = response.is_duplicate == null ? error instanceof Database.DuplicateError : null;
                        // Add to the resonse errors
                        response.errors.add('Error updating Account - Status Code: ' + error.getStatusCode() + ' Message: ' + error.getMessage() + ' Fields: ' + String.join(error.getFields(), ','));
                    }
                }
            }

            // Add/Update Business Representatives
            if (response.errors.size() == 0 && accountReq.business != null && accountReq.business.business_representatives != null && accountReq.business.business_representatives.size() > 0) {
                createOrUpdateBusinessRepresentatives(accountReq.business.business_representatives, response.account_id);
            }

            // Add/Update Contacts
            if (response.errors.size() == 0 && accountReq.contacts != null && accountReq.contacts.size() > 0) {
                createOrUpdateContacts(accountReq.contacts, response.account_id);
            }

            // Add/Update Offerings
            if (response.errors.size() == 0 && accountReq.offerings != null) {
                createOrUpdateOfferings(accountReq.offerings, response.account_id);
            }

        } catch (Exception e) {
            response.errors.add(CLASS_NAME + '.' + METHOD_NAME + '(Line Number: ' + e.getLineNumber() + '): ' + e.getMessage());
        }

        return response;
    }

    // Returns a populated Account object with any non-null fields on the request
    @TestVisible
    private static Account buildAccountFromRequest(AccountRequest account, Account accountRecord) {
        galoreToPicklistValueMap = new Map<String, String>();
        for (BUC_Galore_Picklist_Mapping__mdt mapping : [SELECT Field_Api_Name__c, Galore_Value__c, Picklist_Value__c FROM BUC_Galore_Picklist_Mapping__mdt]) {
            galoreToPicklistValueMap.put(mapping.Field_Api_Name__c + ':' + mapping.Galore_Value__c, mapping.Picklist_Value__c);
        }

        accountRecord.Name = account.name;
        if (account.name == null) {
            accountRecord.Name = account.business.name;
        }

        if (account.buc_status != null) {
            accountRecord.BUC_Status__c = getPicklistValue('BUC_Status__c', account.buc_status);
        }

        if (account.address != null) {
            if (account.address.line1 != null) {
                String addressLine = account.address.line1;
                if (account.address.line2 != null) {
                    addressLine += '\r\n' + account.address.line2;
                }
                accountRecord.ShippingStreet = addressLine;
            }
            if (account.address.city != null) {
                accountRecord.ShippingCity = account.address.city;
            }
            if (account.address.state != null) {
                accountRecord.ShippingState = account.address.state;
            }
            if (account.address.postal_code != null) {
                accountRecord.ShippingPostalCode = account.address.postal_code;
            }
        }
        if (account.address != null) {
            if (account.address.line1 != null) {
                String addressLine = account.address.line1;
                if (account.address.line2 != null) {
                    addressLine += '\r\n' + account.address.line2;
                }
                accountRecord.BillingStreet = addressLine;
            }
            if (account.address.city != null) {
                accountRecord.BillingCity = account.address.city;
            }
            if (account.address.state != null) {
                accountRecord.BillingState = account.address.state;
            }
            if (account.address.postal_code != null) {
                accountRecord.BillingPostalCode = account.address.postal_code;
            }
        }

        if (account.uuid != null) {
            accountRecord.Galore_Business_Id__c = account.uuid;
        }
        if (account.utilization != null) {
            accountRecord.Utilization__c = account.utilization;
        }
        // if (account.providerStatus != null) {
        //     accountRecord.Provider_Status__c = account.providerStatus;
        // }
        if (account.phone != null) {
            accountRecord.Phone = account.phone;
        }

        if (account.license != null) {
            accountRecord.License_uuid__c = account.license.uuid;
            accountRecord.Galore_License_URL__c = account.license.edit_license_url;
            // accountRecord.License_Status__c = account.status; // make sure value is in picklist if we use this
            accountRecord.License_Number__c = account.license.license_number;
            // accountRecord.Billing_Entity_Name__c = account.business_entity_name;
            if (account.license.address != null) {
                accountRecord.License_Address_Line_1__c = account.license.address.line1;
                accountRecord.License_Address_Line_2__c = account.license.address.line2;
                accountRecord.License_Address_City__c = account.license.address.city;
                accountRecord.License_Address_State__c = account.license.address.state;
                accountRecord.License_Address_Postal_Code__c = account.license.address.postal_code;
            }
        }

        if (account.insurance != null) {
            accountRecord.Insurance_uuid__c = account.insurance.uuid;
            accountRecord.Insurance_URL__c = account.insurance.url;
            accountRecord.Insurance_Status__c = getPicklistValue('Insurance_Status__c', account.insurance.status);
            if (account.insurance.uploaded != null) {
                // Convert from Unix timestamp to Salesforce Datetime. If zero is passed, set the value to null
                accountRecord.Insurance_Uploaded__c = account.insurance.uploaded == 0 ? null : (Datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0)).addSeconds(account.insurance.uploaded);
            }
            if (account.insurance.expires != null) {
                // Convert from Unix timestamp to Salesforce Datetime. If zero is passed, set the value to null
                accountRecord.Insurance_Expires__c = account.insurance.expires == 0 ? null : (Datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0)).addSeconds(account.insurance.expires);
            }
        }

        return accountRecord;
    }

    @TestVisible
    private static void createOrUpdateBusinessRepresentatives(List<BusinessRepresentativeObject> businessReps, String accountId) {
        Map<String, Business_Representative__c> businessRepMap = new Map<String, Business_Representative__c>();
        for (Business_Representative__c busRepRecord : [
            SELECT Galore_uuid__c, First_Name__c, Last_Name__c, Birthdate__c, State__c, Zip_Postal_Code__c
            FROM Business_Representative__c
            WHERE Account__c = :accountId
        ]) {
            businessRepMap.put(busRepRecord.Galore_uuid__c, busRepRecord);
        }

        List<Business_Representative__c> busRepsToUpsert = new List<Business_Representative__c>();
        for (BusinessRepresentativeObject busRepObj : businessReps) {
            Business_Representative__c busRepRecord = businessRepMap.containsKey(busRepObj.uuid) ? businessRepMap.get(busRepObj.uuid) : new Business_Representative__c();
            if (busRepRecord.Account__c == null) {
                busRepRecord.Account__c = accountId;
            }
            busRepRecord.Galore_uuid__c = busRepObj.uuid;
            busRepRecord.First_Name__c = busRepObj.first_name;
            busRepRecord.Last_Name__c = busRepObj.last_name;
            busRepRecord.Birthdate__c = String.isBlank(busRepObj.dob) ? null : Date.valueOf(busRepObj.dob); // Convert from 'yyyy-MM-dd' string-formatted date to a Salesforce Date value
            busRepRecord.State__c = busRepObj.state;
            busRepRecord.Zip_Postal_Code__c = busRepObj.zip;
            busRepsToUpsert.add(busRepRecord);
        }

        upsert busRepsToUpsert;
    }

    @TestVisible
    private static void createOrUpdateContacts(List<ContactObject> contacts, String accountId) {
        Map<String, Contact> contactMap = new Map<String, Contact>();
        for (Contact contactRecord : [
            SELECT Galore_uuid__c, FirstName, LastName, Email, Phone, BUC_Contact_Type__c
            FROM Contact
            WHERE AccountId = :accountId
        ]) {
            contactMap.put(contactRecord.Galore_uuid__c, contactRecord);
        }

        List<Contact> contactsToUpsert = new List<Contact>();
        for (ContactObject contactObj : contacts) {
            Contact contactRecord = contactMap.containsKey(contactObj.uuid) ? contactMap.get(contactObj.uuid) : new Contact(AccountId = accountId, RecordTypeId = contactRecordTypeId);
            contactRecord.Galore_uuid__c = contactObj.uuid;
            contactRecord.FirstName = contactObj.first_name;
            contactRecord.LastName = contactObj.last_name;
            contactRecord.Email = contactObj.email;
            contactRecord.Phone = contactObj.phone;
            contactRecord.BUC_Contact_Type__c = contactObj.type;
            contactsToUpsert.add(contactRecord);
        }

        upsert contactsToUpsert;
    }

    @TestVisible
    private static void createOrUpdateOfferings(List<OfferingObject> offerings, String accountId) {
        Map<String, Offering__c> offeringMap = new Map<String, Offering__c>();
        for (Offering__c offeringRecord : [
            SELECT Active__c, Capacity__c, Care_Type__c, Daily_Price__c, Galore_uuid__c,
                Hourly_Price__c, Maximum_Months__c, Minimum_Months__c, Service__c, Vertical__c
            FROM Offering__c
            WHERE Account__c = :accountId
        ]) {
            offeringMap.put(offeringRecord.Galore_uuid__c, offeringRecord);
        }

        List<Offering__c> offeringsToUpsert = new List<Offering__c>();
        for (OfferingObject offeringObj : offerings) {
            Offering__c offeringRecord = offeringMap.containsKey(offeringObj.uuid) ? offeringMap.get(offeringObj.uuid) : new Offering__c(Account__c = accountId);
            offeringRecord.Galore_uuid__c = offeringObj.uuid;
            offeringRecord.Active__c = offeringObj.active == true;
            offeringRecord.Capacity__c = offeringObj.capacity;
            offeringRecord.Care_Type__c = getPicklistValue('Care_Type__c', offeringObj.care_type);
            offeringRecord.Daily_Price__c = getSafeDecimalValue(offeringObj.daily_price);
            offeringRecord.Hourly_Price__c = getSafeDecimalValue(offeringObj.hourly_price);
            offeringRecord.Maximum_Months__c = offeringObj.max_months;
            offeringRecord.Minimum_Months__c = offeringObj.min_months;
            offeringRecord.Service__c = getPicklistValue('Service__c', offeringObj.service);
            offeringRecord.Vertical__c = getPicklistValue('Vertical__c', offeringObj.vertical);
            offeringsToUpsert.add(offeringRecord);
        }

        upsert offeringsToUpsert;
    }

    @TestVisible
    private static String getPicklistValue(String fieldApiName, String galoreValue) {
        String result;
        if (galoreValue != null) {
            if (galoreToPicklistValueMap.containsKey(fieldApiName + ':' + galoreValue)) {
                result = galoreToPicklistValueMap.get(fieldApiName + ':' + galoreValue);
            } else {
                throw new CustomException('No field mapping exists for Salesforce picklist field ' + fieldApiName + ' and Galore value \'' + galoreValue + '\'');
            }
        }
        return result;
    }

    @TestVisible
    private static AccountResponse validatePostRequest(AccountRequest account) {
        AccountResponse response = new AccountResponse();

        return response;
    }

    @TestVisible
    private static AccountResponse validatePatchRequest(AccountRequest account) {
        AccountResponse response = new AccountResponse();

        return response;
    }

    /**
    * @description Logs the service call to Contract_Composer_REST_Log__c
    * @param url (String) - The url
    * @param requestBody (String) - The request JSON body
    * @param responseBody (String) - The response
    * @param httpStatus (Integer) - The http status returned in the response
    */
    private static void logRestServiceCall(String url, String requestBody, String responseBody, Integer httpStatus) {
        insert new Contract_Composer_REST_Log__c(
            Service_Name__c = 'BUCAccount',
            URL__c = url,
            Request__c = requestBody,
            Response__c = responseBody,
            Status__c = httpStatus
        );
    }
}