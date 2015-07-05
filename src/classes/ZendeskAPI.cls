// This class provides common functionality for creating requests to interact with the Zendesk API
public with sharing class ZendeskAPI {

	public final static String BASE_PATH =  '/api/v2';

	private String subdomain {get;set;}
	private String username {get;set;}
	private String passwordOrToken {get;set;}
	private AuthType authenticationType {get;set;}

	public Enum AuthType {
		Password,
		Token
	}

	public ZendeskAPI(String subdomain, String username, String passwordOrToken, AuthType authenticationType) {
		this.subdomain = subdomain;
		this.username = username;
		this.passwordOrToken = passwordOrToken;
		this.authenticationType = authenticationType;
	}

	public HttpRequest setupRequest(String reqMethod, String path) {
		Blob headerValue = null;
		if (authenticationType == AuthType.Password) {
			headerValue = Blob.valueOf(username + ':' + passwordOrToken);
		} else { // Token
			headerValue = Blob.valueOf(username + '/token:' + passwordOrToken);
		}
		String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);

		HttpRequest req = new HttpRequest();
		req.setMethod(reqMethod);
		req.setTimeout(20000); // 20 seconds
		req.setHeader('Authorization', authorizationHeader);
		req.setEndpoint('https://' + subdomain + '.zendesk.com' + path);
		if (reqMethod == 'POST' || reqMethod == 'PUT') {
			req.setHeader('Content-Type', 'application/json');
		}
		System.debug('**req=' + req);

		return req;
	}

}
