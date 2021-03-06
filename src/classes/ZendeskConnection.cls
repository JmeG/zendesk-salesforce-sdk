// This class provides functionality for creating requests to interact with the Zendesk API
global class ZendeskConnection {

    // Parameters used to establish a connection
    private String namedCredential;
    private String subdomain;
    private String username;
    private String password;
    private String apiToken;
    private String oauthToken;

    // Overridable properties
    global String userAgent = 'Zendesk SDK for Salesforce';
    global Integer timeoutSeconds = 30;

    // Note that System.debug logs can't be exposed from within a managed package but
    // we can save debug messages to a custom List that we expose publically.
    global Boolean debugAll = false;
    global Boolean debugRequest = false;
    global Boolean debugResponseStatus = false;
    global Boolean debugResponseBody = false;
    global Boolean debugResponseHeaders = false;
    global Boolean saveDebugLogsToList = false;
    private List<String> debugLogs;

    global class ZendeskError {
        global String error;
        global String description;
        global Map<String, Object> details;
        public ZendeskError(String jsonString) {
            Map<String, Object> raw = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            error = (String)raw.get('error');
            description = (String)raw.get('description');
            if (null != raw.get('details')) {
                details = (Map<String, Object>)raw.get('details');
            }
        }
    }

    // Factory method to initialize a ZendeskConnection with a Password
    global static ZendeskConnection createWithPassword(String subdomain, String username, String password) {
        return new ZendeskConnection(subdomain, username, password, null, null);
    }

    // Factory method to initialize a ZendeskConnection with an API Token
    global static ZendeskConnection createWithAPIToken(String subdomain, String username, String apiToken) {
        return new ZendeskConnection(subdomain, username, null, apiToken, null);
    }

    // Factory method to initialize a ZendeskConnection with an OAuth token
    global static ZendeskConnection createWithOAuthToken(String subdomain, String oauthToken) {
        return new ZendeskConnection(subdomain, null, null, null, oauthToken);
    }

    // Factory method to initialize a ZendeskConnection via a Named Credential
    // In order to make use of a Named Credential set it up like follows.
    // Identity Type: Named Principal
    // Auth Protocol: Password Authentication
    // Username: user@domain.com or user@domain.com/token (if using an api token)
    // Password: <password> or <token>
    // Generate Authorization Header: checked
    global static ZendeskConnection createWithNamedCredential(String namedCredential) {
        return new ZendeskConnection(namedCredential);
    }

    // Private constructor called by the factory initialization methods
    private ZendeskConnection(String subdomain, String username, String password, String apiToken, String oauthToken) {
        if (String.isBlank(subdomain)) { throw new ZendeskException('subdomain parameter must not be empty'); }
        if (String.isBlank(password) && String.isBlank(apiToken) && String.isBlank(oauthToken)) { throw new ZendeskException('password or token must not be empty'); }
        // username is required for password and apiToken authentication flows
        if ((!String.isBlank(password) || !String.isBlank(apiToken)) && String.isBlank(username)) { throw new ZendeskException('username parameter must not be empty'); }

        this.subdomain = subdomain;
        this.username = username;
        this.password = password;
        this.apiToken = apiToken;
        this.oauthToken = oauthToken;

        debugLogs = new List<String>();
    }

    // Private constructor called by the factory initialization methods
    private ZendeskConnection(String namedCredential) {
        if (String.isBlank(namedCredential)) { throw new ZendeskException('namedCredential parameter must not be empty'); }

        this.namedCredential = namedCredential;

        debugLogs = new List<String>();
    }

    // Return the namedCredential associated with this connection
    global String getNamedCredential() {
        return namedCredential;
    }

    // Return the subdomain associated with this connection
    global String getSubdomain() {
        return subdomain;
    }

    global List<String> getDebugLogs() {
        return debugLogs;
    }

    global void clearDebugLogs() {
        debugLogs = new List<String>();
    }

    private void addDebugLog(Logginglevel logLevel, Object obj) {
        if (obj != null) {
            // Always write to the standard debugger
            System.debug(logLevel, obj);
            // Optionally save to our custom debug logs list
            if (saveDebugLogsToList) {
                debugLogs.add(logLevel + ': ' + String.valueOf(obj));
            }
        }
    }

    // Create an API Request
    global HttpRequest createRequest(String reqMethod, String path) {
        return createRequest(reqMethod, path, null, null);
    }

    // Create an API Request
    global HttpRequest createRequest(String reqMethod, String path, String body) {
        return createRequest(reqMethod, path, body, null);
    }

    // Create an API Request
    global HttpRequest createRequest(String reqMethod, String path, Map<String, Object> queryParams) {
        return createRequest(reqMethod, path, null, queryParams);
    }

    // Create an API Request
    global HttpRequest createRequest(String reqMethod, String path, String body, Map<String, Object> queryParams) {
        return createRequest(reqMethod, path, body, queryParams, true);
    }

    global HttpRequest createRequest(String reqMethod, String path, String body, Map<String, Object> queryParams, Boolean unreplaceReservedWords) {
        if (String.isBlank(reqMethod)) { throw new ZendeskException('reqMethod parameter must not be empty'); }
        if (String.isBlank(path)) { throw new ZendeskException('path parameter must not be empty'); }
        if (!path.startsWith('/')) { throw new ZendeskException('path parameter must start with /'); }

        String authorizationHeader = null;
        if (String.isEmpty(namedCredential)) {
            if (password != null) {
                authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password));
            } else if (apiToken != null) {
                authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(Blob.valueOf(username + '/token:' + apiToken));
            } else if (oauthToken != null) {
                authorizationHeader = 'Bearer ' + oauthToken;
            } else {
                throw new ZendeskException('Authentication not configured correctly');
            }
        }

        HttpRequest req = new HttpRequest();
        req.setMethod(reqMethod);
        req.setTimeout(timeoutSeconds * 1000);
        if (!String.isEmpty(namedCredential)) {
            req.setEndpoint(String.format('callout:{0}/api/v2{1}{2}', new List<String>{namedCredential, path, buildQueryParamString(queryParams)}));
        } else {
            req.setHeader('Authorization', authorizationHeader);
            req.setEndpoint(String.format('https://{0}.zendesk.com/api/v2{1}{2}', new List<String>{subdomain, path, buildQueryParamString(queryParams)}));
        }
        req.setHeader('Accept', 'application/json');
        if (reqMethod == 'POST' || reqMethod == 'PUT') {
            req.setHeader('Content-Type', 'application/json');
        }
        if (!String.isEmpty(userAgent)) {
            req.setHeader('User-Agent', userAgent);
        }
        if (body != null) {
            if (unreplaceReservedWords) {
                body = unreplaceReservedWords(body);
            }
            req.setBody(body);
        }

        return req;
    }

    // Build a query parameters string from a map of values
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

    // Returns a map of all query string name/value's.
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
        try {
            HttpResponse res = new Http().send(createRequest('GET', '/users/me.json'));
            if (res.getStatusCode() == 200) {
                // Note that a 200 response doesn't necessarily mean our credentials are good.
                // The API will return an anonymous user if we send a bad username/password in the request
                // {"user":{"id":null,"url":null,"name":"Anonymous user","email":"invalid@example.com","created_at":null,"updated_at":null,"time_zone":"Pacific Time (US & Canada)","phone":null,"shared_phone_number":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"authenticity_token":"Uc68v64GiT2jUBocB/g6JCbuThuUET9xCt6ClQqZAn8="}}
                ZendeskUsersAPI.UserWrapper resultWrapper = (ZendeskUsersAPI.UserWrapper)JSON.deserialize(res.getBody(), ZendeskUsersAPI.UserWrapper.class);
                if (resultWrapper == null || resultWrapper.user == null) {
                    throw new ZendeskException('API returned invalid response');
                } else if (resultWrapper.user.id == null) {
                    throw new ZendeskException('API could not authenticate you');
                }

                return true;
            } else {
                throw new ZendeskException('API returned Status Code ' + res.getStatusCode());
            }
        } catch(Exception e) {
            throw new ZendeskException('Cannot login: ' + e.getMessage());
        }
    }

    // Send an API Request
    global String sendRequest(HttpRequest req) {
        if (debugAll || debugRequest) {
            addDebugLog(Logginglevel.INFO, '**REQUEST=' + req);
            addDebugLog(Logginglevel.INFO, '**REQUEST_BODY=' + req.getBody());
        }

        // Send it
        HttpResponse res = new Http().send(req);

        // Debug the response
        if (debugAll || debugResponseHeaders) {
            addDebugLog(LoggingLevel.INFO, '**HeaderKeys=' + res.getHeaderKeys());
            for (String s : res.getHeaderKeys()) {
                if (s != null) {
                    addDebugLog(LoggingLevel.INFO, 'header: "' + s + '" value: "' + res.getHeader(s) + '"');
                }
            }
        }
        if (debugAll || debugResponseStatus) {
            addDebugLog(LoggingLevel.INFO, '**STATUS=' + res.getStatus());
            addDebugLog(LoggingLevel.INFO, '**STATUS_CODE=' + res.getStatusCode());
        }
        if (debugAll || debugResponseBody) {
            addDebugLog(LoggingLevel.INFO, '**RESPONSE_BODY=' + res.getBody());
        }

        // Validate the response - anything outside the 200 range will result in an exception
        if (res.getStatusCode() < 200 || res.getStatusCode() > 299) {
            if (res.getStatusCode() == 429) {
                String retrySeconds = res.getHeader('Retry-After');
                addDebugLog(LoggingLevel.INFO, 'retrySeconds=' + retrySeconds);
                throw new ZendeskResponseException('Rate Limit Exception. Try after ' + retrySeconds);
            }
            ZendeskError zerr = safeGetError(res.getBody());
            if (zerr != null && !String.isEmpty(zerr.error)) {
                throw new ZendeskResponseException(
                    String.format('Zendesk API Error ({0}, {1}) ERR={2} {3}', new List<String>{
                        String.valueOf(res.getStatusCode()),
                        res.getStatus(),
                        zerr.error,
                        zerr.description
                    }), zerr);
            } else {
                throw new ZendeskResponseException('Zendesk API Error (' + res.getStatusCode() + ', ' + res.getStatus() + ')');
            }
        }

        return res.getBody();
    }

    // Attempt to deserialize the response body JSON into a ZendeskError class
    // Examples of error responses
    // {"error":"RecordNotFound", "description":"Not found"}
    // {"error":"InvalidEndpoint", "description":"Not found"}
    // {"error":"RecordInvalid", "description":"Record validation errors", "details":{"base":[{"description":"Description: cannot be blank","error":"BlankValue"}]}}
    private ZendeskError safeGetError(String resBody) {
        ZendeskError zerr = null;
        try {
            zerr = new ZendeskError(resBody);
        } catch(Exception e) {System.debug(e);}
        return zerr;
    }

    // replace reserved keywords in the JSON string and map them to field names prefixed with "x_"
    // Use when calling deserialize()
    // Note that a full list of reserved words can be found here
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_reserved_words.htm
    private String replaceReservedWords(String str) {
        str = str.replaceAll('"default"\\s*:', '"x_default":');
        str = str.replaceAll('"group"\\s*:', '"x_group":');
        str = str.replaceAll('"system"\\s*:', '"x_system":');
        str = str.replaceAll('"public"\\s*:', '"x_public":');
        return str;
    }

    // un-replace reserved keywords in the JSON string
    // Use before sending a request to the API
    private String unreplaceReservedWords(String str) {
        str = str.replaceAll('"x_default"\\s*:', '"default":');
        str = str.replaceAll('"x_group"\\s*:', '"group":');
        str = str.replaceAll('"x_system"\\s*:', '"system":');
        str = str.replaceAll('"x_public"\\s*:', '"public":');
        return str;
    }

    // Allow for setting Mock Callout response from external code when this code is used as part of a managed package.
    global static void setHttpCalloutMock(HttpCalloutMock mock) {
        Test.setMock(HttpCalloutMock.class, mock);
    }
}
