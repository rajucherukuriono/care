import BaseChatHeader from 'lightningsnapin/baseChatHeader';
import { api, wire, track } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import CDCC_CHAT_CHANNEL from '@salesforce/messageChannel/CDCC_Chat__c';
import CDCC_ASSETS from '@salesforce/resourceUrl/CDCC_Assets';
import BETREUT_DE_LOGO from '@salesforce/resourceUrl/betreutDELogo';
import BETREUT_AT_LOGO from '@salesforce/resourceUrl/BetreutATLogo';
import CARE_LOGO from '@salesforce/resourceUrl/CareLogo';
import { getLocale } from 'c/localeService';


export default class CdccChatHeader extends BaseChatHeader {
    @track logo = 'logo_chat_grey.png';
    @track theme = 'white-theme';
    text;
    betreutDeLogoURL = `${BETREUT_DE_LOGO}#betreutDeLogo`;
    betreutAtLogoURL = `${BETREUT_AT_LOGO}#betreutAtLogo`;
    careDotComLogoURL = `${CARE_LOGO}#careLogo`;
    locale;

    @wire(MessageContext)
    messageContext;

    get containerClass() {
        return `container ${this.theme}`;
    }

    get iconClass() {
        switch (this.theme) {
            case 'white-theme':
                return 'black-icon';
            case 'blue-theme':
            case 'red-theme':
                return 'white-icon';
            default:
                return 'black-icon';
        }
    }

    get logoUrl() {
        return CDCC_ASSETS + '/imgs/' + this.logo;
    }

    @api
    get locale() {
        return getLocale();
    }

    get svgLogoUrl(){
        if (this.locale === 'de_DE'){
            return this.betreutDeLogoURL;
        } else if (this.locale === 'de_AT'){
            return this.betreutAtLogoURL;
        }
        return this.careDotComLogoURL;
    }

    connectedCallback() {
        this.assignHandler('prechatState', (data) => {
            //console.log('prechatState');
            this.setText(data.label);
            this.logo = 'logo_chat_grey.png';
            this.theme = 'white-theme';
        });
        this.assignHandler('offlineSupportState', (data) => {
            //console.log('offlineSupportState');
            this.setText(data.label);
            this.logo = 'logo_chat_grey.png';
            this.theme = 'white-theme';
        });
        this.assignHandler('waitingState', (data) => {
            //console.log('waitingState');
            this.setText(data.label);
            this.logo = 'logo_chat_grey.png';
            this.theme = 'white-theme';
        });
        this.assignHandler('waitingEndedState', (data) => {
            //console.log('waitingEndedState');
            this.setText(data.label);
            this.logo = 'logo_chat_grey.png';
            this.theme = 'white-theme';
        });
        this.assignHandler('chatState', (data) => {
            //console.log('chatState');
            this.setText(data.label);
            this.logo = 'logo_chat_grey.png';
            this.theme = 'white-theme';
        });
        this.assignHandler('chatTimeoutUpdate', (data) => {
            //console.log('chatTimeoutUpdate');
            this.setText('You will time out soon.');
            this.logo = 'logo_chat_white.png';
            this.theme = 'red-theme';
        });
        this.assignHandler('chatTimeoutClear', (data) => {
            //console.log('chatTimeoutClear');
            this.setText(data.label);
            this.logo = 'logo_chat_grey.png';
            this.theme = 'white-theme';
        });
        this.assignHandler('chatEndedState', (data) => {
            //console.log('chatEndedState');
            this.setText(data.label);
            this.logo = 'logo_chat_grey.png';
            this.theme = 'white-theme';
        });
        this.assignHandler('reconnectingState', (data) => {
            //console.log('reconnectingState');
            this.setText(data.label);
            this.logo = 'logo_chat_white.png';
            this.theme = 'red-theme';
        });
        this.assignHandler('postchatState', (data) => {
            //console.log('postchatState');
            this.setText(data.label);
            this.logo = 'logo_chat_grey.png';
            this.theme = 'white-theme';
        });
        this.assignHandler('chatConferenceState', (data) => {
            //console.log('chatConferenceState');
            this.setText(data.label);
            this.logo = 'logo_chat_grey.png';
            this.theme = 'white-theme';
        });
        subscribe(
            this.messageContext,
            CDCC_CHAT_CHANNEL,
            (payload) => {
                if (payload.message === 'close') {
                    this.close();
                }
            }
        );
    }

    setText(str) {
        if (typeof str !== 'string') {
            throw new Error('Expected text value to be a `String` but received: ' + str + '.');
        }
        this.text = str;
    }
}