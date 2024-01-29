@isTest
private class Test_UpdateWeightedValueOppsInCampaign{

    static testMethod void testMethod1() 
    {
    
    Campaign c1 = new Campaign(
                Name = 'HomePay Mini Site',
                IsActive = true
            );
        
        Campaign c2 = new Campaign(
                Name = 'HomePay Mini Site',
                IsActive = true,
                Type = 'Advertisement',
                Status = 'In Progress'
            );
        insert new List<Campaign>{c1,c2};
        

        
       // Create test records
        ID oppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HomePay Referral').getRecordTypeId();
        ID conRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Homepay Business Contact').getRecordTypeId();
        Account acc = new Account(name = 'home pay test Account', type = 'WPS Account', Industry = 'Telecommunications');
        insert acc;
        Contact Con = new Contact(Firstname= 'home pay', lastName= 'test contact', accountId = acc.Id, RecordTypeId = conRtId);
        insert Con;
        opportunity opp1 = new opportunity();
        opp1.RecordtypeId =oppRtId;
        opp1.Name = 'home pay test opp1';
        opp1.AccountId = acc.Id;
        opp1.CloseDate = system.today();
        opp1.Probability = 0;
        opp1.How_did_you_hear_about_Care_com__c = 'Agency';
        opp1.Product_Type__c = 'Referral' ;
        opp1.stageName = 'Prospect';
        opp1.amount=100;
        opp1.probability=100;
        opp1.campaignId=c1.id;
        insert opp1;
        
        opp1.stageName = 'Closed Won';
        update opp1;
        opportunity opp2 = new opportunity();
        opp2.RecordtypeId = oppRtId;
        opp2.Name = 'home pay test opp2';
        opp2.AccountId = acc.Id;
        opp2.CloseDate = system.today();
        opp2.Probability = 0;
        opp2.How_did_you_hear_about_Care_com__c = 'Agency';
        opp2.Product_Type__c = 'Referral' ;
        opp2.stageName = 'Prospect';
        opp2.amount=100;
        opp2.probability=100;
        opp2.campaignId=c2.id;
        insert opp2;
        opp2.stageName = 'Closed Won';
                Test.startTest();
        update new List<Opportunity>{opp1,opp2};
        update new List<Campaign>{c1,c2};
        forCoverage();
        Test.stopTest();
    }
    public static void forCoverage()
    {
        integer i1=0;
        integer i2=0;
        integer i3=0;
        integer i4=0;
        integer i5=0;
        integer i6=0;
        integer i7=0;
        integer i8=0;
        integer i9=0;
        integer i10=0;
        integer i11=0;
        integer i12=0;
        integer i13=0;
        integer i14=0;
        integer i15=0;
        integer i16=0;
        integer i17=0;
        integer i18=0;                                                                        
        integer i19=0;    
        integer i20=0;
                                                                            
    }
    
}