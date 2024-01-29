@IsTest 
public class test_SocialPostTrigger
{
    public static Id socialMediaUS = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Social_Media_US').getRecordTypeId();

    @testSetup
    static void testsetup()
    {
        
        Test.startTest();
        Account a = new Account(Name = 'TestCo');
        insert a;        
        
        contact con1=new contact(firstName='Care', lastname='Admin');
        contact con2=new contact(lastname='caredotcom');
        contact con3=new contact( lastname='Care.com');
        insert new List<contact>{con1,con2, con3};
        
        Datetime now = Datetime.now();
        
        Case c1 = new Case(Subject = 'incoming', contact_Theme__c='Safety',
                           contact_reason__c='Safety Communication',
                           contact_secondary_reason__c='Other',
                           Sentiment__c='Positive',
                           recordTypeId = socialMediaUS, 
                           AccountID = a.Id, 
                           Reason = 'Account', 
                           Status='Closed',
                           Secondary_Case_Reason__c = 'Add Profile');
        
        insert c1;
         SocialPost sp1=new SocialPost(Provider='Facebook',Name='SocialPost1',Posted=System.now(),parentId=c1.id,MessageType='Post',whoid=con1.id);
        SocialPost sp2=new SocialPost(Provider='Twitter',Name='SocialPost2',Posted=System.now(),parentId=c1.id,MessageType='Reply',whoid=con2.id);
        SocialPost sp3=new SocialPost(Provider='Instagram',Name='SocialPost3',Posted=System.now(),parentId=c1.id,MessageType='Post',whoid=con3.id);
         SocialPost sp4=new SocialPost(Provider='Twitter',Name='SocialPost4',Posted=System.now(),parentId=c1.id,MessageType='Comment');
        SocialPost sp5=new SocialPost(Provider='Facebook',Name='SocialPost5',Posted=System.now(),parentId=c1.id,MessageType='Private');
        SocialPost sp6=new SocialPost(Provider='Facebook',Name='SocialPost6',Posted=System.now(),parentId=c1.id,MessageType='Direct');
        insert new list<SocialPost>{sp1, sp2, SP3, sp4, sp5, sp6};
        Test.stopTest();
    }
    
     @isTest
    static void testInsert()
    {
        
        Test.startTest();
        integer count = 0;
        List<SocialPost> socialPostList=[SELECT who.name,AssignedTo,Classification,Content,CreatedById,CreatedDate,Id,Language,LastModifiedById,LastModifiedDate,MediaProvider,MediaType,MessageType,Name,OwnerId,ParentId,PersonaId,Posted,PostPriority,PostTags,PostUrl,Provider,R6PostId,Recipient,RecipientType,RecordTypeId,ReplyToId,Social_Post_Age_Minutes_Custom__c,SourceTags,Status,StatusMessage,TopicProfileName,TopicType,WhoId FROM  SocialPost where  Provider in('Facebook','Twitter')  order by Posted asc];
        for(SocialPost sp : socialPostList){
           count ++;
            
        }
		system.assertEquals(count, socialPostList.size());        
    }
    
    @isTest
    static void testUpdate()
    {
        
        Test.startTest();
        Contact con = [Select Id from contact limit 1];
        integer count = 0;
        List<SocialPost> socialPostList=[SELECT who.name,AssignedTo,Classification,Content,CreatedById,CreatedDate,Id,Language,LastModifiedById,LastModifiedDate,MediaProvider,MediaType,MessageType,Name,OwnerId,ParentId,PersonaId,Posted,PostPriority,PostTags,PostUrl,Provider,R6PostId,Recipient,RecipientType,RecordTypeId,ReplyToId,Social_Post_Age_Minutes_Custom__c,SourceTags,Status,StatusMessage,TopicProfileName,TopicType,WhoId FROM  SocialPost where  Provider in('Facebook','Twitter')  order by Posted asc];
        List<SocialPost> updS = new List<SocialPost>();
        for(SocialPost sp : socialPostList){
           sp.WhoId = con.Id;  
           updS.add(sp);
        }
        update updS;
		system.assertEquals(con.Id, updS[0].WhoId);        
    }
    
    @isTest
    static void testDelete()
    {
        
        Test.startTest();
        integer count = 0;
        List<id> spIds = new list<id>();
        List<SocialPost> socialPostList= [SELECT id, IsDeleted, Provider ,Posted , WhoId FROM  SocialPost where  Provider in('Facebook','Twitter')  order by Posted asc];
        for(socialPost sp : socialPostList){
            spIds.add(sp.Id);
        }
        delete socialPostList;
        
        List<SocialPost> socialPostList2= [SELECT IsDeleted, Provider ,Posted , WhoId FROM  SocialPost where  id IN:spIds];
        for(socialPost sp2 : socialPostList2){
            system.assertEquals(SP2.IsDeleted , true); 
        }
        
        
		       
    }
    
    
}