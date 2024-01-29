// Jack Odell, Salesforce Consultant, 2022-05-05
// This is the code that adds Google Analytics to our Help Center
// For legal reasons, GA should only be loaded in the US

window.dataLayer = window.dataLayer || [];
const gaMeasurementId = 'G-XMJQJVFLTW';
const cdnSource = 'https://www.googletagmanager.com/gtag/js?id=' + gaMeasurementId;

if (isUS()){
    careDotComLoadScript(cdnSource).then(function() {
        //console.log('Loaded GA');
        gtag('js', new Date());
        gtag('config', gaMeasurementId, {
            cookie_domain: '.care.com',
            send_page_view: false
        });
    }, function() {
        console.error('Error loading script')
    });
   
    window.addEventListener("gaPageView", function(event) {
        //console.log('event: ' + event);
        
        gtag('event', 'page_view', {
            page_title: document.title,
            page_location: location.href,
            page_path: location.pathname,
            send_to: gaMeasurementId
          });
    });
    
    window.addEventListener("gaCustomEvent", function(event) {
        //console.log('fireGAEvent');
        let messageStr;
        let memberTypeStr;
        let action = 'Click'; 
    
        if (event !== undefined && event.detail.message !== undefined) {
            messageStr = event.detail.message;
            //console.log('messageStr: ' + messageStr);
            //console.log('action (before): ' + action);
    
            memberTypeStr = event.detail.memberType;
            //console.log('memberTypeStr: ' + memberTypeStr);
    
            if (memberTypeStr !== undefined){
                if (memberTypeStr.toLowerCase() == 'premium'){
                    action = 'PremiumClick';
                } else if (memberTypeStr.toLowerCase() == 'basic'){
                    action = 'BasicClick';
                }
                //console.log('action (after): ' + action);
            }
    
            if (messageStr !== undefined){
                gtag('event', action, {
                    event_category: 'Button',
                    event_label: messageStr
                  });
            }
        }
    });
}

function isUS() {
    // We identify whether we're in the US with the following logic:
    // 1: If language param is present, it must contain US
    //    Also, the URL must not contain a locale parameter (the presense of a locale param is indicative that language parameter is about to change; see changeLang)
    // 2: Else if language param is missing, we assume we're in the US (this adds support for company/business sites which don't don't use language param because they don't support multiple languages
    const currentUrl = new URL(window.location.href);
    if (((currentUrl.searchParams.has('language')) && (currentUrl.searchParams.get('language').slice(-2) === 'US') && currentUrl.searchParams.has('locale') === false) ||
        (currentUrl.searchParams.has('language') === false)
    ){
        return true;
    }
    return false;
};

function careDotComLoadScript(src) {
    return new Promise(function (resolve, reject) {
        var s;
        s = document.createElement('script');
        s.src = src;
        s.onload = resolve;
        s.onerror = reject;
        document.head.appendChild(s);
    });
}

function gtag(){
    window.dataLayer.push(arguments);
}