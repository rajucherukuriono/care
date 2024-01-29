@isTest(seealldata=false)
public class Test_AssignCaseToQUsBugQUponBugFlag{
    
    @isTest(seeAllData=false)
    public static void testCase1() {
     ID intlCallCenter = Schema.SObjectType.Case.getRecordTypeInfosByName().get('International Call Center').getRecordTypeId();
     Account acct=new Account(firstname='TestFirstName',LastName='TestLastName',recordtypeid=intlCallCenter);
    //Group qUsBug=[select id,name from Group where name='Q: US: Bugs'];
        Case C = new Case(recordTypeId = '01270000000Dq7E', AccountId=acct.Id,Contact_Reason__c='Communication',Contact_Secondary_Reason__c='Professionalism',
                    Device__c='Android App',Contact_Theme__c='Customer Service',
                    Sentiment__c='Positive',Refund_Issued__c=True,Cancel__c=True,Downgrade__c=False,Bug__c=True,Reproduced__c=True,Bug_Summary__c='Bug Summary',
                    Actions_Taken__c='Actions Taken',Jira_Number__c='3306',Browsers_and_Versions__c='Firefox 11.0');
        insert c;
        
    }
 }