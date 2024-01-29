import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import createVotingRecord from "@salesforce/apex/CDCCCaseDeflectionController.createVotingRecord";
import getArticles from "@salesforce/apex/CDCCCaseDeflectionController.getArticles";
import reduceErrors from "c/cdccErrorUtil";
import { getLangURLParam } from 'c/localeService';
import { getExternalMemberId,getMemberUUID, getMemberType } from 'c/memberDetailsService';

export default class CdccCaseDeflection extends NavigationMixin(LightningElement) {
    @api recordId;
    @api prompt;
    @api yesLabel;
    @api noLabel;
    @api yesResponse;
    @api articlesHeader;
    @api numArticles;
    @api moreHelpHeading;
    @api moreHelpPrompt;
    @track showYesResponse = false;
    @track showArticles = false;
    @track yesButtonClass = "button";
    @track noButtonClass = "button";
    @track topArticles = [];
    @track hasVoted = false;
    @track showSpinner = false;
    memberId;
    externalMemberId;  
    memberUUID; 

    memberType;
    langURLParam;

    @api
    get externalMemberId(){
        return getExternalMemberId();
    }

    @api
    get memberUUID(){
        return getMemberUUID();
    }
   
    get memberId(){
        if (this.externalMemberId !== null) return this.externalMemberId;
        if (this.memberUUID !== null) return this.memberUUID;
        return null;
    }

    @api
    get memberType(){
        return getMemberType();
    }

    @api
    get langURLParam(){
        return getLangURLParam();
    }

    get hasArticles() {
        return this.topArticles && this.topArticles.length > 0;
    }
    
    onYesClick(event) {
        this.hasVoted = true;
        this.showYesResponse = true;
        this.showArticles = false;
        this.yesButtonClass = "button button-selected";
        this.noButtonClass = "button";
        createVotingRecord({articleId: this.recordId, memberId: this.memberId, memberType: this.memberType, isArticleHelpful: 'Yes'})
            .catch((error) => {
                console.error(reduceErrors(error));
            });
    }

    onNoClick(event) {
        this.showSpinner = true;
        this.hasVoted = true;
        this.showArticles = true;
        this.showYesResponse = false;
        this.yesButtonClass = "button";
        this.noButtonClass = "button button-selected";
        createVotingRecord({articleId: this.recordId, memberId: this.memberId, memberType: this.memberType, isArticleHelpful: 'No'})
            .catch((error) => {
                console.error(reduceErrors(error));
            });
        getArticles({ articleId: this.recordId, numArticles: this.numArticles, language: this.langURLParam })
            .then((result) => {
                this.showSpinner = false;
                this.topArticles = result;
            })
            .catch((error) => {
                this.showSpinner = false;
                console.error(reduceErrors(error));
            });
    }

    handleArticleClick(event) {
        const urlName = event.currentTarget.getAttribute("data-urlname");
        this[NavigationMixin.Navigate]({
            type: "standard__knowledgeArticlePage",
            attributes: {
                urlName: urlName
            }
        });
    }

    connectedCallback() {    

    }
}