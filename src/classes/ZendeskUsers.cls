// This class provides functionality to call the Zendesk Users API
// Currently supports the following API endpoints:
// GET    /api/v2/users.json
// GET    /api/v2/users/{id}.json
// POST   /api/v2/users.json
// GET    /api/v2/users/search.json?query={query}
// GET    /api/v2/users/me.json
// *************************************
// TODO: Implement the following methods
// GET    /api/v2/groups/{id}/users.json
// GET    /api/v2/organizations/{id}/users.json
// GET    /api/v2/users/show_many.json?ids={ids}
// GET    /api/v2/users/show_many.json?external_ids={external_ids}
// GET    /api/v2/users/{id}/related.json
// GET    /api/v2/users/search.json?external_id={external_id}
// GET    /api/v2/users/autocomplete.json?name={name}
// POST   /api/v2/users/create_many.json
// POST   /api/v2/users/{user_id}/password.json
// PUT    /api/v2/users/{user_id}/password.json
// PUT    /api/v2/users/me/merge.json
// PUT    /api/v2/users/{id}/merge.json
// PUT    /api/v2/users/{id}.json
// PUT    /api/v2/users/update_many.json
// PUT    /api/v2/users/update_many.json?ids={ids}
// PUT    /api/v2/users/update_many.json?external_ids={external_ids}
// DELETE /api/v2/users/destroy_many.json?ids={ids}
// DELETE /api/v2/users/destroy_many.json?external_ids={external_ids}
// DELETE /api/v2/users/{id}.json
public with sharing class ZendeskUsers {

	private final ZendeskAPI zapi;

	public class ZUser {
		public Long id {get; private set;}
		public String name {get; set;}
		public String email {get; set;}
		public String phone {get; set;}
		public String external_id {get; set;}
		public String alias {get; set;}
		public Boolean active {get; private set;}
		public Boolean verified {get; set;}
		public String role {get; set;}
		public DateTime last_login_at {get; private set;}
		public Long organization_id {get; set;}
		public DateTime created_at {get; private set;}
		public DateTime updated_at {get; private set;}
		public Map<String, String> user_fields {get; set;}
	}

	public class UsersWrapper {
		public ZUser[] users {get;set;}

		// Paging support
		public String next_page {get; set;}
		public Long nextPageNumber { get { return ZendeskAPI.getPageNumber(next_page); } private set; }
		public String previous_page {get; set;}
		public Long previousPageNumber { get { return ZendeskAPI.getPageNumber(previous_page); } private set; }
	}

	// Used to deserialize the result of a User create/update API call
	private class UserWrapper {
		public ZUser user {get;set;}
	}

	public ZendeskUsers(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

	public Long createUser(String name, String email) {
		if (String.isBlank(name)) { throw new ZendeskException('name parameter must not be empty'); }
		if (String.isBlank(email)) { throw new ZendeskException('email parameter must not be empty'); }

		ZUser zuser = new ZUser();
		zuser.name = name;
		zuser.email = email;

		return createUser(zuser);
	}

	public Long createUser(ZUser zuser) {
		if (zuser == null) { throw new ZendeskException('zuser parameter must not be null'); }

		UserWrapper wrapper = new UserWrapper();
		wrapper.user = zuser;

		HttpRequest req = zapi.createRequest('POST', ZendeskAPI.BASE_PATH + '/users.json');
		String reqBody = JSON.serialize(wrapper);
		req.setBody(reqBody);
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error creating User (' + res.getStatusCode() + ')');
		}

		UserWrapper resultWrapper = (UserWrapper)JSON.deserialize(res.getBody(), UserWrapper.class);
		// return the ID of the new user
		return ((resultWrapper==null || resultWrapper.user == null) ? null : resultWrapper.user.id);
	}

	public Long getUserIdByEmail(String email) {
		if (String.isBlank(email)) { throw new ZendeskException('email parameter must not be empty'); }

		ZUser user = findUserByEmail(email);
		return (user == null ? null : user.id);
	}

	// This can be a partial or complete Name or Email address
	public UsersWrapper findUsersByNameOrEmail(String nameOrEmail) {
		if (String.isBlank(nameOrEmail)) { throw new ZendeskException('nameOrEmail parameter must not be empty'); }

		String encodedNameOrEmail = EncodingUtil.urlEncode(nameOrEmail, 'UTF-8');
		HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/users/search.json?query=' + encodedNameOrEmail);
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error searching Users (' + res.getStatusCode() + ')');
		}

		UsersWrapper wrapper = (UsersWrapper)JSON.deserialize(res.getBody(), UsersWrapper.class);
		return wrapper;
	}

	public ZUser findUserByEmail(String email) {
		if (String.isBlank(email)) { throw new ZendeskException('email parameter must not be empty'); }

		// Make sure to set the email to lowercase because that's the way Zendesk will return it
		String encodedEmail = EncodingUtil.urlEncode(email.toLowerCase(), 'UTF-8');
		HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/users/search.json?query=' + encodedEmail);
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error searching Users (' + res.getStatusCode() + ')');
		}

		UsersWrapper wrapper = (UsersWrapper)JSON.deserialize(res.getBody(), UsersWrapper.class);
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

	public UsersWrapper getUsers() {
        return getUsers(null);
    }

    public UsersWrapper getUsers(Long page) {
        HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/users.json' + (page==null ? '' : '?page=' + page));
        HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error getting Users (' + res.getStatusCode() + ')');
		}

        UsersWrapper wrapper = (UsersWrapper)JSON.deserialize(res.getBody(), UsersWrapper.class);
        return wrapper;
    }

	public ZUser getUser(Long userId) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/users/' + userId + '.json');
        HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error getting User ' + userId + ' (' + res.getStatusCode() + ')');
		}

        UserWrapper wrapper = (UserWrapper)JSON.deserialize(res.getBody(), UserWrapper.class);
        return wrapper.user;
    }

	public ZUser getCurrentUser() {
        HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/users/me.json');
        HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error getting current User (' + res.getStatusCode() + ')');
		}

        UserWrapper wrapper = (UserWrapper)JSON.deserialize(res.getBody(), UserWrapper.class);
        return wrapper.user;
    }
}
