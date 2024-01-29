const getLocale = () => {
        // if URLParams has locale, & it differs from LS, store it in LS
        // If not & LS is null, store default: en-US to LS
        // Return LS
        const params = new URLSearchParams(window.location.search);
//        console.log('params.get(locale): ' + params.get('locale'));
        if (params.has('locale')) {
            if (params.get('locale') !== window.localStorage.getItem('locale')){
                // Sterlng locale is in this format: de-at.  
                // Our Locale format is driven by our Sterling Country Settings CMD.
                // It's always 5 characters and formatted in this format: en_US
                // The following logic Sterling Locale to Locale format 
                // by separating with underscore & making country upper case

                let sterlingLocaleParam = params.get('locale');
                let sterlingLocale;                
                if (sterlingLocaleParam !== undefined && sterlingLocaleParam.length === 5){
                    sterlingLocale = sterlingLocaleParam.substring(0,2) + '_' + sterlingLocaleParam.substring(3,5).toUpperCase()
                }
                window.localStorage.setItem('locale',sterlingLocale);
            }
        } else if (window.localStorage.getItem('locale') === null){
            window.localStorage.setItem('locale','en_US');
        }
//        console.log('window.localStorage.getItem(locale): ' + window.localStorage.getItem('locale'));
        return window.localStorage.getItem('locale');
};

export { getLocale };

const getLangURLParam = () => {
    // This method returns the URL Param
    // If none is selected, it returns English US (which is the default)
    const params = new URLSearchParams(window.location.search);
    let langURLParam;
//        console.log('params.get(locale): ' + params.get('locale'));
    if (params.has('language')) {
        langURLParam = params.get('language');
    } else {
        langURLParam = 'en_US';
    }
    return langURLParam;
};

export { getLangURLParam };

const localizeDomain = (linkUrl,locale) => {
    // This method converts the care.com domain to betreut
    const careDotComDomain = 'www.care.com';
    const beterutDeDomain = 'www.betreut.de';
    const beterutAtDomain = 'www.betreut.at';
    if (locale === 'de_DE'){
        linkUrl = linkUrl.replace(careDotComDomain,beterutDeDomain);
    } else if (locale === 'de_AT'){
        linkUrl = linkUrl.replace(careDotComDomain,beterutAtDomain);
    }
    return linkUrl;
};

export { localizeDomain };

const getLocaleToLangMap = () => {

    return new Map([// Map from Locale to Salesforce Lang
        ['en_US', 'en_US'], 
        ['da_DK', 'da'], 
        ['de_DE', 'de'], 
        ['de_AT', 'de_AT'], 
        ['de_CH', 'de_CH'], 
        ['en_AU', 'en_AU'], 
        ['en_CA', 'en_CA'], 
        ['en_GB', 'en_GB'], 
        ['en_IE', 'en_IE'], 
        ['en_NZ', 'en_NZ'], 
        ['es_ES', 'es'], 
        ['fi_FI', 'fi'], 
        ['fr_FR', 'fr'], 
        ['fr_BE', 'fr_BE'], 
        ['fr_CA', 'fr_CA'], 
        ['nl_NL', 'nl_NL'], 
        ['nl_BE', 'nl_BE'], 
        ['no_NO', 'no'], 
        ['sv_SE', 'sv']
    ]);    
};
export { getLocaleToLangMap };

const getLangComboToSupportedLangMap = () => {

    return new Map([ // Map from Lang Combo Box to the Languages we actually support
    ['en_US', 'en_US'], 
    ['da', 'en_GB'], 
    ['de', 'de'], 
    ['de_AT', 'de'], 
    ['de_CH', 'de'], 
    ['en_AU', 'en_GB'], 
    ['en_CA', 'en_GB'], 
    ['en_GB', 'en_GB'], 
    ['en_IE', 'en_GB'], 
    ['en_NZ', 'en_GB'], 
    ['es', 'es'], 
    ['fi', 'en_GB'], 
    ['fr', 'fr'], 
    ['fr_BE', 'fr'], 
    ['fr_CA', 'fr'], 
    ['nl_NL', 'en_GB'], 
    ['nl_BE', 'en_GB'], 
    ['no', 'en_GB'], 
    ['sv', 'en_GB']
    ]);
};
export { getLangComboToSupportedLangMap };

const includeLangInURL = () => {
    // this logic determines whether we want to icnlude the lang in our URL
    // the current logic determines this by looking to see whether the current URL has a lang param
    const currentUrl = new URL(window.location.href);
    if (currentUrl.searchParams.has('language')) return true;
    return false;
}
export { includeLangInURL };