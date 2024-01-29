import { LightningElement, api, wire, track } from 'lwc';
import GetArticlesByTopic from '@salesforce/apex/TopicResultsController.GetArticlesByTopic';
import reduceErrors from 'c/cdccErrorUtil';
import { getLocaleToLangMap, getLangComboToSupportedLangMap } from 'c/localeService';
import { getTopicName } from 'c/topicHelperService';

export default class TopicResults extends LightningElement {
    hasRendered = false;
    hideMore = true;
    @api recordId;
    @api numberOfArticles;
    @api articles = new Array();
    @api language;
    @api topicName = undefined;
    /*@api queryLimit = 1;*/
    @api queryOffset = 0; 
    @api localeToLangMap;    
    @api langComboToSupportedLangMap;

    @wire(GetArticlesByTopic, { topicId: '$recordId', queryLimit: '$numberOfArticles',  queryOffset: '$queryOffset', language: '$language'})
    wiredArticles({ error, data }) {
        if (data) this.handleArticleData(data);
        else if (error) console.error(reduceErrors(error));
    }

    get localeToLangMap(){
        return getLocaleToLangMap();
    }

    get langComboToSupportedLangMap(){
        return getLangComboToSupportedLangMap();
    }

    get language(){
        // We get the language from the locale
        // When we retire the logic to map our languages to our core 5 languages, 
        // We should just need to strip out the reference to langComboToSupportedLangMap below
        return this.langComboToSupportedLangMap.get(this.localeToLangMap.get(window.localStorage.getItem('locale')))
        ;
    }

    get topicLabel(){
        return getTopicName(this.topicName);
    }

    handleArticleData(data){
        //console.log('data.length: ' +  data.length);

        if (data.length > 0){ // we have records
            this.articles = this.articles.concat(data);
            if (this.topicName === undefined) this.topicName = data[0].TopicAssignments[0].Topic.Name;
            if (data.length === this.numberOfArticles) this.hideMore = false;
        } else { // We don't have any records
            this.hideMore = true;
        }

    }

    handleMoreClick(){
        //console.log('Onclick fired');
        // increase offset by numberOfArticles
        this.queryOffset = this.queryOffset + this.numberOfArticles;
        //console.log('this.queryOffset: ' + this.queryOffset);

    }

    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            // This logic runs only the first time renderedCallback is called
//            this.invokeGetArticlesByTopic();

        }

        // This logic runs regardless of whether renderedCallback has been called before
    }
   

}