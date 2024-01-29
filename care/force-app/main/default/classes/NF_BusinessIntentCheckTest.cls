/**
 * @description       : Test Class for NF_BusinessIntentCheck
 * @author            : Abbas Jafry (NeuraFlash LLC)
 * @group             : 
 * @last modified on  : 07-28-2023
 * @last modified by  : Abbas Jafry (NeuraFlash LLC)
**/
@IsTest
public with sharing class NF_BusinessIntentCheckTest {
    @TestSetup
    static void testDataSetup(){
        String chatKey = '1234';
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.LiveChatVisitorId = liveChatVisitor.Id;
        transcript.ChatKey = chatKey;
        insert transcript;

        ebotdata__Bot_Session__c session = new ebotdata__Bot_Session__c();
        session.ebotdata__Live_Agent_Session_Id__c = chatKey;
        insert session;

        ebotdata__Bot_Chat_Log__c log = new ebotdata__Bot_Chat_Log__c();
        log.ebotdata__Bot_Session__c = session.Id;
        log.ebotdata__Intent_Name__c = 'bus_testIntent_end';
        log.ebotdata__Current_Dialog_Name__c = 'bus_testIntent_end';
        log.ebotdata__Current_Utterance__c = 'firstUserInput';
        log.ebotdata__Live_Agent_Session_Id__c = session.ebotdata__Live_Agent_Session_Id__c;
        insert log;
    }

    @isTest
    static void testLastBusinessIntent() {
        Test.startTest();
        NF_BusinessIntentCheck.Input input = new NF_BusinessIntentCheck.Input();
        input.chatKey = '1234';
        List<NF_BusinessIntentCheck.Output> result = NF_BusinessIntentCheck.businessIntentCheck(new List<NF_BusinessIntentCheck.Input> { input });
        Test.stopTest();

        System.assertEquals(true, result[0].hasEnteredBusinessIntent);
        System.assertEquals('bus_testIntent_end', result[0].businessIntentName);
    }
}