import { LightningElement, api, wire, track } from 'lwc';
import getArticle from '@salesforce/apex/KnowledgeArticleController.getArticle';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LANG from '@salesforce/i18n/lang';
import { getTopicName } from 'c/topicHelperService';
import HC_Families from '@salesforce/label/c.HC_Families';
import HC_Caregivers from '@salesforce/label/c.HC_Caregivers';

export default class KnowledgeArticle extends NavigationMixin(LightningElement) {
    @api recordId;
    @api title;
    @api body;
    @track getArticleError;
    @track displaySpinner = true;
    @api homePageUrl;
    @api topicDetailUrl;
    topicId;
    topicNameNonLocalized;
    @api TopicURLSafeName;
    lastPublishedDateFormatted;  
    lastPublishedDate;  
    @api communityName;
    @api communityLabel;
    label = {HC_Families, HC_Caregivers}

    @wire(getArticle, { knowledgeArticleId: '$recordId'})
    wiredGetArticle({ error, data }) {
        if (data) {
            this.title = data.Title;
            this.body = data.Body__c;
            this.getArticleError = undefined;
            this.displaySpinner = false;            
            this.topicId = data.TopicId;
            this.topicNameNonLocalized = data.TopicName;
            this.TopicURLSafeName = data.TopicURLSafeName;
            this.communityName = data.CommunityName;
            this.communityLabel = data.CommunityLabel;
            this.lastPublishedDate = new Date(parseInt(data.LastPublishedDate.substring(6,10)), parseInt(data.LastPublishedDate.substring(0,2)) - 1, parseInt(data.LastPublishedDate.substring(3,5)));
            this.lastPublishedDateFormatted = new Intl.DateTimeFormat(LANG,{ year: 'numeric', month: 'short', day: 'numeric' }).format(this.lastPublishedDate);

            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.topicId,
                    objectApiName: 'Topic',
                    actionName: 'view'
                }
            }).then(url => {
                this.topicDetailUrl = url;
            });
        } else if (error) {
            this.getArticleError = error;
            this.title = undefined;
            this.body = undefined;
            this.displaySpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error getting Article',
                    message: '' + error,
                    variant: 'error',
                }),
            );
        }
    }

    get homePageLabel(){
        // For Families & Caregivers, we use Labels (which include translations)
        // For Business Site, we use the Label from the CMD
        if (this.communityName === 'Families'){
            return this.label.HC_Families; 
        } else if (this.communityName === 'Caregivers'){
            return this.label.HC_Caregivers;
        } else {
            return this.communityLabel;
        }
    }

    get topicName(){
        return getTopicName(this.topicNameNonLocalized);
    }

    connectedCallback() {
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        }).then(url => {
            this.homePageUrl = url;
        });

    }

    handleHomePageClick(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

    handleTopicDetailClick(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.topicId,
                objectApiName: 'Topic',
                actionName: 'view'
            }
        });
    }
}