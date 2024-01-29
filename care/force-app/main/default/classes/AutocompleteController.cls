/****************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 09/14/2020
Description: Apex controller for Autocomplete lightning component
Comments:
*****************************************************************************/
public with sharing class AutocompleteController {

    /**
    * @description Handles sObject querying for Autocomplete lightning component
    * @param searchKeyword (String) - The text to search for
    * @param objectName (String) - The API name of the sObject to search
    * @param fieldName (String) - The API name of the sObject field to search
    * @return (List <sObject>) - The list of sObjects found
    */
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyword, String objectName, String fieldName) {
        return fetchLookUpValues(searchKeyword, objectName, fieldName, '');
    }

    /**
    * @description Handles sObject querying for Autocomplete lightning component
    * @param searchKeyword (String) - The text to search for
    * @param objectName (String) - The API name of the sObject to search
    * @param fieldName (String) - The API name of the sObject field to search
    * @param wildcardPosition (String) - Indicates where the wildcard on the searchKeyword should be added ('before', 'after', '')
    *                                    When wildcardPosition is blank wildcards are added both before and after the searchKeyword
    * @return (List <sObject>) - The list of sObjects found
    */
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyword, String objectName, String fieldName, String wildcardPosition) {
        List <sObject> returnList = new List <sObject> ();
        String searchKey;

        switch on wildcardPosition {
            when 'before' {
               searchKey = '%' + searchKeyword;
            }
            when 'after' {
               searchKey = searchKeyword + '%';
            }
            when else {
               searchKey = '%' + searchKeyword + '%';
            }
        }

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        String sQuery =  'SELECT Id, ' + fieldName + ' FROM ' + ObjectName + ' WHERE ' + fieldName + ' LIKE :searchKey ORDER BY ' + fieldName + ' DESC LIMIT 5';
        List <sObject> lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}