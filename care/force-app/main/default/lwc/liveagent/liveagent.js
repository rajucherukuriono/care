import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import LA from '@salesforce/resourceUrl/LiveAgent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LAOnline from '@salesforce/resourceUrl/LAOnline';
import LAOffline from '@salesforce/resourceUrl/LAOffline';
import insertChatCase from '@salesforce/apex/LiveAgentController.insertChatCase';

export default class Liveagent extends LightningElement {
    @api topicButtonId;
    @api deploymentId;
    @api chatInitUrl;
    @api liveAgentSiteUrl;
    @api orgId;
    @track laLoadError;
    @api memberType;

    LAOnlineUrl = LAOnline;
    LAOfflineUrl = LAOffline;
    liveagentUrl = LA;

    hasRendered = false;
    @track disableChatButton = false;

    caseId;
    caseAccountId;
    caseContactId;

    liveAgentWindow;

    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            // Initialize variables
            if (this.deploymentId === undefined || this.deploymentId === '') this.deploymentId = '572390000008Q9d'; // fallback deploymentid if one wasn't provided in settings
            if (this.chatInitUrl === undefined || this.chatInitUrl === '') this.chatInitUrl = 'https://d.la4-c1-dfw.salesforceliveagent.com/chat'; // fallback chat init url if one wasn't provided in settings
            if (this.memberType === undefined || this.memberType === '') this.memberType = 'Seeker'; // fallback to Seeker if not defined

            // createCaseFromArticle.displayLiveAgent controls logic for whether to initialize
            // LiveAgent or not.  Any conditions that should prevent LA from being loaded should be set there
            this.loadLA();
        }
    }

    loadLA(){
        try {
            // Reinitializing the button when topic changes workaround
            delete window._laq;
            delete window.liveagent;
            delete window.liveAgentDeployment;

            // this mock-agent suppresses errors causedby pending avail-checks
            window.liveagent = {'_': {'handlePing': function() {}}};
        } catch (err) { /* do nothing */ }

        Promise.all([
            loadScript(this, this.liveagentUrl/* + '?unique=' + new Date().getTime()*/),
        ])
            .then(() => {
                this.initLA();
            })
            .catch(error => {
                this.laLoadError = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Chat',
                        message: '' + this.laLoadError,
                        variant: 'error',
                    }),
                );
            });
    }

    initLA(){
        const onImg = this.template.querySelector('div.onlineButtonWrapper');
        const offImg = this.template.querySelector('div.offlineButtonWrapper');
        const deploymentId = this.deploymentId;
        const topicButtonId = this.topicButtonId;
        const chatInitUrl = this.chatInitUrl;
        var orgId = this.orgId;
        orgId = orgId.substring(0,15);

        // if this.caseId & this.caseAccountId were set by handleChatClick, we call findOrCreate
        // with these values to associate the chat to the appropriate case & account records
        if (this.caseId !== undefined && this.caseAccountId !== undefined){
            window.liveagent.addCustomDetail('Account Id', this.caseAccountId);
            window.liveagent.addCustomDetail('Case Id', this.caseId);
            window.liveagent.addCustomDetail('Contact Id', this.caseContactId);

            window.liveagent.findOrCreate('Account')
                .map('Id', 'Account Id', true, true, false)
                .saveToTranscript('AccountId')
                .showOnCreate()
                .linkToEntity('Case','AccountId');

            window.liveagent.findOrCreate('Case')
                .map('Id', 'Case Id', true, true, false)
                .saveToTranscript('CaseId')
                .showOnCreate();

            window.liveagent.findOrCreate('Contact')
                .map('Id', 'Contact Id', true, true, false)
                .saveToTranscript('ContactId');
            
        }

        if (!window._laq) { window._laq = []; }
        window._laq.push(function(){
            window.liveagent.showWhenOnline(topicButtonId, onImg);
            window.liveagent.showWhenOffline(topicButtonId, offImg);
        });

        // Live Agent Endpoint, Deployment Id (fixed), Org Id
        window.liveagent.init(chatInitUrl, deploymentId, orgId);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {this.startChatAfterTimeout();}, 1000);
    }

    handleChatClick(event){
        event.preventDefault();

        this.disableChatButton = true;

        const pageUrl = this.getLiveAgentURL() + '/LiveAgentPreChat';
        this.liveAgentWindow = window.open(pageUrl,'livechat','width=500,height=510,menubar=no,toolbar=no,location=no,personalbar=no,scrollbars=yes,resizable=yes');

/*  This javascript is wide open to the world. Secure content must be handled by server side code.
        Call Apex class that will:
            Invoke InstantODS (create Account & Return AccountId)
            Create Chat Case (return case id)
        Then JavaScript should: 
            Use returned ids to find both records via findOrCreate
            In case of error, the user should be shown an error & encouraged to try again
*/
        const memberType = this.memberType;
        const recordInput = { 
                MemberId: window.localStorage.getItem('MemberId'), 
                ExternalMemberId: window.localStorage.getItem('ExternalMemberId'), 
                MemberType: memberType 
            };
        insertChatCase(recordInput)
            .then(data => {
                if (data.Error === undefined){
                    this.caseAccountId = data.AccountId;
                    this.caseId = data.CaseId;
                    this.caseContactId = data.ContactId;
                    this.loadLA(); // liveagent.init cannot be called after load; so we're reloading all of LiveAgent 
                } 
                else {
                    this.handleInsertChatCaseError(data.Error);
                }
            })
            .catch(error => {
                this.handleInsertChatCaseError(error);
            });
    }

    handleInsertChatCaseError(error){
        if (this.liveAgentWindow !== undefined) this.liveAgentWindow.close(); // close chat window
        this.disableChatButton = false; // re-enable chat button on error to allow user retry
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error Starting Chat',
                message: 'The following error ocurred: ' + error + '\r\n\r\nPlease try again.',
                variant: 'error',
                mode: 'sticky'
            }),
        );
    }


    getLiveAgentURL(){
        const liveAgentSiteUrl = this.liveAgentSiteUrl;
        if (liveAgentSiteUrl === undefined) return 'https://caredotcom.secure.force.com'; // production value
        return liveAgentSiteUrl;
    }

    startChatAfterTimeout(){
        // if this.caseId & this.caseAccountId were set previous by handleChatClick, then we call liveagent.startChat
        if (this.caseId !== undefined && this.caseAccountId !== undefined){
            this.callStartChat();
        }
    }

    callStartChat(){
        try {
            const topicButtonId = this.topicButtonId;
            window.liveagent.startChatWithWindow(topicButtonId,'livechat');
        } catch (err){
            if (err === 'Error: You cannot call liveagent.startChat until the asynchronous call to liveagent.init has completed!'){
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {this.startChatAfterTimeout();}, 1000);
            }
        }
    }
}