public class DealSummaryController
{
    public DealSummaryController()
    {  
      
    }
    public List<Opportunity> oppList{get;set;}
    public Id accountId{get;set;}
    public Id opportunityId{get;set;}
    public Opportunity oppObj{get;set;} 
    public List<OpportunityLineItem> oppLineItemList{get;set;} 
    public Map<id,OpportunityContactRole> oppContRoleList{get;set;}
    public List<Contact> contactList{get;set;}
    public String billingAddress{get;set;}
    public String selectedContactId1_1{get;set;}
    public String selectedContactId1_2{get;set;}
    public String selectedContactId1_3{get;set;}
    public String selectedContactId1_4{get;set;}
                
    public String selectedContactId2{get;set;}
    public String selectedContactId3{get;set;}


    public DealSummaryController(ApexPages.StandardController stdController) 
    {
        oppObj= (Opportunity)stdController.getRecord();
        oppObj=[SELECT id,stageName,BUC_Rollover__c,Other__c,Account.Company_Headquarters_Address__c,Account.Industry,Implementation_Call_Date__c,Billing_Address__c,Client_Success_Manager__c,Account_Manager__c,Notes__c,Type,name,Care_Credits__c,Total_budget__c,Value_per_credit__c,Verticals_covered__c,Number_of_transactions__c,Employer_Transaction_Fee__c,Price_Increase_Amount__c,Organic_Growth_Amount__c,Upsell_Amount__c,Reason_for_increase_decrease__c,Covered_Headcount__c ,Secondary_Competitor__c,owner.name,accountid,account.name,account.billingaddress,account.BillingStreet ,account.BillingCity,account.BillingState,account.BillingCountry,account.BillingPostalCode,contactid1_1__c,contactid1_2__c,contactid1_3__c,contactid1_4__c,contactid2__c,contactid2_Phone__c,contactid2_Email__c,contactid3__c,Competitor__c,Incumbent__c,Effective_Date__c,Account.NumberOfEmployees,WPS_Target_Launch_Date__c,amount,Care_Select_Fee__c,Total_Contract_Value__c,No_of_in_center_days__c,No_of_in_home_days__c,Customer_special_invoicing_requirements__c,International_Employees__c,List_top_5_10_office_locations__c,Payment_Terms_schedule__c,Publicity_reference_investor_call__c,Term_Months_or_Multi_year__c,Term_End_Date__c,Annual_Contract_Value__c,State_Sales_Tax_Applicable__c,Payment_Terms__c,Cancellation_Notice_Requirement__c,Termination_Provisions__c,Previous_Contract_Value__c,Previous_Year_Bundles_and_Overages__c,Auto_Renew__c,Auto_Renewal_Terms__c,SLA_s__c,Non_Standard_Legal_Terms__c,Benefit_Fair_Dates_or_other_important_da__c,Areas_of_concern__c,Marketing_Creative_special_requests__c,Number_of_onsite_events__c,Is_KCE_involved_If_so_how__c,Client_Group_URL__c,International_Description_of_Services__c,Total_Number_of_days_allowed_for_the_con__c,BUC_Special_Terms__c,PAYG_BUC__c,Bundle_Price_per_Day__c,Bundle_Increments__c,Bundle_Overage_Notes__c,Personal_Network_Overage_Fee_if_stated__c,International_Personal_Network__c,International_PN_Notes__c,Personal_Network_Transaction_Fee__c,Personal_Network_Usage_Counting__c,Days_available_per_year_per_employee__c,In_home_BUC_Overage_Fee__c,In_center_BUC_Overage_Fee__c,Final_in_home_and_in_center_results_for__c,Areas_of_opportunity__c,Personal_Network_In_Home__c,Personal_Network_In_Center__c,Personal_Network_Notes__c,Max_Reimbursement_In_home__c,Expansion_Plan_Notes__c,Services_with_BH__c   from Opportunity where id=:oppObj.id];
        //oppObj.Max_Reimbursement_In_home__c=Decimal.valueOf(Opportunity.Description.getDescribe().getDefaultValueFormula());
        //oppObj.Max_Reimbursement_In_Center__c=Decimal.valueOf(Opportunity.Description.getDescribe().getDefaultValueFormula());
        oppObj.Max_Reimbursement_In_home__c=125;
        oppObj.Max_Reimbursement_In_Center__c=125;
        contactList=[select id,name,email,phone,Role__c from contact where accountId=:oppObj.accountId];
        //role from opportunity contact role???
        //Product2.No_of_Employees_Countries__c,Product2.Co_Pay_Details__c,Product2.Notes__c from Product2
        oppLineItemList=[SELECT Id,ListPrice,Name,OpportunityId,PricebookEntryId,Product2Id,Product2.Name,No_of_Employees_Countries__c,Co_Pay_Details__c,Notes__c,ProductCode,Quantity,TotalPrice,UnitPrice,Description FROM OpportunityLineItem where OpportunityId=:oppObj.Id];
        
        billingAddress=(oppObj.account.BillingStreet==null?'':oppObj.account.BillingStreet+
        ' ')+(oppObj.account.BillingCity==null?'':oppObj.account.BillingCity+', ')+
        (oppObj.account.BillingState==null?'':oppObj.account.BillingState+' ')+
        (oppObj.account.BillingCountry==null?'':oppObj.account.BillingCountry+' ')+
        (oppObj.account.BillingPostalCode==null?'':oppObj.account.BillingPostalCode);
        
        //billingAddress=(oppObj.account.BillingStreet==null?'':oppObj.account.BillingStreet+',')+oppObj.account.BillingCity;
        oppContRoleList=new Map<id,OpportunityContactRole>([SELECT Contact.name,Contact.email,Contact.phone,ContactId,Id,Contact.Role__c,IsPrimary,OpportunityId,Role FROM OpportunityContactRole where OpportunityId=:oppObj.id]);
        selectedContactId1_1=oppObj.contactId1_1__c;
        selectedContactId1_2=oppObj.contactId1_2__c;
        selectedContactId1_3=oppObj.contactId1_3__c;
        selectedContactId1_4=oppObj.contactId1_4__c;
        selectedContactId3=oppObj.contactId3__c;
        oppObj.Billing_Address__c=billingAddress;
    }
    
    public PageReference refreshContDetailsCtrlMethod()
    {

        return null;
    }

    public List<SelectOption> getContacts() 
    {
           List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        for(OpportunityContactRole oppContRoleObj:oppContRoleList.values())
        {
            options.add(new SelectOption(oppContRoleObj.Id,oppContRoleObj.Contact.name));
        }

        return options;
    }
    /*
    public List<SelectOption> getProductsOfOpp() 
    {
        List<SelectOption> options = new List<SelectOption>();
                    options.add(new SelectOption('','--None--'));
        for(OpportunityLineItem oppLineItemObj:oppLineItemList)
        {
            options.add(new SelectOption(oppLineItemObj.Product2Id,oppLineItemObj.Product2.Name));
        }
    
        return options;
    }
    public String getProductsList() 
    {
        String prodList='';
        for(OpportunityLineItem oppLineItemObj:oppLineItemList)
        {
            prodList=prodList+oppLineItemObj.Product2.Name+',';
        }
        if(prodList.length()>0)
        prodList=prodList.subString(0,prodList.length()-1);
        return prodList;
    }
    */
    public PageReference saveDealSummary(){
    if(!String.isBlank(oppObj.Services_With_BH__c) && oppObj.Services_With_BH__c.contains('Other') && String.isBlank(oppObj.other__c))
    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please enter Other field value as Services With BH is selected as Other.'));
    else
    {
        oppObj.contactId1_1__c=selectedContactId1_1;
        oppObj.contactId1_2__c=selectedContactId1_2;
        oppObj.contactId1_3__c=selectedContactId1_3;
        oppObj.contactId1_4__c=selectedContactId1_4;
        oppObj.contactId3__c=selectedContactId3;
        update oppContRoleList.values();
        update oppObj;
        update oppObj.Account;
         oppObj=[SELECT id,stageName,BUC_Rollover__c,Other__c,Account.Company_Headquarters_Address__c,Account.Industry,Implementation_Call_Date__c,Billing_Address__c,Client_Success_Manager__c,Account_Manager__c,Notes__c,Type,name,Care_Credits__c,Total_budget__c,Value_per_credit__c,Verticals_covered__c,Number_of_transactions__c,Employer_Transaction_Fee__c,Price_Increase_Amount__c,Organic_Growth_Amount__c,Upsell_Amount__c,Reason_for_increase_decrease__c,Covered_Headcount__c ,Secondary_Competitor__c,owner.name,accountid,account.name,account.billingaddress,account.BillingStreet ,account.BillingCity,account.BillingState,account.BillingCountry,account.BillingPostalCode,contactid1_1__c,contactid1_2__c,contactid1_3__c,contactid1_4__c,contactid2__c,contactid2_Phone__c,contactid2_Email__c,contactid3__c,Competitor__c,Incumbent__c,Effective_Date__c,Account.NumberOfEmployees,WPS_Target_Launch_Date__c,amount,Care_Select_Fee__c,Total_Contract_Value__c,No_of_in_center_days__c,No_of_in_home_days__c,Customer_special_invoicing_requirements__c,International_Employees__c,List_top_5_10_office_locations__c,Publicity_reference_investor_call__c,Term_Months_or_Multi_year__c,Term_End_Date__c,Annual_Contract_Value__c,State_Sales_Tax_Applicable__c,Payment_Terms__c,Payment_Terms_schedule__c,Cancellation_Notice_Requirement__c,Termination_Provisions__c,Previous_Contract_Value__c,Previous_Year_Bundles_and_Overages__c,Auto_Renew__c,Auto_Renewal_Terms__c,SLA_s__c,Non_Standard_Legal_Terms__c,Benefit_Fair_Dates_or_other_important_da__c,Areas_of_concern__c,Marketing_Creative_special_requests__c,Number_of_onsite_events__c,Is_KCE_involved_If_so_how__c,Client_Group_URL__c,International_Description_of_Services__c,Total_Number_of_days_allowed_for_the_con__c,BUC_Special_Terms__c,PAYG_BUC__c,Bundle_Price_per_Day__c,Bundle_Increments__c,Bundle_Overage_Notes__c,Personal_Network_Overage_Fee_if_stated__c,International_Personal_Network__c,International_PN_Notes__c,Personal_Network_Transaction_Fee__c,Personal_Network_Usage_Counting__c,Days_available_per_year_per_employee__c,In_home_BUC_Overage_Fee__c,In_center_BUC_Overage_Fee__c,Final_in_home_and_in_center_results_for__c,Areas_of_opportunity__c,Personal_Network_In_Home__c,Personal_Network_In_Center__c,Personal_Network_Notes__c,Max_Reimbursement_In_home__c,Max_Reimbursement_In_Center__c,Expansion_Plan_Notes__c,Services_with_BH__c   from Opportunity where id=:oppObj.id];
        List<Contact> allContList=new List<Contact>();
        for(OpportunityContactRole oppContRoleObj:oppContRoleList.values()){
        allContList.add(oppContRoleObj.contact);
        }
        if(!allContList.isEmpty()) update allContList;
        
        if(!oppLineItemList.isEmpty()) update oppLineItemList;
        /*
        List<Product2> prodList=new List<Product2>();
        for(OpportunityLineItem oppLineItemObj:oppLineItemList)
        {
            prodList.add(oppLineItemObj.Product2);
        }
        if(!prodList.isEmpty()) update prodList;
        */
        
        return new PageReference('/apex/Deal_Summary_Read_Only_Mode');
    }
    return null;
    }
    public PageReference readOnlyDealSummary()
    {
        return new PageReference('/apex/Deal_Summary_Read_Only_Mode');
    }
    public PageReference editDealSummary()
    {
        return new PageReference('/apex/Edit_Deal_Summary');
    }
    public PageReference existingBusiness()
    {
    return null;
    }
    public List<String> getProductListToMandateCoPayDtls()
    {
        List<String> prodListToMandCoPayDtls=new List<String>{'In-Home Backup Child Care','In-Center Child Care Backup','In-home Backup Adult Care'};
        //return prodListToMandCoPayDtls.contains(selectedProduct);
        return prodListToMandCoPayDtls;
    }
}