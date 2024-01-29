/*
** _________________________________________________________________________________
** Created by:    Sridhar Neeli [www.WaveLabs.in]
** Developer:     Sridhar Neeli, Application Architect Salesforce [sridharn@wavelabs.com]
** Modified Date:  04.02.2020
** =================================================================================
** Description: 
**             This is written as part of SFORCE-3000 CCPA - Access Data - Data Classification for Fields
** SFORCE-3001 CCPA - Access Data - Custom Web Service
** SFORCE-3002 CCPA - Access Data - Prepare a Sample JSON File
** SFORCE-3003 CCPA - Access Data - Query SFDC Fields
** SFORCE-3004 CCPA - Access Data - Encrypted the Queried SFDC Fields
** SFORCE-3005 CCPA - Access Data - Map specific field by record type
** SFORCE-3006 CCPA - Access Data - Generate JSON Files
** SFORCE-3004 CCPA - Access Data - Decrypt Files When US Platform Pulling Them
** SFORCE-3008 CCPA - Access Data - Need a Batch job to asynchronous Prepare Access Data Files
** SFORCE-3009 CCPA - Access Data - Secure Files so only Modify All and View All Data can see
** _______________________________________________________________________________
*/

public class CCPAAccessDataDeleteFiles
{
   
            
    List<Privacy_Request__c> TriggerNew;
    List<Privacy_Request__c> TriggerOld;
    Map<id,Privacy_Request__c> TriggerNewMap;
    Map<id,Privacy_Request__c> TriggerOldMap;
    Boolean TriggerIsInsert;
    Boolean TriggerIsUpdate;
    Boolean TriggerIsDelete;
    Boolean TriggerIsBefore;
    Boolean TriggerIsAfter;
    
    List<Privacy_Request__c> completedSuccessMemList=new List<Privacy_Request__c>();
    public CCPAAccessDataDeleteFiles(){
    }

    public CCPAAccessDataDeleteFiles(List<Privacy_Request__c> TriggerNew,List<Privacy_Request__c> TriggerOld,Map<id,Privacy_Request__c> TriggerNewMap,Map<id,Privacy_Request__c> TriggerOldMap,Boolean TriggerIsInsert,Boolean TriggerIsUpdate,Boolean TriggerIsDelete,Boolean TriggerIsBefore,Boolean TriggerIsAfter)
    {
        this.TriggerOld=TriggerOld;
        this.TriggerNew=TriggerNew;
        this.TriggerNewMap=TriggerNewMap;
        this.TriggerOldMap=TriggerOldMap;
        this.TriggerIsInsert=TriggerIsInsert;
        this.TriggerIsUpdate=TriggerIsUpdate;
        this.TriggerIsDelete=TriggerIsDelete;
        this.TriggerIsBefore=TriggerIsBefore;
        this.TriggerIsAfter=TriggerIsAfter;
    }
    public  void ProcessCCPAAccessDataDeleteFilesInstantRequest()
    { 
            Map<id,Privacy_Request__c> requestAcceptedMap=new Map<id,Privacy_Request__c>();
            for(Privacy_Request__c prObj:(TriggerIsBefore && TriggerIsDelete)?TriggerOld:Triggernew)
            {
                if((prObj.Request_Status__c.contains('Completed') || (TriggerIsBefore && TriggerIsDelete)) && prObj.Source_System__c=='US Platform' 
                && prObj.Request_Type__c=='Access Data')
                {
                    requestAcceptedMap.put(prObj.id,prObj);
                }
            }  
            if(!requestAcceptedMap.isEmpty())
            {
                List<ContentDocumentLink> cdlList=new List<ContentDocumentLink>([select id,contentDocumentId from ContentDocumentLink where LinkedEntityId=:requestAcceptedMap.keySet()]);
                Set<id> cdIdList=new Set<Id>();
                for(ContentDocumentLink cdlObj:cdlList)
                {
                    cdIdList.add(cdlObj.contentDocumentId);
                }
                List<ContentDocument> cdList=new List<ContentDocument>([select id from ContentDocument where id=:cdIdList]);
                if(!cdList.isEmpty()) 
                {
                    Database.delete(cdList,false);Database.emptyRecycleBin(cdList); 
                    for(Id prId:requestAcceptedMap.keySet())
                    {
                        if(!(TriggerIsBefore && TriggerIsDelete))
                        requestAcceptedMap.get(prId).No_Of_Files_Retrieved__c=0;
                    }
                    //if(!requestAcceptedMap.isEmpty()) update requestAcceptedMap.values();
                }
            }
            
            }
            }