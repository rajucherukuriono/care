trigger UpdateLeadHiddenRTFields on Lead (before insert, before update) {
 boolean bypassLeadTriggers=Override_Validation_Rules__c.getInstance().Override_Lead_Triggers__c;
if(!bypassLeadTriggers)
{
      if (Trigger.isBefore && Trigger.isInsert){
         for (Lead l : trigger.new){
           if(l.RecordTypeId == '01270000000HouLAAS'){          
                l.Lead_Account_Type__c = 'Business Account';
                l.Contact_Record_Type__c = 'Marketplace ISR Contact';
                }
        if(l.RecordTypeId == '0121O000000AYRzQAO'){
                l.Lead_Account_Type__c = 'BUC Network Agency';
                 l.Contact_Record_Type__c = 'BUC Contact';
        }   
        if(l.RecordTypeId == '0121O000000AYS0QAO'){
                l.Lead_Account_Type__c = 'BUC Network Center';
                 l.Contact_Record_Type__c = 'BUC Contact';
        }          
        if(l.RecordTypeId == '01270000000Hn8BAAS'){
                l.Lead_Account_Type__c = 'Homepay Business Account';
                l.Contact_Record_Type__c = 'Homepay Business Contact';
        } 
        if(l.RecordTypeId == '01270000000UQGTAA4'){
                l.Lead_Account_Type__c = 'International WPS Business Account';
                l.Lead_Account_Type__c = 'International WPS Contact';
        } 
           
        if(l.RecordTypeId == '01270000000Hl9WAAS' ){
                l.Lead_Account_Type__c = 'Business Account';
                l.Contact_Record_Type__c = 'WPS Contact';
            }
                        
            if(l.RecordTypeId == '01270000000Hq6bAAC' ){
                l.Lead_Account_Type__c = 'Business Account';
                l.Contact_Record_Type__c = 'MKP National Contact';
            }
            }
            }
            if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            for(Lead l2 : Trigger.New){
            if(l2.How_did_you_hear_about_Care_com__c != null || l2.How_did_you_hear_about_Care_com__c != ''){
                l2.How_did_you_hear_about_Care_com_Act__c = l2.How_did_you_hear_about_Care_com__c;
                       }
                    }
               }
      }         
 }