public class LiveAgentPostChatController {

    public string AgentName {get; set;}
    public string FileContents {get; set;}
    
    public LiveAgentPostChatController(){
		AgentName = getAgetNameFromChatDetailsJSON(ApexPages.currentPage().getParameters().get('chatDetails'));

        String Transcript = ApexPages.currentPage().getParameters().get('transcript');
        if (null != Transcript){
            FileContents = EncodingUtil.base64Encode(Blob.valueOf(Transcript));
        }
    }

	public String getAgetNameFromChatDetailsJSON(String chatDetails){
        Map<String, Object> responseMap = null;
        String LocalAgentName = null;
        try {
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(chatDetails);
            Map<String, Object> agentMap = (Map<String, Object>) responseMap.get('agent');
            LocalAgentName = (String) agentMap.get('agentName');
        } catch (System.Exception e){ 
            // If any errors are thrown here, the JSON response does not contain the info we're expecting, so send a default value instead
            LocalAgentName = 'Agent';
        }
        return LocalAgentName;
    }


    public String getFileContents() {
        return FileContents;
	}
    

    public PageReference save(){
        return null;
    }
}