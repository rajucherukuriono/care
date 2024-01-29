//Last Modified By: Mohammed Ashwaq
//Test class for UpdateLeadHiddenRTFields
//Last Modified Date: 10/11/2020
@isTest
public class UpdateLeadHiddenRTFields_Test {
    static testmethod void deDuplication1(){
        Lead l1 = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'CareCo',
            Industry = 'Estate Manager',
            LeadSource = 'Imported List',
            RecordTypeId = '01270000000HouLAAS'
        );
        insert l1;
    }
    static testmethod void deDuplication2(){       
        Lead l2 = new Lead(
            FirstName = 'Second',
            LastName = 'Last',
            Company = 'amazon',
            Industry = 'Estate Manager',
            LeadSource = 'Imported List',
            RecordTypeId = '0121O000000AYRzQAO'
        );
        insert l2;
    }
    static testmethod void deDuplication3(){ 
        Lead l3 = new Lead(
            FirstName = 'Third',
            LastName = 'Last',
            Company = 'flipkart',
            Industry = 'Estate Manager',
            LeadSource = 'Imported List',
            RecordTypeId = '0121O000000AYS0QAO'
        );
        insert l3;
    }
    static testmethod void deDuplication4(){     
        Lead l4 = new Lead(
            FirstName = 'Fourth',
            LastName = 'Last',
            Company = 'flipkart',
            Industry = 'Estate Manager',
            LeadSource = 'Imported List',
            RecordTypeId = '01270000000Hn8BAAS'
        );
        insert l4;
    }
    static testmethod void deDuplication5(){       
        Lead l5 = new Lead(
            FirstName = 'Fifth',
            LastName = 'Last',
            Company = 'flipkart',
            Industry = 'Estate Manager',
            LeadSource = 'Imported List',
            RecordTypeId = '01270000000UQGTAA4'
        );
        insert l5;
    }
    static testmethod void deDuplication6(){       
        Lead l6 = new Lead(
            FirstName = 'Sixth',
            LastName = 'Last',
            Company = 'flipkart',
            Industry = 'Estate Manager',
            LeadSource = 'Imported List',
            RecordTypeId = '01270000000Hl9WAAS'
        );
        insert l6;
    }
    static testmethod void deDuplication7(){       
        Lead l7 = new Lead(
            FirstName = 'seventh',
            LastName = 'Last',
            Company = 'flipkart',
            Industry = 'Estate Manager',
            LeadSource = 'Imported List',
            RecordTypeId = '01270000000HouLAAS'
        );
        insert l7;
    }
    static testmethod void deDuplication8(){        
        Lead l8 = new Lead(
            FirstName = 'Eighth',
            LastName = 'Last',
            Company = 'flipkart',
            Industry = 'Estate Manager',
            LeadSource = 'Imported List',
            RecordTypeId = '01270000000Hq6bAAC'
        );
        insert l8;
    }
}