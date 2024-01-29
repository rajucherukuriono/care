public with sharing class Lookup_class 
{
    public List <EmailTemplate> objTemplate = new List<EmailTemplate>();
    Public String message;
    Folder f;
    
    public Lookup_class()
    {
        
        try
        {
            likeString = System.currentPageReference().getParameters().get('likeString');           
            showSearch = true;
            //SetFlag();
            message = System.currentPagereference().getParameters().get('msg');
            system.debug('***********************************message:'+message);
            if(message=='Seeker')
            {
              f= [Select f.Id, f.DeveloperName From Folder f where f.Name='Seeker Referral Emails' LIMIT 1];
            }
            else if(message=='Provider')
            {
              f= [Select f.Id, f.DeveloperName From Folder f where f.Name='Provider Referral Emails' LIMIT 1];
            }
        }
        catch(exception ex)
        {
            // DO NOTHING
        }
    }
    public boolean showSearch
    {
        set
        {
           showSearch= value;
        }
        get
        {
          return showSearch; 
        }
    }    
    public String likeString 
    {
        set
        {
           likeString = value;
        }
        get
        {
          return likeString; 
        }
    }   
    
    
    
    public list <EmailTemplate> getshowTemplate()
    {        
        if(likeString=='' || likeString==null)
        {
            objTemplate = [Select Id, Name, body,HtmlValue From EmailTemplate where FolderId=:f.Id AND IsActive= true order by Name];
        }
        else
        {
            string likeString1 =  '%'+likeString +'%';
            objTemplate = [Select Id, Name, body,HtmlValue From EmailTemplate where FolderId=:f.Id AND IsActive= true And Name LIKE :likeString1 ORDER BY Name ASC];
        }
        
        return objTemplate; 
    }         
    
    public PageReference findTemplate()
    {
        getshowTemplate();
        return null;
    }
    
    public string Name
    {
        set
        {
            Name= value;
        }
        get
        {
            return Name; 
        }
    }
    
}