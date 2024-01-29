/* *
** LastModified: Md Ashwaq
** ModifiedDate: 07-20-2023
** =================================================================================
*/
public Class AvoidRecursion{
    private static boolean runOnlyOnce = true;
    public static boolean runOnce(){
        if(runOnlyOnce){
            runOnlyOnce=false;
            return true;
        }else{
            return runOnlyOnce;
        }
    }
    private static boolean runOnlyOnceRequestData1 = true;
    public static boolean runOnceRequestData1(){
        if(runOnlyOnceRequestData1){
            runOnlyOnceRequestData1=false;
            return true;
        }else{
            return runOnlyOnceRequestData1;
        }
    }
    private static boolean runOnlyOnceRetention1 = true;
    public static boolean runOnceRetention1(){
        if(runOnlyOnceRetention1){
            runOnlyOnceRetention1=false;
            return true;
        }else{
            return runOnlyOnceRetention1;
        }
    }
    private static boolean runOnlyOnceGdpr1 = true;
    public static boolean runOnceGdpr1(){
        if(runOnlyOnceGdpr1){
            runOnlyOnceGdpr1=false;
            return true;
        }else{
            return runOnlyOnceGdpr1;
        }
    }
    private static boolean runOnlyOnceTask1 = true;
    public static boolean runOnceTask1(){
        if(runOnlyOnceTask1){
            runOnlyOnceTask1=false;
            return true;
        }else{
            return runOnlyOnceTask1;
        }
    } 
    private static boolean runOnlyOnceEvent1 = true;
    public static boolean runOnceEvent1(){
        if(runOnlyOnceEvent1){
            runOnlyOnceEvent1=false;
            return true;
        }else{
            return runOnlyOnceEvent1;
        }
    }
    private static boolean runOnlyOnceEmailMessage1 = true;
    public static boolean runOnceEmailMessage1(){
        if(runOnlyOnceEmailMessage1){
            runOnlyOnceEmailMessage1=false;
            return true;
        }else{
            return runOnlyOnceEmailMessage1;
        }
    }
    private static boolean runOnlyOnceCase3 = true;
    public static boolean runOnceCase3(){
        if(runOnlyOnceCase3){
            runOnlyOnceCase3=false;
            return true;
        }else{
            return runOnlyOnceCase3;
        }
    } 
    private static boolean runOnlyOnceCase2 = true;
    public static boolean runOnceCase2(){
        if(runOnlyOnceCase2){
            runOnlyOnceCase2=false;
            return true;
        }else{
            return runOnlyOnceCase2;
        }
    }
    private static boolean runOnlyOnceCase1 = true;
    public static boolean runOnceCase1(){
        if(runOnlyOnceCase1){
            runOnlyOnceCase1=false;
            return true;
        }else{
            return runOnlyOnceCase1;
        }
    }
    private static boolean runOnlyOnceCaseComment1 = true;
    public static boolean runOnceCaseComment1(){
        if(runOnlyOnceCaseComment1){
            runOnlyOnceCaseComment1=false;
            return true;
        }else{
            return runOnlyOnceCaseComment1;
        }
    }
    private static boolean runOnlyOnceCCPADeletion1 = true;
    public static boolean runOnceCCPADeletion1(){
        if(runOnlyOnceCCPADeletion1){
            runOnlyOnceCCPADeletion1=false;
            return true;
        }else{
            return runOnlyOnceCCPADeletion1;
        }
    }
    private static boolean runOnlyOnceRecentLMD = true;
    public static boolean runOnceRecentLMD(){
        if(runOnlyOnceRecentLMD){
            runOnlyOnceRecentLMD=false;
            return true;
        }else{
            return runOnlyOnceRecentLMD;
        }
    }
    public static boolean runOnlyOnceCaseTriage = true;
    public static boolean runOnceCaseTriage(){
        if(runOnlyOnceCaseTriage){
            runOnlyOnceCaseTriage=false;
            return true;
        }else{
            return runOnlyOnceCaseTriage;
        }
    }
    public static boolean runOnlyOnceSafetyCaseTriage = true;
    public static boolean runOnceSafetyCaseTriage(){
        if(runOnlyOnceSafetyCaseTriage){
            runOnlyOnceSafetyCaseTriage=false;
            return true;
        }else{
            return runOnlyOnceSafetyCaseTriage;
        }
    }  
    public static boolean runOnlyOnceSafetyCaseTriageUpdt = true;
    public static boolean runOnceSafetyCaseTriageUpdt(){
        if(runOnlyOnceSafetyCaseTriageUpdt){
            runOnlyOnceSafetyCaseTriageUpdt=false;
            return true;
        }else{
            return runOnlyOnceSafetyCaseTriageUpdt;
        }
    }  
    public static boolean runOnlyOnceOpenTask = true;
    public static boolean runOnceOpenTask(){
        if(runOnlyOnceOpenTask){
            runOnlyOnceOpenTask=false;
            return true;
        }else{
            return runOnlyOnceOpenTask;
        }
    }
    public static boolean runOnlyOncesmCaseTriage = true;
    public static boolean runOncesmCaseTriage(){
        if(runOnlyOncesmCaseTriage){
            runOnlyOncesmCaseTriage=false;
            return true;
        }else{
            return runOnlyOncesmCaseTriage;
        }
    }
    @TestVisible
    public static boolean runOnlyOnceMCCaseTriage = true;
    public static boolean runOnceMCCaseTriage(){
        if(runOnlyOnceMCCaseTriage){
            runOnlyOnceMCCaseTriage=false;
            return true;
        }else{
            return runOnlyOnceMCCaseTriage;
        }
    }
    
    @TestVisible
    public static boolean runOnlyOnceBlockedAppeal = true;
    public static boolean runOnceBlockedAppeal(){
        if(runOnlyOnceBlockedAppeal){
            runOnlyOnceBlockedAppeal=false;
            return true;
        }else{
            return runOnlyOnceBlockedAppeal;
        }
    }
    
}