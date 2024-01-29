/*********************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 11/23/2020
Description: HTTPRequest class for retrieving the MapBox geocoding API results

Example request:

{
    "url": "",
    "index": "mapbox.places",
    "approx": true,
    "staging": false,
    "onCountry": true,
    "onWorldview": true,
    "onType": true,
    "onProximity": true,
    "onBBOX": true,
    "onLimit": true,
    "onLanguage": true,
    "countries": [],
    "worldviews": [],
    "proximity": "",
    "typeToggle": {
        "country": false,
        "region": false,
        "district": false,
        "postcode": false,
        "locality": false,
        "place": false,
        "neighborhood": false,
        "address": false,
        "poi": false
    },
    "types": [],
    "bbox": "",
    "limit": "",
    "autocomplete": true,
    "languages": [],
    "languageStrict": false,
    "onDebug": false,
    "selectedLayer": "",
    "debugClick": {},
    "localsearch": false,
    "query": "indianapolis"
}

Changes:

*********************************************************************************************/
public without sharing class CCCAPIReqMapBoxGeocoding extends HTTPRequestElement {

    public CCCAPIReqMapBoxGeocoding(String endpoint, Integer httpRequestTimeout) {
        this.setEndPoint(endpoint);
        this.setBody('');
        this.setTimeout(httpRequestTimeout);
        this.setMethod('GET');
    }
}