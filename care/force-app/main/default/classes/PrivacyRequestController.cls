public class PrivacyRequestController {

    
    public static void handleInsert(List<Privacy_Request__c> requests){
        for (Privacy_Request__c request : requests){
            // If Value is blank & formula is not (this protects values added manually from being overridden by formula)
            request.Name__c = (request.Name__c == null && request.Name_Formula__c != null) ? request.Name_Formula__c : request.Name__c;
            request.Email__c = DefaultEmailPublisherSettings.StripMemberIdFromEmail((request.Email__c == null && request.Email_Formula__c != null) ? request.Email_Formula__c : request.Email__c,null);
            request.Universal_Member_Id__c = (request.Universal_Member_Id__c == null && request.Universal_Member_Id_Formula__c != null) ? request.Universal_Member_Id_Formula__c : request.Universal_Member_Id__c;
            
			// Handle Categories if they are not null
			if (request.Data_Categories__c != null ) request.Data_Categories_display_friendly__c = makeCategoriesDisplayFriendly(request);
        }
    }

    public static void handleUpdate(List<Privacy_Request__c> requests, List<Privacy_Request__c> oldRequests, Map<id,Privacy_Request__c> newMap,Map<id,Privacy_Request__c> oldMap){
        for (Privacy_Request__c request : requests){
            // If formula has changed && Old value matched old formula (this protects values added manually from being overridden by formula)
            if (request.Name_Formula__c != oldMap.get(request.id).Name_Formula__c && oldMap.get(request.id).Name__c == oldMap.get(request.id).Name_Formula__c) request.Name__c = request.Name_Formula__c;
            if (request.Email_Formula__c != oldMap.get(request.id).Email_Formula__c && oldMap.get(request.id).Email__c == oldMap.get(request.id).Email_Formula__c) request.Email__c = DefaultEmailPublisherSettings.StripMemberIdFromEmail(request.Email_Formula__c,null);
            if (request.Universal_Member_Id_Formula__c != oldMap.get(request.id).Universal_Member_Id_Formula__c && oldMap.get(request.id).Universal_Member_Id__c == oldMap.get(request.id).Universal_Member_Id_Formula__c) request.Universal_Member_Id__c = request.Universal_Member_Id_Formula__c;

			// Handle Categories if they have changed
			if (request.Data_Categories__c != oldMap.get(request.id).Data_Categories__c) request.Data_Categories_display_friendly__c = makeCategoriesDisplayFriendly(request);

        }
        
    }

    public static String makeCategoriesDisplayFriendly(Privacy_Request__c request){
        String DisplayFriendlyCategories = '';
        if (request.Data_Categories__c != null){
	        DisplayFriendlyCategories += '<ul>';
            for (String DataCategory : request.Data_Categories__c.split(',')){
				DataCategory = DataCategory.toLowerCase().trim();
                if (DataCategory == 'identifiers') DisplayFriendlyCategories += '<li>identifiers (such as name, address, email address);</li>';
                if (DataCategory == 'commercial') DisplayFriendlyCategories += '<li>commercial information (such as transaction data);</li>';
                if (DataCategory == 'financial') DisplayFriendlyCategories += '<li>financial data (such as payment method details and billing address);</li>';
                if (DataCategory == 'internet') DisplayFriendlyCategories += '<li>internet or other network or device activity (such as browsing history or usage information);</li>';
                if (DataCategory == 'geolocation') DisplayFriendlyCategories += '<li>geolocation information (e.g., your approximate location based on IP address, or precise location with your consent);</li>';
                if (DataCategory == 'inference') DisplayFriendlyCategories += '<li>inference data about you (e.g., the additional services or advertising we think would be of most interest to you based on your interactions with us);</li>';
                if (DataCategory == 'professional') DisplayFriendlyCategories += '<li>professional or employment-related data (e.g., if you are a Care Provider, your references and employment history);</li>';
                if (DataCategory == 'education') DisplayFriendlyCategories += '<li>education information (e.g., if you are a Care Provider, your level of education);</li>';
                if (DataCategory == 'legally protected classifications') DisplayFriendlyCategories += '<li>legally protected classifications (such as gender or information obtained from a background check, where applicable);</li>';
                if (DataCategory == 'physical characteristics') DisplayFriendlyCategories += '<li>physical characteristics or description (e.g., photos you choose to upload to your job postings or profile);</li>';
                if (DataCategory == 'sensory') DisplayFriendlyCategories += '<li>sensory or visual information (e.g. if you provide us this information in connection with senior care planning or child care)</li>';
                if (DataCategory == 'medical') DisplayFriendlyCategories += '<li>medical information (e.g. if you provide us this information in connection with senior care planning or child care); and</li>';
                if (DataCategory == 'other') DisplayFriendlyCategories += '<li>other information that identifies or can be reasonably associated with you (e.g., registration and log-in information).</li>';
            }
            DisplayFriendlyCategories += '</ul>';
        }
        return DisplayFriendlyCategories;
        
    }

}