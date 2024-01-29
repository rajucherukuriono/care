/***************************************************************************************************
   Name        : CCCRESTServiceLocation
   Created By  : John Wrightsman, Revelant Technologies
   Email       : john.wrightsman@revelanttech.com
   Created Date: February 2nd, 2021
   Description : This is a REST Service that will be called by Galore to update the Opportunity_Service_Area__c (Location)

   Changes     : 02/02/2021 - John Wrightsman (Class Created)
******************************************************************************************************/
@RestResource(urlMapping='/Location/*')
global class CCCRESTServiceLocation {

    global class PostLocationRequest {
        public Boolean active { get; set; }
        public String name { get; set; }
        public Boolean run_ads { get; set; }
        public String status { get; set; }
        public String phone { get; set; }
        public String email { get; set; }
        public LicenseObject license { get; set; }
    }

    global class LicenseObject {
        public String status { get; set; }
        public Boolean approved { get; set; }
    }

    @HttpPost
    global static void postLocation(PostLocationRequest location) {
       postLocation(location, new CCCUtils.UnitTestFlags());
    }

    @TestVisible
    private static void postLocation(PostLocationRequest location, CCCUtils.UnitTestFlags flags) {
        if (flags == null) flags = new CCCUtils.UnitTestFlags();

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.statusCode = 200;

        // Variables used for logging
        String url;
        Integer httpStatus = 200;
        String requestBody = '';
        String responseBody = '';

        try {
            if (flags.throwRootExceptionFail) throw new CCCUtils.CCCException('Throw Root Exception Unit Test.');

            // Capture request body and url for logging
            requestBody = JSON.serialize(location);
            url = req.requestURI;

            // Grab the Salesforce Id from the request URI
            String locationId = url.substring(url.lastIndexOf('/') + 1);

            // Validate that the Id is the valid type for an Opportunity_Service_Area__c
            if (CCCUtils.getSObjectType(locationId) != 'Opportunity_Service_Area__c') {
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('Invalid Location Id');
                logRestServiceCall(url, requestBody, responseBody, httpStatus);
                return;
            }

            // Get Opportunity_Service_Area__c to validate it exists (Use List in case Opportunity_Service_Area__c doesn't exist and throws error)
            List<Opportunity_Service_Area__c> locationRecords = [SELECT License_Details__c, License_Status__c, Inactive_Agreement_Date__c, Opportunity__c FROM Opportunity_Service_Area__c WHERE Id = :locationId];
            if (locationRecords == null || locationRecords.size() == 0) {
                httpStatus = 404;
                responseBody = 'Location not found';
                res.statusCode = httpStatus;
                res.responseBody = Blob.valueOf(responseBody);
                logRestServiceCall(url, requestBody, responseBody, httpStatus);
                return;
            }
            Opportunity_Service_Area__c locationRecord = locationRecords[0];

            // Update license
            if (location.license != null) {
                // Format the field values
                String licenseStatus = location.license.approved ? 'Approved' : 'Rejected';
                String licenseDetails = location.license.status != null ? location.license.status : '';
                if (licenseDetails.length() > 255) {
                    licenseDetails = licenseDetails.substring(0, 255);
                }

                locationRecord.License_Status__c = licenseStatus;
                locationRecord.License_Details__c = licenseDetails;

                /*
                // Opportunity to be updated
                Opportunity opportunityRecord = new Opportunity(Id = locationRecord.Opportunity__c);

                // Select all locations on Opportunity and see if
                // we need to update the Opportunity StageName
                Integer locationCount = 1;
                Integer approvedCount = location.license.approved ? 1 : 0;
                Integer rejectedCount = !location.license.approved ? 1 : 0;
                for (Opportunity_Service_Area__c loc : [
                    SELECT License_Status__c
                    FROM Opportunity_Service_Area__c
                    WHERE Opportunity__c = :locationRecord.Opportunity__c
                    AND Id != :locationRecord.Id
                ]) {
                    locationCount++;
                    approvedCount += (loc.License_Status__c == 'Approved' ? 1 : 0);
                    rejectedCount += (loc.License_Status__c == 'Rejected' ? 1 : 0);
                }

                // Opportunity StageName logic
                if (approvedCount == locationCount) {
                    // All locations are approved so set opportunity stagename to 'Closed Won'
                    opportunityRecord.StageName = 'Closed Won';
                }
                if (rejectedCount > 0 && opportunityRecord.StageName != 'Closed Won') {
                    // At least one location is Rejected so set opportunity stagename to 'Contract Signed-Has Issues'
                    opportunityRecord.StageName = 'Contract Signed-Has Issues';
                }

                // Only update Opportunity if we've set the StageName
                if (opportunityRecord.StageName != null) {
                    update opportunityRecord;
                }
                */
            }

            // Update active
            if (location.active != null) {
                locationRecord.Active_Ads__c = location.active ? 'Active' : 'Inactive';
                // // Only set Inactive_Agreement_Date__c if it's currently null and location.active is false
                // if (locationRecord.Inactive_Agreement_Date__c == null && location.active == false) {
                //     locationRecord.Inactive_Agreement_Date__c = Date.today();
                // }

                // Set Inactive Agreement Date to null if active=true otherwise set it to today - 8/20/21
                locationRecord.Inactive_Agreement_Date__c = location.active ? null : Date.today();
            }

            // Update name
            if (location.name != null) {
                locationRecord.Name = location.name;
                locationRecord.Registered_Entity_Name__c = location.name;
            }

            // Update active
            if (location.run_ads != null) {
                locationRecord.Active_for_Match__c = location.run_ads ? 'Yes' : 'No';
            }

            // Update phone
            if (location.phone != null) {
                locationRecord.Phone__c = location.phone;
            }

            // Update email
            if (location.email != null) {
                locationRecord.Email__c = location.email;
            }

            // Update status
            if (location.status != null) {
                locationRecord.Galore_Status__c = location.status;
            }

            update locationRecord;
                
        } catch(Exception e) {
            httpStatus = 500;
            responseBody = e.getMessage() + '; ' + e.getStackTraceString();
            res.statusCode = httpStatus;
            res.responseBody = Blob.valueOf(responseBody);
        }

        logRestServiceCall(url, requestBody, responseBody, httpStatus);
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
            Service_Name__c = 'ServiceLocation',
            URL__c = url,
            Request__c = requestBody,
            Response__c = responseBody,
            Status__c = httpStatus
        );
    }

}