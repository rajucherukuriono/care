var openSuccess = function openSuccess(result) {
    //Report whether opening the new tab was successful
    if (result.success == false) {
        // JHO - 2015-06-15 - commenting out because I am now using standard errors; besides this alert wasn't doing anything anyway 
        //                    alert('Primary tab cannot be opened');

    }
};

function refreshFeed() {
    Sfdc.canvas.publisher.publish({
        name : 'publisher.refresh',
        payload : {
            feed : true,
            objectFields : true,
            objectRelatedLists : {}
        }
    });
}

function errorFunc() {
    refreshFeed();
    window.alert("Case has been closed. No more available Cases.");
}

var closeSubtab = function closeSubtab(result) {
    //Now that we have the tab ID, we can close it
    var tabId = result.id;
    sforce.console.closeTab(tabId);
};

function moveToNextCase(validationBool, noNextCase, nextCaseId,nextCaseName,tryOnceAgain) 
        {
            if (sforce.console.isInConsole())
            {
                if (tryOnceAgain == 'true')
                {
                    alert('Try once again please....'); 
                    window.top.location='/console'
                } 
                else if (noNextCase === 'true') 
                {
                    refreshFeed();
                    window.alert("Case has been closed. No more available Cases.");
                    sforce.console.getEnclosingTabId(closeSubtab);
                } 
                else if (validationBool === 'true') 
                {
                // JHO - 2015-06-15 - form validation errors are now handled via validation rules
                // so we don't need to do anything here, but capturing condition is still required 
                // to trigger else statements below. 
                alert(noNextCase);
                } 
                else 
                {
                    refreshFeed();
                    sforce.console.openPrimaryTab(null, '/' + nextCaseId, true,
                    nextCaseName, openSuccess, 'NewCaseTab');
                } 
            }
            else
            {
                if (tryOnceAgain == 'true')
                {
                    alert('Try once again please....'); 
                    window.open('/home/home.jsp', '_parent');
                } 
                else if (noNextCase === 'true') 
                {
                    refreshFeed();
                    window.alert("Case has been closed. No more available Cases.");
                } 
                else if (validationBool === 'true') 
                {
                    // JHO - 2015-06-15 - form validation errors are now handled via validation rules
                    // so we don't need to do anything here, but capturing condition is still required 
                    // to trigger else statements below. 
                    alert(noNextCase);
                } 
                else 
                {
                    window.open('/' + nextCaseId, '_parent');
                }
            }
        }

function moveToNextCaseFromHome(dispError, DesiredURL,tryOnceAgain) {
    if (tryOnceAgain == 'true')
	{
        alert('Try once again please....');  
		if(sforce.console.isInConsole())
		{
			window.top.location='/console'
		}
		else
		{
			window.open('/home/home.jsp', '_parent');
		}
    } else if (dispError === 'true') {
        errorFunc();
    } else if (sforce.console.isInConsole()) {
        sforce.console.openPrimaryTab(null, DesiredURL, true, '', openSuccess, 'NewCaseTab');
    } else {
        window.open(DesiredURL, '_parent');
    }
}
