// This class provides common functionality to call the Zendesk API to interact with User records
public with sharing class ZendeskUsers {

	private final ZendeskAPI zapi;

	public class ZUser {
		public Integer id {get; private set;}
		public String name {get; set;}
		public String email {get; set;}
		public String phone {get; set;}
		public String external_id {get; set;}
		public String alias {get; set;}
		public Boolean active {get; private set;}
		public Boolean verified {get; set;}
		public String role {get; set;}
		public DateTime last_login_at {get; private set;}
		public Integer organization_id {get; set;}
		public DateTime created_at {get; private set;}
		public DateTime updated_at {get; private set;}
		public Map<String, String> user_fields {get; set;}
	}

	public class PagedUsersWrapper {
		public ZUser[] users {get;set;}

		// "https://test.zendesk.com/api/v2/users.json?page=2"
		public String next_page {get;set;}
		public Integer nextPageNumber {
			public get { return (String.isEmpty(next_page) ? null : Integer.valueOf(next_page.substringAfterLast('page=').substringBefore('&'))); }
			private set;
		}
	}

	// Used to deserialize the result of a User create/update API call
	private class UserWrapper {
		public ZUser user {get;set;}
	}

	public ZendeskUsers(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

	public Integer createUser(String name, String email) {
		ZUser zuser = new ZUser();
		zuser.name = name;
		zuser.email = email;

		return createUser(zuser);
	}

	public Integer createUser(ZUser zuser) {
		Http h = new Http();
		HttpRequest req = zapi.setupRequest('POST', ZendeskAPI.BASE_PATH + '/users.json');

		UserWrapper wrapper = new UserWrapper();
		wrapper.user = zuser;
		String reqBody = JSON.serialize(wrapper);
		System.debug('**** json string = ' + reqBody);
		req.setBody(reqBody);

		HttpResponse res = h.send(req);
		System.debug('createUser res: ' + res);
		String resBody = res.getBody();
		System.debug('createUser res body: ' + resBody);

		if (res.getStatusCode() != 201) {
			throw new ZendeskException('Error occurred trying to create user.');
		}

		UserWrapper resultWrapper = (UserWrapper)JSON.deserialize(resBody, UserWrapper.class);
		System.debug('zuserResult=' + resultWrapper);

		return ((resultWrapper==null || resultWrapper.user == null) ? null : resultWrapper.user.id);
	}

	public Integer getUserIdByEmail(String email) {
		ZUser user = findUserByEmail(email);
		return (user == null ? null : user.id);
	}

	// This can be a partial or complete Name or Email address
	public PagedUsersWrapper findUsersByNameOrEmail(String nameOrEmail) {
		Http h = new Http();
		String encodedNameOrEmail = EncodingUtil.urlEncode(nameOrEmail, 'UTF-8');
		HttpRequest queryReq = zapi.setupRequest('GET', ZendeskAPI.BASE_PATH + '/users/search.json?query=' + encodedNameOrEmail);

		HttpResponse res = h.send(queryReq);
		System.debug('findUsersByNameOrEmail res: ' + res);
		String resBody = res.getBody();
		System.debug('findUsersByNameOrEmail res body: ' + resBody);

		PagedUsersWrapper wrapper = null;
		if (res.getStatusCode() == 200) {
			wrapper = (PagedUsersWrapper)JSON.deserialize(resBody, PagedUsersWrapper.class);
		} else {
			throw new ZendeskException('Error searching users (' + res.getStatusCode() + ')');
		}

		return wrapper;
	}

	public ZUser findUserByEmail(String email) {
		Http h = new Http();
		// Make sure to set the email to lowercase because that's the way Zendesk will return it
		String encodedEmail = EncodingUtil.urlEncode(email.toLowerCase(), 'UTF-8');
		HttpRequest queryReq = zapi.setupRequest('GET', ZendeskAPI.BASE_PATH + '/users/search.json?query=' + encodedEmail);

		HttpResponse res = h.send(queryReq);
		System.debug('findUserByEmail res: ' + res);
		String resBody = res.getBody();
		System.debug('findUserByEmail res body: ' + resBody);

		ZUser user = null;
		if (res.getStatusCode() == 200) {
			PagedUsersWrapper wrapper = (PagedUsersWrapper)JSON.deserialize(resBody, PagedUsersWrapper.class);

			if (wrapper != null && wrapper.users != null) {
				for (ZUser obj : wrapper.users) {
					if (obj.email != null && obj.email.equalsIgnoreCase(email)) {
						user = obj;
						break;
					}
				}
			}
			// TODO: what if there are multiple pages?
		}

		return user;
	}

	public PagedUsersWrapper getUsers() {
        return getUsers(null);
    }

    public PagedUsersWrapper getUsers(Integer page) {
        Http h = new Http();
        HttpRequest queryReq = zapi.setupRequest('GET', ZendeskAPI.BASE_PATH + '/users.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
        HttpResponse res = h.send(queryReq);
        String resBody = res.getBody();
		System.debug('getUsers response: ' + resBody);

        PagedUsersWrapper wrapper = null;
        if (res.getStatusCode() == 200) {
            wrapper = (PagedUsersWrapper)JSON.deserialize(resBody, PagedUsersWrapper.class);
        }

        return wrapper;
    }
}
