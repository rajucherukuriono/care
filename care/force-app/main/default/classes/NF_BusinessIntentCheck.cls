/**
 * @description       : Utility class for the BOT
 * @author            : Fazleabbas Jafry (NeuraFlash LLC)
 * @group             : 
 * @last modified on  : 07-06-2023
 * @last modified by  : Fazleabbas Jafry (NeuraFlash LLC)
**/
public with sharing class NF_BusinessIntentCheck {

    public class Input {
        @InvocableVariable(required=true)
        public String chatKey;
    }

    public class Output {
        @InvocableVariable(required=true)
        public Boolean hasEnteredBusinessIntent;

        @InvocableVariable(required=false)
        public String businessIntentName;
    }

    @InvocableMethod(label='NeuraFlash - Has Entered Business Intent')
    public static List<Output> businessIntentCheck(List<Input> input) {
        List<Output> outputs = new List<NF_BusinessIntentCheck.Output>();
        Output out = new Output();
        out.hasEnteredBusinessIntent = false;

        try{
            String busIntent = NF_BotUtil.getLastBusinessIntent(input[0].chatKey);
            if(String.isNotBlank(busIntent)){
                out.hasEnteredBusinessIntent = true;
                out.businessIntentName = busIntent;
            }

            outputs.add(out);
        }catch(Exception e){
            System.debug('Exception while processing Business Intent:' + e);
        }
        return outputs;
    }
}