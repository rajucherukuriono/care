import { LightningElement, api, wire} from 'lwc';
import CDCC_ASSETS from '@salesforce/resourceUrl/CDCC_Assets';
import getCommunitySettings from '@salesforce/apex/CDCCHeaderController.getCommunitySettings';
import { isUS } from 'c/memberDetailsService';

export default class CdccFooter extends LightningElement {
    hasRendered = false;
    showFBLike = false;
    iframeSrc = 'https://www.facebook.com/plugins/like.php?href=' + 'https://' + location.host + location.pathname.substring(0,location.pathname.indexOf('/s/'))  + '&width=450&layout=button_count&action=like&size=small&share=false&height=35&appId=296867961907';    

    facebookIconUrl = `${CDCC_ASSETS}/imgs/Facebook-Filled.svg#Facebook-Filled`;
    twitterIconUrl = `${CDCC_ASSETS}/imgs/Twitter-Filled.svg#Twitter-Filled`;
    youtubeIconUrl = `${CDCC_ASSETS}/imgs/YouTube-Filled.svg#YouTube-Filled`;
    instagramIconUrl = `${CDCC_ASSETS}/imgs/Instagram-Filled.svg#Instagram-Filled`;
    instagramIconUrlIntl = CDCC_ASSETS + '/imgs/Instagram-Filled.svg#Instagram-Filled';
    facebookIconUrlIntl = `${CDCC_ASSETS}/imgs/Facebook-Filled.svg#Facebook-Filled`;
    twitterIconUrlIntl = `${CDCC_ASSETS}/imgs/Twitter-Filled.svg#Twitter-Filled`;
    youtubeIconUrlIntl = `${CDCC_ASSETS}/imgs/YouTube-Filled.svg#YouTube-Filled`;

    currentYear = new Date().getFullYear();

    @api communitySettings = {};
    @wire(getCommunitySettings)
    wireCommunitySettings({data, error}) {
        if (data) {
            this.communitySettings = data;
        } else if (error) {
            console.error(reduceErrors(error));
        }
    }
    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            // This logic runs only the first time renderedCallback is called
            setTimeout(() => {this.showFBLikeAfterTimeout();}, 1000);

        }

        // This logic runs regardless of whether renderedCallback has been called before
    }

    showFBLikeAfterTimeout(){
        this.showFBLike = true;
    }


    get showChangeLang(){
        if (this.communitySettings.communityName === 'Families' || 
            this.communitySettings.communityName === 'Caregivers'
            ){
                return true;
            }

        return false;
    }

    get isUs(){
        return isUS();
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

    get isSvSe(){
        return (window.localStorage.getItem('locale') === 'sv_SE');
    }


}