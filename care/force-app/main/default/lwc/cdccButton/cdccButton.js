import { LightningElement, api } from 'lwc';

export default class CdccButton extends LightningElement {
    @api color;

    get style() {
        return `background-color: ${this.color};`;
    }

    handleClick() {
        // 2023-06-30: Jack Odell: this used to fire a custom event called click
        // which resulted in onclick handlers getting duplicate events.
        // Duplicate events don't matter too much for navigation, but were problematic for 
        // other use cases.  So I changed the event name to give us a choice as to whether
        // we want to handle the standard click event or this custom one.
        this.dispatchEvent(new CustomEvent('clickfromchild'));
    }
}