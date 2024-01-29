import { LightningElement, api } from 'lwc';
import trustAndSafetyFaqUrl from '@salesforce/resourceUrl/trustAndSafetyFaq';
import standOutToFamiliesFaqUrl from '@salesforce/resourceUrl/standOutToFamiliesFaq';	 
import subscriptionAndBillingFaqUrl from '@salesforce/resourceUrl/subscriptionAndBillingFaq';

export default class FeaturedTopicsOverride1 extends LightningElement {
@api trustAndSafetyLink;
@api trustAndSafetyFaqUrl=trustAndSafetyFaqUrl;
@api trustAndSafetyBottomLeft;
@api trustAndSafetyTopLeft;
@api trustAndSafetyTopRight;
@api trustAndSafetyBottomRight;
@api trustAndSafetyCentered;

@api standOutToFamiliesLink;
@api standOutToFamiliesFaqUrl=standOutToFamiliesFaqUrl;
@api standOutToFamiliesBottomLeft;
@api standOutToFamiliesTopLeft;
@api standOutToFamiliesTopRight;
@api standOutToFamiliesBottomRight;
@api standOutToFamiliesCentered;


@api subscriptionAndBillingLink;
@api subscriptionAndBillingFaqUrl=subscriptionAndBillingFaqUrl;
@api subscriptionAndBillingBottomLeft;
@api subscriptionAndBillingTopLeft;
@api subscriptionAndBillingTopRight;
@api subscriptionAndBillingBottomRight;
@api subscriptionAndBillingCentered;
}