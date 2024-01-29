/***
Created by: Vivek Suryawanshi.
Date:13/01/2012
Description: It consist the HTTP request to service and JSON parser.
1: It calls the service which accepts zipcode and distance within which we need to find providers as input which is 
   hosted on legacy system as a result it returns the JSON as output. 
2: It than parses the JSON to get the zipcodes and stores it in map in which zipcodes is key and distance is value.
***/

public class JSONParserUtil {

    public static map<string,Decimal> parseJSONResponse(string zpcd, string rad1) {   
        //map to store the valid zipcodes as key and distance as values.
        map<string,Decimal> zipcdes=new map<string,Decimal>();     
        Http httpProtocol = new Http();
        // Create HTTP request to send. 
        HttpRequest request = new HttpRequest();
        // Set the endpoint URL. 
       try
       {
        
         webServiceURL__c  urlSt = webServiceURL__c.getInstance();
         String url = urlSt.URL1__c;

         webServiceAPIKey__c  key1 = webServiceAPIKey__c.getInstance();
         String token1 = key1.defaultAPIKey__c;
       
        String endpoint =url+zpcd+'&aRadius='+rad1+token1;
        request.setEndPoint(endpoint);
        // Set the HTTP verb to GET. 
    
        request.setMethod('GET');
        // Send the HTTP request and get the response. 
        // The response is in JSON format. 
    
        HttpResponse response = httpProtocol.send(request);

        // Parse JSON response to get all the required zipcodes.
        JSONParser parser = JSON.createParser(response.getBody());
        system.debug('*******************************response:'+response.getBody());
        String fieldName;
        String fieldValue;
        while(fieldName!='data')
       {
          parser.nextToken();
          // Advance to the next value. 
    
          fieldName = parser.getCurrentName();
          // Get the textual representation  
          // of the value. 
          fieldValue = parser.getText();
       }
       parser.nextToken();
       fieldName='';
       integer counter=0;
       while(fieldName!='data')
      {
        counter++;
       
        parser.nextToken();
        fieldName = parser.getCurrentName();
        if(fieldName!='data')
        {
          //zipcdes.add(fieldName);
          parser.nextValue();
           //fieldName = parser.getCurrentName();
          // Get the textual representation  
         // of the value. 
         fieldValue = parser.getText();
         if(fieldName!=Null && fieldValue!=Null)
         {
           zipcdes.put(fieldName,Decimal.valueOf(fieldValue));
         }  
        }
      }
      
      if(!zipcdes.isEmpty())
      {
       //returning zipcodes
        return zipcdes;
      }
      else
      {
       return Null;
      } 
     }Catch(Exception e){
      system.debug('*************************************Exception in json parser:'+e);
      Return Null;
     }
    }   
}