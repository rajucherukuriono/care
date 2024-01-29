const buildLoginUrl = (loginUrl) => {
    //console.log('loginUrl: ' + loginUrl);

    if (loginUrl === undefined) return loginUrl;

    const loginUrlObj = new URL(loginUrl);
    const currentUrl = new URL(window.location.href);
    // I am purposefully not include URL parameters in the redirect URL for now
    // They should not be neccessary because most paramters are tracked via local storage
    const redirectUrl = new URL(currentUrl.protocol + currentUrl.host + currentUrl.pathname);
    //console.log('redirectUrl: ' + redirectUrl);
    loginUrlObj.searchParams.append('redirect_uri', redirectUrl);
    return loginUrlObj.href;
    
};
export { buildLoginUrl };