@isTest
private class Test_SearchCandidateProfile
{
    static testMethod void testMethod1() {
       // Create test records
        List<String> recNameList = new List<String>{'AS - Housekeeping','AS - Child Care','AS - Personal Assistant','AS - Pet Care','AS - Tutor','AS - Child Care Center','Child Care Center Account','Provider','Candidate Profile US WPS Service','AS-Child Care Center','Candidate Profile US AS-Housekeeping'};
        Map<String,Id> RecordTypeIdMap = getRecordTypesStatic.getFilteredRecNameIdMap(recNameList);
        
        
        Account providerAcc= new Account(lastname = 'Test Provider1', RecordTypeId=RecordTypeIdMap.get('Provider'),job_type__c= 'Full Time Nanny', BillingCity='ABCD',BillingState='MA',BillingPostalCode='123456');
        insert providerAcc;
        //Contact Con = new Contact(Firstname= 'home pay', lastName= 'test contact', accountId = acc.Id, RecordTypeId = conRtId);
        //insert Con;
        
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = false;
        
        Case ProviderAcc1 = new Case(status = 'new',subject='TestCase1',RecordTypeId=RecordTypeIdMap.get('AS - Child Care'),job_type__c= 'Full Time Nanny', AS_type_city__c='ABCD',AS_type_state__c='MA',AS_type_zip_code__c='123456');
        ProviderAcc1.setOptions(dmo);
        insert ProviderAcc1;
        
        Case ProviderAcc2 = new Case(status = 'new',subject='TestCase1',RecordTypeId=RecordTypeIdMap.get('AS - Child Care Center'),job_type__c= 'Child Care Center', AS_type_city__c='ABCD',AS_type_state__c='MA',AS_type_zip_code__c='123456');
        ProviderAcc2.setOptions(dmo);
        insert ProviderAcc2;
        
        Case ProviderAcc3 = new Case(status = 'new',subject='TestCase1',RecordTypeId=RecordTypeIdMap.get('AS - Housekeeping'),job_type__c= 'Housekeeper', AS_type_city__c='ABCD',AS_type_state__c='MA',AS_type_zip_code__c='123456');
        ProviderAcc3.setOptions(dmo);
        insert ProviderAcc3;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ProviderAcc1);
SearchCandidateProfile ac = new SearchCandidateProfile(sc);
ac.cpObjList=null;

        Candidate_Profile__c cp1=new Candidate_Profile__c(RecordTypeId=RecordTypeIdMap.get('Candidate Profile US WPS Service'),Provider_Account__c=providerAcc.id,case__c=ProviderAcc1.id);
        insert cp1;
        
        ApexPages.currentPage().getParameters().put('id',ProviderAcc1.Id);
        SearchCandidateProfile scp=new SearchCandidateProfile();
        scp.customClone();
        scp.getCPList();
        scp.refreshPageSize();
        Apexpages.StandardSetController ssc=scp.SetCon;
        
        ApexPages.currentPage().getParameters().put('id',ProviderAcc2.Id);
        SearchCandidateProfile scp1=new SearchCandidateProfile();
        scp1.customClone();
        scp1.getCPList();
        scp1.refreshPageSize();
        Apexpages.StandardSetController ssc1=scp1.SetCon;
        
        ApexPages.currentPage().getParameters().put('id',ProviderAcc3.Id);
        SearchCandidateProfile scp2=new SearchCandidateProfile();
        scp2.customClone();
        scp2.getCPList();
        scp2.refreshPageSize();
        Apexpages.StandardSetController ssc2=scp2.SetCon;
        
        
        
    }
/*
'AS - Child Care','AS - Personal Assistant','AS - Pet Care','AS - Tutor','AS - Child Care Center','Child Care Center Account','Provider',
'Candidate Profile US WPS Service','AS-Child Care Center','Candidate Profile US AS-Housekeeping'

if(caseObj.RecordType.Name=='AS - Child Care' || 
caseObj.RecordType.Name=='AS - Personal Assistant' || 
caseObj.RecordType.Name=='AS - Pet Care' || 
caseObj.RecordType.Name=='AS - Tutor'
caseObj.RecordType.Name=='AS - Child Care Center'

Account Record Type=Child Care Center Account/Provider

Candidate Profile Record Type

Candidate Profile US WPS Service
AS-Child Care Center
Candidate Profile US AS-Housekeeping


    Account Job Type    
Full Time Nanny
Part Time Nanny
Afterschool Job
Housekeeper
Personal Assistant
Pet Care
Babysitter
Tutor
Other

zipCode=caseObj.AS_type_zip_code__c;
city=caseObj.AS_type_City__c;
state=caseObj.AS_type_state__c;
jobType=caseObj.Job_Type__c;

recordType.Name='Candidate Profile US WPS Service'
AND Provider_Account__r.Job_Type__c=:caseObj.Job_Type__c
AND Provider_Account__r.BillingPostalCode=:zipCode   
AND Provider_Account__r.BillingState=:state 
AND Provider_Account__r.BillingCity=:city AND 
Provider_Account__r.RecordType.Name='Provider'
*/

}