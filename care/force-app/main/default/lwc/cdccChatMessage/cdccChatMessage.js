import BaseChatMessage from 'lightningsnapin/baseChatMessage';
import { track } from 'lwc';

const CHAT_CONTENT_CLASS = 'chat-content';
const AGENT_USER_TYPE = 'agent';
const CHASITOR_USER_TYPE = 'chasitor';
const SUPPORTED_USER_TYPES = [AGENT_USER_TYPE, CHASITOR_USER_TYPE];

export default class ChatMessageDefaultUI extends BaseChatMessage {
    @track messageStyle = '';
    memberId;
    memberType;

    isSupportedUserType(userType) {
        return SUPPORTED_USER_TYPES.some((supportedUserType) => supportedUserType === userType);
    }

    connectedCallback() {
        const params = new URLSearchParams(window.location.search);
        if (params.has('memberId')) {
            this.memberId = params.get('memberId');
            if (this.memberId) {
                window.localStorage.setItem('memberId', this.memberId);
            }
        } else {
            const memberId = window.localStorage.getItem('memberId');
            if (memberId) {
                this.memberId = memberId;
            }
        }
        if (params.has('memberType')) {
            this.memberType = params.get('memberType');
            if (this.memberType) {
                window.localStorage.setItem('memberType', this.memberType);
            }
        } else {
            const memberType = window.localStorage.getItem('memberType');
            if (memberType) {
                this.memberType = memberType;
            }
        }
        console.log('member id = ' + this.memberId);
        console.log('member type = ' + this.memberType);

        if (this.isSupportedUserType(this.userType)) {
            this.messageStyle = `${CHAT_CONTENT_CLASS} ${this.userType}`;
        } else {
            throw new Error(`Unsupported user type passed in: ${this.userType}`);
        }


    }
}