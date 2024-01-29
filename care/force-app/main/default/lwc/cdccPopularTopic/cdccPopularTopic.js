import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CdccPopularTopic extends NavigationMixin(LightningElement) {
    @api type;
    @api id;
    @api title;
    @api urlName;
    @api iconUrl;

    handleButtonClick(event) {
        event.preventDefault();
        event.stopPropagation();
        if (this.type === 'topic') {
            this.navigateToTopic(this.id);
        } else if (this.type === 'article') {
            this.navigateToArticle(this.urlName);
        }
    }

    navigateToTopic(topicId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: topicId,
                actionName: 'view'
            }
        });
    }

    navigateToArticle(urlName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__knowledgeArticlePage',
            attributes: {
                urlName: urlName
            }
        });
    }
}