/*********************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 03/28/2022
Description: Apex class representation of a BUC Case Update Request

Example Request:

{
    "accounts": [
        {
            "salesforce_account_id": "whatever",
            "buc_status": "active",   // string - not_available, not_enrolled, vetting, failed_vetting, active, paused, license_failure, insurance_failure, permanently_paused
            "run_buc": true, // boolean - Abstract business logic in Galore statuses to approve the provider to run matching in backup care
            "license":{
                “uuid”:  license.uuid,
                "license_number": "1873232983",
                "approved": true, // boolean
                "licensing_website_url": "url",
            },
            "insurance":{
                 “uuid”: insurance.uuid,
                "status": "", //"missing", "under_review", "compliant", "non_compliant", "expired"
                "expires": 1645116098, // integer / Unix timestamp for when the insurance will expire. can be nil
            },
            "infractions":{
                // not yet available, not needed for MVP
            }
        }
    ]
}

Changes:

*********************************************************************************************/
public without sharing class BUCAccountGaloreUpdateRequest extends HTTPRequestElement {

    public List<AccountUpdateObject> accounts { get; set; }

    public class AccountUpdateObject {
        public String salesforce_account_id { get; set; }
        public String buc_status { get; set; }              // string - not_available, not_enrolled, vetting, failed_vetting, active, paused, license_failure, insurance_failure, permanently_paused
        // public Boolean run_buc { get; set; }                // boolean - Abstract business logic in Galore statuses to approve the provider to run matching in backup care
        // public LicenseObject license { get; set; }
        public InsuranceObject insurance { get; set; }
    }

    // public class LicenseObject {
    //     public String uuid { get; set; }
    //     public String license_number { get; set; }
    //     public Boolean approved { get; set; }
    //     public String licensing_website_url { get; set; }
    // }

    public class InsuranceObject {
        public String uuid { get; set; }
        public String status { get; set; }    //"missing", "under_review", "compliant", "non_compliant", "expired"
        public Long expires { get; set; }  // integer / Unix timestamp for when the insurance will expire. can be nil
    }

}