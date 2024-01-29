import { LightningElement, api } from 'lwc';
import { getLocale, localizeDomain } from 'c/localeService';

export default class CdccQuickLinks extends LightningElement {
    @api heading;
    @api link1Url;
    @api link1Title;
    @api link2Url;
    @api link2Title;
    @api link3Url;
    @api link3Title;
    @api link4Url;
    @api link4Title;
    @api link5Url;
    @api link5Title;
    @api link6Url;
    @api link6Title;
    hasRendered = false;
    locale;

    @api
    get locale() {
        return getLocale();
    }
    
    get showLink1() {
        return this.link1Url && this.link1Title;
    }

    get showLink2() {
        return this.link2Url && this.link2Title;
    }

    get showLink3() {
        return this.link3Url && this.link3Title;
    }

    get showLink4() {
        return this.link4Url && this.link4Title;
    }

    get showLink5() {
        return this.link5Url && this.link5Title;
    }

    get showLink6() {
        return this.link6Url && this.link6Title;
    }

    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            // This logic runs only the first time renderedCallback is called

            this.localizeLinks();
        }

        // This logic runs regardless of whether renderedCallback has been called before

    }

    localizeLinks(){
        this.link1Url = this.localizeLink(this.link1Url);
        this.link2Url = this.localizeLink(this.link2Url);
        this.link3Url = this.localizeLink(this.link3Url);
        this.link4Url = this.localizeLink(this.link4Url);
        this.link5Url = this.localizeLink(this.link5Url);
        this.link6Url = this.localizeLink(this.link6Url);
    }

    localizeLink(linkUrl){
        if (linkUrl !== undefined){
            // Replace LOCALE if it exists
            if (linkUrl.search('LOCALE') != -1){
                linkUrl = linkUrl.replace('LOCALE',this.convertLocaleToSterlingLocale(this.locale));
            }
            // Replace domains for DE & AT
            linkUrl = localizeDomain(linkUrl,this.locale);
        } 
        return linkUrl;
    }

    convertLocaleToSterlingLocale(locale){
        // Sterlng locale is in this format: de-at.  
        // Our Locale format is driven by our Sterling Country Settings CMD.
        // It's always 5 characters and formatted in this format: en_US
        // This method converts Our Locale to Sterling Locale format 
        // by separating with a dash & making country lower case
        if (locale === undefined) return undefined;
        if (locale.length !== 5) return undefined;
        return locale.substring(0,2) + '-' + locale.substring(3,5).toLowerCase();
    }
}