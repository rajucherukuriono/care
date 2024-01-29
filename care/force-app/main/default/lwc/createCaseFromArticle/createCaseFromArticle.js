import { LightningElement, api, wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTopicMap from '@salesforce/apex/KnowledgeArticleController.getTopicMap';
import getArticle from '@salesforce/apex/KnowledgeArticleController.getArticle';
import getOrgId from '@salesforce/apex/KnowledgeArticleController.getOrgId';
import CASE_OBJECT from '@salesforce/schema/Case';
import NAME_FIELD from '@salesforce/schema/Case.SuppliedName';
import EMAIL_FIELD from '@salesforce/schema/Case.SuppliedEmail';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import TYPE_FIELD from '@salesforce/schema/Case.Type';
import ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import REASON_FIELD from '@salesforce/schema/Case.Reason';
import SECONDARYREASON_FIELD from '@salesforce/schema/Case.Secondary_Case_Reason__c';
import WEBEXTERNALMEMBERID_FIELD from '@salesforce/schema/Case.Web_External_Member_Id__c';
import ARTICLETOPIC_FIELD from '@salesforce/schema/Case.Article_Topic__c';

export default class CreateCaseFromArticle extends LightningElement {
    @api recordId;
    @api memberType;
    @api displayPhoneProperty;
    @api displayLiveAgentProperty;
    @api deploymentId; // live agent deployment id; value is passed to live agent component
    @api chatInitUrl; // live agent chat init url; value is passed to live agent component
    @api liveAgentSiteUrl;// live agent site url; value is passed to live agent component
    @api displaySpinner = false;
    @track hideFormLoadSpinner = false;
    @api hideLightningMessages = false;
    @track disableSubmitButton = false;
    @api holidayMonth1;
    @api holidayDate1;
    @api holidayMonth2;
    @api holidayDate2;
    @api holidayMonth3;
    @api holidayDate3;
    @api holidayMonth4;
    @api holidayDate4;
        
    caseObject = CASE_OBJECT;
    nameField = NAME_FIELD;
    emailField = EMAIL_FIELD;
    subjectField = SUBJECT_FIELD;
    descriptionField = DESCRIPTION_FIELD;
    typeField = TYPE_FIELD;
    originField = ORIGIN_FIELD;
    statusField = STATUS_FIELD;
    reasonField = REASON_FIELD;
    secondaryReasonField = SECONDARYREASON_FIELD;
    webExternalMemberIdField = WEBEXTERNALMEMBERID_FIELD;
    articleTopicField = ARTICLETOPIC_FIELD;

    caseType;
    memberVisibility;
    visitorVisibility;

    @track topicButtonId;
    @track caseArticleTopic;
    
    @wire(getTopicMap, { knowledgeArticleId: '$recordId', memberType: '$memberType' })
    wiredTopicMap({ error, data }) {
        if (data) {
            console.table(data);
            this.caseType = data.Case_Type__c;
            this.topicButtonId = data.Button_Id__c;
            this.memberVisibility = data.Member_Visibility__c;
            this.visitorVisibility = data.Visitor_Visibility__c;
            this.caseArticleTopic = data.Topic__c;
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error getting Topic Map',
                    message: '' + error,
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
        }
    }

    @api orgId;

    @wire(getOrgId)
    wiredOrgId({ error, data }) {
        if (data) {
           this.orgId = data;
        } else if (error) {
            this.orgId = undefined;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error getting Org id',
                    message: '' + error,
                    variant: 'error',
                }),
            );
        }
    }

    @api subject;

    @wire(getArticle, { knowledgeArticleId: '$recordId'})
    wiredArticle({ error, data }) {
        if (data) {
            this.subject = 'Re: ' + data.Title;
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error getting Article',
                    message: '' + error,
                    variant: 'error',
                }),
            );
        }
    }

    hasFormLoadedOnce = false;

    handleFormLoad(){
        if (this.hasFormLoadedOnce === false){
            this.hasFormLoadedOnce = true;
            this.hideFormLoadSpinner = true;
            
        }
    }

    handleSubmit(){
        this.displaySpinner = true;
    }
    
    handleCaseCreated(){
        this.handlePostSuccess();
    }

    handlePostSuccess(){
        this.displaySpinner = false;
        this.disableSubmitButton = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'An email was sent to Customer Support.',
                variant: 'success',
                mode: 'sticky'
            }),
        );

    }

    handleFormError(event){
        const message = event.detail.message;
        if (message === 'The requested resource does not exist'){
            // Salesforce is throwing this error, because the guest user no longer has access to this
            // case because its been assigned to a queue via assingment rules.
            // We're going to cancel this error & treat it like a success.
            event.preventDefault();
            this.hideLightningMessages = true;
            this.handlePostSuccess();

        } else { // other errors are handled here
            this.displaySpinner = false;
        }
    }

    @track value = '';
    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No, I need more help!', value: 'No' },
        ];
    }

    @track displayForm = false;
    @track displayWelcome = false;
    handleRadioChange(event) {
        var selectedOption = event.detail.value;
        this.displayForm = (selectedOption === 'No') ? true : false;
        this.displayWelcome = (selectedOption === 'Yes') ? true : false;
    }

    get caseTypeValue(){
        // For some reason, using track on case type stopped working, so I switched to this getter
        const caseTypeString = '' + this.caseType;
        console.log(this.caseType);
        return caseTypeString;
    }

    /*get caseArticleTopicValue(){
       const caseArticleTopicString = '' + this.caseArticleTopic;
       console.log(this.caseArticleTopic);
       return caseArticleTopicString;
    }*/

    get webExternalMemberId(){
        return window.localStorage.getItem('ExternalMemberId');
    }

    get displayLiveAgent(){
        if ((this.displayLiveAgentProperty === true)
                && (window.localStorage.getItem('ExternalMemberId') !== null) 
                && (this.topicButtonId !== undefined)
                && (this.orgId !== undefined)
                ){
                    return true;
        }
        return false;
    }

}


    /* Logic to invoke wire methods empirically

            getTopicMap({knowledgeArticleId: this.recordId,memberType: this.memberType})
                .then(data => {
                    this.subject = data.Topic__c;
                    this.topicButtonId = data.Button_Id__c;
                    this.caseType = data.Case_Type__c;
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error getting Topic Map',
                            message: '' + error,
                            variant: 'error',
                            mode: 'sticky'
                        }),
                    );
                });

            getOrgId()
                .then(data => {
                    this.orgId = data;
                })
                .catch(error => {
                    this.orgId = undefined;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error calling get org id',
                            message: '' + error,
                            variant: 'error',
                        }),
                    );
                });
*/