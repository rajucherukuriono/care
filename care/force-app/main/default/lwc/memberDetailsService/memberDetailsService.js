export const emiUrlParam = 'ExternalMemberId'; // External Member Id URL Param
export const emiLSKey = 'memberId';            // External Member Id Local Storage Key            
export const uuidUrlParam = 'memberUUID';      // UUID URL Param
export const uuidLSKey = 'memberUUID';         // UUID Local Storage Key
export const mtUrlParam = 'memberType';        // Member Type URL Param
export const mtLSKey = 'memberType';           // Member Type Local Storage Key

const getExternalMemberId = () => {
    // URL Param logic
    // If URLParams have a valid ExternalMemberId & it differs from LS, store it in LS;  
    // Then return LS (as long as its valid; otherwuse delete LS then return null); this logic is needed in case bad values end up in LS somehow
    // The above logic only applies if we have a valid memberUUID (because meberUUID should have precedence over ExtMemId)

    const params = new URLSearchParams(window.location.search);
    //console.log('params.get(ExternalMemberId): ' + params.get('ExternalMemberId'));
    if (params.has(emiUrlParam)) {
        if (!isMemberUUIDValid(params.get(uuidUrlParam))) { // only allow ExtMemId if we don't have a valid memberUUID
            let ExternalMemberIdParam = params.get(emiUrlParam);
            if (isExternalMemberIdValid(ExternalMemberIdParam)){ // Validate External Id: If invalid, we remove the LS key
                if (ExternalMemberIdParam !== window.localStorage.getItem(emiLSKey)){ // does Param differ from LS?
                    window.localStorage.setItem(emiLSKey,ExternalMemberIdParam);
                    window.localStorage.removeItem(uuidLSKey); // Remove UUID from LS because we only allow one Member Id at time
                }
            } else window.localStorage.removeItem(emiLSKey); // remove key if invalid (LS.setitem doesn't support null values very well)
        }    
    }
    if (!isExternalMemberIdValid(window.localStorage.getItem(emiLSKey))) window.localStorage.removeItem(emiLSKey); // Validate External Id: If invalid, we remove the LS key
    //console.log('window.localStorage.getItem(memberId): ' + window.localStorage.getItem('memberId'));
    return window.localStorage.getItem(emiLSKey);
};
export { getExternalMemberId };

const isExternalMemberIdValid = (ExternalMemberId) => {
    // If we're US, then ext member must be numeric
    if (isUS()){
        if (!isNaN(ExternalMemberId)) return true; // if it's numberic, return true
        else return false;
    } else { // If we're in ROW, we don't currenty validate IDs (so we always return true)
        return true;
    }
};
export { isExternalMemberIdValid };

const getMemberUUID = () => {
    // URL Param logic (same as External Member Id)

    const params = new URLSearchParams(window.location.search);
    //console.log('params.get(uuidUrlParam): ' + params.get(uuidUrlParam));
    if (params.has(uuidUrlParam)) {
        let memberUUIDParam = params.get(uuidUrlParam);
        if (memberUUIDParam !== window.localStorage.getItem(uuidLSKey)){ // does Param differ from LS?
            if (isMemberUUIDValid(memberUUIDParam)){ // Validate Id: If invalid, we remove the LS key
                window.localStorage.setItem(uuidLSKey,memberUUIDParam);
                window.localStorage.removeItem(emiLSKey); // Remove ExternalMemberId from LS because we only allow one Member Id at time
            } else window.localStorage.removeItem(uuidLSKey); // remove key if invalid (LS.setitem doesn't support null values very well)
        }
    }
    if (!isMemberUUIDValid(window.localStorage.getItem(uuidLSKey))) window.localStorage.removeItem(uuidLSKey); // Validate Id: If invalid, we remove the LS key
    //console.log('window.localStorage.getItem(uuidLSKey): ' + window.localStorage.getItem(uuidLSKey));
    return window.localStorage.getItem(uuidLSKey);
};
export { getMemberUUID };

const isMemberUUIDValid = (MemberUUID) => {
    // We validate UUIDs with a regular expression
    if (MemberUUID === undefined || MemberUUID == null) return false;

    const regexExpUUID = /^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$/gi;
    if (regexExpUUID.test(MemberUUID) === true) return true;        

    return false;    
};
export { isMemberUUIDValid };

const getMemberType = () => {
    // Returns the Member Account Type (Basic, Premium) from a URL parameter confusingly called memberType
    // URL Param logic (same as above)

    const params = new URLSearchParams(window.location.search);
    //console.log('params.get(mtUrlParam): ' + params.get(mtUrlParam));
    if (params.has(mtUrlParam)) {
        if (params.get(mtUrlParam) !== window.localStorage.getItem(mtLSKey)){
            let memberUUIDParam = params.get(mtUrlParam);
            window.localStorage.setItem(mtLSKey,memberUUIDParam);
        }
    }
    //console.log('window.localStorage.getItem(mtLSKey): ' + window.localStorage.getItem(mtLSKey));
    return window.localStorage.getItem(mtLSKey);
};

export { getMemberType };

const getMemberTypeIB = (isIbBasic) => {
    // A version of Get Member Type which changes IB Basics to Premiums
    // The change is temporary & only affects this method & is not stored in LS
    let memberType = getMemberType();
    if (isIbBasic){ // override Member Type to PREMIUM if is IB Basic
        memberType = 'PREMIUM';
    }
    return memberType;
};

export { getMemberTypeIB };

const isVisitor = (externalMemberId,memberUUID,memberType) => {
//    console.log('isVisitor externalMemberId: ' + externalMemberId);
//    console.log('isVisitor memberUUID: ' + memberUUID);

    if (externalMemberId === null && memberUUID === null){
        return true;
    }
    return false;
};

export { isVisitor };

const buildCommunityUrlHelper = (url,externalMemberId,memberUUID,memberType) => {
    const urlObj = new URL(url);
    if (memberUUID) {
        urlObj.searchParams.append(uuidUrlParam, memberUUID);
    }

    if (externalMemberId) {
        urlObj.searchParams.append(emiUrlParam, externalMemberId);
    }
    // Add Member Type, but only if we have a member id
    if (memberType && (memberUUID || externalMemberId)) {
        urlObj.searchParams.append(mtUrlParam, memberType);
    }
    // Get lang url Param from current url (if it exists)
    const currentUrl = new URL(window.location.href);
    if (currentUrl.searchParams.has('language')){ 
        urlObj.searchParams.append('language', currentUrl.searchParams.get('language'));
    }

    return urlObj.href;
};

export { buildCommunityUrlHelper };

const resetMemberInfoOnCountryChangeHelper = (locale,currentUrl,currentLangComboLocale) => {
    // We do not want to mantain Memebr Info if user's switch countries.  
    // If we are witnessing a Country Change, we remove Member Info from URL & Local Storage
    // To identify a Country change we compare the current locale w/the Locale from 
    // the current Lang Combo selection
    if (locale.slice(-2) !== currentLangComboLocale.slice(-2)){
        //console.log('Country Change!');
        currentUrl.searchParams.delete(mtUrlParam);
        window.localStorage.removeItem(mtLSKey);
        currentUrl.searchParams.delete(emiUrlParam);
        window.localStorage.removeItem(emiLSKey);
        currentUrl.searchParams.delete(uuidUrlParam);
        window.localStorage.removeItem(uuidLSKey);
    }
};

export { resetMemberInfoOnCountryChangeHelper };

const isUS = () => {
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

export { isUS };

const isCareDotCom = () => {
    // We identify whether we're in the Care.com site by looking for www in the domain.
    // Technically, we could look for www.care.com, www.dev.carezen.net & www.stg.carezen.net, 
    // But I'd prefer not to hardcode those domains.  
    
    const hostName = window.location.hostname;
    if (hostName.toLowerCase().includes('www')){  
        return true;
    }
    return false;
};

export { isCareDotCom };


const shouldUseEntitlementService = (externalMemberId,memberUUID,memberType) => {
    // Entitlement queries US platform API to get members entitlements (like whether they can chat or not)
    // Only Logged In US Seekers or Providers w/MemberUUIDs can check for entitlements.  
    //console.log('isUS(): ' + isUS());
    //console.log('memberType eq Seeker: ' + (memberType === 'Seeker'));
    //console.log('!isVisitor(externalMemberId,memberUUID,): ' + !isVisitor(externalMemberId,memberUUID,''));
    //console.log('memberUUID ne null: ' + (memberUUID !== null));


    if (isUS() && (memberType === 'Seeker' || memberType === 'Provider') && !isVisitor(externalMemberId,memberUUID,'') && memberUUID !== null){                 
        return true;
    }
    return false;
};

export { shouldUseEntitlementService };