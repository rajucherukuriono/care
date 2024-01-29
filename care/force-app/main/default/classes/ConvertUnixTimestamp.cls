global with sharing class ConvertUnixTimestamp {

    global class UnixTimeStampInput {
        @InvocableVariable(
            Label='Number' 
            Description='Number' 
            Required=true)
        global Integer unixTimestamp;
    }


    global class ConvertedTimeStampOutput {
        @InvocableVariable(
            Label='Datetime' 
            Description='Datetime as converted from Unix timestamp' 
            Required=true)
        global DateTime convertedDateTime;
    }
    
    @InvocableMethod(
        Label='Convert Unix Timestamp into Datetime'
        Description='Accepts a numbeer (as a string) and returns a datetime')
    public static List<ConvertedTimeStampOutput> ConvertUnixTimestampIntoDateTime(List<UnixTimeStampInput> timestamps) {
        List<ConvertedTimeStampOutput> convertedTimestamps = new List<ConvertedTimeStampOutput>();
        for(UnixTimeStampInput each : timestamps){
            Datetime timeFromUnix = Datetime.newInstance(0).addSeconds(each.unixTimestamp);
            ConvertedTimeStampOutput converted = new ConvertedTimeStampOutput();
            converted.convertedDateTime = timeFromUnix;
            convertedTimestamps.add(converted);
        }
        
        return convertedTimestamps;
    }
}