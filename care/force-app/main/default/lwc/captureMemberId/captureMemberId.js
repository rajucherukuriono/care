import { LightningElement } from 'lwc';

export default class CaptureMemberId extends LightningElement {

    renderedCallback(){
        this.storeMemberId();
        this.storeExternalMemberId();
    }

    storeExternalMemberId(){
        var LSExternalId = window.localStorage.getItem('ExternalMemberId');
        var QSExternalId;

        var qsMap = this.getQueryStringMap();   

        // eslint-disable-next-line dot-notation
        QSExternalId = this.getValidMemberId(qsMap['ExternalMemberId']);

        // If Query String Member Id is defined & valid & differs from Local Storage Member Id, then save QS Member Id to Local Storage
        if (QSExternalId !== undefined && QSExternalId !== LSExternalId){
            window.localStorage.setItem('ExternalMemberId',QSExternalId);
        }
    }

    storeMemberId(){
        var LSMemberId = window.localStorage.getItem('MemberId');
        var QSMemberId;

        var qsMap = this.getQueryStringMap();   

        // eslint-disable-next-line dot-notation
        QSMemberId = this.getValidMemberId(qsMap['MemberId']);

        // If Query String Member Id is defined & valid & differs from Local Storage Member Id, then save QS Member Id to Local Storage
        if (QSMemberId !== undefined && QSMemberId !== LSMemberId){
            window.localStorage.setItem('MemberId',QSMemberId);
        }
    }

    getQueryStringMap(){
        // Turn Query String into an object
        var queryString = window.location.search.substring(1,window.location.search.length);
        var qsMap = queryString.split("&").reduce(function(prev, curr) {
            var p = curr.split("=");
            prev[decodeURIComponent(p[0])] = decodeURIComponent(p[1]);
            return prev;
            },
        {});
        return qsMap;
    }

    getValidMemberId(memberId){
        // US Member Ids are fully numeric
        // International Member Ids start with two letter country code, underscore & then numeric (GB_1234)
        // Method returns undefined if member id is not valid
        if (memberId !== undefined){
            if (this.isNumericInteger(memberId)) return memberId;
            else if (memberId.length > 3){
                if (memberId.substring(2,3) === '_' && this.isNumericInteger(memberId.substring(3,memberId.length))){
                    return memberId;
                }
            }
        }
        return undefined;
    }

    isNumericInteger(n) {
        return !isNaN(parseFloat(n)) && isFinite(n) && (n.indexOf('.') === -1);
      }

}