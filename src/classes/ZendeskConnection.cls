// This class provides functionality for creating requests to interact with the Zendesk API
global class ZendeskConnection {

	private final static String DEFAULT_USER_AGENT =  'Force.com Toolkit for Zendesk';

	private String subdomain;
	private String username;
	private String password;
	private String token;

	// overridable properties
	global String userAgent = DEFAULT_USER_AGENT;
	global Integer timeoutSeconds = 30;
	global Boolean debugAll = false;
	global Boolean debugRequest = false;
	global Boolean debugResponseStatus = false;
	global Boolean debugResponseBody = false;
	global Boolean debugResponseHeaders = false;

	global class ZendeskError {
		global String error;
		global String description;
	}

	// Factory method to initialize a ZendeskConnection with a Password
	global static ZendeskConnection createWithPassword(String subdomain, String username, String password) {
		return new ZendeskConnection(subdomain, username, password, null);
	}

	// Factory method to initialize a ZendeskConnection with a Token
	global static ZendeskConnection createWithToken(String subdomain, String username, String token) {
		return new ZendeskConnection(subdomain, username, null, token);
	}

	// Private constructor called by the factory initialization methods
	private ZendeskConnection(String subdomain, String username, String password, String token) {
		if (String.isBlank(subdomain)) { throw new ZendeskException('subdomain parameter must not be empty'); }
		if (String.isBlank(username)) { throw new ZendeskException('username parameter must not be empty'); }
		if (String.isBlank(password) && String.isBlank(token)) { throw new ZendeskException('password or token must not be empty'); }

		this.subdomain = subdomain;
		this.username = username;
		this.password = password;
		this.token = token;
	}

	global HttpRequest createRequest(String reqMethod, String path) {
		return createRequest(reqMethod, path, null, null);
	}

	global HttpRequest createRequest(String reqMethod, String path, String body) {
		return createRequest(reqMethod, path, body, null);
	}

	global HttpRequest createRequest(String reqMethod, String path, Map<String, Object> queryParams) {
		return createRequest(reqMethod, path, null, queryParams);
	}

	global HttpRequest createRequest(String reqMethod, String path, String body, Map<String, Object> queryParams) {
		if (String.isBlank(reqMethod)) { throw new ZendeskException('reqMethod parameter must not be empty'); }
		if (String.isBlank(path)) { throw new ZendeskException('path parameter must not be empty'); }
		if (!path.startsWith('/')) { throw new ZendeskException('path parameter must start with /'); }

		Blob headerValue = null;
		if (password != null) {
			headerValue = Blob.valueOf(username + ':' + password);
		} else { // Token
			headerValue = Blob.valueOf(username + '/token:' + token);
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

	global static Map<String, String> getQueryStringMap(String url) {
        Map<String, String> queryStringMap = new Map<String, String>();
        if (!String.isEmpty(url)) {
            for (String s : url.substringAfter('?').split('&')) {
				if (s != null && s.contains('=')) {
                	String[] splits = s.split('=');
                	queryStringMap.put(splits[0], (splits.size() > 1 ? splits[1] : null));
				}
            }
        }
        return queryStringMap;
    }

	// Validate that the API login parameters are valid by simply trying to get our own user record
	global Boolean canLogin() {
        HttpResponse res = new Http().send(createRequest('GET', '/users/me.json'));
		if (res.getStatusCode() == 200) {
			return true;
		} else {
			throw new ZendeskException('Cannot login: ' + res.getStatusCode());
		}
	}

	global String sendRequest(HttpRequest req) {
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
				throw new ZendeskResponseException(
					String.format('Zendesk API Error ({0}, {1}) ERR={2} {3}', new List<String>{
						String.valueOf(res.getStatusCode()),
						res.getStatus(),
						zerr.error,
						zerr.description
					}));
			} else {
				throw new ZendeskResponseException('Zendesk API Error (' + res.getStatusCode() + ', ' + res.getStatus() + ')');
			}
		}

		return res.getBody();
	}

	private Boolean isSuccess(HttpResponse res) {
		if (res == null) { throw new ZendeskException('res parameter cannot be null'); }

		Boolean isSuccess = (res.getStatusCode() != null && res.getStatusCode() >= 200 && res.getStatusCode() <= 299);
		return isSuccess;
	}

	// Attempt to deserialize the response body JSON into a ZendeskError class
	// Examples of error responses
	// {"error":"RecordNotFound", "description":"Not found"}
	// {"error":"InvalidEndpoint", "description":"Not found"}
	// {"error":"RecordInvalid", "description":"Record validation errors", "details":{"base":[{"description":"Description: cannot be blank","error":"BlankValue"}]}}
	private ZendeskError safeGetError(String resBody) {
		ZendeskError zerr = null;
		try {
			zerr = (ZendeskError)JSON.deserialize(resBody, ZendeskError.class);
		} catch(Exception e) {System.debug(e);}
		return zerr;
	}
}
