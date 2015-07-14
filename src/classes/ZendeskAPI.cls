// This class provides functionality for creating requests to interact with the Zendesk API
public with sharing class ZendeskAPI {

	public final static String BASE_PATH =  '/api/v2';
	private final static String DEFAULT_USER_AGENT =  'Force.com Toolkit for Zendesk';

	private String subdomain {get;set;}
	private String username {get;set;}
	private String passwordOrToken {get;set;}
	private AuthType authenticationType {get;set;}
	public String userAgent {get;set;}

	public Enum AuthType {
		Password,
		Token
	}

	public ZendeskAPI(String subdomain, String username, String passwordOrToken, AuthType authenticationType) {
		this.subdomain = subdomain;
		this.username = username;
		this.passwordOrToken = passwordOrToken;
		this.authenticationType = authenticationType;

		userAgent = DEFAULT_USER_AGENT;
	}

	public HttpRequest createRequest(String reqMethod, String path) {
		Blob headerValue = null;
		if (authenticationType == AuthType.Password) {
			headerValue = Blob.valueOf(username + ':' + passwordOrToken);
		} else { // Token
			headerValue = Blob.valueOf(username + '/token:' + passwordOrToken);
		}
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);

		HttpRequest req = new HttpRequest();
		req.setMethod(reqMethod);
		req.setTimeout(30000); // 30 seconds
		req.setHeader('Authorization', authorizationHeader);
		req.setEndpoint('https://' + subdomain + '.zendesk.com' + path);
		req.setHeader('Accept', 'application/json');
		if (reqMethod == 'POST' || reqMethod == 'PUT') {
			req.setHeader('Content-Type', 'application/json');
		}
		if (!String.isEmpty(userAgent)) {
			req.setHeader('User-Agent', userAgent);
		}

		return req;
	}

	// Validate that the API login parameters are valid by simply trying to get our own user record
	public Boolean canLogin() {
        HttpResponse res = new Http().send(createRequest('GET', BASE_PATH + '/users/me.json'));
		if (res.getStatusCode() == 200) {
			return true;
		} else {
			throw new ZendeskException('Cannot login: ' + res.getStatusCode());
		}
	}

	// Zendesk responds to successful requests with HTTP status codes in the 200 or 300 range.
	public static Boolean isSuccessStatus(Integer statusCode) {
		return (statusCode != null && statusCode >= 200 && statusCode <= 299);
	}

	public static Boolean isSuccess(HttpResponse res)) {
		Boolean isSuccess = (res.getStatusCode() != null && res.getStatusCode() >= 200 && res.getStatusCode() <= 299);
		if (!isSuccess) {
			System.debug(Logginglevel.ERROR, '**STATUS_CODE=' + res.getStatusCode());
			System.debug(Logginglevel.ERROR, '**RESPONSE_BODY=' + res.getBody());
		}
		return isSuccess;
	}

	// pageURL looks like "https://test.zendesk.com/api/v2/tickets.json?page=2"
	// simply return 2
	public static Long getPageNumber(String pageUrl) {
		return (String.isEmpty(pageUrl) ? null : Long.valueOf(pageUrl.substringAfterLast('page=').substringBefore('&')));
	}

	// A custom JSON serializer that strips out fields with NULL values from the resulting JSON
	// Hopefully Salesforce will add support to allow this to be done natively at some point
	// If you do need specific fields with NULL values to remain in the JSON then add the names
	// of those fields to the fieldsToNull set.
	// NOTE that this only looks at fields 1 level down from the top
	public static String serializeJsonNoNulls(Object obj) {
		return serializeJsonNoNulls(obj, null);
	}

	public static String serializeJsonNoNulls(Object obj, Set<String> fieldsToNull) {
		Map<String, Object> fieldsMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
		System.debug('**fieldsMap=' + fieldsMap);
		Map<String, Object> updateMap = new Map<String, Object>();
		for (String key : fieldsMap.keySet()) {
			System.debug('**[' + key + '] = ' + fieldsMap.get(key));
			// Only keep items that have a non-null value
			// or that have been specified in the fieldsToNull set
			if (fieldsMap.get(key) != null || (fieldsToNull != null && fieldsToNull.contains(key))) {
				updateMap.put(key, fieldsMap.get(key));
			}
		}

		String updateJson = JSON.serialize(updateMap);
		System.debug('**updateJson=' + updateJson);

		return updateJson;
	}
}
