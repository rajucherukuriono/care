import BasePrechat from 'lightningsnapin/basePrechat';
import { api, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import styles from '@salesforce/resourceUrl/SLDS';  
import NF_BOTCSSOVERRIDES from '@salesforce/resourceUrl/NF_BotCSSOverrides';  
import ebcm__EinsteinBotResources from '@salesforce/resourceUrl/ebcm__EinsteinBotResources';  
import HC_Form_Prompt from '@salesforce/label/c.HC_Form_Prompt';
import HC_Form_Name from '@salesforce/label/c.HC_Form_Name';
import HC_Form_Name_Prompt from '@salesforce/label/c.HC_Form_Name_Prompt';
import HC_Form_Email from '@salesforce/label/c.HC_Form_Email';
import HC_Form_Email_Prompt from '@salesforce/label/c.HC_Form_Email_Prompt';
import HC_Form_Phone from '@salesforce/label/c.HC_Form_Phone';
import HC_Form_Phone_Prompt from '@salesforce/label/c.HC_Form_Phone_Prompt';
import HC_Form_Subject from '@salesforce/label/c.HC_Form_Subject';
import HC_Form_Subject_Prompt from '@salesforce/label/c.HC_Form_Subject_Prompt';
import HC_Form_Message from '@salesforce/label/c.HC_Form_Message';
import HC_Form_Message_Prompt from '@salesforce/label/c.HC_Form_Message_Prompt';
import HC_Form_Topic from '@salesforce/label/c.HC_Form_Topic';
import HC_Join_Now from '@salesforce/label/c.HC_Join_Now';
import HC_Log_In from '@salesforce/label/c.HC_Log_In';
import HC_Back from '@salesforce/label/c.HC_Back';
import HC_Form_Send_Email from '@salesforce/label/c.HC_Form_Send_Email';
import HC_Form_Message_Sent from '@salesforce/label/c.HC_Form_Message_Sent';
import HC_Form_Message_Sent_Thanks from '@salesforce/label/c.HC_Form_Message_Sent_Thanks';
import HC_Chat_Form_Prompt from '@salesforce/label/c.HC_Chat_Form_Prompt';
import HC_Chat_Form_Start from '@salesforce/label/c.HC_Chat_Form_Start';
import HC_Pre_Chat_Prompt from '@salesforce/label/c.HC_Pre_Chat_Prompt';
import HC_Pre_Chat_Basic_Prompt from '@salesforce/label/c.HC_Pre_Chat_Basic_Prompt';
import HC_Pre_Chat_Email_Heading from '@salesforce/label/c.HC_Pre_Chat_Email_Heading';
import HC_Pre_Chat_Email_Prompt from '@salesforce/label/c.HC_Pre_Chat_Email_Prompt';
import HC_Pre_Chat_Chat_Heading from '@salesforce/label/c.HC_Pre_Chat_Chat_Heading';
import HC_Pre_Chat_Chat_Prompt from '@salesforce/label/c.HC_Pre_Chat_Chat_Prompt';
import HC_Pre_Chat_Email_Button from '@salesforce/label/c.HC_Pre_Chat_Email_Button';
import HC_Pre_Chat_Chat_Button from '@salesforce/label/c.HC_Pre_Chat_Chat_Button';
import HC_Pre_Chat_Visitor_Heading from '@salesforce/label/c.HC_Pre_Chat_Visitor_Heading';
import HC_Pre_Chat_Visitor_Prompt from '@salesforce/label/c.HC_Pre_Chat_Visitor_Prompt';

import HC_Topic_Account_Management from '@salesforce/label/c.HC_Topic_Account_Management';
import HC_Topic_Using_Your_Account from '@salesforce/label/c.HC_Topic_Using_Your_Account';
import HC_Topic_Subscription_Billing from '@salesforce/label/c.HC_Topic_Subscription_Billing';

import HC_Topic_Trust_Safety from '@salesforce/label/c.HC_Topic_Trust_Safety';
import HC_Topic_Account_and_Profile from '@salesforce/label/c.HC_Topic_Account_and_Profile';
import HC_Topic_Finding_a_Caregiver from '@salesforce/label/c.HC_Topic_Finding_a_Caregiver';
import HC_Topic_Running_My_Business from '@salesforce/label/c.HC_Topic_Running_My_Business';
import HC_Topic_Bookings_and_Full_Time_Jobs from '@salesforce/label/c.HC_Topic_Bookings_and_Full_Time_Jobs';
import HC_Topic_Payments from '@salesforce/label/c.HC_Topic_Payments';
import HC_Topic_My_Profile_and_Services from '@salesforce/label/c.HC_Topic_My_Profile_and_Services';
import HC_Topic_Getting_Started from '@salesforce/label/c.HC_Topic_Getting_Started';

import HC_Chat_Form_Description from '@salesforce/label/c.HC_Chat_Form_Description';
import CDCC_CHAT_CHANNEL from '@salesforce/messageChannel/CDCC_Chat__c';
import CDCC_ASSETS from '@salesforce/resourceUrl/CDCC_Assets';
import getCommunitySettings from '@salesforce/apex/CDCCPreChatController.getCommunitySettings';
import getHelpCenterEntitlement from '@salesforce/apex/helpCenterEntitlement.getHelpCenterEntitlement';
import createCase from '@salesforce/apex/CDCCPreChatController.createCase';
import getArticleTopic from '@salesforce/apex/CDCCPreChatController.getArticleTopic';
import sendMemberInfoToODS from '@salesforce/apex/CDCCPreChatController.sendMemberInfoToODS';
import getSettingByLocale from '@salesforce/apex/CountryLocaleMapHelper.getSettingByLocale';
import reduceErrors from 'c/cdccErrorUtil';
import { getLangURLParam } from 'c/localeService';
import { getExternalMemberId,getMemberUUID,getMemberType,isVisitor,shouldUseEntitlementService,emiLSKey, uuidLSKey, mtLSKey, isCareDotCom } from 'c/memberDetailsService';
import { buildLoginUrl } from 'c/linkHelperService';

export default class CdccPreChat extends BasePrechat {
    @api prechatFields;
    @api backgroundImgURL;
    @track fields;
    @track namelist;
    @track currentScreen;
    @track errorMessage = '';
    @track showSpinner = false;
    previousScreen;
    chatIcon = CDCC_ASSETS + '/imgs/chat.png';
    successIcon = CDCC_ASSETS + '/imgs/success.png';
    communitySettings = {};
    localeSettings = {};
    @api helpCenterEntitlement = {};
    hasRendered = false;
    hasFiredGACustomEventSendEmail = false;
    hasFiredGACustomEventStartChat = false;
    //memberId;      
    externalMemberId;  
    memberUUID; 
    memberType;
    langURLParam;
    @track article = {
        id: '',
        title: '',
        topicName: 'Using Your Account',
        whitelistArticleForWebCases: false
    };
    label = {
        HC_Form_Prompt, HC_Form_Name, HC_Form_Name_Prompt, HC_Form_Email, HC_Form_Email_Prompt, HC_Form_Phone, HC_Form_Phone_Prompt, 
        HC_Form_Subject, HC_Form_Subject_Prompt, HC_Form_Message, HC_Form_Message_Prompt, HC_Form_Topic, HC_Join_Now, HC_Log_In, 
        HC_Back, HC_Form_Send_Email, HC_Form_Message_Sent, HC_Form_Message_Sent_Thanks, HC_Chat_Form_Prompt, HC_Chat_Form_Start, 
        HC_Pre_Chat_Chat_Heading, HC_Pre_Chat_Chat_Prompt, HC_Pre_Chat_Email_Heading, HC_Pre_Chat_Email_Prompt, HC_Pre_Chat_Prompt, 
        HC_Pre_Chat_Email_Button, HC_Pre_Chat_Chat_Button, HC_Pre_Chat_Visitor_Heading, HC_Pre_Chat_Visitor_Prompt, 
        HC_Topic_Account_Management, HC_Topic_Using_Your_Account, HC_Topic_Trust_Safety, HC_Topic_Subscription_Billing, 
        HC_Topic_Account_and_Profile, HC_Topic_Finding_a_Caregiver, HC_Topic_Running_My_Business, HC_Topic_Bookings_and_Full_Time_Jobs,
        HC_Topic_Payments, HC_Topic_My_Profile_and_Services, HC_Topic_Getting_Started, HC_Chat_Form_Description, HC_Pre_Chat_Basic_Prompt
    }

    @wire(MessageContext)
    messageContext;

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
        return getMemberType();
    }

    @api
    get langURLParam(){
        return getLangURLParam();
    }

    get areWeOnAnArticlePage(){
        if (window.location.pathname.search('/article/') !== -1) return true;
        else return false;

    }

    get emailFormSubjectValue(){
        if (this.article.title !== undefined) return this.article.title;
    }

    get showLoginStartScreen() {
        return this.currentScreen === 'loginStart';
    }

    get showEmail() {
        if (this.communitySettings !== undefined){
            if (this.communitySettings.showEmail === undefined) return false;
            else if (this.communitySettings.showEmail === 'Visitor') return true;
            else if (this.communitySettings.showEmail === 'Basic'){
                // If Entitlement returns true, then return true (Entitlement returns true for US Premium Seekers & US IB Basics)
                if (this.helpCenterEntitlement !== undefined && this.helpCenterEntitlement.canChatWithCSR !== undefined){
                    if (this.helpCenterEntitlement.canChatWithCSR === true) return true;
                }            
                if (this.memberType.toUpperCase() === 'PREMIUM') return true; // return true if premium who doesn't use entitlements (like providers)
                if (this.memberType.toUpperCase() === 'BASIC'){ // If user is a basic
                    // If WhiteList is disabled in Community CMD, return true
                    if (this.communitySettings.useArticleWhitelistForWebCases === undefined) return true;

                    // If Comm CMD doesn't contains User Locale, return true
                    // else return whether article is whitelisted 
                    if (this.communitySettings.useArticleWhitelistForWebCases.includes(window.localStorage.getItem('locale')) === false) return true;
                    else return this.article.whitelistArticleForWebCases; // returns true if article is whitelised or false if it isn't; also returns false if we are not in an article page
                }                
            }      
            else if (this.communitySettings.showEmail.toUpperCase() === this.memberType.toUpperCase()) return true;
        }
        return false;
    }    

    get showChat() {
        // Determines whether to show chat based whether the user is a Basic, Premium or Visitor
        // Logged In US Seekers & Providers w/MemberUUID use an API call (we pass MemberUUId & they tell us whether to show chat)
        // Everyone else will use CMD/Member Type URL Param     

        if (shouldUseEntitlementService(this.externalMemberId,this.memberUUID,this.getMemberType())){ 
            if (this.communitySettings !== undefined){
                if (this.communitySettings.showChat === undefined) return false;
                else if (this.communitySettings.showChat === 'Visitor') return true; // if CMD is set to visitor, we want everyone to chat
                else if (this.communitySettings.showChat === 'Basic' || this.communitySettings.showChat === 'Premium'){
                    // If Entitlement returns true, then return true (Entitlement returns true for US Premium Seekers & US IB Basics)
                    if (this.helpCenterEntitlement !== undefined && this.helpCenterEntitlement.canChatWithCSR !== undefined){
                        return this.helpCenterEntitlement.canChatWithCSR;
                    }
                }      
            }
            return false;

        } else { // Everyone else
            if (this.communitySettings !== undefined){
                if (this.communitySettings.showChat === undefined) return false;
                else if (this.communitySettings.showChat === 'Visitor') return true; // if CMD is set to visitor, we want everyone to chat
                else if (this.communitySettings.showChat === 'Basic'){
                    if (this.memberType.toUpperCase() === 'BASIC' || this.memberType.toUpperCase() === 'PREMIUM') return true;
                }      
                else if (this.communitySettings.showChat.toUpperCase() === this.memberType.toUpperCase()) return true;
            }
            return false;
        }
    }    

    get showChatLang() {
        // Determines whether to show chat based on the locale
        if (this.communitySettings !== undefined){
            if (this.communitySettings.showChatLang === undefined) return true; // we're being permissive here; this allows marektplace to get chat without defining a locale
            else if (this.communitySettings.showChatLang.includes(window.localStorage.getItem('locale')) === true) return true;
        }
        return false;
    }    
    
    get showEmailAndChatStartScreen() {
        return this.currentScreen === 'emailAndChatStart';
    }   

    get showEmailScreen1() {
        return this.currentScreen === 'email1';
    }

    get showEmailScreen2() {
        return this.currentScreen === 'email2';
    }

    get showPreChatScreen() {
        return this.currentScreen === 'prechat';
    }

    get showEmailSpinner() {
        return this.currentScreen === 'email1' && this.showSpinner === true;
    }

    get showEmailAndChatSpinner() {
        return this.currentScreen === 'emailAndChatStart' && this.showSpinner === true;
    }

    get showChatSpinner() {
        return  this.currentScreen === 'prechat' && this.showSpinner === true;;
    }


    get isTopicTrustAndSafety() {
        return this.article.topicName === 'Trust & Safety';
    }

    get isTopicUsingYourAccount() {
        return this.article.topicName === 'Using Your Account';
    }

    get isTopicSubscriptionAndBilling() {
        return this.article.topicName === 'Subscription & Billing';
    }

    get isAccountAndProfile() {
        return this.article.topicName === 'Account and Profile';
    }

    get isFindingACareGiver() {
        return this.article.topicName === 'Finding a Caregiver';
    }

    get isRunningABusiness() {
        return this.article.topicName === 'Running My Business';
    }

    get isBookingsAndFullTimeJobs() {
        return this.article.topicName === 'Bookings and Full-Time Jobs';
    }

    get isPayments() {
        return this.article.topicName === 'Payments';
    }

    get isMyProfileAndServices() {
        return this.article.topicName === 'My Profile and Services';
    }

    get isGettingStarted() {
        return this.article.topicName === 'Getting Started';
    }

    connectedCallback() {
        //console.log('this.externalMemberId: ' + this.externalMemberId);
        //console.log('this.memberUUID: ' + this.memberUUID);
        //console.log('this.memberType: ' + this.memberType);

        this.loadSldsStyles();
        this.loadNfStylesAndScripts();
        this.getPreChatFields();
        this.handlePreChatFields();  // this logic should follow getPreChatFields & precede setInitialScreen
        this.setInitialScreen();
        this.callGetCommunitySettings(); // Will call setInitialScreen and handleEntitlement after it's done
        
    }

    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            // This logic runs only the first time renderedCallback is called
            this.callGetArticleDetails();
            this.callGetSettingsByLocale();
            this.handleGACustomEventShowPopup();            

        }

        // This logic runs regardless of whether renderedCallback has been called before
        if (this.currentScreen === 'email1') {
            this.template.querySelector('.email-fields > input').focus();
        } else if (this.currentScreen === 'prechat') {
            this.template.querySelector('.prechat-fields input').focus();
        }        
    }

    loadSldsStyles(){
        if (isCareDotCom()){  // we only want to load SLDS on care.com site, not help center
            Promise.all([
                loadStyle(this, styles + '/styles/salesforce-lightning-design-system.css')/*,
                loadStyle(this, styles + '/styles/salesforce-lightning-design-system.sanitized.css'),
                loadStyle(this, styles + '/styles/salesforce-lightning-design-system_touch.min.css'),
                loadStyle(this, styles + '/styles/salesforce-lightning-design-system-imports.sanitized.css'),
                loadStyle(this, styles + '/styles/salesforce-lightning-design-system-legacy.min.css'),
                loadStyle(this, styles + '/styles/salesforce-lightning-design-system-offline.min.css')*/
            ]).then(() => {
                console.log('SLDS Files loaded.');
            }).catch(error => {
                console.log("Error " + error.body.message);
            })    
        }
    }
    
    loadNfStylesAndScripts(){
        // Logic to load Neuraflash Styles & Scripts 
        
        if (isCareDotCom()){  // we only want to load NF Styles & Scripts on care.com site, not help center
            Promise.all([
                loadStyle(this, NF_BOTCSSOVERRIDES + '/NF_BotCSSOverride.css'),
                loadScript(this, ebcm__EinsteinBotResources + '/Intentcall.js')
            ]).then(() => {
                console.log('NF_BOTCSSOVERRIDES CSS & ebcm__EinsteinBotResources scripts loaded.');
            }).catch(error => {
                console.log('Error ' + error.body.message);
            })    
        }
    }


    getPreChatFields(){
        this.fields = this.prechatFields.map(field => {
            let { label, name, value, required, maxLength } = field;
            const lowerName = name.toLowerCase();
            const hidden = lowerName !== 'help_needed__c';
            let displayLabel = label;
            if (lowerName === 'help_needed__c') {
                displayLabel = this.label.HC_Chat_Form_Description;
            }
            const f = { label, value, displayLabel, name, required, maxLength, hidden };
            switch (field.type) {
                case 'inputSplitName':
                case 'inputText':
                    f.type = 'text';
                    break;
                case 'inputEmail':
                    f.type = 'email';
                    break;
                default:
                    f.type = 'text';
            }
            return f;
        });
        this.namelist = this.fields.map(field => field.name.toLowerCase());
    }

    callGetSettingsByLocale(){
        getSettingByLocale({ locale: window.localStorage.getItem('locale')})
        .then(result => {
            this.localeSettings = result;
        })
        .catch(error => {
            console.error(reduceErrors(error));
        });
    }

    callGetArticleDetails(){
        const articleName = this.getArticleName();
        if (articleName) {
            getArticleTopic({kavUrlName: articleName, language: this.langURLParam})
                .then(result => {
                    this.article = result;
                })
                .catch(error => {
                    console.error(reduceErrors(error));
                });
        }
    }

    callGetCommunitySettings(){
        this.showSpinner = true;
        getCommunitySettings()
        .then(result => {
            this.communitySettings = result;
            this.showSpinner = false;
            this.setInitialScreen();
            this.handleEntitlement();
        })
        .catch(error => {
            console.error(reduceErrors(error));
            this.showSpinner = false;
        });
        
    }

    handleEntitlement(){
        // Because of the Member Type requirement, entitlement needs to be invoked after we get Community Settings (callGetCommunitySettings)

        if (shouldUseEntitlementService(this.externalMemberId,this.memberUUID,this.getMemberType())){ 
            this.showSpinner = true;

            const getPreChatJSONFlow = this.getPreChatJSONFlow();
            //console.log('getPreChatJSONFlow : ' + getPreChatJSONFlow);
            
            getHelpCenterEntitlement({externalMemberId: this.externalMemberId, memberUUID: this.memberUUID, locale: window.localStorage.getItem('locale'), chatEntitlementFlow : getPreChatJSONFlow})
            .then(result => {
                this.helpCenterEntitlement = result;
                this.showSpinner = false;
                console.log('this.helpCenterEntitlement.canChatWithCSR: ' + this.helpCenterEntitlement.canChatWithCSR);
                // handleEntitlement Errors can be handled by just outputting them to console.
                if (this.helpCenterEntitlement.errors) console.error('Handle Entitlement Error: ' + this.helpCenterEntitlement.errors);
                this.handlePostEntitlement();
            })
            .catch(error => {
                console.error(reduceErrors(error));
                this.showSpinner = false;
            });            
        }
    }

    handlePostEntitlement(){
        // this method is invoked after we get the Entitlement
        this.handleSkipPreChat();

    }

    handleSkipPreChat(){
        // All logged in Seekers can skip prechat
        // I implemented logic to occur after entitlement arrives, but technically it COULD be moved until
        // after community settings arrive, but I am going to keep it here to allow time for prechat form to load
        if (this.communitySettings.memberType === 'Seeker' && !isVisitor(this.externalMemberId,this.memberUUID,this.memberType)){
            
            this.showSpinner = true;
            this.navigateToPreChatScreen();
            setTimeout(() => {this.handleStartChat(true);}, 1000);            
        }
        
    }


    getPreChatJSONFlow(){
        const preChatJsonData = this.getPreChatJSONData();
        if (preChatJsonData !== undefined){
            return preChatJsonData.flow;
        }
        return undefined;
    }

    getPreChatJSONData(){
        let preChatJsonData;
        if (this.fields[this.namelist.indexOf('pre_chat_json_data__c')].value !== undefined){
            preChatJsonData = JSON.parse(this.fields[this.namelist.indexOf('pre_chat_json_data__c')].value);
        }
        return preChatJsonData;

    }

    handleStartChat(skipValidation) {
        //console.log('handleStartChat called');

        this.showSpinner = true;
        this.errorMessage = '';
        const prechatFields = this.template.querySelectorAll('.prechat-fields input');
        const isValid = Array.from(prechatFields).reduce((accumulator, currentInput) => {
            return accumulator && currentInput.checkValidity();
        }, true);
        if (isValid === true || skipValidation === true) {
            prechatFields.forEach(input => {
                this.fields[this.namelist.indexOf(input.name.toLowerCase())].value = input.value;                
            });
            
            this.fields[this.namelist.indexOf('help_needed__c')].value = this.getHelpNeeded(this.fields[this.namelist.indexOf('help_needed__c')].value);
            this.fields[this.namelist.indexOf('web_external_member_id__c')].value = this.externalMemberId;
            this.fields[this.namelist.indexOf('web_member_uuid__c')].value = this.memberUUID;
            this.fields[this.namelist.indexOf('type__c')].value = this.memberType;
            this.fields[this.namelist.indexOf('membertype__c')].value = this.getMemberType();
            this.fields[this.namelist.indexOf('chat_case__c')].value = 'Yes';   
            this.fields[this.namelist.indexOf('article_id__c')].value = this.article.id;
            this.fields[this.namelist.indexOf('subject')].value = this.getChatFormSubject();
            this.fields[this.namelist.indexOf('article_topic__c')].value = this.article.topicName;
            this.fields[this.namelist.indexOf('entitlement_can_chat_with_csr__c')].value = this.getCanChatWithCSREntitlement();
            if (window.localStorage.getItem('locale') !== null && window.localStorage.getItem('locale').slice(-2).toLowerCase() !== 'us'){ // only pass Locale & Country for International
                this.fields[this.namelist.indexOf('member_locale__c')].value = this.localeSettings.Locale__c;
                this.fields[this.namelist.indexOf('member_country__c')].value = this.localeSettings.Country_Code__c;
            }
            sendMemberInfoToODS({externalMemberId: this.externalMemberId, memberUUID: this.memberUUID, memberType: this.getMemberType(), locale: window.localStorage.getItem('locale')})
                    .then(result => {
                        if (result) {
                            if (result.Error === undefined){
                                this.errorMessage = '';                            
                                this.fields[this.namelist.indexOf('pre_chat_account_id__c')].value = result.AccountId;
                                this.fields[this.namelist.indexOf('suppliedemail')].value = result.DummyEmail;
                                if (this.validateFields(this.fields).valid) {
                                    this.handleGACustomEventStartChat();
                                    this.startChat(this.fields);                
                                } else {
                                    this.errorMessage = 'An unexpected error has occurred. Please try again at a later time.';
                                }
                            } else {
                                this.errorMessage = 'The following error ocurred: ' + result.Error + '.  \r\n\r\nPlease try again at a later time.';
                            }
                        } else {
                            this.errorMessage = 'An unexpected error has occurred. Please try again at a later time.';
                        }
                        this.showSpinner = false;
                    })
                    .catch(error => {
                        this.errorMessage = 'An unexpected error has occurred. Please try again at a later time.';
                        this.showSpinner = false;
                        console.error(reduceErrors(error));
                    });            
        } else {
            this.errorMessage = 'Please fill out all form fields.';
            this.showSpinner = false;
        }
    }

    handleSendEmail() {
        this.showSpinner = true;
        this.errorMessage = '';
        const emailFormElements = this.template.querySelector('.email-fields').children;
        const inputElements = ['INPUT', 'SELECT', 'TEXTAREA'];
        const isValid = Array.from(emailFormElements)
            .filter(element => {
                return inputElements.includes(element.tagName);
            })
            .reduce((accumulator, currentElement) => {
                return accumulator && currentElement.checkValidity();
            }, true);
        if (isValid) {
            const name = this.template.querySelector('input[name="name"]').value;
            const email = this.template.querySelector('input[name="email"]').value;
            const phone = this.template.querySelector('input[name="phone"]').value;
            const topic = this.template.querySelector('select[name="topic"]').value;
            const message = this.template.querySelector('textarea[name="message"]').value;
            const subject = this.getEmailFormSubject();
            createCase({name: name, email: email, phone: phone, topic: topic, message: message, externalMemberId: this.externalMemberId, memberUUID: this.memberUUID, memberAccountType: this.memberType, memberType: this.getMemberType(), articleId: this.article.id, subject: subject, locale: window.localStorage.getItem('locale')})
                .then(() => {
                    this.handleGACustomEventSendEmail();
                    this.navigateToEmail2Screen();
                    this.showSpinner = false;
                })
                .catch((error) => {
                    this.errorMessage = 'An unexpected error has occurred. Please try again at a later time.';
                    this.showSpinner = false;
                    console.error(reduceErrors(error));
               });
        } else {
            this.errorMessage = 'Please fill out all form fields.';
            this.showSpinner = false;
        }
    }

    handleGACustomEventShowPopup() {
        // Logic: only fire once per render; only fire for logged in members
        // once per render logic handled in renderedcallback method
        if (!isVisitor(this.externalMemberId,this.memberUUID,this.memberType)){
            publish(this.messageContext, CDCC_CHAT_CHANNEL, {message: 'ShowPopUp', memberType: this.memberType});
        }
    }

    handleGACustomEventSendEmail() {
        // Logic: only fire once per render; only fire for logged in members
        if (!this.hasFiredGACustomEventSendEmail) {
            this.hasFiredGACustomEventSendEmail = true;
            if (!isVisitor(this.externalMemberId,this.memberUUID,this.memberType)){
                publish(this.messageContext, CDCC_CHAT_CHANNEL, {message: 'SendEmail', memberType: this.memberType});
            }
        }
    }

    handleGACustomEventStartChat() {
        // Logic: only fire once per render; only fire for logged in members
        if (!this.hasFiredGACustomEventStartChat) {
            this.hasFiredGACustomEventStartChat = true;
            if (!isVisitor(this.externalMemberId,this.memberUUID,this.memberType)){
                publish(this.messageContext, CDCC_CHAT_CHANNEL, {message: 'StartChat', memberType: this.memberType});
            }
        }
    }

    setInitialScreen(){
        // This method gets called twice before & after fetching Community settings for the best user 
        // experience (a spinner spins while the asynchronous calls happen)
        if (!isVisitor(this.externalMemberId,this.memberUUID,this.memberType)){
            if (this.memberType === 'BASIC' || this.memberType === 'PREMIUM') this.currentScreen = 'emailAndChatStart';
        } else if (this.communitySettings !== undefined &&
            (this.communitySettings.showEmail === 'Visitor' || this.communitySettings.showChat === 'Visitor')){
                this.currentScreen = 'emailAndChatStart';
       } else {
           this.currentScreen = 'loginStart';
       }
    }

    navigateToLogIn() {
        window.location = buildLoginUrl(this.localeSettings.Login__c);
    }

    navigateToJoinNow() {
        window.location = this.localeSettings.Join_Now__c;
    }

    navigateToEmail1Screen() {
        this.previousScreen = this.currentScreen;
        this.currentScreen = 'email1';
    }

    navigateToEmail2Screen() {
        this.previousScreen = this.currentScreen;
        this.currentScreen = 'email2';
    }

    navigateToPreChatScreen() {
        this.previousScreen = this.currentScreen;
        this.currentScreen = 'prechat';
    }

    navigateToPreviousScreen() {
        this.currentScreen = this.previousScreen;
        this.previousScreen = null;
        this.errorMessage = '';
    }

    getMemberType() {
        // This method returns Member Type (Seeker, Provider, SMB Provider)
        // This should not be confused with this.memberType which tracks the Member Account Type (Basic, Premium)        
        let memberType = '';
        if (this.communitySettings !== undefined){
            memberType = this.communitySettings.memberType;
        }
        return memberType;
    }

    getEmailFormSubject(){
        // If the form subject is null, use default value as defined in emailFormSubjectValue
        let subject = (this.template.querySelector('input[name="subject"]') === null) ? this.emailFormSubjectValue : this.template.querySelector('input[name="subject"]').value;
        return this.getSubjectPrefix() + subject;
    }

    getChatFormSubject(){
        // Returns Article Title if we're on an Article page.  
        // Otherwise returns default value
        let subject = this.areWeOnAnArticlePage ? this.article.title : 'Home Page Case';
        return this.getSubjectPrefix() + subject;
    }
    
    getSubjectPrefix(){
        // Subject prefix will be set to IB if we're in the US & chat Entitlement returns true
        // & member type is Basic.  
        // NOTE: this should be considered a short-term solution for identifying IB users
        // Longer term, this shoould be tracked by handling LastBookingDate via Salesforce Sync
        if (shouldUseEntitlementService(this.externalMemberId,this.memberUUID,this.getMemberType())){ 
            if (this.helpCenterEntitlement !== undefined){
                if (this.helpCenterEntitlement.canChatWithCSR !== undefined){
                    if (this.helpCenterEntitlement.canChatWithCSR === true && this.memberType.toUpperCase() === 'BASIC'){
                        return 'IB: ';
                    }
                }
            
            }
        }
            
        return '';

    }

    getCanChatWithCSREntitlement(){
        return (this.helpCenterEntitlement.canChatWithCSR === true) ? 'Yes' : 'No';
    }

    getHelpNeeded(helpNeededValue){
        return (helpNeededValue === '') ? 'Blank on Purpose' : helpNeededValue;

    }

    getArticleName() {
        let articleName = '';
        const pathname = window.location.pathname;
        const articlePath = '/article/';
        const startPosition = pathname.indexOf(articlePath);
        if (startPosition >= 0) {
            articleName = pathname.substr(startPosition + articlePath.length);
            const endSlashPosition = articleName.indexOf('/');
            const queryParamsPosition = articleName.indexOf('?');
            if (endSlashPosition >= 0) {
                articleName = articleName.substr(0, endSlashPosition);
            } else if (queryParamsPosition >= 0) {
                articleName = articleName.substr(0, queryParamsPosition);
            }
        }
        return articleName;
    }

    closeChat() {
        publish(this.messageContext, CDCC_CHAT_CHANNEL, {message: 'close'});
    }

    handlePreChatFields(){
        // If Member Info is passed via PreChat, we will trust it above the values
        // passed via URL parameters
        // This logic relies on this.fields, so it needs to be called after those fields are defined

        //this.fields[this.namelist.indexOf('web_external_member_id__c')].value = '103074';
//        this.fields[this.namelist.indexOf('web_member_uuid__c')].value = '132d2c78-f3df-4f93-95e6-1bcc600be024';
//        this.fields[this.namelist.indexOf('type__c')].value = 'PREMIUM';

//        console.log('web_external_member_id__c: ' + this.fields[this.namelist.indexOf('web_external_member_id__c')].value);
//        console.log('web_member_uuid__c: ' + this.fields[this.namelist.indexOf('web_member_uuid__c')].value);
//        console.log('type__c: ' + this.fields[this.namelist.indexOf('type__c')].value);
//        console.log('pre_chat_json_data__c: ' + this.fields[this.namelist.indexOf('pre_chat_json_data__c')].value);
        

        const externalMemberIdFieldValue = this.fields[this.namelist.indexOf('web_external_member_id__c')].value;
        if (externalMemberIdFieldValue !== undefined){
            window.localStorage.setItem(emiLSKey, externalMemberIdFieldValue);
            this.externalMemberId = externalMemberIdFieldValue; 
        }

        const memberUUIDFieldValue = this.fields[this.namelist.indexOf('web_member_uuid__c')].value;
        if (memberUUIDFieldValue !== undefined){
            window.localStorage.setItem(uuidLSKey, memberUUIDFieldValue);
            this.memberUUID = memberUUIDFieldValue;
            ;
        }

        const memberAccountTypeFieldValue = this.fields[this.namelist.indexOf('type__c')].value;
        if (memberAccountTypeFieldValue !== undefined){
            window.localStorage.setItem(mtLSKey, memberAccountTypeFieldValue);
            this.memberType = memberAccountTypeFieldValue;
        }

    }
}