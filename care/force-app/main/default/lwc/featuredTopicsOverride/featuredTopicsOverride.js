import { LightningElement, api } from 'lwc';
import trustAndSafetyFaqUrl from '@salesforce/resourceUrl/trustAndSafetyFaq';
import companyFaqUrl from '@salesforce/resourceUrl/companyFaq';
import subscriptionAndBillingFaqUrl from '@salesforce/resourceUrl/subscriptionAndBillingFaq';

export default class FeaturedTopicsOverride extends LightningElement {

@api trustAndSafetyLink;
@api trustAndSafetyFaqUrl=trustAndSafetyFaqUrl;
@api trustAndSafetyBottomLeft;
@api trustAndSafetyTopLeft;
@api trustAndSafetyTopRight;
@api trustAndSafetyBottomRight;
@api trustAndSafetyCentered;

@api companyLink;
@api companyFaqUrl=companyFaqUrl;
@api companyBottomLeft;
@api companyTopLeft;
@api companyTopRight;
@api companyBottomRight;
@api companyCentered;


@api subscriptionAndBillingLink;
@api subscriptionAndBillingFaqUrl=subscriptionAndBillingFaqUrl;
@api subscriptionAndBillingBottomLeft;
@api subscriptionAndBillingTopLeft;
@api subscriptionAndBillingTopRight;
@api subscriptionAndBillingBottomRight;
@api subscriptionAndBillingCentered;

}