public class CreateIntlPersonAccount{
    
    public case  cas{get; set;}
    public Account acct{get; set;}
    public String fname{get; set;}
    public String lname{get; set;}
    public String cPhone{get; set;}
    public String cEmail{get; set;}
    public String Eprog{get; set;}
    public boolean memberAlreadyLinked{get;set;}
    public static ID recType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Person Account').getRecordTypeId();
    
    public createIntlPersonAccount(ApexPages.StandardController controller) {
        cas = (case) controller.getRecord();
        cas = [select id,accountId, web_first_name__c, web_last_name__c, SuppliedPhone, SuppliedEmail, Employer_Program__c from case where id=:cas.id];
        fname=cas.web_first_name__c;
        lname=cas.web_last_name__c;
        Eprog=cas.Employer_Program__c;
        cPhone=cas.SuppliedPhone;
        cEmail=cas.SuppliedEmail;
        if(cas.accountId!=null) memberAlreadyLinked=true;
    }
    public PageReference save() {
        
        Account acct = new Account();
        acct.recordtypeid = recType;
        acct.FirstName=fname;
        acct.LastName=lname;
        acct.Phone = cPhone;
        acct.PersonEmail = cEmail;
        acct.Employer_Program_Pick__c = Eprog;
        insert(acct);  
        Contact cont=[select id,Employer_Program__c from contact where accountid=:acct.id];
        cont.Employer_Program__c=Eprog;
        update cont;
        cas.AccountId = acct.id;  
        cas.Employer_Program__c = acct.Employer_Program_Pick__c;    
        update cas;           
        PageReference newPage = New PageReference('/'+cas.id);
        newPage.setRedirect(true);
        return newPage;
        
    }
    
    public list<SelectOption> getEmpProg(){
        
        list<selectoption> acc = new list<selectoption>();
        schema.DescribeFieldResult fd = Account.Employer_Program_Pick__c.getdescribe();
        list<schema.picklistentry> pc = fd.getpicklistvalues();
        for(schema.picklistentry f: pc){
            acc.add(new selectoption(f.getlabel(),f.getvalue()));
          }
        
        return acc;
        }
    
   }