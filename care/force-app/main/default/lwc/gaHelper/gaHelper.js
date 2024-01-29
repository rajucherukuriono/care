import { LightningElement,wire } from 'lwc';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import CDCC_CHAT_CHANNEL from '@salesforce/messageChannel/CDCC_Chat__c';

export default class GaHelper extends LightningElement {
    // 2022-05-06: Jack Odell, Salesforce Consultant
    // This component supports the Google Analytics code in our community (static resource ga.js)
    // It does several things:
    // First: it tracks page views & sends them to our GA logic via Custom Events (gaPageView)
    // Second: it receives GA Events from the prechat component (cdccPreChat) & sends them to our 
    //      GA logic via Custom Events (gaCustomEvent)
    // I originally placed this component in our template, but that didn't fire enough 
    // page views, so I moved it into the body of each page that needs to be tracked.
    
    hasRendered = false;
    subscription = null;

    @wire(MessageContext)
    messageContext;

   subscribeToMessageChannel() {
    if (!this.subscription) {
        this.subscription = subscribe(
            this.messageContext,
            CDCC_CHAT_CHANNEL,
            (message) => this.handleMessage(message),
            { scope: APPLICATION_SCOPE }
        );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(message){
        const gaCustomEvent = new CustomEvent("gaCustomEvent", {
            bubbles: true,
            composed: true,
            detail: message
          });
          this.dispatchEvent(gaCustomEvent);

    }

    trackPageView(){
        const gaPageView = new CustomEvent("gaPageView", {
            bubbles: true,
            composed: true
          });
          this.dispatchEvent(gaPageView);
    }

    connectedCallback() {
        //console.log('gaHelper ConnecteCallback');
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            // This logic runs only the first time renderedCallback is called
            this.trackPageView();
        }
    }

}