import { LightningElement, api, track } from 'lwc';
import getTopicInfo from '@salesforce/apex/CDCCPopularTopicsController.getTopicInfo';
import CDCC_ASSETS from '@salesforce/resourceUrl/CDCC_Assets';
import reduceErrors from 'c/cdccErrorUtil';

export default class CdccPopularTopics extends LightningElement {
    @api heading;
    @api topic1Id;
    @api topic1IconName;
    @api topic2Id;
    @api topic2IconName;
    @api topic3Id;
    @api topic3IconName;
    @api topic4Id;
    @api topic4IconName;
    @api topic5Id;
    @api topic5IconName;
    @api topic6Id;
    @api topic6IconName;
    @api topic7Id;
    @api topic7IconName;
    @api topic8Id;
    @api topic8IconName;
    @api topic9Id;
    @api topic9IconName;
    @api topic10Id;
    @api topic10IconName;
    @track topics;

    connectedCallback() {
        let recordIds = [];
        if (this.topic1Id) {
            recordIds.push(this.topic1Id);
        }
        if (this.topic2Id) {
            recordIds.push(this.topic2Id);
        }
        if (this.topic3Id) {
            recordIds.push(this.topic3Id);
        }
        if (this.topic4Id) {
            recordIds.push(this.topic4Id);
        }
        if (this.topic5Id) {
            recordIds.push(this.topic5Id);
        }
        if (this.topic6Id) {
            recordIds.push(this.topic6Id);
        }
        if (this.topic7Id) {
            recordIds.push(this.topic7Id);
        }
        if (this.topic8Id) {
            recordIds.push(this.topic8Id);
        }
        if (this.topic9Id) {
            recordIds.push(this.topic9Id);
        }
        if (this.topic10Id) {
            recordIds.push(this.topic10Id);
        }
        getTopicInfo({recordIds: recordIds})
            .then(result => {
                let data = [];
                if (result && result.length > 0) {
                    let iconNameMap = new Map();
                    iconNameMap.set(this.topic1Id, this.topic1IconName);
                    iconNameMap.set(this.topic2Id, this.topic2IconName);
                    iconNameMap.set(this.topic3Id, this.topic3IconName);
                    iconNameMap.set(this.topic4Id, this.topic4IconName);
                    iconNameMap.set(this.topic5Id, this.topic5IconName);
                    iconNameMap.set(this.topic6Id, this.topic6IconName);
                    iconNameMap.set(this.topic7Id, this.topic7IconName);
                    iconNameMap.set(this.topic8Id, this.topic8IconName);
                    iconNameMap.set(this.topic9Id, this.topic9IconName);
                    iconNameMap.set(this.topic10Id, this.topic10IconName);
                    for (let i = 0; i < result.length; i++) {
                        let temp = Object.assign({}, result[i]);
                        temp.index = i;
                        temp.iconUrl = `${CDCC_ASSETS}/imgs/${iconNameMap.get(temp.id)}.png`;
                        data.push(temp);
                    }
                }
                this.topics = data;
            })
            .catch(error => {
                console.error(reduceErrors(error));
            });
    }
}