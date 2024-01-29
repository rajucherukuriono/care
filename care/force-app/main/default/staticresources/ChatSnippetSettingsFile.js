console.log('Snippet settings file loaded 1');

embedded_svc.snippetSettingsFile.extraPrechatInfo = [{
	"entityName":"Contact",
	"saveToTranscript":"ContactId",
	"showOnCreate":false, 
    "entityFieldMaps":[{
		"doCreate":false,
		"doFind":false,
		"fieldName":"LastName",
		"isExactMatch":true,
		"label":"Last Name"
	}, {
		"doCreate":false,
		"doFind":false,
		"fieldName":"FirstName",
		"isExactMatch":true,
		"label":"First Name"
	}, {
		"doCreate":false,
		"doFind":false,
		"fieldName":"Email",
		"isExactMatch":true,
		"label":"Web Email"
	}, {
        "isExactMatch": true,
        "fieldName": "AccountId",
        "doCreate": false,
        "doFind": true,
        "label": "Pre-Chat Account Id"
    }]
    }, {
	'entityName':'Account',
	'showOnCreate':true,
	'saveToTranscript':'AccountId',
	'entityFieldMaps':[{
        "isExactMatch": true,
        "fieldName": "id",
        "doCreate": false,
        "doFind": true,
        "label": "Pre-Chat Account Id"
    }]}
];

embedded_svc.snippetSettingsFile.directToButtonRouting = function(prechatFormData) {
	const seekerButtonId = '5735Y0000004xmc';
	const defaultButtonId = '5735Y000000oLkU';

	const mtindex = prechatFormData.map(function(e) { return e.name; }).indexOf('MemberType__c');
	const entIndex = prechatFormData.map(function(e) { return e.name; }).indexOf('Entitlement_Can_Chat_With_CSR__c');
	console.log('prechatFormData[entIndex].value: ' + prechatFormData[entIndex].value);
	console.log('prechatFormData[mtindex].value: ' + prechatFormData[mtindex].value);

	// We only route to the NF chatbot if the Entitlement service has approved member
	if (prechatFormData[entIndex].value.toLowerCase() === 'yes'){
		// We only route to the NF chatbot if its a seeker.  Providers should get the old chatbot.
		if (prechatFormData[mtindex].value.toLowerCase() === 'seeker'){
			console.log('Returning seeker button Id: ' + seekerButtonId);
			return seekerButtonId;
		}
	}

	console.log('Returning default button Id: ' + defaultButtonId);
	return defaultButtonId;
}
