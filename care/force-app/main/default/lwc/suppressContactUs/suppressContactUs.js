import { LightningElement, api } from 'lwc';
import { getExternalMemberId,getMemberUUID,getMemberType,getMemberTypeIB,isVisitor,isUS,shouldUseEntitlementService } from 'c/memberDetailsService';
import getHelpCenterEntitlement from '@salesforce/apex/helpCenterEntitlement.getHelpCenterEntitlement';

export default class SuppressContactUs extends LightningElement {
    @api memberAccountType;
    memberType;
    externalMemberId;  
    memberUUID; 
    @api helpCenterEntitlement = {};
    @api isIbBasic = false;

    @api
    get externalMemberId(){
        return getExternalMemberId();
    }

    @api
    get memberUUID(){
        return getMemberUUID();
    }

    @api
    get memberType(){
        return getMemberTypeIB(this.isIbBasic);
    }

    connectedCallback(){
        this.handleEntitlement();
    }

    handleSuppression(){
        //console.log('call handleSuppression');
        // Currently, we only suppress US members
        if (isUS()){
            // Handle the Visitor use case
            // Hides chat if members is a visitor & visitors have been suppressed
            if (isVisitor(this.externalMemberId,this.memberUUID,this.memberType)){
                if (this.memberAccountType.toLowerCase().includes('visitor')){
                    this.hideChat();
                }

            } else {
                // Handles non-visitor use case
                // Hides chat if members type matches types that have been flagged for suppression in the component properties
                let memberAccountTypes = this.memberAccountType.split(',');
                for (let matItem in memberAccountTypes){
                    //console.log('memberAccountTypes[matItem].toLowerCase(): ' + memberAccountTypes[matItem].toLowerCase());
                    //console.log('this.memberType.toLowerCase(): ' + this.memberType.toLowerCase());
                    if (memberAccountTypes[matItem].toLowerCase() === this.memberType.toLowerCase()){
                        this.hideChat();
                        break;
                    }
                }
            }
        }
    }
 
    handleEntitlement(){
        // Hard coding to seekers because this component is only supported by Seekers
        // Longer term, we could derive the value from Community CMD
        if (shouldUseEntitlementService(this.externalMemberId,this.memberUUID,'Seeker')){ 
            getHelpCenterEntitlement({externalMemberId: this.externalMemberId, memberUUID: this.memberUUID, locale: window.localStorage.getItem('locale'), chatEntitlementFlow : undefined}) // The flow parameter is only required when the widget is shown on the US website
            .then(result => {
                this.helpCenterEntitlement = result;
                //console.log('this.helpCenterEntitlement.canChatWithCSR: ' + this.helpCenterEntitlement.canChatWithCSR);
                //console.log('this.memberType.toUpperCase(): ' + this.memberType.toLowerCase());
                if (this.helpCenterEntitlement.canChatWithCSR === true && this.memberType.toLowerCase() === 'basic'){
                    this.isIbBasic = true;
                    // console.log('this.isIbBasic: ' + this.isIbBasic);
                }
                this.handleSuppression();

                
                // handleEntitlement Errors can be handled by just outputting them to console.
                if (this.helpCenterEntitlement.errors) console.error('Handle Entitlement Error: ' + this.helpCenterEntitlement.errors);
            })
            .catch(error => {
                this.handleSuppression();
                console.error(reduceErrors(error));
            });            
        } else {
            this.handleSuppression();
        }
    }

    disconnectedCallback() {
        // ensures chat is restored when we leave the current page (unless it's supresssed again by another component in the next page)
        this.showChat();
    }

    showChat(){
        if (document.body.classList.contains('hide-chat')) {
            document.body.classList.remove('hide-chat');
        }

    }

    hideChat(){
        if (!document.body.classList.contains('hide-chat')) {
            document.body.classList.add('hide-chat');
        }
    }

}