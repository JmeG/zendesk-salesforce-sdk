// This class provides functionality for creating requests to interact with the Zendesk API
public class ZendeskAPI {

	public final static String BASE_PATH =  '/api/v2';
	private final static String DEFAULT_USER_AGENT =  'Force.com Toolkit for Zendesk';

	private String subdomain {get;set;}
	private String username {get;set;}
	private String passwordOrToken {get;set;}
	private AuthType authenticationType {get;set;}
	public String userAgent {get;set;}

	public Enum AuthType { Password, Token }

	private class ZendeskError {
		public String error;
		public String description;
	}

	public ZendeskAPI(String subdomain, String username, String passwordOrToken, AuthType authenticationType) {
		if (String.isBlank(subdomain)) { throw new ZendeskException('subdomain parameter must not be empty'); }
		if (String.isBlank(username)) { throw new ZendeskException('username parameter must not be empty'); }
		if (String.isBlank(passwordOrToken)) { throw new ZendeskException('passwordOrToken parameter must not be empty'); }

		this.subdomain = subdomain;
		this.username = username;
		this.passwordOrToken = passwordOrToken;
		this.authenticationType = authenticationType;

		userAgent = DEFAULT_USER_AGENT;
	}

	public HttpRequest createRequest(String reqMethod, String path) {
		if (String.isBlank(reqMethod)) { throw new ZendeskException('reqMethod parameter must not be empty'); }
		if (String.isBlank(path)) { throw new ZendeskException('path parameter must not be empty'); }

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

	public String sendRequest(HttpRequest req) {
		HttpResponse res = new Http().send(req);

		System.debug(Logginglevel.INFO, '**STATUS_CODE=' + res.getStatusCode());
		System.debug(Logginglevel.INFO, '**RESPONSE_BODY=' + res.getBody());

		if (!isSuccess(res)) {
			ZendeskError zerr = safeGetError(res.getBody());
			if (zerr != null && !String.isEmpty(zerr.error)) {
				throw new ZendeskResponseException('Zendesk API Error (' + res.getStatusCode() + ') ' + zerr.error + ' ' + zerr.description);
			} else {
				throw new ZendeskResponseException('Zendesk API Error (' + res.getStatusCode() + ')');
			}
		}
		return res.getBody();
	}

	private Boolean isSuccess(HttpResponse res) {
		if (res == null) { throw new ZendeskException('res parameter must not be null'); }

		Boolean isSuccess = (res.getStatusCode() != null && res.getStatusCode() >= 200 && res.getStatusCode() <= 299);
		return isSuccess;
	}

	// Attempt to deserialize the response body JSON into a ZendeskError class
	// Examples of error responses
	// {"error":"RecordNotFound","description":"Not found"}
	// {"error":"InvalidEndpoint","description":"Not found"}
	private ZendeskError safeGetError(String resBody) {
		ZendeskError zerr = null;
		try {
			zerr = (ZendeskError)JSON.deserialize(resBody, ZendeskError.class);
		} catch(Exception e) {}
		return zerr;
	}

	public static String arrayToCSV(Long[] longs) {
		String csv = '';
		if (longs != null && !longs.isEmpty()) {
			for (Long l : longs) {
				csv += l + ',';
			}
			csv = csv.removeEnd(','); // remove trailing comma
		}
		return csv;
	}

	public static String arrayToCSV(String[] strings) {
		String csv = '';
		if (strings != null && !strings.isEmpty()) {
			for (String str : strings) {
				csv += str + ',';
			}
			csv = csv.removeEnd(','); // remove trailing comma
		}
		return csv;
	}

	/*
	// A custom JSON serializer that strips out fields with NULL values from the resulting JSON
	// Hopefully Salesforce will add support to allow this to be done natively at some point
	// If you do need specific fields with NULL values to remain in the JSON then add the names
	// of those fields to the fieldsToNull set.
	// NOTE that this only looks at fields 1 level down from the top
	public static String serializeJsonNoNulls(Object obj) {
		return serializeJsonNoNulls(obj, null);
	}

	public static String serializeJsonNoNulls(Object obj, Set<String> fieldsToNull) {
		if (obj == null) { throw new ZendeskException('obj parameter must not be null'); }

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
	*/

	// Realllly hacky way of stripping out nulls. Experimenting with this instead of using deserializeUntyped
	// https://iwritecrappycode.wordpress.com/2014/07/16/stripping-nulls-from-a-json-object-in-apex/
	public static string stripJsonNulls(String jsonString) {
		System.debug('stripJsonNulls: input=' + jsonString);
		if (!String.isEmpty(jsonString)) {
			jsonString = jsonString.replaceAll('\"[^\"]*\":null',''); // basic removal of null values
			jsonString = jsonString.replaceAll(',{2,}', ','); // remove duplicate/multiple commas
			jsonString = jsonString.replace('{,', '{'); // prevent opening brace from having a comma after it
			jsonString = jsonString.replace(',}', '}'); // prevent closing brace from having a comma before it
			jsonString = jsonString.replace('[,', '['); // prevent opening bracket from having a comma after it
			jsonString = jsonString.replace(',]', ']'); // prevent closing bracket from having a comma before it
		}
		System.debug('stripJsonNulls: output=' + jsonString);
		return jsonString;
	}
}
