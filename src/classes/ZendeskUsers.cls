// This class provides functionality to call the Zendesk API to interact with User records
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

		// Paging support
		public String next_page {get; set;}
		public Integer nextPageNumber { get { return ZendeskAPI.getPageNumber(next_page); } private set; }
		public String previous_page {get; set;}
		public Integer previousPageNumber { get { return ZendeskAPI.getPageNumber(previous_page); } private set; }
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
		UserWrapper wrapper = new UserWrapper();
		wrapper.user = zuser;

		HttpRequest req = zapi.createRequest('POST', ZendeskAPI.BASE_PATH + '/users.json');
		String reqBody = JSON.serialize(wrapper);
		req.setBody(reqBody);
		HttpResponse res = new Http().send(req);
		String resBody = res.getBody();

		if (res.getStatusCode() != 201) {
			throw new ZendeskException('Error creating User (' + res.getStatusCode() + ')');
		}

		// Deserialize the response into a concrete class
		UserWrapper resultWrapper = (UserWrapper)JSON.deserialize(resBody, UserWrapper.class);

		return ((resultWrapper==null || resultWrapper.user == null) ? null : resultWrapper.user.id);
	}

	public Integer getUserIdByEmail(String email) {
		ZUser user = findUserByEmail(email);
		return (user == null ? null : user.id);
	}

	// This can be a partial or complete Name or Email address
	public PagedUsersWrapper findUsersByNameOrEmail(String nameOrEmail) {
		String encodedNameOrEmail = EncodingUtil.urlEncode(nameOrEmail, 'UTF-8');
		HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/users/search.json?query=' + encodedNameOrEmail);
		HttpResponse res = new Http().send(queryReq);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error searching users (' + res.getStatusCode() + ')');
		}

		// Deserialize the response into a concrete class
		PagedUsersWrapper wrapper = (PagedUsersWrapper)JSON.deserialize(resBody, PagedUsersWrapper.class);

		return wrapper;
	}

	public ZUser findUserByEmail(String email) {
		// Make sure to set the email to lowercase because that's the way Zendesk will return it
		String encodedEmail = EncodingUtil.urlEncode(email.toLowerCase(), 'UTF-8');
		HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/users/search.json?query=' + encodedEmail);
		HttpResponse res = new Http().send(queryReq);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error searching users (' + res.getStatusCode() + ')');
		}

		// Deserialize the response into a concrete class
		PagedUsersWrapper wrapper = (PagedUsersWrapper)JSON.deserialize(resBody, PagedUsersWrapper.class);

		ZUser user = null;
		if (wrapper != null && wrapper.users != null) {
			for (ZUser obj : wrapper.users) {
				if (obj.email != null && obj.email.equalsIgnoreCase(email)) {
					user = obj;
					break;
				}
			}
		}

		return user;
	}

	public PagedUsersWrapper getUsers() {
        return getUsers(null);
    }

	// TODO: does paging exist for Users endpoing?
    public PagedUsersWrapper getUsers(Integer page) {
        HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/users.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
        HttpResponse res = new Http().send(queryReq);
        String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error getting users (' + res.getStatusCode() + ')');
		}

		// Deserialize the response into a concrete class
        PagedUsersWrapper wrapper = (PagedUsersWrapper)JSON.deserialize(resBody, PagedUsersWrapper.class);

        return wrapper;
    }

	public ZUser getUser(Integer userId) {
        HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/users/' + String.valueOf(userId) + '.json');
        HttpResponse res = new Http().send(queryReq);
        String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error getting user ' + userId + ' (' + res.getStatusCode() + ')');
		}

		// Deserialize the response into a concrete class
        UserWrapper wrapper = (UserWrapper)JSON.deserialize(resBody, UserWrapper.class);

        return wrapper.user;
    }

	public ZUser getCurrentUser() {
        HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/users/me.json');
        HttpResponse res = new Http().send(queryReq);
        String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error getting current user (' + res.getStatusCode() + ')');
		}

		// Deserialize the response into a concrete class
        UserWrapper wrapper = (UserWrapper)JSON.deserialize(resBody, UserWrapper.class);

        return wrapper.user;
    }
}
