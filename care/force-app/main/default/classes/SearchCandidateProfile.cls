public class SearchCandidateProfile{

    public List<Candidate_Profile__c> cpObjList{get;set;}
    public Case caseObj{get;set;}
    public String selectedCP{get;set;}
    public SearchCandidateProfile(ApexPages.StandardController stdController) {
        //cpObj = (Candidate_Profile__c)stdController.getRecord();
        caseObj=(Case)stdController.getRecord();
   }
   
   
    Public Integer size{get;set;} 
    Public Integer noOfRecords{get; set;} 
    public List<SelectOption> paginationSizeOptions{get;set;}
    public String zipCode{get;set;}
    public String state{get;set;}
    public String city{get;set;}
    public String jobType{get;set;}
         
    public SearchCandidateProfile(){
    
        caseObj=[select id,subject,caseNumber,AS_type_City__c,AS_type_state__c,AS_type_zip_code__c,Job_Type__c,RecordType.Name from case where id=:ApexPages.currentPage().getParameters().get('id')];
zipCode=caseObj.AS_type_zip_code__c;
city=caseObj.AS_type_City__c;
state=caseObj.AS_type_state__c;
jobType=caseObj.Job_Type__c;
        size=10;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
    }
 
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {  
            
            if(caseObj.RecordType.Name=='AS - Child Care' || caseObj.RecordType.Name=='AS - Personal Assistant' || caseObj.RecordType.Name=='AS - Pet Care' || caseObj.RecordType.Name=='AS - Tutor') 
            {
                      setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [SELECT id,Provider_Account__r.Name,Provider_Account__r.Open_Availability__c,Provider_Account__r.Job_Type__c,
                      Provider_Account__r.BillingAddress,Provider_Account__r.BillingCity,Provider_Account__r.BillingCountry,
                      Provider_Account__r.BillingGeocodeAccuracy,Provider_Account__r.BillingLatitude,
                      Provider_Account__r.BillingLongitude,Provider_Account__r.BillingPostalCode,Provider_Account__r.BillingState,
                      Provider_Account__r.BillingStreet,Provider_Account__r.personEmail,Provider_Account__r.Phone,Name,CreatedDate,
                      RecordType.Name from Candidate_Profile__c 
                      where 
                      recordType.Name='Candidate Profile US WPS Service'
                      AND Provider_Account__r.Job_Type__c=:caseObj.Job_Type__c
                      AND Provider_Account__r.BillingPostalCode=:zipCode   
                      AND Provider_Account__r.BillingState=:state 
                      AND Provider_Account__r.BillingCity=:city AND 
                      Provider_Account__r.RecordType.Name='Provider' 
                      order by createddate desc LIMIT 10000]));
            }
            else if(caseObj.RecordType.Name=='AS - Child Care Center')
            {             
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [SELECT id,Provider_Account__r.Name,Provider_Account__r.Open_Availability__c,Provider_Account__r.Job_Type__c,
                      Provider_Account__r.BillingAddress,Provider_Account__r.BillingCity,Provider_Account__r.BillingCountry,
                      Provider_Account__r.BillingGeocodeAccuracy,Provider_Account__r.BillingLatitude,
                      Provider_Account__r.BillingLongitude,Provider_Account__r.BillingPostalCode,Provider_Account__r.BillingState,
                      Provider_Account__r.BillingStreet,Provider_Account__r.personEmail,Provider_Account__r.Phone,Name,CreatedDate,
                      RecordType.Name from Candidate_Profile__c 
                      where 
                      recordtype.name='AS-Child Care Center'
                      AND Provider_Account__r.Job_Type__c=:caseObj.Job_Type__c 
                      AND Provider_Account__r.BillingPostalCode=:zipCode   
                      AND Provider_Account__r.BillingState=:state 
                      AND Provider_Account__r.BillingCity=:city AND 
                      Provider_Account__r.RecordType.Name='Child Care Center Account' 
                      order by createddate desc LIMIT 10000]));
                      }
            else if(caseObj.RecordType.Name=='AS - Housekeeping')
            {             
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [SELECT id,Provider_Account__r.Name,Provider_Account__r.Open_Availability__c,Provider_Account__r.Job_Type__c,
                      Provider_Account__r.BillingAddress,Provider_Account__r.BillingCity,Provider_Account__r.BillingCountry,
                      Provider_Account__r.BillingGeocodeAccuracy,Provider_Account__r.BillingLatitude,
                      Provider_Account__r.BillingLongitude,Provider_Account__r.BillingPostalCode,Provider_Account__r.BillingState,
                      Provider_Account__r.BillingStreet,Provider_Account__r.personEmail,Provider_Account__r.Phone,Name,CreatedDate,
                      RecordType.Name from Candidate_Profile__c 
                      where 
                      recordtype.name='Candidate Profile US AS-Housekeeping'
                      AND Provider_Account__r.Job_Type__c=:caseObj.Job_Type__c
                      AND Provider_Account__r.BillingPostalCode=:zipCode   
                      AND Provider_Account__r.BillingState=:state 
                      AND Provider_Account__r.BillingCity=:city AND 
                      Provider_Account__r.RecordType.Name='Provider' 
                      order by createddate desc LIMIT 10000]));
                      }
                      /*
            else if(caseObj.RecordType.Name=='AS - Personal Assistant' || caseObj.RecordType.Name=='AS - Pet Care' || caseObj.RecordType.Name=='AS - Tutor')
            {             
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [SELECT id,Provider_Account__r.Name,Provider_Account__r.Open_Availability__c,Provider_Account__r.Job_Type__c,
                      Provider_Account__r.BillingAddress,Provider_Account__r.BillingCity,Provider_Account__r.BillingCountry,
                      Provider_Account__r.BillingGeocodeAccuracy,Provider_Account__r.BillingLatitude,
                      Provider_Account__r.BillingLongitude,Provider_Account__r.BillingPostalCode,Provider_Account__r.BillingState,
                      Provider_Account__r.BillingStreet,Provider_Account__r.personEmail,Provider_Account__r.Phone,Name,CreatedDate,
                      RecordType.Name from Candidate_Profile__c 
                      where 
                      recordType.Name='Candidate Profile US WPS Service'
                      AND Provider_Account__r.Job_Type__c=:caseObj.Job_Type__c
                      AND Provider_Account__r.BillingPostalCode=:zipCode   
                      AND Provider_Account__r.BillingState=:state 
                      AND Provider_Account__r.BillingCity=:city AND 
                      Provider_Account__r.RecordType.Name='Provider' 
                      order by createddate desc LIMIT 10000]));
                      }
                      */
                setCon.setPageSize(size);  
                noOfRecords = setCon.getResultSize();
            }            
            return setCon;
        }
        set;
    }
     
    //Changes the size of pagination
    public PageReference refreshPageSize() {
         setCon.setPageSize(size);
         return null;
    }
 
    // Initialize setCon and return a list of record    
     
    public List<Candidate_Profile__c> getCPList() {
         return (List<Candidate_Profile__c>) setCon.getRecords();
    }
    public PageReference customClone()
    {
        return new PageReference('/'+selectedCP+'/e?CF00N70000003XMdI='+caseObj.caseNumber+'&CF00N70000003XMdI_lkid='+caseObj.id+'&clone=1&retURL=%2F'+caseObj.Id);
    }
}