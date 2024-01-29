import { LightningElement } from 'lwc';

export default class FooterDisclaimer extends LightningElement {

    get currentYear(){
        const now = new Date();
        return now.getUTCFullYear();

    }

    get isEnUs(){
        return (window.localStorage.getItem('locale') === 'en_US');
    }

    get isDaDk(){
        return (window.localStorage.getItem('locale') === 'da_DK');
    }

    get isDeAt(){
        return (window.localStorage.getItem('locale') === 'de_AT');
    }

    get isDeCh(){
        return (window.localStorage.getItem('locale') === 'de_CH');
    }

    get isDeDe(){
        return (window.localStorage.getItem('locale') === 'de_DE');
    }

    get isEnAu(){
        return (window.localStorage.getItem('locale') === 'en_AU');
    }

    get isEnCa(){
        return (window.localStorage.getItem('locale') === 'en_CA');
    }

    get isEnGb(){
        return (window.localStorage.getItem('locale') === 'en_GB');
    }

    get isEnIe(){
        return (window.localStorage.getItem('locale') === 'en_IE');
    }

    get isEnNz(){
        return (window.localStorage.getItem('locale') === 'en_NZ');
    }

    get isEsEs(){
        return (window.localStorage.getItem('locale') === 'es_ES');
    }

    get isFiFi(){
        return (window.localStorage.getItem('locale') === 'fi_FI');
    }

    get isFrBe(){
        return (window.localStorage.getItem('locale') === 'fr_BE');
    }

    get isFrCa(){
        return (window.localStorage.getItem('locale') === 'fr_CA');
    }

    get isFrFr(){
        return (window.localStorage.getItem('locale') === 'fr_FR');
    }

    get isNlNl(){
        return (window.localStorage.getItem('locale') === 'nl_NL');
    }

    get isNlBe(){
        return (window.localStorage.getItem('locale') === 'nl_BE');
    }

    get isNoNo(){
        return (window.localStorage.getItem('locale') === 'no_NO');
    }

    get isSvSv(){
        return (window.localStorage.getItem('locale') === 'sv_SE');
    }

}