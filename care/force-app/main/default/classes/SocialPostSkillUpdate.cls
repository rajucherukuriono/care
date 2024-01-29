public class SocialPostSkillUpdate {

    public static void skillandQueueUpdate(list<SocialPost>records, map<Id, SocialPost>oldMap)
    {
        
        User u = [SELECT Id,name, isActive FROM User WHERE Name = 'Social Studio User' and isActive=true limit 1];
        Group g = [SELECT Id, name , developerName from group where DeveloperName ='Q_Social_Post' limit 1];
        for (SocialPost so : records){ 
            if( so.Language != '' && so.Language !=null ){
                so.Skill_Language__c = so.Language;
            }
            if( so.Language == '' || so.Language ==null ){
                so.Language  = 'English';
                so.Skill_Language__c = 'English';                
            }
            if(so.Language != '' && so.Language !=null  && !so.IsOutbound && g!=null && u!=null && so.OwnerId ==u.Id){
                so.OwnerId  =g.Id;                
            }
            if( so.PostTags !='' && so.PostTags !=null ){
                so.Post_Tags_Short__c =so.PostTags;          
            }
            
        }
        
    }
}