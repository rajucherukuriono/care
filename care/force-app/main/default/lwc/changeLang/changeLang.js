import { LightningElement,api } from 'lwc';
import LANG from '@salesforce/i18n/lang';
import { getLocale, getLocaleToLangMap, getLangComboToSupportedLangMap } from 'c/localeService';
import { resetMemberInfoOnCountryChangeHelper } from 'c/memberDetailsService';

export default class ChangeLang extends LightningElement {
    hasRendered = false;
    locale;
    langComboValue;

    langComboOptions = [ // The Lang Combo Box; indexed by Salesfore Language
        { value: 'en_AU', label: 'Australia'},
        { value: 'fr_BE', label: 'Belgique (Français)'},
        { value: 'nl_BE', label: 'België (Nederlands)'},
        { value: 'en_CA', label: 'Canada (English)'},
        { value: 'fr_CA', label: 'Canada (Français)'},
        { value: 'da', label: 'Danmark'},
        { value: 'de', label: 'Deutschland'},
        { value: 'es', label: 'España'},
        { value: 'fr', label: 'France'},
        { value: 'en_IE', label: 'Ireland'},
        { value: 'nl_NL', label: 'Nederland'},
        { value: 'en_NZ', label: 'New Zealand'},
        { value: 'no', label: 'Norge'},
        { value: 'de_CH', label: 'Schweiz'},
        { value: 'fi', label: 'Suomi'},
        { value: 'sv', label: 'Sverige'},
        { value: 'en_GB', label: 'United Kingdom'},
        { value: 'en_US', label: 'United States'},
        { value: 'de_AT', label: 'Österreich'}
    ];

    @api langComboToSupportedLangMap;

    @api localeToLangMap;    

    @api
    get locale() {
        return getLocale();
    }

    get localeToLangMap(){
        return getLocaleToLangMap();
    }

    get langComboToSupportedLangMap(){
        return getLangComboToSupportedLangMap();
    }

    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            // This logic runs only the first time renderedCallback is called

            // Set default LangComboValue based on the locale
            // The localeToLangMap maps the relationship between Locale & Lang
            this.langComboValue = this.localeToLangMap.get(this.locale);

            this.handleLocaleLangMismatch();

        }

        // This logic runs regardless of whether renderedCallback has been called before
    }

    handleLocaleLangMismatch(){
        // We need to determine whether locale URL param has triggered a lang change
        // We will use the Lang derived from the locale (langComboValue) to look in 
        // langComboToSupportedLangMap to get which lang is assocated with the locale
        // Then we will compare that Lang with the Lang in URL params
        // If they are different, we will invoke handleLocaleChange 

        const currentUrl = new URL(window.location.href);
        // the check is only required if lang is a param (otherwise we can get infinite loops)
        // the check should also be prevented in the Site Builder (which has builner in its hostname)
        if (currentUrl.searchParams.has('language') && currentUrl.hostname.search('builder') === -1){ 
            if (this.langComboToSupportedLangMap.get(this.langComboValue) !== currentUrl.searchParams.get('language')){
                // If we have URL Lang Param & locale mismatch and we have a locale URL param, 
                // then that means someone is try to change the lang via the locale param
                if (currentUrl.searchParams.get('locale') !== null){
                    this.handleLocaleChange(this.langComboValue);
                } else {
                // Otherwise, it means someone is trying to change the lang via URL Lang Param
                    this.handleLocaleChange(currentUrl.searchParams.get('language'));
                }                    
            }
        }
    }

    handleLangComboChange(event){
        // Sets the value of the selected value
        this.langComboValue = event.detail.value;
        this.handleLocaleChange(this.langComboValue);
    }

    handleLocaleChange(langComboValue){
        // In our combo box we show all 19 languages, but behind the scenes, we only really
        // suport five languages.
        // We handle this discrepancy by storing the true locale in Local Storge
        // And then mapping our 19 languages to the ones we really support (langComboToSupportedLangMap)
        const currentLangComboLocale = this.convertLangComboToLocale(langComboValue);
        if (currentLangComboLocale !== undefined){
            const currentUrl = new URL(window.location.href);
            this.resetMemberInfoOnCountryChange(currentUrl,currentLangComboLocale);

            // Navigate to URLParamLang value (as determined by our langComboToSupportedLangMap)
            // & remove locale from URL
            const targetURLParamLangValue = this.langComboToSupportedLangMap.get(langComboValue);
            currentUrl.searchParams.set('language', targetURLParamLangValue);
            currentUrl.searchParams.delete('locale');

            // Set New Locale to Local Storage
            window.localStorage.setItem('locale',currentLangComboLocale);

            window.location.href = currentUrl;                 
        }
    }

    resetMemberInfoOnCountryChange(currentUrl,currentLangComboLocale){
        resetMemberInfoOnCountryChangeHelper(this.locale,currentUrl,currentLangComboLocale);
    }

    convertLangComboToLocale(langComboValue){
        // The localeTolangArray maps locales to langs
        // We will use it in reverse here, to map the lang to the locale 
        
        for (let [mLocale, mLang] of  this.localeToLangMap.entries()) {
            if (mLang === langComboValue){
                return mLocale;

            }
        }
        return undefined;

    }


}