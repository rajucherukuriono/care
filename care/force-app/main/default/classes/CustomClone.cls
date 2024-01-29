public class CustomClone {

    private ApexPages.StandardController controller {get; set;}
    private case cas {get;set;}
    public ID newRecordId {get;set;}

    public CustomClone(ApexPages.StandardController controller) {

        this.controller = controller;
        cas = (case)controller.getRecord();

    }

    public PageReference cloneCase() {

         Savepoint sp = Database.setSavepoint();
         case newCas;

         try {
          cas = [select Id, Subject, ContactId, AccountId, Description, Comments, Origin, Status, Reason, Secondary_Case_Reason__c,
                 Reopen_Criteria_Met__c, Bug__c, Member_Account_Type__c, Member_Type__c,
                 Member_Overall_Status__c, USAA_Member__c, Employer_Program__c, Priority, Case_Categories__c, Incident_Type__c, 
                 Video_Received__c,SafetyCaseTriage__c,Member_language__c, Refund_Issued__c, Promo_Code_Offered__c from Case where id = :cas.id];
             
             newCas = cas.clone();
             newCas.Type = 'Q: Safety/Fraud';
             newCas.Support_Skill__c ='Safety Email';
             newCas.RecordTypeId =[select id, name from recordtype where name ='Standard'].Id;
             List<Group> safeyEmailGrp=[select id from Group where name ='Safety - Safety Email'];
            if(!safeyEmailGrp.isEmpty())
             newCas.OwnerId = safeyEmailGrp[0].id;
               insert newCas;
            
              
              newRecordId = newCas.id;
            
            } catch (Exception e){
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
         }

        return new PageReference('/'+newCas.id+'/e?retURL=%2F'+newCas.id); 
    }

}