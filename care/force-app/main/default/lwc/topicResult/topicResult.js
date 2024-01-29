import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { includeLangInURL } from 'c/localeService';


export default class TopicResult extends NavigationMixin(LightningElement) {
    hasRendered = false;
    @api article;
    @api language;
    articleURLWithLang;   

    getArticleURLWithLang(){
        this[NavigationMixin.GenerateUrl]({
            type: "standard__knowledgeArticlePage",
            attributes: {
                urlName: this.article.UrlName
            }
        }).then(url => {
            if (this.language !== undefined && includeLangInURL() === true) url += '?language=' + this.language;
            this.articleURLWithLang = url;
            //console.log('this.articleURLWithLang: ' + this.articleURLWithLang);
        });
    }

    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            // This logic runs only the first time renderedCallback is called
            this.getArticleURLWithLang();

        }
        // This logic runs regardless of whether renderedCallback has been called before
        
    }


    handleArticleClick(event) {
        event.preventDefault();
        event.stopPropagation();

        const urlName = event.currentTarget.getAttribute("data-urlname");
        this[NavigationMixin.Navigate]({
            type: "standard__knowledgeArticlePage",
            attributes: {
                urlName: urlName
            }
        });
    }

}