public with sharing class OrgNotesController {
    // Get the one Active Account RecordTypes that is available to the running user
    public OrgNotes__c orgnoteslist {get;}
    public String label;
    public String text;    
  	public OrgNotesController ()
    {
        // List to hold ALL Active Record Types for the given SObjectType OrgNotes__c 
        //  Obtain ALL Active Record Types for the given SObjectType OrgNotes__c 
        List<String> lststrId = new List<String>();
        Schema.DescribeSObjectResult orgNotesR = OrgNotes__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> orgNotesRT = orgNotesR.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rt: orgNotesRT){
            if (  rt.isAvailable() && rt.isDefaultRecordTypeMapping()) 
            {
                lststrId.add(Id.valueOf(rt.getRecordTypeId()));
                // Loop through all of the active Record Types we found,
        		// and get only those that are available to the Running User
    			// This RecordType IS available to the running user and this should be valid for only one record type
        	}
        }
            
        
        
        // Get Record Entry 
        List<OrgNotes__c> orgnoteslist = [select name, grouplabel__c, message__c, RecordtypeID_18__c 
                                          from OrgNotes__c  
                                          where RecordtypeID_18__c IN :lststrId
                                          order by createddate desc limit 1];
        
            if(orgnoteslist.size() > 0) {
                for (OrgNotes__c onotes : orgnoteslist) {
                    label = (String) onotes.grouplabel__c;
                    System.debug('label  '+label);
                    text = (String) onotes.message__c;
                    System.debug('message  '+ text);
                    }
          
      }  // end for          
    } // constructor  
    
    public String getLabel() {
       return label; 
    }
    public String getMessage() {
        return text;
    }
}