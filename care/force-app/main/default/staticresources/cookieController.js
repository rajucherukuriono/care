// If IsUS
// Get cookie UUID & MT
// If URL Params exist & differ
// OR If URL Params don't exist
// Navigate to new page w/cookie params

const params = new URLSearchParams(window.location.search);
const uuidCookieName = 'cr_wp';  // UUID Local Storage Key (for UUID that came from Cookie)
const uuidUrlParam = 'memberUUID';                   // UUID URL Param
const mtUrlParam = 'memberType';                     // Member Type URL Param
const premium = 'PREMIUM';                           // Unqiue identified for premiums
const basic = 'BASIC';                           // Unqiue identified for premiums
let crwpCookie = getCookie(uuidCookieName);

// premium - production
// crwpCookie = 'eyJ6aXAiOiI5OTU0NyIsImhtIjpmYWxzZSwidiI6ImNjIiwibXQiOiJzIiwiaXNwIjp0cnVlLCJsYyI6ImVuLXVzIiwibWkiOjkxNzk1ODAsInV1aWQiOiJkZDFhY2Y3ZC00MTdmLTRmNjYtYjczOC0yZDlhYmZiOWNlMzEiLCJuIjoiUHJhdmVlbiBTLiJ9';
// basic - stage
// crwpCookie = '\"eyJ6aXAiOiIwMjEzMCIsImhtIjpmYWxzZSwidiI6InBjIiwibXQiOiJzIiwiaXNwIjpmYWxzZSwibGMiOiJlbi11cyIsIm1pIjo1NjYyMzE2NCwidXVpZCI6ImFlOWFkMzUzLWI0NmYtNDU2ZC05N2M3LTUzZDdkZTBlYTM0NiIsIm4iOiJKYWNrIE8uIn0=\"';

//console.log('crwpCookie: ' + crwpCookie);
if (cc_isUS()){
    if (crwpCookie !== undefined){
        // cr_wp is sometimes surrounded by double quotes & sometimes not
        // it's also base 64 encoded, which means it's content should not contain any double quotes
        // So I will remove all double quotes from the entire string
        crwpCookie = crwpCookie.replaceAll('"',''); 
        //console.log('crwpCookie: ' + crwpCookie);
        const crWpcookieJson = JSON.parse(atob(crwpCookie));    
        let currentUrl = new URL(window.location.href);
        if (crWpcookieJson !== undefined){
            //console.log('crWpcookieJson.uuid: ' + crWpcookieJson.uuid);
            if (crWpcookieJson.uuid !== params.get(uuidUrlParam) || params.has(uuidUrlParam) === false){
                currentUrl.searchParams.set(uuidUrlParam,crWpcookieJson.uuid);
            }
            //console.log('crWpcookieJson.isp: ' + crWpcookieJson.isp);
            if (crWpcookieJson.isp === true){
                if (premium !== params.get(mtUrlParam) || params.has(mtUrlParam) === false){
                    currentUrl.searchParams.set(mtUrlParam,premium);
                }
            } else {
                if (basic !== params.get(mtUrlParam)){
                    currentUrl.searchParams.set(mtUrlParam,basic);
                }
            }

            if (currentUrl.href !== window.location.href){
                //console.log('Navigatin to: ' + currentUrl);
                window.location.href = currentUrl;
            }
        }
    }
}





function cc_isUS() {
    // Duplicated isUS method

    const currentUrl = new URL(window.location.href);
    if (((currentUrl.searchParams.has('language')) && (currentUrl.searchParams.get('language').slice(-2) === 'US') && currentUrl.searchParams.has('locale') === false) ||
        (currentUrl.searchParams.has('language') === false)
    ){
        return true;
    }
    return false;
};

function getCookie(cname) {
    let name = cname + "=";
    let ca = document.cookie.split(';');
    for(let i = 0; i < ca.length; i++) {
      let c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
      }
    }
    return undefined;
}