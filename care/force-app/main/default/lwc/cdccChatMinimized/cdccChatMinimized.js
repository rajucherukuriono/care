import { LightningElement, track } from 'lwc';
import { assignHandler, maximize } from 'lightningsnapin/minimized';
import CDCC_ASSETS from '@salesforce/resourceUrl/CDCC_Assets';

export default class CdccChatMinimized extends LightningElement {
    @track message;
    logoUrl = `${CDCC_ASSETS}/imgs/logo_chat_white.png`;

    constructor() {
        super();
        assignHandler("prechatState", this.setMinimizedMessage.bind(this));
        assignHandler("offlineSupportState", this.setMinimizedMessage.bind(this));
        assignHandler("waitingState", this.setMinimizedMessage.bind(this));
        assignHandler("queueUpdate", this.setMinimizedQueuePosition.bind(this));
        assignHandler("waitingEndedState", this.setMinimizedMessage.bind(this));
        assignHandler("chatState", this.setMinimizedChatState.bind(this));
        assignHandler("chatTimeoutUpdate", this.setMinimizedMessage.bind(this));
        assignHandler("chatUnreadMessage", this.setMinimizedMessage.bind(this));
        assignHandler("chatTransferringState", this.setMinimizedMessage.bind(this));
        assignHandler("chatEndedState", this.setMinimizedMessage.bind(this));
        assignHandler("reconnectingState", this.setMinimizedMessage.bind(this));
        assignHandler("postchatState", this.setMinimizedMessage.bind(this));
    }

    handleClick() {
        maximize();
    }

    setMinimizedMessage(eventData) {
        this.message = eventData.label;
    }

    setMinimizedQueuePosition(eventData) {
        this.message = eventData.label;
        // For queue position = 0, the label will be "You're next!"
        if (eventData.queuePosition) {
            this.message += " " + eventData.queuePosition;
        }
    }

    setMinimizedChatState(eventData) {
        this.message = eventData.agentName;
    }
}