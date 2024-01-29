import { LightningElement, api } from 'lwc';
import CDCC_ASSETS from '@salesforce/resourceUrl/CDCC_Assets';

export default class CdccTile extends LightningElement {
    @api iconName;
    @api title;
    @api description;
    @api linkUrl;
    @api linkText;

    get iconUrl() {
        return `${CDCC_ASSETS}/imgs/${this.iconName}`;
    }

    handleLinkClick() {
        this.dispatchEvent(new CustomEvent('linkclick'));
    }
}