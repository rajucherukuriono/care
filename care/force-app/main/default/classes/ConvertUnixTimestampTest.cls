@IsTest
public with sharing class ConvertUnixTimestampTest {
    
    @isTest
    static void TimestampIsConvertedToDateTime() {
        List<ConvertUnixTimestamp.UnixTimeStampInput> input = new List<ConvertUnixTimestamp.UnixTimeStampInput>();
        ConvertUnixTimestamp.UnixTimeStampInput timestamp = new ConvertUnixTimestamp.UnixTimeStampInput();
        timestamp.unixTimestamp = 1000000000;
        input.add(timestamp);
        List<ConvertUnixTimestamp.ConvertedTimeStampOutput> output = ConvertUnixTimestamp.ConvertUnixTimestampIntoDateTime(input);
        System.AssertEquals(output[0].convertedDateTime, DateTime.newInstance(0).addSeconds(1000000000));
    }
}