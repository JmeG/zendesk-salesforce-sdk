// This class provides functionality to call the Zendesk Users API
// Currently supports the following API endpoints:
// GET    /api/v2/users.json
// GET    /api/v2/users/{id}.json
// GET    /api/v2/users/search.json?query={query}
// GET    /api/v2/users/me.json
// GET    /api/v2/users/show_many.json?ids={ids}
// GET    /api/v2/users/show_many.json?external_ids={external_ids}
// GET    /api/v2/organizations/{id}/users.json
// GET    /api/v2/groups/{id}/users.json
// GET    /api/v2/users/{id}/related.json
// GET    /api/v2/users/search.json?external_id={external_id}
// GET    /api/v2/users/autocomplete.json?name={name}
// POST   /api/v2/users.json
// POST   /api/v2/users/create_many.json
// PUT    /api/v2/users/{id}.json
// PUT    /api/v2/users/{id}/merge.json
// PUT    /api/v2/users/update_many.json
// PUT    /api/v2/users/update_many.json?ids={ids}
// PUT    /api/v2/users/update_many.json?external_ids={external_ids}
// DELETE /api/v2/users/destroy_many.json?ids={ids}
// DELETE /api/v2/users/destroy_many.json?external_ids={external_ids}
// DELETE /api/v2/users/{id}.json
// *************************************
// TODO: Implement the following methods
// POST   /api/v2/users/{user_id}/password.json
// PUT    /api/v2/users/{user_id}/password.json
// PUT    /api/v2/users/me/merge.json
public class ZendeskUsers {

	private final ZendeskAPI zapi;

	public class ZUser {
		public Long id {get;set;}
		public String name {get;set;}
		public String email {get;set;}
		public String phone {get;set;}
		public String external_id {get;set;}
		public String alias {get;set;}
		public Boolean verified {get;set;}
		public String role {get;set;}
		public Long organization_id {get;set;}
		public Map<String, String> user_fields {get;set;}
		public Boolean active {get; private set;}
		public DateTime last_login_at {get; private set;}
		public DateTime created_at {get; private set;}
		public DateTime updated_at {get; private set;}
	}

	public class UsersWrapper extends ZendeskPagingSupport {
		public List<ZUser> users {get;set;}
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

		HttpRequest req = zapi.createRequest('POST', '/users.json');
		String reqBody = JSON.serialize(wrapper);
		req.setBody(reqBody);
		String resBody = zapi.sendRequest(req);

		UserWrapper resultWrapper = (UserWrapper)JSON.deserialize(resBody, UserWrapper.class);
		return ((resultWrapper==null || resultWrapper.user == null) ? null : resultWrapper.user.id);
	}

	public ZendeskJobStatuses.JobStatus createUsers(List<ZUser> zusers) {
        if (zusers == null || zusers.isEmpty()) { throw new ZendeskException('zusers parameter must not be null or empty'); }

        HttpRequest req = zapi.createRequest('POST', '/users/create_many.json');
        req.setBody('{ "users": ' + ZendeskAPI.stripJsonNulls(JSON.serialize(zusers)) + '}');
		String resBody = zapi.sendRequest(req);

        return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
    }

	public void updateUser(Long userId, ZUser zuser) {
		if (zuser == null) { throw new ZendeskException('zuser parameter must not be null'); }

		HttpRequest req = zapi.createRequest('PUT', '/users/' + userId + '.json');
		req.setBody('{ "user": ' + ZendeskAPI.stripJsonNulls(JSON.serialize(zuser)) + '}');
		zapi.sendRequest(req);
	}

	public ZendeskJobStatuses.JobStatus updateUsers(List<ZUser> zusers) {
		if (zusers == null || zusers.isEmpty()) { throw new ZendeskException('zusers parameter must not be null or empty'); }
		for (ZUser zuser : zusers) {
			if (zuser.id == null && String.isEmpty(zuser.external_id)) { throw new ZendeskException('Each user must have either an id or external_id populated'); }
		}

		HttpRequest req = zapi.createRequest('PUT', '/users/update_many.json');
		req.setBody('{ "users": ' + ZendeskAPI.stripJsonNulls(JSON.serialize(zusers)) + ' }');
		String resBody = zapi.sendRequest(req);

		return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
	}

	public ZendeskJobStatuses.JobStatus updateUsers(Set<Long> userIds, ZUser zuser) {
		if (userIds == null || userIds.isEmpty()) { throw new ZendeskException('userIds parameter must not be null or empty'); }
        if (zuser == null) { throw new ZendeskException('zuser parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', '/users/update_many.json?ids=' + ZendeskAPI.toCSV(userIds));
		req.setBody('{ "user": ' + ZendeskAPI.stripJsonNulls(JSON.serialize(zuser)) + ' }');
		String resBody = zapi.sendRequest(req);

		return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
	}

	public ZendeskJobStatuses.JobStatus updateUsers(Set<String> externalIds, ZUser zusers) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter must not be null or empty'); }
		if (zusers == null) { throw new ZendeskException('zusers parameter must not be null'); }

		HttpRequest req = zapi.createRequest('PUT', '/users/update_many.json?external_ids=' + ZendeskAPI.toCSV(externalIds));
		req.setBody('{ "user": ' + ZendeskAPI.stripJsonNulls(JSON.serialize(zusers)) + ' }');
		String resBody = zapi.sendRequest(req);

		return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
	}

	public void mergeUsers(Long sourceUserId, Long targetUserId) {
		if (sourceUserId == null) { throw new ZendeskException('sourceUserId parameter must not be null'); }
		if (targetUserId == null) { throw new ZendeskException('targetUserId parameter must not be null'); }

		ZUser u = new ZUser();
		u.id = targetUserId;

		HttpRequest req = zapi.createRequest('PUT', '/users/' + sourceUserId + '/merge.json');
		req.setBody('{ "user": ' + ZendeskAPI.stripJsonNulls(JSON.serialize(u)) + '}');
		zapi.sendRequest(req);
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
		HttpRequest req = zapi.createRequest('GET', '/users/search.json?query=' + encodedNameOrEmail);
		String resBody = zapi.sendRequest(req);

		return (UsersWrapper)JSON.deserialize(resBody, UsersWrapper.class);
	}

	public ZUser findUserByEmail(String email) {
		if (String.isBlank(email)) { throw new ZendeskException('email parameter must not be empty'); }

		// Make sure to set the email to lowercase because that's the way Zendesk will return it
		String encodedEmail = EncodingUtil.urlEncode(email.toLowerCase(), 'UTF-8');
		HttpRequest req = zapi.createRequest('GET', '/users/search.json?query=' + encodedEmail);
		String resBody = zapi.sendRequest(req);

		UsersWrapper wrapper = (UsersWrapper)JSON.deserialize(resBody, UsersWrapper.class);
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
        HttpRequest req = zapi.createRequest('GET', '/users.json');
        return getUsers(req);
    }

    public UsersWrapper getUsers(Long page) {
        HttpRequest req = zapi.createRequest('GET', '/users.json' + (page==null ? '' : '?page=' + page));
        return getUsers(req);
    }

	public UsersWrapper getUsersByIds(Set<Long> userIds) {
		if (userIds == null || userIds.isEmpty()) { throw new ZendeskException('userIds parameter must not be null or empty'); }

        HttpRequest req = zapi.createRequest('GET', '/users/show_many.json?ids=' + ZendeskAPI.toCSV(userIds));
        return getUsers(req);
    }

	public UsersWrapper getUsersByExternalIds(Set<String> externalIds) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter must not be null or empty'); }

        HttpRequest req = zapi.createRequest('GET', '/users/show_many.json?external_ids=' + ZendeskAPI.toCSV(externalIds));
        return getUsers(req);
    }

	public UsersWrapper getUsersByGroup(Long groupId) {
		if (groupId == null) { throw new ZendeskException('groupId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/groups/' + groupId + '/users.json');
        return getUsers(req);
    }

	public UsersWrapper getUsersByOrganization(Long orgId) {
		if (orgId == null) { throw new ZendeskException('orgId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/organizations/' + orgId + '/users.json');
        return getUsers(req);
    }

	public UsersWrapper getUsers(String autoCompleteName) {
		if (String.isBlank(autoCompleteName) || autoCompleteName.length() < 2) { throw new ZendeskException('autoCompleteName parameter must at least 2 characters'); }

        HttpRequest req = zapi.createRequest('GET', '/users/autocomplete.json?name=' + autoCompleteName);
        return getUsers(req);
    }

	public UsersWrapper searchUsers(String externalId) {
		if (String.isBlank(externalId)) { throw new ZendeskException('externalId parameter must not be null or empty'); }

        HttpRequest req = zapi.createRequest('GET', '/users/search.json?external_id=' + externalId);
        return getUsers(req);
    }

	// Helper method for getting Users
	private UsersWrapper getUsers(HttpRequest req) {
        String resBody = zapi.sendRequest(req);

        return (UsersWrapper)JSON.deserialize(resBody, UsersWrapper.class);
    }

	public ZUser getUser(Long userId) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/users/' + userId + '.json');
        String resBody = zapi.sendRequest(req);

        UserWrapper wrapper = (UserWrapper)JSON.deserialize(resBody, UserWrapper.class);
        return wrapper.user;
    }

	public ZUser getCurrentUser() {
        HttpRequest req = zapi.createRequest('GET', '/users/me.json');
        String resBody = zapi.sendRequest(req);

        UserWrapper wrapper = (UserWrapper)JSON.deserialize(resBody, UserWrapper.class);
        return wrapper.user;
    }

	public Map<String, Object> getUserRelatedInfo(Long userId) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/users/' + userId + '/related.json');
        String resBody = zapi.sendRequest(req);

		return (Map<String, Object>)JSON.deserializeUntyped(resBody);
	}

	public void deleteUser(Long userId) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('DELETE', '/users/' + userId + '.json');
		zapi.sendRequest(req);
	}

	public void deleteUsers(Set<Long> userIds) {
		if (userIds == null || userIds.isEmpty()) { throw new ZendeskException('userIds parameter must not be null or empty'); }

		HttpRequest req = zapi.createRequest('DELETE', '/users/destroy_many.json?ids=' + ZendeskAPI.toCSV(userIds));
		zapi.sendRequest(req);
	}

	public void deleteUsers(Set<String> externalIds) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter must not be null or empty'); }

		HttpRequest req = zapi.createRequest('DELETE', '/users/destroy_many.json?external_ids=' + ZendeskAPI.toCSV(externalIds));
		zapi.sendRequest(req);
	}
}
