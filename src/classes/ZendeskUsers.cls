// This class provides common functionality to call the Zendesk API to interact with User records
public with sharing class ZendeskUsers {

	private final ZendeskAPI zapi;

	private class MultipleUsersWrapper {
		public ZendeskAPISchema.ZUser[] users {get;set;}

		// "https://test.zendesk.com/api/v2/users.json?page=2"
		public String next_page {get;set;}
		public Integer nextPageNumber {
			public get { return (String.isEmpty(next_page) ? null : Integer.valueOf(next_page.substringAfterLast('page=').substringBefore('&'))); }
			private set;
		}
	}

	// Used to deserialize the result of a User create/update API call
	private class SingleUserWrapper {
		public ZendeskAPISchema.ZUser user {get;set;}
	}

	public ZendeskUsers(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

	public Integer createUser(String name, String email) {
		ZendeskAPISchema.ZUser zuser = new ZendeskAPISchema.ZUser();
		zuser.name = name;
		zuser.email = email;

		return createUser(zuser);
	}

	public Integer createUser(ZendeskAPISchema.ZUser zuser) {
		Http h = new Http();
		HttpRequest req = zapi.setupRequest('POST', '/api/v2/users.json');

		SingleUserWrapper userWrapper = new SingleUserWrapper();
		userWrapper.user = zuser;
		String reqBody = JSON.serialize(userWrapper);
		System.debug('**** json string = ' + reqBody);
		req.setBody(reqBody);

		HttpResponse res;
		if (!Test.isRunningTest()) {
			res = h.send(req);
		} else {
			// fake response
			res = new HttpResponse();
			res.setStatusCode(201);
			res.setStatus('OK');
			res.setBody('{"user":{"id":487700530,"url":"https://test.zendesk.com/api/v2/users/487700530.json","name":"Bob Smith","email":"bsmith1@zendesktest.com","created_at":"2014-07-02T21:57:13Z","updated_at":"2014-07-02T21:57:13Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null}}');
		}
		System.debug('createUser res: ' + res);
		String resBody = res.getBody();
		System.debug('createUser res body: ' + resBody);

		if (res.getStatusCode() != 201) {
			throw new ZendeskException('Error occurred trying to create user.');
		}

		SingleUserWrapper resultWrapper = (SingleUserWrapper)JSON.deserialize(resBody, SingleUserWrapper.class);
		System.debug('zuserResult=' + resultWrapper);

		return ((resultWrapper==null || resultWrapper.user == null) ? null : resultWrapper.user.id);
	}

	public Integer getUserIdFromEmail(String email) {
		ZendeskAPISchema.ZUser user = getUserFromEmail(email);
		return (user == null ? null : user.id);
	}

	public ZendeskAPISchema.ZUser getUserFromEmail(String email) {
		Http h = new Http();
		// Make sure to set the email to lowercase because that's the way Zendesk will return it
		String encodedEmail = EncodingUtil.urlEncode(email.toLowerCase(), 'UTF-8');
		HttpRequest queryReq = zapi.setupRequest('GET', '/api/v2/users/search.json?query=' + encodedEmail);

		HttpResponse res = new HttpResponse();
		if (!Test.isRunningTest()) {
			res = h.send(queryReq);
		} else {
			// fake response
			res = new HttpResponse();
			res.setStatusCode(200);
			res.setStatus('OK');
			res.setBody('{"users":[{"id":487705900,"url":"https://test.zendesk.com/api/v2/users/487705900.json","name":"Bob Smith","email":"foo@bar.com","created_at":"2014-07-02T22:03:28Z","updated_at":"2014-07-02T22:03:28Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null,"signature":null,"details":null,"notes":null,"custom_role_id":null,"moderator":false,"ticket_restriction":"requested","only_private_comments":false,"restricted_agent":true,"suspended":false}],"next_page":null,"previous_page":null,"count":1}');
		}
		System.debug('searchUser res: ' + res);
		String resBody = res.getBody();
		System.debug('searchUser res body: ' + resBody);

		ZendeskAPISchema.ZUser user = null;
		if (res.getStatusCode() == 200) {
			MultipleUsersWrapper wrapper = (MultipleUsersWrapper)JSON.deserialize(resBody, MultipleUsersWrapper.class);

			if (wrapper != null && wrapper.users != null) {
				for (ZendeskAPISchema.ZUser obj : wrapper.users) {
					if (obj.email != null && obj.email.equalsIgnoreCase(email)) {
						user = obj;
						break;
					}
				}
				// Testing support
				if (user == null && Test.isRunningTest()) {
					user = wrapper.users[0];
				}
			}
			// TODO: what if there are multiple pages?
		}

		return user;
	}
}
