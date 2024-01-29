trigger OnDemandSyncAccountTrigger on Account (after insert) {
	OnDemandSync.HandleNewlyCreatedAccounts(trigger.new);
}