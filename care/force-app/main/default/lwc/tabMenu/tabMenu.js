import { LightningElement, api } from 'lwc';
import hc_families from '@salesforce/label/c.HC_Families';
import hc_caregivers from '@salesforce/label/c.HC_Caregivers';
import hc_businesses from '@salesforce/label/c.HC_Businesses';
import getCommunitySettings from '@salesforce/apex/CDCCHeaderController.getCommunitySettings';
import reduceErrors from 'c/cdccErrorUtil';
import { getLocale } from 'c/localeService';
import { getExternalMemberId,getMemberUUID, getMemberType, buildCommunityUrlHelper } from 'c/memberDetailsService';


export default class TabMenu extends LightningElement {
    @api communitySettings = {};
    locale;
    externalMemberId;  
    memberUUID; 
    memberType;

    label = {hc_families, hc_caregivers, hc_businesses};

    @api
    get locale() {
        return getLocale();
    }

    @api
    get externalMemberId(){
        return getExternalMemberId();
    }

    @api
    get memberUUID(){
        return getMemberUUID();
    }

    @api
    get memberType(){
        return getMemberType();
    }

    get showForBusinessesLink(){
        // We only show Business Links if the checkbox is checked AND if we're in the US
        // If we ever want more granular control on a per lang basis, we'll need to add that to the CMD
        let show = false;
        if (this.communitySettings === undefined){
            show = false;
        } else if (this.communitySettings.showForBusinessesLink === true && this.locale == 'en_US'){
            show = true;
        }
        return show;        
    }

    get isFamiliesSelected() {
        return this.communitySettings.communityName === 'Families';
    }


    get familiesLinkClass() {
        return this.communitySettings.communityName === 'Families' ? 'selected' : '';
    }

    get familiesLinkUrl() {
        return this.buildCommunityUrl(this.communitySettings.forFamiliesLinkUrl);
    }

    get isCaregiversSelected() {
        return this.communitySettings.communityName === 'Caregivers';
    }

    get caregiversLinkClass() {
        return this.communitySettings.communityName === 'Caregivers' ? 'selected' : '';
    }

    get caregiversLinkUrl() {
        return this.buildCommunityUrl(this.communitySettings.forCaregiversLinkUrl);
    }

    get isBusinessSelected() {
        return this.communitySettings.communityName === 'Companies' || 
        this.communitySettings.communityName === 'Marketing_Solutions' || 
        this.communitySettings.communityName === 'Recruiting_Solutions';
    }

    get businessesLinkClass() {
        let linkClass = '';
        if (this.communitySettings.communityName === 'Companies' || 
            this.communitySettings.communityName === 'Marketing_Solutions' || 
            this.communitySettings.communityName === 'Recruiting_Solutions'
            ){
                linkClass = 'selected';
            }

        return linkClass;
    }

    get businessesLinkUrl() {
        return this.buildCommunityUrl(this.communitySettings.forBusinessesLinkUrl);
    }

    get marketingSolutionsLinkUrl() {
        return this.buildCommunityUrl(this.communitySettings.forMarketingSolutionsLinkUrl);
    }

    get recruitingSolutionsLinkUrl() {
        return this.buildCommunityUrl(this.communitySettings.forRecruitingSolutionsLinkUrl);
    }


    connectedCallback() {
        this.callGetCommunitySettings(); 
        
    }

    callGetCommunitySettings(){
        getCommunitySettings()
        .then(result => {
            this.communitySettings = result;
 
        })
        .catch(error => {
            console.error(reduceErrors(error));
        });
        
    }

    buildCommunityUrl(url) {
        return buildCommunityUrlHelper(url,this.externalMemberId,this.memberUUID,this.memberType);
    }

}