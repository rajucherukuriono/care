import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import CDCC_ASSETS from '@salesforce/resourceUrl/CDCC_Assets';
import BETREUT_DE_LOGO from '@salesforce/resourceUrl/betreutDELogo';
import BETREUT_AT_LOGO from '@salesforce/resourceUrl/BetreutATLogo';
import CARE_LOGO from '@salesforce/resourceUrl/CareLogo';
import reduceErrors from 'c/cdccErrorUtil';
import hc_help_center from '@salesforce/label/c.HC_Help_Center';
import hc_log_in from '@salesforce/label/c.HC_Log_In';
import hc_join_now from '@salesforce/label/c.HC_Join_Now';
import hc_upgrade from '@salesforce/label/c.HC_Upgrade';
import getCommunitySettings from '@salesforce/apex/CDCCHeaderController.getCommunitySettings';
import getSettingByLocale from '@salesforce/apex/CountryLocaleMapHelper.getSettingByLocale';
import { getLocale } from 'c/localeService';
import { getMemberType } from 'c/memberDetailsService';
import { buildLoginUrl } from 'c/linkHelperService';

export default class CdccHeader extends NavigationMixin(LightningElement) {
    @api isMobile;
    memberType;
    @api communitySettings = {};
    locale;
    @api localeSettings = {};
    @track homeUrl;
    @track homePageRef;
    @track mobileNavOpen = false;
    mql;
    @api showJoinNowLink = false;
    @api showUpgradeLink = false;
    @api showLoginLink = false;
    hasRendered = false;
    @api logoLink;
    logoLinkRoot;
    betreutDeLogoURL = `${BETREUT_DE_LOGO}#betreutDeLogo`;
    betreutAtLogoURL = `${BETREUT_AT_LOGO}#betreutAtLogo`;
    careDotComLogoURL = `${CARE_LOGO}#careLogo`;

    label = {
        hc_help_center, hc_log_in, hc_join_now, hc_upgrade
    };

    @wire(getCommunitySettings)
    wireCommunitySettings({data, error}) {
        if (data) {
            this.communitySettings = data;
            this.showJoinNowLink = this.showJoinNowLinkHelper();
            this.showUpgradeLink = this.showUpgradeLinkHelper();
            this.showLoginLink = this.showLoginLinkHelper();
        } else if (error) {
            console.error(reduceErrors(error));
        }
    }

    @wire(getSettingByLocale,{ locale: '$locale'})
    wireSettingsByLocale({data, error}) {
        if (data) {
            this.localeSettings = data;
            this.logoLinkRoot = data.Production_URL_Root__c;
            this.showJoinNowLink = this.showJoinNowLinkHelper();
            this.showUpgradeLink = this.showUpgradeLinkHelper();
            this.showLoginLink = this.showLoginLinkHelper();
        } else if (error) {
            console.error(reduceErrors(error));
        }
    }

    get showApplyToJobsLink(){
        // Only show link if it's defined in locale settings
        if (this.localeSettings !== undefined && this.localeSettings.Apply_to_Jobs__c !== undefined) return true;
        return false; 

    }
    
    @api
    get memberType(){
        return getMemberType();
    }

    @api
    get locale() {
        return getLocale();
    }

    get loginUrl(){
        console.log('get loginUrl');
        return buildLoginUrl(this.localeSettings.Login__c);
    }

    @api
    get logoLinkRoot(){
        return this.logoLink;
    }

    set logoLinkRoot(value){        
        this.logoLink = 'https://' + value + '/';
    }

    get svgLogoUrl(){
        if (this.locale === 'de_DE'){
            return this.betreutDeLogoURL;
        } else if (this.locale === 'de_AT'){
            return this.betreutAtLogoURL;
        }
        return this.careDotComLogoURL;
    }

    get logoUrl() {
        let url = CDCC_ASSETS;
        if (this.isMobile) {
            url += '/imgs/logo_mobile.png';
        } else {
            url += '/imgs/logo_desktop.png';
        }
        return url;
    }

    get isVisitor() {
        return this.isVisitorHelper();
    }


    get isBasicMember() {
        return this.isBasicMemberHelper();
    }

    get isPremiumMember() {
        return this.isPremiumMemberHelper();
    }

    get navMenuIconName() {
        return this.mobileNavOpen ? 'utility:close' : 'utility:rows';
    }

    constructor() {
        super();
        const mqls = [window.matchMedia('(max-device-width : 1023px)'), window.matchMedia('(max-width : 1023px)')];
        this.isMobile = mqls[0].matches || mqls[1].matches;
        mqls.forEach((mql) => {
            mql.addEventListener('change', () => {
                this.isMobile = mql.matches;
            });
        });
    }

    handleCareLogoClick() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

    handleHelpCenterClick(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate](this.homePageRef);
    }

    handleJoinNowClick(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        // Using NavigationMixin.Navigate for standard__webPage was opening new window
        this[NavigationMixin.GenerateUrl]({
            type: "standard__webPage",
            attributes: {
                url: this.localeSettings.Join_Now__c
            }
        }).then(url => {
            location.href = url;
        });
    }

    handleUpgradeClick(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "standard__webPage",
            attributes: {
                url: this.localeSettings.Upgrade__c
            }
        }).then(url => {
            location.href = url;
        });
    }

    handleNavMenuIconClick() {
        this.mobileNavOpen = !this.mobileNavOpen;
        if (this.mobileNavOpen) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = 'scroll';
        }
    }
    
    isVisitorHelper() {
        return this.memberType !== 'BASIC' && this.memberType !== 'PREMIUM';
    }

    isBasicMemberHelper() {
        return this.memberType === 'BASIC';
    }

    isPremiumMemberHelper() {
        return this.memberType === 'PREMIUM';
    }

    isCompaniesMemberHelper() {
        if (this.communitySettings.communityName === 'Companies' || 
            this.communitySettings.communityName === 'Marketing_Solutions' || 
            this.communitySettings.communityName === 'Recruiting_Solutions'
            ){
                return true;
            }
        else return false;
    }


    showJoinNowLinkHelper(){
        // We show Join Now Link if visitor & if link is defined in CMD
        // Companies store link in CommunitySettings & others in LocaleSettgngs
        let show = false;
        if (this.isVisitorHelper()){
            if (!this.hasRendered){ // We default showing button to true (until CMD loads)
                show = true;
            } else if (this.isCompaniesMemberHelper()){
                if (this.communitySettings.joinNowLinkUrl !== undefined){
                    show = true;
                }
            } else if (this.localeSettings !== undefined && this.localeSettings.Join_Now__c !== undefined){
                show = true;
            }
        }
//        console.log('showJoinNowLinkHelper: ' + show);
        return show;
    }

    showLoginLinkHelper(){
        // We show Login Link if visitor & if link is defined in CMD
        // Companies store link in CommunitySettings & others in LocaleSettgngs
        let show = false;
        if (this.isVisitorHelper()){
            if (!this.hasRendered){ // We default showing button to true (until CMD loads)
                show = true;
            } else if (this.isCompaniesMemberHelper()){
                if (this.communitySettings.logInLinkUrl !== undefined){
                    show = true;
                }
            } else if (this.localeSettings !== undefined && this.localeSettings.Login__c !== undefined){
                show = true;
            }
        }
//        console.log('showLoginLinkHelper: ' + show);
        return show;
    }

    showUpgradeLinkHelper(){
        // We show Upgrade Link if Basic & if link is defined in CMD
        let show = false;
        if (this.isBasicMemberHelper()){
            if (!this.hasRendered){ // We default showing button to true (until CMD loads)
                show = true;
            } else if (this.isCompaniesMemberHelper()){
                if (this.communitySettings.upgradeLinkUrl !== undefined){
                    show = true;
                }
            } else if (this.localeSettings !== undefined && this.localeSettings.Upgrade__c !== undefined){
                show = true;
            }
        }
//        console.log('showUpgradeLinkHelper: ' + show);
        return show;
    }

    connectedCallback() {
        // These values rely on memberType, so they should be defined after membetType is set
        this.showJoinNowLink = this.showJoinNowLinkHelper();
        this.showUpgradeLink = this.showUpgradeLinkHelper();
        this.showLoginLink = this.showLoginLinkHelper();


        this.homePageRef = {
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        };
        this[NavigationMixin.GenerateUrl](this.homePageRef)
            .then(url => this.homeUrl = url);
    }

    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            // This logic runs only the first time renderedCallback is called
            
        }


        // This logic runs regardless of whether renderedCallback has been called before
        

    }
}

        /*
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        }).then(url => {
            this.homeUrl = url
        });
        */