/**
 * @description       : Utility class for the BOT
 * @author            : Fazleabbas Jafry (NeuraFlash LLC)
 * @group             : 
 * @last modified on  : 07-06-2023
 * @last modified by  : Fazleabbas Jafry (NeuraFlash LLC)
**/
public with sharing class NF_BotUtil {

    public static String getLastBusinessIntent(String chatKey) {
        String lastBusinessIntent = '';
        try {
            ebotdata__Bot_Chat_Log__c[] botChatLogs = [
                SELECT Id, ebotdata__Current_Dialog_Name__c
                FROM ebotdata__Bot_Chat_Log__c
                WHERE ebotdata__Live_Agent_Session_Id__c = :chatKey
                AND ebotdata__Current_Dialog_Name__c LIKE 'bus_%'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            if(botChatLogs.size() > 0) {
                lastBusinessIntent = botChatLogs[0].ebotdata__Current_Dialog_Name__c;
            }

        } catch(Exception e) {
            // ErrorLogUtility.fireErrorEvent(e, 'NF_BotUtil', 'getLastBusinessIntent');
        }
        return lastBusinessIntent;
    }
}