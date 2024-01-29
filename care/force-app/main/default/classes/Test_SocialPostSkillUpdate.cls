/*
    test Class for SocialPost records
    updates skill language for socialpost inbound posts.
    CreatedBy : md Ashwaq
    CreatedDate: 21/10/2021
*/
@isTest
public class Test_SocialPostSkillUpdate {
    public static Id socialMediaUS = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Social_Media_US').getRecordTypeId();
    
    @testSetup 
    static void setupData(){
         Test.startTest();
        User u = [SELECT Id,name, isActive FROM User WHERE Name = 'Social Studio User' and isActive=true limit 1];
		//Group g = [SELECT Id, name , developerName from group where DeveloperName ='Q_Social_Post' limit 1];
        
       
        
        Case c1 = new Case(Subject = 'incoming',
                           recordTypeId = socialMediaUS, 
                           Origin = 'Email', 
                           Status='New');
        
        
        insert new list<Case>{c1};
            
        
        SocialPost sp1=new SocialPost(ownerId =u.id,IsOutbound =false,Provider='Facebook',language='French',Name='SocialPost1',Posted=System.now(),parentId=c1.id,MessageType='Post');
        SocialPost sp2=new SocialPost(ownerId =u.id,IsOutbound =false,Provider='Facebook',language='English',Name='SocialPost2',Posted=System.now(),parentId=c1.id,MessageType='Reply');
        SocialPost sp3=new SocialPost(ownerId =u.id,IsOutbound =false,Provider='Facebook',language='Dutch',Name='SocialPost3',Posted=System.now(),parentId=c1.id,MessageType='Post');
         SocialPost sp4=new SocialPost(ownerId =u.id,IsOutbound =false,Provider='Facebook',language='German', Name='SocialPost4',Posted=System.now(),parentId=c1.id,MessageType='Comment');
        SocialPost sp5=new SocialPost(ownerId =u.id,IsOutbound =false,Provider='Facebook',Name='SocialPost5',Posted=System.now(),parentId=c1.id,MessageType='Private');
        SocialPost sp6=new SocialPost(ownerId =u.id,IsOutbound =false,Provider='Facebook',language='',Name='SocialPost6',Posted=System.now(),parentId=c1.id,MessageType='Direct' ,PostTags='UK/IE,Intl EN,International');
        
        insert new list<SocialPost>{sp1, sp2, SP3, sp4, sp5, sp6};
        Test.stopTest();
    }
    @IsTest
    static void TestIncomingSocials()
    {
        List<SocialPost> socialPostList=[SELECT isoutbound, ownerId, owner.Name, skill_language__C, language from socialpost];
        
    }

}