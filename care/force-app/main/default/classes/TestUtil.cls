/**

The TestUtil class is a helper class for tests.  It contains utility methods for
creating members and stuff like that.

 */
@isTest

public class TestUtil {
    public static ID pcRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
    public static ID saRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Seeker').getRecordTypeId();
    public static ID paRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
    public static ID smbpaRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SMB_Provider').getRecordTypeId();
    public static ID laRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lite').getRecordTypeId();
    public static ID isaRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Seeker').getRecordTypeId();
    public static ID ipaRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Provider').getRecordTypeId();
    
    public static ID intEmailRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Email').getRecordTypeId();
    public static ID intCallCenterRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Call Center').getRecordTypeId();
    public static ID EmailRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    public static ID CallCenterRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call Center').getRecordTypeId();
    
    public static Integer MarketplaceProviderMemberId = 999999005;
    public static Integer ChildCareProviderMemberId = 999999008;
    public static Integer SeniorCareHousingProviderMemberId = 999999009;
    public static Integer FeaturedMarketplaceProviderMemberId = 999999010;
    public static Integer BasicChildCareSeekerMemberId = 999999011;
    public static Integer PremiumSeekerMemberId = 999999012;
    public static Integer NthDayPremiumSeekerMemberId = 999999013;
    public static Integer BasicProviderMemberId = 999999014;
    public static Integer PremiumProviderMemberId = 999999015;
    public static Integer NthDayPremiumProviderMemberId = 999999016;
    public static Integer NthDayPremiumSeekerUSAAMemberId = 999999017;
    public static Integer LiteMemberId = 999999020;
    public static String InternationalProviderMemberId = 'GB_999999005';
    public static String InternationalPremiumSeekerMemberId = 'GB_999999006';
    public static String InternationalBasicSeekerMemberId = 'DE_999999004';

    public static String MarketplaceProviderFirstName = 'MarketplaceProvider';
    public static String ChildCareProviderFirstName = 'MarketplaceChildCareProviderOne';
    public static String SeniorCareHousingProviderFirstName = 'SeniorCareHousingProviderFirstNameOne';
    public static String FeaturedMarketplaceProviderFirstName = 'FeaturedMarketplaceProvider';
    public static String BasicChildCareSeekerFirstName = 'BasicSeekerOne';
    public static String PremiumSeekerFirstName = 'PremiumSeekerOne';
    public static String NthDayPremiumSeekerFirstName = 'NthDayPremiumSeekerOne';
    public static String BasicProviderFirstName = 'BasicProviderOne';
    public static String PremiumProviderFirstName = 'PremiumProviderOne';
    public static String NthDayPremiumProviderFirstName = 'NthDayPremiumProviderOne';
    public static String NthDayPremiumSeekerUSAAFirstName = 'NthDayPremiumSeekerUSAAOne';
    public static String LiteFirstName = 'LiteOne';
    public static String InternationalProviderFirstName = 'Mary';
    public static String InternationalProviderLastName = 'Poppins';
    public static String InternationalPremiumSeekerFirstName = 'George';
    public static String InternationalPremiumSeekerLastName = 'Banks';
    public static String InternationalBasicSeekerFirstName = 'Christoph';
    public static String InternationalBasicSeekerLastName = 'Waltz';

    public static String MarketplaceProviderEmail = 'jack.odell+smbp001@gmail.com';
    public static String ChildCareProviderEmail = 'jack.odell+smbp004@gmail.com';
    public static String SeniorCareHousingProviderEmail = 'jack.odell+smbp006@gmail.com';
    public static String FeaturedMarketplaceProviderEmail = 'jack.odell+smbp007@gmail.com';
    public static String BasicChildCareSeekerEmail = 'jack.odell+bs001@gmail.com';
    public static String PremiumSeekerEmail = 'jack.odell+ps001@gmail.com';
    public static String NthDayPremiumSeekerEmail = 'jack.odell+ps002@gmail.com';
    public static String BasicProviderEmail = 'jack.odell+bp001@gmail.com';
    public static String PremiumProviderEmail = 'jack.odell+pp001@gmail.com';
    public static String NthDayPremiumProviderEmail = 'jack.odell+pp002@gmail.com';
    public static String NthDayPremiumSeekerUSAAEmail = 'jack.odell+ps003@gmail.com';
    public static String LiteEmail = 'jack.odell+lite003@gmail.com';
    public static String InternationalProviderEmail = 'jack.odell+intp001@gmail.com';
    public static String InternationalPremiumSeekerEmail = 'jack.odell+intps001@gmail.com';
    public static String InternationalBasicSeekerEmail = 'jack.odell+intbs001@gmail.com';

    public static String InternationalBasicProviderLocale = 'en_GB';
    public static String InternationalBasicSeekerLocale = 'de_DE';
    public static String InternationalPremiumSeekerLocale = 'en_GB';

    public static String InternationalBasicSeekerCountryCode = 'de';
    public static String InternationalPremiumSeekerCountryCode = 'uk';

    public static String MarketplaceProviderLocationId = '495943';
    public static String ChildCareProviderLocationId = '495945';
    public static String SeniorCareHousingProviderLocationId = '495948';
    public static String FeaturedMarketplaceProviderLocationId = '495949';

    public static String MarketplaceProviderBusinessName = 'MarketplaceBusinessNameOne';
    public static String SeniorHomeCareProviderBusinessName = 'SeniorHomeCareBusinessNameOne';
    public static String ChildCareProviderBusinessName = 'ChildCareBusinessNameOne';
    public static String SeniorCareHousingProviderBusinessName = 'SeniorCareHousingProviderBusinessNameOne';
    public static String FeaturedMarketplaceProviderBusinessName = 'FeaturedMarketplaceBusinessNameOne';
    
    public static integer BulkLimit = 25;

    public static testMethod void SterlingCreatesBasicProvider_enGB() {
        
        Account a = new Account(
            RecordTypeId = ipaRtId,
            FirstName = InternationalProviderFirstName,
            LastName = InternationalProviderLastName,
            PersonEmail = InternationalProviderEmail,
            Global_Member_Id__c = InternationalProviderMemberId,
            Gender__pc = 'Female',
            Locale__pc = InternationalBasicProviderLocale,
            PersonMailingPostalCode = 'SW1V 1QJ',
            PersonMailingCity = 'London',
            PersonMailingCountry = 'uk',
            PersonMailingStreet = '23 Hugh St',
            PersonHomePhone = '+44 20 7828 2840',
            MembershipCreationDate__pc = date.today(),
            MemberType__pc = 'Provider',
            Type__pc = 'Basic',
            Status__pc = 'Open',
            Pricing_Plan_Description__pc = 'Basic',
            //LastPaymentDate__pc = date.today(),
            Next_Payment_Plan_Action__pc = '',
            NextPaymentDate__pc = date.today(),
            Employer_Program__pc = '',
            IPAddress__pc = '',
            CloseDowngradeReason__pc = '',
            Downgrade_Reason__pc = '',
            Pricing_Plan_Fee_Display__pc = '',
            PromoCode__pc = '',
            Subscription_Plan_Change_Date__pc = date.today()
            );
        insert a;

        Account[] accountList = [SELECT id,Language__pc,Locale__pc FROM Account WHERE Global_Member_Id__c = :InternationalProviderMemberId];

        System.assert(accountList.size() == 1);
    }

    public static testMethod void SterlingCreatesPremiumSeeker_enGB() {
        
        Account a = new Account(
            RecordTypeId = isaRtId,
            FirstName = InternationalPremiumSeekerFirstName,
            LastName = InternationalPremiumSeekerLastName,
            PersonEmail = InternationalPremiumSeekerEmail,
            Global_Member_Id__c = InternationalPremiumSeekerMemberId,
            Gender__pc = 'Male',
            Locale__pc = 'en_GB',
            PersonMailingPostalCode = 'SW1V 1QJ',
            PersonMailingCity = 'London',
            PersonMailingCountry = 'uk',
            PersonMailingStreet = '23 Hugh St',
            PersonHomePhone = '+44 20 7828 2840',
            MembershipCreationDate__pc = date.today(),
            MemberType__pc = 'Seeker',
            Type__pc = 'Premium',
            Status__pc = 'Open',
            Pricing_Plan_Description__pc = 'Premium',
            //LastPaymentDate__pc = date.today(),
            Next_Payment_Plan_Action__pc = '',
            NextPaymentDate__pc = date.today(),
            Employer_Program__pc = '',
            IPAddress__pc = '',
            CloseDowngradeReason__pc = '',
            Downgrade_Reason__pc = '',
            Pricing_Plan_Fee_Display__pc = '',
            PromoCode__pc = '',
            Subscription_Plan_Change_Date__pc = date.today()
            );
        insert a;

        Account[] accountList = [SELECT id,Language__pc,Locale__pc FROM Account WHERE Global_Member_Id__c = :InternationalPremiumSeekerMemberId];

        System.assert(accountList.size() == 1);
    }

    public static testMethod void SterlingCreatesBasicSeeker_deDE() {
        
        Account a = new Account(
            RecordTypeId = isaRtId,
            FirstName = InternationalBasicSeekerFirstName,
            LastName = InternationalBasicSeekerLastName,
            PersonEmail = InternationalBasicSeekerEmail,
            Global_Member_Id__c = InternationalBasicSeekerMemberId,
            Gender__pc = 'Male',
            Locale__pc = InternationalBasicSeekerLocale,
            PersonMailingCountry = InternationalBasicSeekerCountryCode,
            MembershipCreationDate__pc = date.today(),
            MemberType__pc = 'Seeker',
            Type__pc = 'Basic',
            Status__pc = 'Open',
            Pricing_Plan_Description__pc = 'Basic',
            //LastPaymentDate__pc = date.today(),
            Next_Payment_Plan_Action__pc = '',
            NextPaymentDate__pc = date.today(),
            Employer_Program__pc = '',
            IPAddress__pc = '',
            CloseDowngradeReason__pc = '',
            Downgrade_Reason__pc = '',
            Pricing_Plan_Fee_Display__pc = '',
            PromoCode__pc = '',
            Subscription_Plan_Change_Date__pc = date.today()
            );
        insert a;

        Account[] accountList = [SELECT id,Language__pc,Locale__pc FROM Account WHERE Global_Member_Id__c = :InternationalBasicSeekerMemberId];

        System.assert(accountList.size() == 1);
    }
    
    public static testMethod void createFeaturedButUnapprovedSeniorHomeCareMarketplaceProvider() {
        // This method creates Senior Home Care Marketplace account that has signed up to be featured but has not yet been approved (AKA an "unapproved featured")
        // To turn provider into approved featured, update overall_status__c to "Active Featured"
        
        String firstName = FeaturedMarketplaceProviderFirstName;
        String lastName = 'Brady';
        String email = FeaturedMarketplaceProviderEmail;
        Integer memberId = FeaturedMarketplaceProviderMemberId;
        String companyName = FeaturedMarketplaceProviderBusinessName;
        String locationId = FeaturedMarketplaceProviderLocationId;

        Account a = new Account(
            basicmembersignupdate__pc = date.today(),
            blacklisted__pc = false,
            firstname = firstName,
            groupie__pc = false,
            groups__pc = '',
            ipaddress__pc = '127.0.0.1',
            karoo__pc = false,
            lastname = lastName,
            memberid__c = String.valueOf(memberId), 
            memberid__pc = memberId,
            membershipcreationdate__pc = date.today(),
            messagenotificationfrequency__pc = 'immediately',
            no_longer_with_company__pc = false,  
            optinmemberalert__pc = false,
            optinnewsletters__pc = true,
            optinoffers__pc  = true,
            optinphone__pc = false, 
            optinprovideralert__pc = true, 
            overallstatuschangedate__pc = date.today(),
            PersonEmail = email,
            personhomephone = '(555) 555-5555',
            personmailingcity = 'Jamaica Plain',
            personmailingpostalcode = '02130',
            personmailingstate = 'MA',
            personotherphone = '(666) 666-6666',
            pricetestcellscheme__pc = '',             
            product_type__pc = 'SUBSCRIPTION',
            provideralertfrequency__pc = 'weekly',
            receiving_emails__pc = true,
            rx1__pc = 'sem_Google', 
            rx2__pc = 'General_Brand',           
            rx3__pc = 'care com_e',
            rx4__pc = '99999999999',
            rx5__pc = 'General_Exact',
            statuschangedate__pc = date.today(),

            // Fields that correspond to member status should be put here to make them easier to modify later
            recordtypeid = smbpaRtId,
            Business_Name__pc = companyName,
            Location_ID__pc = locationId,
            Brand_ID__pc = 'SCRB000012952752',
            Company_ID__pc = 'SCRC000012952752',
            Service_Id__pc = 'SENIRCARE',               // The primary service of the provider is child care
            Sub_Service_Id__pc = 'homeCare',            // Their secondary service is day care
            membertype__pc = 'SMB_Provider',            
            overallstatus__pc = 'New',                  // unapproved featureds have a status of "new"
            //pricing_features__pc = '',                       
            pricing_plan_id__pc = 'SMBSHCJULY13101',    // Unapproved featureds have a pricing plan
            status__pc = 'Active',
            type__pc = 'Featured'                       // Unapproved featureds have a type of featured

            );

        insert a;

        Account[] accountList = [SELECT id,firstName,PersonEmail,memberid__pc,type__pc,recordtypeid,isPersonAccount,overallstatus__pc,pricing_plan_id__pc,
                                    Service_Id__pc,Sub_Service_Id__pc,membertype__pc,memberid__c
                                    FROM Account WHERE id = :a.id];

        // check the vitals
        System.assert(accountList.size() == 1);
        System.assert(accountList[0].firstName == firstName);
        System.assert(accountList[0].PersonEmail == email);
        System.assert(accountList[0].memberid__pc == memberId);
        System.assert(accountList[0].memberid__c == String.valueOf(memberId));
        System.assert(accountList[0].recordtypeid == smbpaRtId);
        System.assert(accountList[0].isPersonAccount == true);

        // check it is an unnapproved featured Senior Home Care SMB Provider
        System.assert(accountList[0].type__pc == 'Featured');
        System.assert(accountList[0].overallstatus__pc == 'New');
        System.assert(accountList[0].recordtypeid == smbpaRtId);
        System.assert(accountList[0].membertype__pc == 'SMB_Provider');
        System.assert(accountList[0].pricing_plan_id__pc != 'SMBBASIC');
        System.assert(accountList[0].Service_Id__pc == 'SENIRCARE');
        System.assert(accountList[0].Sub_Service_Id__pc == 'homeCare');
        

    }

    public static testMethod void createBasicSeniorHomeCareMarketplaceProvider() {
        // This method creates a Basic Senior Home Care Marketplace provider as a Person Account

        String firstName = MarketplaceProviderFirstName;
        String lastName = 'Brady';
        String email = MarketplaceProviderEmail;
        Integer memberId = MarketplaceProviderMemberId;
        String companyName = MarketplaceProviderBusinessName;
        String locationId = MarketplaceProviderLocationId;
        
        //Inserting Campaign if it doesn't exist
        List<Campaign> signupCamp = [Select Id FROM Campaign WHERE Name = 'Care.com Signup' limit 1];
        if (signupCamp.isEmpty()) {
            Campaign cpg=new Campaign(Name = 'Care.com Signup');
            Insert cpg;
        }

        Account a = new Account(
            basicmembersignupdate__pc = date.today(),
            blacklisted__pc = false,
            firstname = firstName,
            groupie__pc = false,
            groups__pc = '',
            ipaddress__pc = '127.0.0.1',
            karoo__pc = false,
            lastname = lastName,
            memberid__c = String.valueOf(memberId), 
            memberid__pc = memberId,
            membershipcreationdate__pc = date.today(),
            messagenotificationfrequency__pc = 'immediately',
            no_longer_with_company__pc = false,  
            optinmemberalert__pc = false,
            optinnewsletters__pc = true,
            optinoffers__pc  = true,
            optinphone__pc = false, 
            optinprovideralert__pc = true, 
            overallstatuschangedate__pc = date.today(),
            PersonEmail = email,
            personhomephone = '(555) 555-5555',
            personmailingcity = 'Jamaica Plain',
            personmailingpostalcode = '02130',
            personmailingstate = 'MA',
            personotherphone = '(666) 666-6666',
            pricetestcellscheme__pc = '',             
            product_type__pc = 'SUBSCRIPTION',
            provideralertfrequency__pc = 'weekly',
            receiving_emails__pc = true,
            rx1__pc = 'sem_Google', 
            rx2__pc = 'General_Brand',           
            rx3__pc = 'care com_e',
            rx4__pc = '99999999999',
            rx5__pc = 'General_Exact',
            statuschangedate__pc = date.today(),

            // Fields that correspond to member status should be put here to make them easier to modify later
            recordtypeid = smbpaRtId,
            Business_Name__pc = companyName,
            Location_ID__pc = locationId,
            Brand_ID__pc = 'SCRB000012952752',
            Company_ID__pc = 'SCRC000012952752',
            Service_Id__pc = 'SENIRCARE',               // The primary service of the provider is child care
            Sub_Service_Id__pc = 'homeCare',            // Their secondary service is day care
            membertype__pc = 'SMB_Provider',            
            overallstatus__pc = 'Active Basic',         // Basics have an overallstatus of Active Basic
            //pricing_features__pc = '',                  // blank for basics;     
            pricing_plan_id__pc = 'SMBBASIC',           // Pricing Plan all SMB basics get
            status__pc = 'Active',
            type__pc = 'Basic'                          // Basics have a type of 'Basic'

            );

        insert a;

        Account[] accountList = [SELECT id,firstName,PersonEmail,memberid__pc,type__pc,recordtypeid,isPersonAccount,overallstatus__pc,pricing_plan_id__pc,
                                    Service_Id__pc,Sub_Service_Id__pc,membertype__pc,memberid__c
                                    FROM Account WHERE id = :a.id];

        // check the vitals
        System.assert(accountList.size() == 1);
        System.assert(accountList[0].firstName == firstName);
        System.assert(accountList[0].PersonEmail == email);
        System.assert(accountList[0].memberid__c == String.valueOf(memberId));
        System.assert(accountList[0].memberid__pc == memberId);
        System.assert(accountList[0].isPersonAccount == true);

        // check it is a Basic Senior Home Care Marketplace provider
        System.assert(accountList[0].recordtypeid == smbpaRtId);
        System.assert(accountList[0].membertype__pc == 'SMB_Provider');
        System.assert(accountList[0].type__pc == 'Basic');
        System.assert(accountList[0].pricing_plan_id__pc == 'SMBBASIC');
        System.assert(accountList[0].Service_Id__pc == 'SENIRCARE');
        System.assert(accountList[0].Sub_Service_Id__pc == 'homeCare');

    }

    public static testMethod void createBasicSeniorHousingMarketplaceProvider() {
        // This method creates a Basic Senior Housing SMB Provider 
        
        String firstName = SeniorCareHousingProviderFirstName;
        String lastName = 'Brady';
        String email = SeniorCareHousingProviderEmail;
        Integer memberId = SeniorCareHousingProviderMemberId;
        String companyName = SeniorCareHousingProviderBusinessName;
        String locationId = SeniorCareHousingProviderLocationId;

        Account a = new Account(
            basicmembersignupdate__pc = date.today(),
            blacklisted__pc = false,
            firstname = firstName,
            groupie__pc = false,
            groups__pc = '',
            ipaddress__pc = '127.0.0.1',
            karoo__pc = false,
            lastname = lastName,
            memberid__c = String.valueOf(memberId), 
            memberid__pc = memberId,
            membershipcreationdate__pc = date.today(),
            messagenotificationfrequency__pc = 'immediately',
            no_longer_with_company__pc = false,  
            optinmemberalert__pc = false,
            optinnewsletters__pc = true,
            optinoffers__pc  = true,
            optinphone__pc = false, 
            optinprovideralert__pc = true, 
            overallstatuschangedate__pc = date.today(),
            PersonEmail = email,
            personhomephone = '(555) 555-5555',
            personmailingcity = 'Jamaica Plain',
            personmailingpostalcode = '02130',
            personmailingstate = 'MA',
            personotherphone = '(666) 666-6666',
            pricetestcellscheme__pc = '',             
            product_type__pc = 'SUBSCRIPTION',
            provideralertfrequency__pc = 'weekly',
            receiving_emails__pc = true,
            rx1__pc = 'sem_Google', 
            rx2__pc = 'General_Brand',           
            rx3__pc = 'care com_e',
            rx4__pc = '99999999999',
            rx5__pc = 'General_Exact',
            statuschangedate__pc = date.today(),

            // Fields that correspond to member status should be put here to make them easier to modify later
            recordtypeid = smbpaRtId,
            Business_Name__pc = companyName,
            Location_ID__pc = locationId,
            Brand_ID__pc = 'SCRB000012952752',
            Company_ID__pc = 'SCRC000012952752',
            Service_Id__pc = 'SENIRCARE',               // The primary service of the provider is child care
            Sub_Service_Id__pc = 'housing',         // Their secondary service is day care
            membertype__pc = 'SMB_Provider',            
            overallstatus__pc = 'Active Basic',         // Basics have an overallstatus of Active Basic
            //pricing_features__pc = '',                  // blank for basics;     
            pricing_plan_id__pc = 'SMBBASIC',           // Pricing Plan all SMB basics get
            status__pc = 'Active',
            type__pc = 'Basic'                          // Basics have a type of 'Basic'

            );

        insert a;

        Account[] accountList = [SELECT id,firstName,PersonEmail,memberid__pc,type__pc,recordtypeid,isPersonAccount,overallstatus__pc,pricing_plan_id__pc,
                                    Service_Id__pc,Sub_Service_Id__pc,membertype__pc,memberid__c
                                    FROM Account WHERE id = :a.id];

        // check the vitals
        System.assert(accountList.size() == 1);
        System.assert(accountList[0].firstName == firstName);
        System.assert(accountList[0].PersonEmail == email);
        System.assert(accountList[0].memberid__c == String.valueOf(memberId));
        System.assert(accountList[0].memberid__pc == memberId);
        System.assert(accountList[0].isPersonAccount == true);

        // check it is a Basic Senior Housing SMB Provider 
        System.assert(accountList[0].recordtypeid == smbpaRtId);
        System.assert(accountList[0].membertype__pc == 'SMB_Provider');
        System.assert(accountList[0].type__pc == 'Basic');
        System.assert(accountList[0].pricing_plan_id__pc == 'SMBBASIC');
        System.assert(accountList[0].Service_Id__pc == 'SENIRCARE');
        System.assert(accountList[0].Sub_Service_Id__pc == 'housing');
    }

    public static testMethod void createBasicChildCareMarketplaceProvider() {
        // This method creates a Basic Child Care Marketplace provider

        String firstName = ChildCareProviderFirstName;
        String lastName = 'Brady';
        String email = ChildCareProviderEmail;
        Integer memberId = ChildCareProviderMemberId;
        String companyName = ChildCareProviderBusinessName;
        String locationId = ChildCareProviderLocationId;

        Account a = new Account(
            basicmembersignupdate__pc = date.today(),
            blacklisted__pc = false,
            firstname = firstName,
            groupie__pc = false,
            groups__pc = '',
            ipaddress__pc = '127.0.0.1',
            karoo__pc = false,
            lastname = lastName,
            memberid__c = String.valueOf(memberId), 
            memberid__pc = memberId,
            membershipcreationdate__pc = date.today(),
            messagenotificationfrequency__pc = 'immediately',
            no_longer_with_company__pc = false,  
            optinmemberalert__pc = false,
            optinnewsletters__pc = true,
            optinoffers__pc  = true,
            optinphone__pc = false, 
            optinprovideralert__pc = true, 
            overallstatuschangedate__pc = date.today(),
            PersonEmail = email,
            personhomephone = '(555) 555-5555',
            personmailingcity = 'Jamaica Plain',
            personmailingpostalcode = '02130',
            personmailingstate = 'MA',
            personotherphone = '(666) 666-6666',
            pricetestcellscheme__pc = '',             
            product_type__pc = 'SUBSCRIPTION',
            provideralertfrequency__pc = 'weekly',
            receiving_emails__pc = true,
            rx1__pc = 'sem_Google', 
            rx2__pc = 'General_Brand',           
            rx3__pc = 'care com_e',
            rx4__pc = '99999999999',
            rx5__pc = 'General_Exact',
            statuschangedate__pc = date.today(),

            // Fields that correspond to member status should be put here to make them easier to modify later
            recordtypeid = smbpaRtId,
            Business_Name__pc = companyName,
            Location_ID__pc = locationId,
            Brand_ID__pc = 'SCRB000012952752',
            Company_ID__pc = 'SCRC000012952752',
            Service_Id__pc = 'CHILDCARE',               // The primary service of the provider is child care
            Sub_Service_Id__pc = 'familyCare',          // Their secondary service is day care
            membertype__pc = 'SMB_Provider',            
            overallstatus__pc = 'Active Basic',         // Basics have an overallstatus of Active Basic
            //pricing_features__pc = '',                  // blank for basics;     
            pricing_plan_id__pc = 'SMBBASIC',           // Pricing Plan all SMB basics get
            status__pc = 'Active',
            type__pc = 'Basic'                          // Basics have a type of 'Basic'

            );

        insert a;

        Account[] accountList = [SELECT id,firstName,PersonEmail,memberid__pc,type__pc,recordtypeid,isPersonAccount,overallstatus__pc,pricing_plan_id__pc,
                                    Service_Id__pc,Sub_Service_Id__pc,membertype__pc,memberid__c
                                    FROM Account WHERE id = :a.id];

        // check the vitals
        System.assert(accountList.size() == 1);
        System.assert(accountList[0].firstName == firstName);
        System.assert(accountList[0].PersonEmail == email);
        System.assert(accountList[0].memberid__c == String.valueOf(memberId));
        System.assert(accountList[0].memberid__pc == memberId);
        System.assert(accountList[0].isPersonAccount == true);

        // check it is a Basic Child Care Marketplace provider
        System.assert(accountList[0].recordtypeid == smbpaRtId);
        System.assert(accountList[0].membertype__pc == 'SMB_Provider');
        System.assert(accountList[0].type__pc == 'Basic');
        System.assert(accountList[0].pricing_plan_id__pc == 'SMBBASIC');
        System.assert(accountList[0].Service_Id__pc == 'CHILDCARE');
        System.assert(accountList[0].Sub_Service_Id__pc == 'familyCare');

    }

    public static testMethod void createBasicChildCareSeeker(){
        // This method creates a Basic Child Care Seeker as a person account
        
        String firstName = BasicChildCareSeekerFirstName;
        String lastName = 'Brady';
        String email = BasicChildCareSeekerEmail;
        Integer memberId = BasicChildCareSeekerMemberId;

        Account a = new Account(
            recordtypeid = saRtId,
            basicmembersignupdate__pc = date.today(),
            blacklisted__pc = false,
            firstname = firstName,
            groupie__pc = false,
            groups__pc = '',
            ipaddress__pc = '127.0.0.1',
            karoo__pc = false,
            lastname = lastName,
            memberid__c = String.valueOf(memberId), 
            memberid__pc = memberId,
            membershipcreationdate__pc = date.today(),
            messagenotificationfrequency__pc = 'immediately',
            no_longer_with_company__pc = false,  
            optinmemberalert__pc = false,
            optinnewsletters__pc = true,
            optinoffers__pc  = true,
            optinphone__pc = false, 
            optinprovideralert__pc = true, 
            overallstatuschangedate__pc = date.today(),
            PersonEmail = email,
            personhomephone = '(555) 555-5555',
            personmailingcity = 'Jamaica Plain',
            personmailingpostalcode = '02130',
            personmailingstate = 'MA',
            personotherphone = '(666) 666-6666',
            pricetestcellscheme__pc = '',             
            product_type__pc = 'SUBSCRIPTION',
            provideralertfrequency__pc = 'weekly',
            receiving_emails__pc = true,
            rx1__pc = 'sem_Google', 
            rx2__pc = 'General_Brand',           
            rx3__pc = 'care com_e',
            rx4__pc = '99999999999',
            rx5__pc = 'General_Exact',
            statuschangedate__pc = date.today(),

            // Fields that correspond to member status should be put here to make them easier to modify later
            membertype__pc = 'Seeker',
            overallstatus__pc = 'Active Basic',         // Basics have an overallstatus of Active Basic
            //pricing_features__pc = '',                  // blank for basics;     
            pricing_plan_id__pc = 'BASICPLAN',          // Pricing Plan all basics get
            Service_Id__pc = 'CHILDCARE',               // The Basic's primary service is child care
            status__pc = 'Active',
            type__pc = 'Basic'                          // Basics have a type of 'Basic'
            );

        insert a;

        Account[] accountList = [SELECT id,firstName,PersonEmail,memberid__pc,type__pc,recordtypeid,isPersonAccount,overallstatus__pc,pricing_plan_id__pc,
                                    Service_Id__pc,Sub_Service_Id__pc,membertype__pc,memberid__c
                                    FROM Account WHERE id = :a.id];

        // check the vitals
        System.assert(accountList.size() == 1);
        System.assert(accountList[0].firstName == firstName);
        System.assert(accountList[0].PersonEmail == email);
        System.assert(accountList[0].memberid__c == String.valueOf(memberId));
        System.assert(accountList[0].memberid__pc == memberId);
        System.assert(accountList[0].isPersonAccount == true);

        // check it is a Basic Child Care Seeker
        System.assert(accountList[0].recordtypeid == saRtId);
        System.assert(accountList[0].membertype__pc == 'Seeker');
        System.assert(accountList[0].type__pc == 'Basic');
        System.assert(accountList[0].pricing_plan_id__pc == 'BASICPLAN');
        System.assert(accountList[0].Service_Id__pc == 'CHILDCARE');
    }

    public static testMethod void createBasicChildCareSeekerBulk(){
        // This method creates many Basic Child Care Seeker as a person account in a single transcation
        
        String firstName = BasicChildCareSeekerFirstName;
        String lastName = 'Brady';
        String email = '';
        Integer memberId = BasicChildCareSeekerMemberId;
        
        List<Account> Accounts = new List<Account>();
        for (Integer i = 0; i < bulkLimit; i++ ){
            email = 'jackodell+bulkseeker' + i + '@gmail.com';

            Account a = new Account(
                recordtypeid = saRtId,
                basicmembersignupdate__pc = date.today(),
                blacklisted__pc = false,
                firstname = firstName,
                groupie__pc = false,
                groups__pc = '',
                ipaddress__pc = '127.0.0.1',
                karoo__pc = false,
                lastname = lastName,
                memberid__c = String.valueOf(memberId+i), 
                memberid__pc = memberId+i,
                membershipcreationdate__pc = date.today(),
                messagenotificationfrequency__pc = 'immediately',
                no_longer_with_company__pc = false,  
                optinmemberalert__pc = false,
                optinnewsletters__pc = true,
                optinoffers__pc  = true,
                optinphone__pc = false, 
                optinprovideralert__pc = true, 
                overallstatuschangedate__pc = date.today(),
                PersonEmail = email,
                personhomephone = '(555) 555-5555',
                personmailingcity = 'Jamaica Plain',
                personmailingpostalcode = '02130',
                personmailingstate = 'MA',
                personotherphone = '(666) 666-6666',
                pricetestcellscheme__pc = '',             
                product_type__pc = 'SUBSCRIPTION',
                provideralertfrequency__pc = 'weekly',
                receiving_emails__pc = true,
                rx1__pc = 'sem_Google', 
                rx2__pc = 'General_Brand',           
                rx3__pc = 'care com_e',
                rx4__pc = '99999999999',
                rx5__pc = 'General_Exact',
                statuschangedate__pc = date.today(),
    
                // Fields that correspond to member status should be put here to make them easier to modify later
                membertype__pc = 'Seeker',
                overallstatus__pc = 'Active Basic',         // Basics have an overallstatus of Active Basic
                //pricing_features__pc = '',                  // blank for basics;     
                pricing_plan_id__pc = 'BASICPLAN',          // Pricing Plan all basics get
                Service_Id__pc = 'CHILDCARE',               // The Basic's primary service is child care
                status__pc = 'Active',
                type__pc = 'Basic'                          // Basics have a type of 'Basic'
                );
    
            Accounts.add(a);
        }

        insert Accounts;
        
        Account[] accountList = [SELECT id,firstName,PersonEmail,memberid__pc,type__pc,recordtypeid,isPersonAccount,overallstatus__pc,pricing_plan_id__pc,
                                    Service_Id__pc,Sub_Service_Id__pc,membertype__pc,memberid__c
                                    FROM Account WHERE id IN :Accounts];


        // check the vitals
        for (Account a : accountList){
            System.assertEquals(a.firstName,firstName,'First Name is wrong.');
            //System.assert(a.PersonEmail == email);
            //System.assert(a.memberid__c == String.valueOf(memberId));
            //System.assert(a.memberid__pc == memberId);
            System.assertEquals(a.isPersonAccount,true,'Is not Person Account');
    
            // check it is a Basic Child Care Seeker
            System.assertEquals(a.recordtypeid,saRtId,'Record Type is not Seeker');
            System.assertEquals(a.membertype__pc,'Seeker','Member Type is not seeker');
            System.assertEquals(a.type__pc,'Basic','Account Type is not Basic');
            System.assertEquals(a.pricing_plan_id__pc,'BASICPLAN','Pricing Plan is not BASICPLAN');
            System.assertEquals(a.Service_Id__pc,'CHILDCARE','Service is not CHILDCARE');
        }
    }
    
    public static testMethod void createPremiumSeeker(){
        // Creates premium child care seeker with 1 month plan as a person account
        
        String firstName = PremiumSeekerFirstName;
        String lastName = 'Brady';
        String email = PremiumSeekerEmail;
        Integer memberId = PremiumSeekerMemberId;

        Account a = new Account(
            recordtypeid = saRtId,
            basicmembersignupdate__pc = date.today(),
            blacklisted__pc = false,
            firstname = firstName,
            groupie__pc = false,
            groups__pc = '',
            ipaddress__pc = '127.0.0.1',
            karoo__pc = false,
            lastname = lastName,
            memberid__c = String.valueOf(memberId), 
            memberid__pc = memberId,
            membershipcreationdate__pc = date.today(),
            messagenotificationfrequency__pc = 'immediately',
            no_longer_with_company__pc = false,  
            optinmemberalert__pc = false,
            optinnewsletters__pc = true,
            optinoffers__pc  = true,
            optinphone__pc = false, 
            optinprovideralert__pc = true, 
            overallstatuschangedate__pc = date.today(),
            PersonEmail = email,
            personhomephone = '(555) 555-5555',
            personmailingcity = 'Jamaica Plain',
            personmailingpostalcode = '02130',
            personmailingstate = 'MA',
            personotherphone = '(666) 666-6666',
            provideralertfrequency__pc = 'weekly',
            receiving_emails__pc = true,
            rx1__pc = 'sem_Google', 
            rx2__pc = 'General_Brand',           
            rx3__pc = 'care com_e',
            rx4__pc = '99999999999',
            rx5__pc = 'General_Exact',
            status__pc = 'Active',
            statuschangedate__pc = date.today(),

            // Fields that correspond to member status should be put here to make them easier to modify later
            membertype__pc = 'Seeker',
            nextpaymentdate__pc = date.today().addMonths(1), // 1 month plan, we set next payment date 1 month in the future
            overallstatus__pc = 'Active Premium',           // Premiums that are active have an overallstatus of Active Premium
            //pricing_features__pc = 'CONSUMER_FULL_SUBSCRIPTION; CONV_PAYMENT_TRANS_FEE_1', // Premiums can have pricing features                    
            Pricing_Plan_Duration__pc = 1,                  // This is a 1 month plan
            Pricing_Plan_Fee__pc = 39.00,                   // The cost associated with this plan
            pricing_plan_id__pc = 'MAR132001',              // Premiums have pricing plans associated with their accounts
            pricetestcellscheme__pc = 'MAR132',           
            product_type__pc = 'SUBSCRIPTION',
            Service_Id__pc = 'CHILDCARE',                   // The primary service of this seeker is child care
            type__pc = 'Premium'                            // Premiums have a type of 'Premium'

            );

        insert a;

        Account[] accountList = [SELECT id,firstName,PersonEmail,memberid__pc,type__pc,recordtypeid,isPersonAccount,overallstatus__pc,pricing_plan_id__pc,
                                    Service_Id__pc,Sub_Service_Id__pc,membertype__pc,Pricing_Plan_Duration__pc,memberid__c
                                    FROM Account WHERE id = :a.id];

        // check the vitals
        System.assert(accountList.size() == 1);
        System.assert(accountList[0].firstName == firstName);
        System.assert(accountList[0].PersonEmail == email);
        System.assert(accountList[0].memberid__c == String.valueOf(memberId));
        System.assert(accountList[0].memberid__pc == memberId);
        System.assert(accountList[0].isPersonAccount == true);

        // check it is a Premium child care seeker with a 1 month plan
        System.assert(accountList[0].recordtypeid == saRtId);
        System.assert(accountList[0].membertype__pc == 'Seeker');
        System.assert(accountList[0].overallstatus__pc == 'Active Premium');
        //System.assert(accountList[0].pricing_features__pc != '');
        System.assert(accountList[0].Pricing_Plan_Duration__pc == 1);
        System.assert(accountList[0].type__pc == 'Premium');
        System.assert(accountList[0].pricing_plan_id__pc != 'BASICPLAN');
        System.assert(accountList[0].Service_Id__pc == 'CHILDCARE');
    }

    public static testMethod void createNthDayPremiumSeeker(){
        // Creates a Basic Child Care Seeker and then upgrades them to a Premium 
        // Premiums who upgrade from Basics are known as NthDayPremium Seekers because it took them N days to become Premiums
        
        String firstName = NthDayPremiumSeekerFirstName;
        String email = NthDayPremiumSeekerEmail;
        Integer memberId = NthDayPremiumSeekerMemberId;
        
        // Create Basic Seeker Person Account
        createBasicChildCareSeeker();
        
        //Query for Basic Seeker Person Contact
        Contact basicSeeker = [SELECT id, type__c, Pricing_Plan_Fee__c, pricing_plan_id__c, pricetestcellscheme__c,
                                        nextpaymentdate__c,  overallstatuschangedate__c, premiummembersignupdate__c,
                                        statuschangedate__c, firstName, email, memberid__c 
                                 FROM Contact WHERE memberid__c = :BasicChildCareSeekerMemberId];

        // sanity check we're actually getting a basic
        System.assert(basicSeeker.type__c != 'Premium');
        //System.assert(basicSeeker.pricing_features__c != 'CONSUMER_FULL_SUBSCRIPTION; CONV_PAYMENT_TRANS_FEE_1');
        System.assert(basicSeeker.Pricing_Plan_Fee__c != 39.00);
        System.assert(basicSeeker.pricing_plan_id__c != 'MAR132001');
        System.assert(basicSeeker.pricetestcellscheme__c != 'MAR132');
        System.assert(basicSeeker.nextpaymentdate__c != date.today().addMonths(1));
        //System.assert(basicSeeker.lastpaymentdate__c != date.today());
        System.assert(basicSeeker.premiummembersignupdate__c != date.today());
        System.assert(basicSeeker.firstName == BasicChildCareSeekerFirstName);   
        System.assert(basicSeeker.email == BasicChildCareSeekerEmail);           
        System.assert(basicSeeker.memberid__c == BasicChildCareSeekerMemberId);  

        // NthDay Premium Seeker upgraded today with a 1 month plan
        basicSeeker.nextpaymentdate__c = date.today().addMonths(1);         // 1 month plan, we set next payment date 1 month in the future
        basicSeeker.Pricing_Plan_Duration__c = 1;                           // This is a 1 month plan
        //basicSeeker.lastpaymentdate__c = date.today();                      // Set to today
        basicSeeker.overallstatus__c = 'Active Premium';                    // Premiums that are active have an overallstatus of Active Premium
        basicSeeker.overallstatuschangedate__c = date.today();              // Set to today
        basicSeeker.premiummembersignupdate__c = date.today();              // Set to today
        basicSeeker.statuschangedate__c = date.today();                     // Set to today
        basicSeeker.type__c = 'Premium';                                    // Premiums have a type of 'Premium'
        //basicSeeker.pricing_features__c = 'CONSUMER_FULL_SUBSCRIPTION; CONV_PAYMENT_TRANS_FEE_1';  // Premiums can have pricing features       
        basicSeeker.Pricing_Plan_Fee__c = 39.00;                            // The cost associated with this plan
        basicSeeker.pricing_plan_id__c = 'MAR132001';
        basicSeeker.pricetestcellscheme__c = 'MAR132';   
        basicSeeker.firstName = firstName;                                  // updating from basic to nthday premium names   
        basicSeeker.email = email;                                          // updating from basic to nthday premium names
        basicSeeker.memberid__c = memberId;                                 // updating from basic to nthday premium names
        update basicSeeker; 

        Contact nthDayPremium = [SELECT id,type__c,Pricing_Plan_Fee__c,pricing_plan_id__c,pricetestcellscheme__c,
                                        nextpaymentdate__c,overallstatuschangedate__c,premiummembersignupdate__c,
                                        statuschangedate__c,firstName,email,memberid__c
                                    FROM Contact WHERE id = :basicSeeker.id];

        // Sanity check that the seeker has been upgraded 
        System.assert(nthDayPremium.type__c == 'Premium');
        //System.assert(nthDayPremium.pricing_features__c.contains('CONSUMER_FULL_SUBSCRIPTION'));
        //System.assert(nthDayPremium.pricing_features__c.contains('CONV_PAYMENT_TRANS_FEE_1'));
        System.assert(nthDayPremium.Pricing_Plan_Fee__c == 39.00);
        System.assert(nthDayPremium.pricing_plan_id__c == 'MAR132001');
        System.assert(nthDayPremium.pricetestcellscheme__c == 'MAR132');
        System.assert(nthDayPremium.type__c == 'Premium');
        System.assert(nthDayPremium.nextpaymentdate__c == date.today().addMonths(1));
        //System.assert(nthDayPremium.lastpaymentdate__c == date.today());
        System.assert(nthDayPremium.overallstatuschangedate__c == date.today());
        System.assert(nthDayPremium.premiummembersignupdate__c == date.today());
        System.assert(nthDayPremium.statuschangedate__c == date.today());
        System.assert(nthDayPremium.firstName == firstName);    
        System.assert(nthDayPremium.email == email);            
        System.assert(nthDayPremium.memberid__c == memberId);   


    }

    public static testMethod void createNthDayPremiumSeekerUSAA(){
        // Creates Nth Day Premium Seeker who is a USAA member 
        
        String firstName = NthDayPremiumSeekerUSAAFirstName;
        String email = NthDayPremiumSeekerUSAAEmail;
        Integer memberId = NthDayPremiumSeekerUSAAMemberId;
        
        // Create Basic Seeker Person Account
        createBasicChildCareSeeker();
        
        //Query for Basic Seeker Person Contact
        Contact basicSeeker = [SELECT id, type__c,  Pricing_Plan_Fee__c, pricing_plan_id__c, pricetestcellscheme__c,
                                        nextpaymentdate__c, overallstatuschangedate__c, premiummembersignupdate__c,
                                        statuschangedate__c, firstName, email, memberid__c,USAA_Member__c 
                                 FROM Contact WHERE memberid__c = :BasicChildCareSeekerMemberId];

        // sanity check we're actually getting a basic
        System.assert(basicSeeker.type__c != 'Premium');
        //System.assert(basicSeeker.pricing_features__c != 'CONSUMER_FULL_SUBSCRIPTION; CONV_PAYMENT_TRANS_FEE_1');
        System.assert(basicSeeker.Pricing_Plan_Fee__c != 39.00);
        System.assert(basicSeeker.pricing_plan_id__c != 'MAR132001');
        System.assert(basicSeeker.pricetestcellscheme__c != 'MAR132');
        System.assert(basicSeeker.type__c != 'Premium');
        System.assert(basicSeeker.nextpaymentdate__c != date.today().addMonths(1));
        //System.assert(basicSeeker.lastpaymentdate__c != date.today());
        System.assert(basicSeeker.premiummembersignupdate__c != date.today());
        System.assert(basicSeeker.firstName == BasicChildCareSeekerFirstName);   
        System.assert(basicSeeker.email == BasicChildCareSeekerEmail);           
        System.assert(basicSeeker.memberid__c == BasicChildCareSeekerMemberId);  
        System.assert(basicSeeker.USAA_Member__c == false);                 // Sanity check that they're not a USAA member yet 

        // NthDay Premium Seeker upgraded today with a 1 month plan
        basicSeeker.nextpaymentdate__c = date.today().addMonths(1);         // 1 month plan, we set next payment date 1 month in the future
        basicSeeker.Pricing_Plan_Duration__c = 1;                           // This is a 1 month plan
        //basicSeeker.lastpaymentdate__c = date.today();                      // Set to today
        basicSeeker.overallstatus__c = 'Active Premium';                    // Premiums that are active have an overallstatus of Active Premium
        basicSeeker.overallstatuschangedate__c = date.today();              // Set to today
        basicSeeker.premiummembersignupdate__c = date.today();              // Set to today
        basicSeeker.statuschangedate__c = date.today();                     // Set to today
        basicSeeker.type__c = 'Premium';                                    // Premiums have a type of 'Premium'
        //basicSeeker.pricing_features__c = 'CONSUMER_FULL_SUBSCRIPTION; CONV_PAYMENT_TRANS_FEE_1';  // Premiums can have pricing features       
        basicSeeker.Pricing_Plan_Fee__c = 39.00;                            // The cost associated with this plan
        basicSeeker.pricing_plan_id__c = 'MAR132001';
        basicSeeker.pricetestcellscheme__c = 'MAR132';   
        basicSeeker.firstName = firstName;                                  // updating from basic to nthday premium names   
        basicSeeker.email = email;                                          // updating from basic to nthday premium names
        basicSeeker.memberid__c = memberId;                                 // updating from basic to nthday premium names
        basicSeeker.USAA_Member__c = true;                                  // Make Seeker a USAA member  
        update basicSeeker; 

        Contact nthDayPremium = [SELECT id,type__c,Pricing_Plan_Fee__c,pricing_plan_id__c,pricetestcellscheme__c,
                                        nextpaymentdate__c,overallstatuschangedate__c,premiummembersignupdate__c,
                                        statuschangedate__c,firstName,email,memberid__c,USAA_Member__c
                                    FROM Contact WHERE id = :basicSeeker.id];

        // Sanity check that the seeker has been upgraded 
        System.assert(nthDayPremium.type__c == 'Premium');
        //System.assert(nthDayPremium.pricing_features__c.contains('CONSUMER_FULL_SUBSCRIPTION'));
        //System.assert(nthDayPremium.pricing_features__c.contains('CONV_PAYMENT_TRANS_FEE_1'));
        System.assert(nthDayPremium.Pricing_Plan_Fee__c == 39.00);
        System.assert(nthDayPremium.pricing_plan_id__c == 'MAR132001');
        System.assert(nthDayPremium.pricetestcellscheme__c == 'MAR132');
        System.assert(nthDayPremium.type__c == 'Premium');
        System.assert(nthDayPremium.nextpaymentdate__c == date.today().addMonths(1));
        //System.assert(nthDayPremium.lastpaymentdate__c == date.today());
        System.assert(nthDayPremium.overallstatuschangedate__c == date.today());
        System.assert(nthDayPremium.premiummembersignupdate__c == date.today());
        System.assert(nthDayPremium.statuschangedate__c == date.today());
        System.assert(nthDayPremium.firstName == firstName);    
        System.assert(nthDayPremium.email == email);            
        System.assert(nthDayPremium.memberid__c == memberId);   

        // Sanity check the USAA flag is still there
        System.assert(nthDayPremium.USAA_Member__c == true);    
       
    }

    public static testMethod void createBasicProvider(){
        // Creates a basic child care provider as a person account 
        
        String firstName = BasicProviderFirstName;
        String lastName = 'Poppins';
        String email = BasicProviderEmail;
        Integer memberId = BasicProviderMemberId;

        Account a = new Account(
            basicmembersignupdate__pc = date.today(),
            blacklisted__pc = false,
            firstname = firstName,
            groupie__pc = false,
            groups__pc = '',
            ipaddress__pc = '127.0.0.1',
            karoo__pc = false,
            lastname = lastName,
            memberid__c = String.valueOf(memberId), 
            memberid__pc = memberId,
            membershipcreationdate__pc = date.today(),
            messagenotificationfrequency__pc = 'immediately',
            no_longer_with_company__pc = false,  
            optinmemberalert__pc = false,
            optinnewsletters__pc = true,
            optinoffers__pc  = true,
            optinphone__pc = false, 
            optinprovideralert__pc = true, 
            overallstatuschangedate__pc = date.today(),
            PersonEmail = email,
            personhomephone = '(555) 555-5555',
            personmailingcity = 'Jamaica Plain',
            personmailingpostalcode = '02130',
            personmailingstate = 'MA',
            personotherphone = '(666) 666-6666',
            pricetestcellscheme__pc = '',             
            product_type__pc = 'SUBSCRIPTION',
            provideralertfrequency__pc = 'weekly',
            receiving_emails__pc = true,
            rx1__pc = 'sem_Google', 
            rx2__pc = 'General_Brand',           
            rx3__pc = 'care com_e',
            rx4__pc = '99999999999',
            rx5__pc = 'General_Exact',
            statuschangedate__pc = date.today(),

            // Fields that correspond to member status should be put here to make them easier to modify later
            recordtypeid = paRtId,  // Providers use the "Provider" record type
            membertype__pc = 'Provider',                // Providers have a membertype of "Provider"
            overallstatus__pc = 'Active Basic',         // Basics have an overallstatus of Active Basic
            //pricing_features__pc = '',                  // blank for basics;     
            pricing_plan_id__pc = 'BASICPLAN',          // Pricing Plan all basics get
            Service_Id__pc = 'CHILDCARE',               // The Basic's primary service is child care
            PersonBirthdate = date.today().addYears(-20), // Making babysitter 20 years so that we don't we trigger underage babysitter logic 
            FirstApprovalDate__pc = date.today(),       // Providers need to be approved, so setting this date to today
            InitialApprovalDateChildCare__pc = date.today(), // Stamping Child Care profile as approved
            ProfileQualityChildCare__pc = 'Med',            // Child Care profile quality
            CurrentStatusChildCare__pc = 'Active',      // Marking Child Care profile as active
            status__pc = 'Active',
            type__pc = 'Individual'                     // Individual providers (as opposed to marketplace providers) have this value as "Individual"
            );

        insert a;

        Account[] accountList = [SELECT id,firstName,PersonEmail,memberid__pc,type__pc,recordtypeid,isPersonAccount,overallstatus__pc,pricing_plan_id__pc,
                                    Service_Id__pc,Sub_Service_Id__pc,membertype__pc,memberid__c
                                    FROM Account WHERE id = :a.id];

        // check the vitals
        System.assert(accountList.size() == 1);
        System.assert(accountList[0].firstName == firstName);
        System.assert(accountList[0].PersonEmail == email);
        System.assert(accountList[0].memberid__c == String.valueOf(memberId));
        System.assert(accountList[0].memberid__pc == memberId);
        System.assert(accountList[0].isPersonAccount == true);

        // check it is a Basic Child Care Provider
        System.assert(accountList[0].recordtypeid == paRtId);
        System.assert(accountList[0].membertype__pc == 'Provider');
        System.assert(accountList[0].type__pc == 'Individual');
        System.assert(accountList[0].pricing_plan_id__pc == 'BASICPLAN');
        System.assert(accountList[0].Service_Id__pc == 'CHILDCARE');
    }

    public static testMethod void createPremiumProvider(){
        // Creates a Premium Child Care Provider as a Person Account 
        
        String firstName = PremiumProviderFirstName;
        String lastName = 'Brady';
        String email = PremiumProviderEmail;
        Integer memberId = PremiumProviderMemberId;

        Account a = new Account(
            basicmembersignupdate__pc = date.today(),
            blacklisted__pc = false,
            firstname = firstName,
            groupie__pc = false,
            groups__pc = '',
            ipaddress__pc = '127.0.0.1',
            karoo__pc = false,
            lastname = lastName,
            memberid__c = String.valueOf(memberId), 
            memberid__pc = memberId,
            membershipcreationdate__pc = date.today(),
            messagenotificationfrequency__pc = 'immediately',
            no_longer_with_company__pc = false,  
            optinmemberalert__pc = false,
            optinnewsletters__pc = true,
            optinoffers__pc  = true,
            optinphone__pc = false, 
            optinprovideralert__pc = true, 
            overallstatuschangedate__pc = date.today(),
            PersonEmail = email,
            personhomephone = '(555) 555-5555',
            personmailingcity = 'Jamaica Plain',
            personmailingpostalcode = '02130',
            personmailingstate = 'MA',
            personotherphone = '(666) 666-6666',
            provideralertfrequency__pc = 'weekly',
            receiving_emails__pc = true,
            rx1__pc = 'sem_Google', 
            rx2__pc = 'General_Brand',           
            rx3__pc = 'care com_e',
            rx4__pc = '99999999999',
            rx5__pc = 'General_Exact',
            statuschangedate__pc = date.today(),

            // Fields that correspond to member status should be put here to make them easier to modify later
            recordtypeid = paRtId,  // Providers use the "Provider" record type
            membertype__pc = 'Provider',                // Providers have a membertype of "Provider"
            Service_Id__pc = 'CHILDCARE',               // The provider's primary service is child care
            PersonBirthdate = date.today().addYears(-20), // Making babysitter 20 years so that we don't we trigger underage babysitter logic 
            FirstApprovalDate__pc = date.today(),       // Providers need to be approved, so setting this date to today
            InitialApprovalDateChildCare__pc = date.today(), // Stamping Child Care profile as approved
            ProfileQualityChildCare__pc = 'Med',            // Child Care profile quality
            CurrentStatusChildCare__pc = 'Active',      // Marking Child Care profile as active
            overallstatus__pc = 'Active Featured',      // Premiums have an overallstatus of Active Featured
            //pricing_features__pc = '',                       
            Pricing_Plan_Fee__pc = 20.00,               // The cost associated with this plan
            Pricing_Plan_Duration__pc = 1,              // This is a 1 month plan
            pricing_plan_id__pc = 'FPP082001',          // Premiums have pricing plans associated with their accounts
            pricetestcellscheme__pc = 'FPP082',           
            product_type__pc = 'SUBSCRIPTION',
            premiummembersignupdate__pc = date.today(),
            nextpaymentdate__pc = date.today().addMonths(1), // 1 month plan, we set next payment date 1 month in the future
            status__pc = 'Active',
            type__pc = 'Individual'                     // Individual providers (as opposed to marketplace providers) have this value as "Individual" even when premiums

            );

        insert a;

        Account[] accountList = [SELECT id,firstName,PersonEmail,memberid__pc,type__pc,recordtypeid,isPersonAccount,overallstatus__pc,pricing_plan_id__pc,
                                    Service_Id__pc,Sub_Service_Id__pc,membertype__pc,Pricing_Plan_Duration__pc,Pricing_Plan_Fee__pc,
                                    nextpaymentdate__pc,memberid__c
                                    FROM Account WHERE id = :a.id];

        // check the vitals
        System.assert(accountList.size() == 1);
        System.assert(accountList[0].firstName == firstName);
        System.assert(accountList[0].PersonEmail == email);
        System.assert(accountList[0].memberid__c == String.valueOf(memberId));
        System.assert(accountList[0].memberid__pc == memberId);
        System.assert(accountList[0].isPersonAccount == true);

        // check it is a Premium child care provider with a 1 month plan
        System.assert(accountList[0].recordtypeid == paRtId);
        System.assert(accountList[0].Pricing_Plan_Fee__pc == 20.00);
        System.assert(accountList[0].pricing_plan_id__pc == 'FPP082001');
        System.assert(accountList[0].membertype__pc == 'Provider');
        System.assert(accountList[0].overallstatus__pc == 'Active Featured');
        System.assert(accountList[0].Pricing_Plan_Duration__pc == 1);
        System.assert(accountList[0].type__pc == 'Individual');
        System.assert(accountList[0].Service_Id__pc == 'CHILDCARE');
        System.assert(accountList[0].nextpaymentdate__pc == date.today().addMonths(1));
    }

    public static testMethod void createNthDayPremiumProvider(){
        // Creates a Basic Child Care Provider and then upgrades them to a Premium 
        // Premiums who upgrade from Basics are known as NthDayPremium Providers because it took them N days to become Premiums
        
        String firstName = NthDayPremiumProviderFirstName;
        String email = NthDayPremiumProviderEmail;
        Integer memberId = NthDayPremiumProviderMemberId;
        
        // Create Basic Provider Person Account
        createBasicProvider();
        
        //Query for Basic Provider Person Contact
        Contact basicProvider = [SELECT id, type__c,  Pricing_Plan_Fee__c, pricing_plan_id__c, pricetestcellscheme__c,
                                        nextpaymentdate__c,  overallstatuschangedate__c, premiummembersignupdate__c,
                                        statuschangedate__c, firstName, email, memberid__c, overallstatus__c
                                 FROM Contact WHERE memberid__c = :BasicProviderMemberId];

        // sanity check we're actually getting a basic
        System.assert(basicProvider.overallstatus__c != 'Active Featured');
        System.assert(basicProvider.Pricing_Plan_Fee__c != 20.00);
        System.assert(basicProvider.pricing_plan_id__c != 'FPP082001');
        System.assert(basicProvider.pricetestcellscheme__c != 'FPP082');
        System.assert(basicProvider.nextpaymentdate__c != date.today().addMonths(1));
        //System.assert(basicProvider.lastpaymentdate__c != date.today());
        System.assert(basicProvider.premiummembersignupdate__c != date.today());
        System.assert(basicProvider.firstName == BasicProviderFirstName);   
        System.assert(basicProvider.email == BasicProviderEmail);           
        System.assert(basicProvider.memberid__c == BasicProviderMemberId);  

        // NthDay Premium Provider upgraded today with a 1 month plan
        basicProvider.nextpaymentdate__c = date.today().addMonths(1);       // 1 month plan, we set next payment date 1 month in the future
        basicProvider.Pricing_Plan_Duration__c = 1;                         // This is a 1 month plan
        //basicProvider.lastpaymentdate__c = date.today();                    // Set to today
        basicProvider.overallstatus__c = 'Active Featured';                 // Premium Providers that are active have an overallstatus of Active Featured
        basicProvider.overallstatuschangedate__c = date.today();            // Set to today
        basicProvider.premiummembersignupdate__c = date.today();            // Set to today
        basicProvider.statuschangedate__c = date.today();                   // Set to today
        basicProvider.type__c = 'Individual';                               // Premium Providers have a type of 'Individual'
        //basicProvider.pricing_features__c = '';                                    
        basicProvider.Pricing_Plan_Fee__c = 20.00;                          // The cost associated with this plan
        basicProvider.pricing_plan_id__c = 'FPP082001';
        basicProvider.pricetestcellscheme__c = 'FPP082';   
        basicProvider.firstName = firstName;                                // updating from basic to nthday premium names   
        basicProvider.email = email;                                        // updating from basic to nthday premium names
        basicProvider.memberid__c = memberId;                               // updating from basic to nthday premium names
        update basicProvider; 

        Contact nthDayPremium = [SELECT id,type__c,Pricing_Plan_Fee__c,pricing_plan_id__c,pricetestcellscheme__c,
                                        nextpaymentdate__c,overallstatuschangedate__c,premiummembersignupdate__c,
                                        statuschangedate__c,firstName,email,memberid__c,overallstatus__c
                                    FROM Contact WHERE id = :basicProvider.id];

        // Sanity check that the provider has been upgraded 
        System.assert(nthDayPremium.Pricing_Plan_Fee__c == 20.00);
        System.assert(nthDayPremium.pricing_plan_id__c == 'FPP082001');
        System.assert(nthDayPremium.pricetestcellscheme__c == 'FPP082');
        System.assert(nthDayPremium.overallstatus__c == 'Active Featured');
        System.assert(nthDayPremium.nextpaymentdate__c == date.today().addMonths(1));
        //System.assert(nthDayPremium.lastpaymentdate__c == date.today());
        System.assert(nthDayPremium.overallstatuschangedate__c == date.today());
        System.assert(nthDayPremium.premiummembersignupdate__c == date.today());
        System.assert(nthDayPremium.statuschangedate__c == date.today());
        System.assert(nthDayPremium.firstName == firstName);    
        System.assert(nthDayPremium.email == email);            
        System.assert(nthDayPremium.memberid__c == memberId);   
       
    }

    public static testMethod void createLite(){
        // This method creates a Lite member as a person account
        
        String firstName = LiteFirstName;
        String lastName = 'Benioff';
        String email = LiteEmail;
        Integer memberId = LiteMemberId;

        Account a = new Account(
            basicmembersignupdate__pc = date.today(),
            blacklisted__pc = false,
            firstname = firstName,
            groupie__pc = false,
            groups__pc = '',
            ipaddress__pc = '127.0.0.1',
            karoo__pc = false,
            lastname = lastName,
            memberid__c = String.valueOf(memberId), 
            memberid__pc = memberId,
            membershipcreationdate__pc = date.today(),
            messagenotificationfrequency__pc = 'immediately',
            no_longer_with_company__pc = false,  
            optinmemberalert__pc = false,
            optinnewsletters__pc = true,
            optinoffers__pc  = true,
            optinphone__pc = false, 
            optinprovideralert__pc = true, 
            overallstatuschangedate__pc = date.today(),
            PersonEmail = email,
            personhomephone = '(555) 555-5555',
            personmailingcity = 'Jamaica Plain',
            personmailingpostalcode = '02130',
            personmailingstate = 'MA',
            personotherphone = '(666) 666-6666',
            pricetestcellscheme__pc = '',             
            product_type__pc = 'SUBSCRIPTION',
            provideralertfrequency__pc = 'weekly',
            receiving_emails__pc = true,
            rx1__pc = 'sem_Google', 
            rx2__pc = 'General_Brand',           
            rx3__pc = 'care com_e',
            rx4__pc = '99999999999',
            rx5__pc = 'General_Exact',
            statuschangedate__pc = date.today(),

            // Fields that correspond to member status should be put here to make them easier to modify later
            recordtypeid = laRtId,
            membertype__pc = 'Lite',                    // Lites have a membertype of 'Lite'
            overallstatus__pc = 'Active Lite'           // Lites have an overallstatus of Active Lite
            );

        insert a;

        Account[] accountList = [SELECT id,firstName,PersonEmail,memberid__pc,type__pc,recordtypeid,isPersonAccount,overallstatus__pc,pricing_plan_id__pc,
                                    Service_Id__pc,Sub_Service_Id__pc,membertype__pc,memberid__c
                                    FROM Account WHERE id = :a.id];

        // check the vitals
        System.assert(accountList.size() == 1);
        System.assert(accountList[0].firstName == firstName);
        System.assert(accountList[0].PersonEmail == email);
        System.assert(accountList[0].memberid__c == String.valueOf(memberId));
        System.assert(accountList[0].memberid__pc == memberId);
        System.assert(accountList[0].isPersonAccount == true);

        // check it is a Lite
        System.assert(accountList[0].recordtypeid == laRtId);
        System.assert(accountList[0].membertype__pc == 'Lite');
        System.assert(accountList[0].overallstatus__pc == 'Active Lite');


    }
    
    public static testMethod void testBatchConvertContactsToPersonAccts(){
        // Creates a Provider contact under the Provider Account. Then, invoke batch class to
        // transform the contact to a person account.
        
        String firstName = BasicProviderFirstName;
        String lastName = 'Disney';
        String email = BasicProviderEmail;
        Integer memberId = BasicProviderMemberId;

        Account a = new Account(
            Name = 'Provider',
            AccountId__c = 1
            );
        insert a;
        
        Contact c = new Contact(                        
            AccountId = a.id,
            basicmembersignupdate__c = date.today(),
            blacklisted__c = false,
            email = email,
            firstname = firstName,
            groupie__c = false,
            groups__c = 'boston',
            ipaddress__c = '127.0.0.1',
            karoo__c = false,
            lastname = lastName,
            mailingcity = 'Jamaica Plain',
            mailingpostalcode = '02130',
            mailingstate = 'MA',
            memberid__c = memberId,
            membershipcreationdate__c = date.today(),
            membertype__c = 'Provider',
            messagenotificationfrequency__c = 'immediately',
            no_longer_with_company__c = false,  
            optinmemberalert__c = false,
            optinnewsletters__c = true,
            optinoffers__c  = true,
            optinphone__c = false, 
            optinprovideralert__c = true, 
            otherphone = '(666) 666-6666',
            overallstatus__c = 'Active',
            overallstatuschangedate__c = date.today(),
            phone = '(555) 555-5555',
            //pricing_features__c = '',                   // blank for basics; 
            pricing_plan_id__c = '',                    // blank for basic providers
            pricetestcellscheme__c = '',             
            product_type__c = 'SUBSCRIPTION',
            provideralertfrequency__c = 'weekly',
            receiving_emails__c = true,
            recordtypeid = pcRtId, 
            rx1__c = 'sem_Google', 
            rx2__c = 'General_Brand',           
            rx3__c = 'care com_e',
            rx4__c = '99999999999',
            rx5__c = 'General_Exact',
            status__c = 'Active',
            statuschangedate__c = date.today(),
            type__c = 'Individual',
            Birthdate = date.today().addYears(-20), // Making babysitter 20 years old 
            FirstApprovalDate__c = date.today(),
            InitialApprovalDateChildCare__c = date.today(), 
            ProfileQualityChildCare__c = 'Med',
            CurrentStatusChildCare__c = 'Active'
            );
        insert c;       
        
         //envoke batchable class
        Test.StartTest();
        BatchConvertContactsToPersonAccts b = new BatchConvertContactsToPersonAccts();
        b.query = 'SELECT id, accountId, recordTypeId, OwnerId, MemberID__c FROM Contact where Account.AccountId__c in (1,2,3,4,5,6) and IsPersonAccount = false';
        ID batchprocessid = Database.executeBatch(b, 100);
        Test.StopTest();

        c = [SELECT id, accountId FROM Contact WHERE id = :c.id];
        System.assert(c.accountId != a.id); // the batch class should have moved the contact under a stub Account then changed it to a person Account
        
        //verify contact has been correctly transformed into a person account with the matching record type
        Account acct = [SELECT id, recordTypeId FROM Account WHERE id =: c.accountId];
        system.assertEquals(acct.recordTypeId, paRtId);
    }
    
    public static testMethod void testBatchUnconvertPersonAccts(){
        // Creates a Provider Person Account. Then, invoke batch class to
        // transform the contact back to a Provider Contact.
        
        Account a = new Account(
            Name = 'Provider',
            AccountId__c = 1
            );
        insert a;

        Account basicProviderAcct = new Account(                        
            basicmembersignupdate__pc = date.today(),
            blacklisted__pc = false,
            personemail = BasicProviderEmail,
            firstname = BasicProviderFirstName,
            groupie__pc = false,
            groups__pc = 'boston',
            ipaddress__pc = '127.0.0.1',
            karoo__pc = false,
            lastname = 'Poppins',
            personmailingcity = 'Jamaica Plain',
            personmailingpostalcode = '02130',
            personmailingstate = 'MA',
            memberid__c = String.valueOf(BasicProviderMemberId), 
            memberid__pc = BasicProviderMemberId,
            membershipcreationdate__pc = date.today(),
            membertype__pc = 'Provider',
            messagenotificationfrequency__pc = 'immediately',
            no_longer_with_company__pc = false,  
            optinmemberalert__pc = false,
            optinnewsletters__pc = true,
            optinoffers__pc  = true,
            optinphone__pc = false, 
            optinprovideralert__pc = true, 
            personotherphone = '(666) 666-6666',
            overallstatus__pc = 'Active',
            overallstatuschangedate__pc = date.today(),
            phone = '(555) 555-5555',
            //pricing_features__pc = '',                   // blank for basics; 
            pricing_plan_id__pc = '',                    // blank for basic providers
            pricetestcellscheme__pc = '',             
            product_type__pc = 'SUBSCRIPTION',
            provideralertfrequency__pc = 'weekly',
            receiving_emails__pc = true,
            recordtypeid = paRtId,
            rx1__pc = 'sem_Google', 
            rx2__pc = 'General_Brand',           
            rx3__pc = 'care com_e',
            rx4__pc = '99999999999',
            rx5__pc = 'General_Exact',
            status__pc = 'Active',
            statuschangedate__pc = date.today(),
            type__pc = 'Individual',
            PersonBirthdate = date.today().addYears(-20), // Making babysitter 20 years old 
            FirstApprovalDate__pc = date.today(),
            InitialApprovalDateChildCare__pc = date.today(), 
            ProfileQualityChildCare__pc = 'Med',
            CurrentStatusChildCare__pc = 'Active'
            );
        insert basicProviderAcct;
        
        //envoke batchable class
        Test.StartTest();
        BatchUnconvertPersonAccts b = new BatchUnconvertPersonAccts();
        b.query = 'SELECT id, RecordTypeId FROM Account where IsPersonAccount = true and (RecordTypeId = \'' + pcRtId + '\' or RecordTypeId = \'' + saRtId + '\' or RecordTypeId = \'' + paRtId + '\' or RecordTypeId = \'' + smbpaRtId + '\')';
        ID batchprocessid = Database.executeBatch(b, 100); 
        Test.StopTest();
        
        Contact[] contactList = [SELECT id, accountId, recordTypeId FROM Contact WHERE lastname = 'Poppins'];
        System.assertEquals(contactList.size(), 1);
        system.assertEquals(contactList[0].RecordTypeId, pcRtId);
        System.assertEquals(contactList[0].accountId, a.id); 
    }
    
}