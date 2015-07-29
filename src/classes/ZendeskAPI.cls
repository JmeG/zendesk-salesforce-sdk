// This class provides functionality for creating requests to interact with the Zendesk API
public class ZendeskAPI {

	private final static String DEFAULT_USER_AGENT =  'Force.com Toolkit for Zendesk';

	private String subdomain;
	private String username;
	private String passwordOrToken;
	private AuthType authenticationType;

	// overridable properties
	public String userAgent = DEFAULT_USER_AGENT;
	public Integer timeoutSeconds = 30;
	public Boolean debugAll = false;
	public Boolean debugRequest = false;
	public Boolean debugResponseStatus = false;
	public Boolean debugResponseBody = false;
	public Boolean debugResponseHeaders = false;

	public Enum AuthType { Password, Token }

	private class ZendeskError {
		public String error;
		public String description;
	}

	public ZendeskAPI(String subdomain, String username, String password) {
		if (String.isBlank(subdomain)) { throw new ZendeskException('subdomain parameter must not be empty'); }
		if (String.isBlank(username)) { throw new ZendeskException('username parameter must not be empty'); }
		if (String.isBlank(password)) { throw new ZendeskException('password parameter must not be empty'); }

		this.subdomain = subdomain;
		this.username = username;
		this.passwordOrToken = password;
		this.authenticationType = AuthType.Password;
	}

	// Use this constructor if you need to specify a Token instead of a Password
	// This constructor will allow you to choose either method of authentication
	public ZendeskAPI(String subdomain, String username, String passwordOrToken, AuthType authenticationType) {
		if (String.isBlank(subdomain)) { throw new ZendeskException('subdomain parameter must not be empty'); }
		if (String.isBlank(username)) { throw new ZendeskException('username parameter must not be empty'); }
		if (String.isBlank(passwordOrToken)) { throw new ZendeskException('passwordOrToken parameter must not be empty'); }

		this.subdomain = subdomain;
		this.username = username;
		this.passwordOrToken = passwordOrToken;
		this.authenticationType = authenticationType;
	}

	public HttpRequest createRequest(String reqMethod, String path) {
		return createRequest(reqMethod, path, null, null);
	}

	public HttpRequest createRequest(String reqMethod, String path, String body) {
		return createRequest(reqMethod, path, body, null);
	}

	public HttpRequest createRequest(String reqMethod, String path, Map<String, Object> queryParams) {
		return createRequest(reqMethod, path, null, queryParams);
	}

	public HttpRequest createRequest(String reqMethod, String path, String body, Map<String, Object> queryParams) {
		if (String.isBlank(reqMethod)) { throw new ZendeskException('reqMethod parameter must not be empty'); }
		if (String.isBlank(path)) { throw new ZendeskException('path parameter must not be empty'); }
		if (!path.startsWith('/')) { throw new ZendeskException('path parameter must start with /'); }

		Blob headerValue = null;
		if (authenticationType == AuthType.Password) {
			headerValue = Blob.valueOf(username + ':' + passwordOrToken);
		} else { // Token
			headerValue = Blob.valueOf(username + '/token:' + passwordOrToken);
		}
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);

		HttpRequest req = new HttpRequest();
		req.setMethod(reqMethod);
		req.setTimeout(timeoutSeconds * 1000);
		req.setHeader('Authorization', authorizationHeader);
		req.setEndpoint(String.format('https://{0}.zendesk.com/api/v2{1}{2}', new List<String>{subdomain, path, buildQueryParamString(queryParams)}));
		req.setHeader('Accept', 'application/json');
		if (reqMethod == 'POST' || reqMethod == 'PUT') {
			req.setHeader('Content-Type', 'application/json');
		}
		if (!String.isEmpty(userAgent)) {
			req.setHeader('User-Agent', userAgent);
		}
		if (body != null) {
			req.setBody(body);
		}

		return req;
	}

	private String buildQueryParamString(Map<String, Object> queryParams) {
		String str = '';
		if (queryParams != null && !queryParams.isEmpty()) {
			str = '?';
			for (String key : queryParams.keySet()) {
				Object obj = queryParams.get(key);
				String strVal = (obj==null ? '' : String.valueOf(obj));
				str += String.format('{0}={1}&', new List<String>{key, strVal});
			}
		}
		str = str.removeEnd('&');
		return str;
	}

	// Validate that the API login parameters are valid by simply trying to get our own user record
	public Boolean canLogin() {
        HttpResponse res = new Http().send(createRequest('GET', '/users/me.json'));
		if (res.getStatusCode() == 200) {
			return true;
		} else {
			throw new ZendeskException('Cannot login: ' + res.getStatusCode());
		}
	}

	public String sendRequest(HttpRequest req) {
		if (debugAll || debugRequest) {
			System.debug(Logginglevel.INFO, '**REQUEST=' + req);
		}

		// Send it!
		HttpResponse res = new Http().send(req);

		// Debug the response
		if (debugAll || debugResponseHeaders) {
			System.debug(LoggingLevel.INFO, '**HeaderKeys=' + res.getHeaderKeys());
			for (String s : res.getHeaderKeys()) {
				if (s != null) {
					System.debug(LoggingLevel.INFO, 'header: "' + s + '" value: "' + res.getHeader(s) + '"');
				}
			}
		}
		if (debugAll || debugResponseStatus) {
			System.debug(LoggingLevel.INFO, '**STATUS=' + res.getStatus());
			System.debug(LoggingLevel.INFO, '**STATUS_CODE=' + res.getStatusCode());
		}
		if (debugAll || debugResponseBody) {
			System.debug(LoggingLevel.INFO, '**RESPONSE_BODY=' + res.getBody());
		}

		// Validate the response
		if (!isSuccess(res)) {
			ZendeskError zerr = safeGetError(res.getBody());
			if (zerr != null && !String.isEmpty(zerr.error)) {
				throw new ZendeskResponseException('Zendesk API Error (' + res.getStatusCode() + ') ' + res.getStatus() + ': '+ zerr.error + ' ' + zerr.description);
			} else {
				throw new ZendeskResponseException('Zendesk API Error (' + res.getStatusCode() + ') ' + res.getStatus());
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

}
