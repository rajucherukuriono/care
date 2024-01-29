global class SyncPromoCodeBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('');
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    }
    
    global void finish(Database.BatchableContext BC){
    }
    /* 
//Commented as per SFORCE-3680
global final String query;
//public static String TABLE_ID = '3185370'; // ALPromoRelationalTable; Test Id=3158151; Prod Id=3185370;
public static String TABLE_ID = '4199823';	// CL Upgrade Table and the table ID is 4199823; Prod Id=4199823;



global SyncPromoCodeBatch(){
//query = 'SELECT Expiration_Date__c,Id,Name,Redemption_Date__c,Redemption_Status__c,Contact__r.MemberID__c FROM Promo_Code__c WHERE Sync_In_Progress__c = true';
query = 'SELECT Expiration_Date__c,Id,Name,Redemption_Date__c,Redemption_Status__c,Account__r.MemberID__pc FROM Promo_Code__c WHERE Sync_In_Progress__c = true';
} 

//Commented as per SFORCE-3680
global Database.QueryLocator start(Database.BatchableContext BC){

// select records to by synced
List<sObject> promoCodesToSyncList = Database.query('Select id from Promo_Code__c where Sync_To_Silverpop__c = true');
for (sObject s : promoCodesToSyncList){
// Set flag "Contact.Sync to SP in Progress" to true
s.put('Sync_In_Progress__c',true);
s.put('Sync_To_Silverpop__c',false);
}
update promoCodesToSyncList;

return Database.getQueryLocator(query);
}

global void execute(Database.BatchableContext BC, List<sObject> scope){

try {
dom.Document requestDoc = new Dom.Document();
dom.XmlNode envelopeNode = requestDoc.createRootElement('Envelope', null, null);
dom.XmlNode bodyNode = envelopeNode.addChildElement('Body',null,null);
dom.XmlNode relatTableNode = bodyNode.addChildElement('InsertUpdateRelationalTable',null,null);
dom.XmlNode tableIdNode = relatTableNode.addChildElement('TABLE_ID',null,null);
dom.XmlNode rowsNode = relatTableNode.addChildElement('ROWS',null,null);

tableIdNode.addTextNode(TABLE_ID);

system.debug('*****Number of records to send to Silverpop = ' + scope.size());

for(sObject s : scope){

//'<Envelope><Body><InsertUpdateRelationalTable><TABLE_ID>3158151</TABLE_ID><ROWS><ROW><COLUMN name="Member Id"><![CDATA[123456]]></COLUMN>
// <COLUMN name="AL Promo Code"><![CDATA[ABCDEF]]></COLUMN><COLUMN name="Redemption Date"><![CDATA[01/31/2013]]></COLUMN><COLUMN name="Expiration Date"><![CDATA[01/31/2013]]></COLUMN><COLUMN name="Redemption Status"><![CDATA[Redeemed]]></COLUMN></ROW></ROWS></InsertUpdateRelationalTable></Body></Envelope>';
dom.XmlNode firstRowNode = rowsNode.addChildElement('ROW',null,null);
dom.XmlNode firstColumnNode = firstRowNode.addChildElement('COLUMN',null,null);
firstColumnNode.setAttribute('name','Member Id');
//sObject PromoContact =  s.getSObject('Contact__r');
//firstColumnNode.addTextNode(String.valueOf(integer.valueOf(PromoContact.get('MemberID__c'))));
sObject PromoAccount =  s.getSObject('Account__r');
firstColumnNode.addTextNode(String.valueOf(integer.valueOf(PromoAccount.get('MemberID__pc'))));

dom.XmlNode secondColumnNode = firstRowNode.addChildElement('COLUMN',null,null);
//secondColumnNode.setAttribute('name','AL Promo Code');
secondColumnNode.setAttribute('name','CL Promo Code');
secondColumnNode.addTextNode(String.valueOf(s.get('Name')));

// don't send redemption date field if undefined (it ends up not sending a text node and Silverpop API complains about it missing the text node)
String redemptionDate = getRedemptionDateString(s.get('Redemption_Date__c'));
if (redemptionDate != ''){
dom.XmlNode thirdColumnNode = firstRowNode.addChildElement('COLUMN',null,null);
thirdColumnNode.setAttribute('name','Redemption Date');
thirdColumnNode.addTextNode(redemptionDate);
}

dom.XmlNode fourthColumnNode = firstRowNode.addChildElement('COLUMN',null,null);
fourthColumnNode.setAttribute('name','Expiration Date');
Datetime expirationDateGmt = Datetime.valueOf(String.valueOf(s.get('Expiration_Date__c')));
fourthColumnNode.addTextNode(expirationDateGmt.format('MM/dd/yyyy','America/New_York'));

dom.XmlNode fifthColumnNode = firstRowNode.addChildElement('COLUMN',null,null);
fifthColumnNode.setAttribute('name','Redemption Status');
fifthColumnNode.addTextNode(String.valueOf(s.get('Redemption_Status__c')));

}

String xmlDoc = requestDoc.toXmlString();
system.debug('*****Silverpop xmlDoc = ' + xmlDoc);

// sendRecordsToSilverpop
SyncPromoCode mySPC = new SyncPromoCode();
mySPC.sendToSilverpop(requestDoc);

} catch (DmlException de) {
System.debug('DML error creating running batch sync: ' + de.getMessage());
System.debug('More details to follow ...');
Integer numErrors = de.getNumDml();
System.debug('getNumDml=' + numErrors);
for(Integer i=0;i<numErrors;i++) {
System.debug('getDmlFieldNames=' + de.getDmlFieldNames(i));
System.debug('getDmlMessage=' + de.getDmlMessage(i));  
}	
} catch (System.XMLException e) {  
System.debug('XML exception caught running batch sync: ' + e.getMessage());
} catch(SObjectException e) {
System.debug('SObjectException caught running batch sync: ' + e.getMessage());        
} catch (Exception e){
System.debug('Generic exception caught running batch sync: ' + e.getMessage());    
}


}

global void finish(Database.BatchableContext BC){
}

private String getRedemptionDateString(object redemptionDate){
// An empty vlaue for Redemption Date is valid; it means the user hasn't redeemed the promo code yet 
String redemptionDateStr = String.valueOf(redemptionDate);
if (redemptionDateStr != null){
DateTime redemptionDateGmt = DateTime.valueOf(redemptionDateStr);
redemptionDateStr = redemptionDateGmt.format('MM/dd/yyyy','America/New_York');
} else {
redemptionDateStr = '';
}		
return redemptionDateStr;
}
*/
}