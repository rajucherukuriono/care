import { LightningElement, api } from 'lwc';

export default class CdccTiles extends LightningElement {
    @api tile1IconName;
    @api tile1Title;
    @api tile1Description;
    @api tile1LinkUrl;
    @api tile1LinkText;
    @api tile2IconName;
    @api tile2Title;
    @api tile2Description;
    @api tile2LinkUrl;
    @api tile2LinkText;
    @api tile3IconName;
    @api tile3Title;
    @api tile3Description;
    @api tile3LinkUrl;
    @api tile3LinkText;

    handleLinkClick() {
        //this.showChat();
    }

    connectedCallback() {
        //this.hideChat();
    }

    disconnectedCallback() {
        //this.showChat();
    }

    showChat() {
        if (document.body.classList.contains('hide-chat')) {
            document.body.classList.remove('hide-chat');
        }
    }

    hideChat() {
        if (!document.body.classList.contains('hide-chat')) {
            document.body.classList.add('hide-chat');
        }
    }
}