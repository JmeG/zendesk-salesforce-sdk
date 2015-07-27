// This class provides functionality to call the Zendesk Users API
// *************************************
// TODO: Implement the following methods
// POST   /api/v2/users/{user_id}/password.json
// PUT    /api/v2/users/{user_id}/password.json
// PUT    /api/v2/users/me/merge.json
public class ZendeskUsersAPI extends ZendeskResourceBase {

	public class UserWrapper extends ZendeskSideLoadingBase {
		public ZUser user {get;set;}
		public UserWrapper(ZUser user) { this.user = user; }
	}

	public class UsersWrapper extends ZendeskPagingBase {
		public List<ZUser> users {get;set;}
		public UsersWrapper(List<ZUser> users) { this.users = users; }
	}

	public ZendeskUsersAPI(ZendeskAPI zapi) {
		super(zapi);
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

		HttpRequest req = zapi.createRequest('POST', '/users.json');
		req.setBody(stripJsonNulls(JSON.serialize(new UserWrapper(zuser))));
		UserWrapper resultWrapper = (UserWrapper)JSON.deserialize(zapi.sendRequest(req), UserWrapper.class);
		return ((resultWrapper==null || resultWrapper.user == null) ? null : resultWrapper.user.id);
	}

	public ZendeskTypes.ZJobStatus createUsers(List<ZUser> zusers) {
        if (zusers == null || zusers.isEmpty()) { throw new ZendeskException('zusers parameter must not be null or empty'); }
        HttpRequest req = zapi.createRequest('POST', '/users/create_many.json');
        req.setBody(stripJsonNulls(JSON.serialize(new UsersWrapper(zusers))));
        return (ZendeskTypes.ZJobStatus)JSON.deserialize(zapi.sendRequest(req), ZendeskTypes.ZJobStatus.class);
    }

	public void updateUser(Long userId, ZUser zuser) {
		if (zuser == null) { throw new ZendeskException('zuser parameter must not be null'); }

		HttpRequest req = zapi.createRequest('PUT', '/users/'+userId+'.json');
		req.setBody(stripJsonNulls(JSON.serialize(new UserWrapper(zuser))));
		zapi.sendRequest(req);
	}

	public ZendeskTypes.ZJobStatus updateUsers(List<ZUser> zusers) {
		if (zusers == null || zusers.isEmpty()) { throw new ZendeskException('zusers parameter must not be null or empty'); }
		for (ZUser zuser : zusers) {
			if (zuser.id == null && String.isEmpty(zuser.external_id)) { throw new ZendeskException('Each user must have either an id or external_id populated'); }
		}

		HttpRequest req = zapi.createRequest('PUT', '/users/update_many.json');
		req.setBody(stripJsonNulls(JSON.serialize(new UsersWrapper(zusers))));
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zapi.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public ZendeskTypes.ZJobStatus updateUsers(Set<Long> userIds, ZUser zuser) {
		if (userIds == null || userIds.isEmpty()) { throw new ZendeskException('userIds parameter must not be null or empty'); }
        if (zuser == null) { throw new ZendeskException('zuser parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', '/users/update_many.json?ids=' + toCSV(userIds));
		req.setBody(stripJsonNulls(JSON.serialize(new UserWrapper(zuser))));
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zapi.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public ZendeskTypes.ZJobStatus updateUsers(Set<String> externalIds, ZUser zuser) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter must not be null or empty'); }
		if (zuser == null) { throw new ZendeskException('zuser parameter must not be null'); }

		HttpRequest req = zapi.createRequest('PUT', '/users/update_many.json?external_ids=' + toCSV(externalIds));
		req.setBody(stripJsonNulls(JSON.serialize(new UserWrapper(zuser))));
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zapi.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public void mergeUsers(Long sourceUserId, Long targetUserId) {
		if (sourceUserId == null) { throw new ZendeskException('sourceUserId parameter must not be null'); }
		if (targetUserId == null) { throw new ZendeskException('targetUserId parameter must not be null'); }

		ZUser u = new ZUser();
		u.id = targetUserId;

		HttpRequest req = zapi.createRequest('PUT', '/users/'+sourceUserId+'/merge.json');
		req.setBody(stripJsonNulls(JSON.serialize(new UserWrapper(u))));
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

		HttpRequest req = zapi.createRequest('GET', '/users/search.json?query=' + urlEncode(nameOrEmail));
		return (UsersWrapper)JSON.deserialize(zapi.sendRequest(req), UsersWrapper.class);
	}

	public ZUser findUserByEmail(String email) {
		if (String.isBlank(email)) { throw new ZendeskException('email parameter must not be empty'); }

		// Set the email to lowercase because that's how Zendesk stores it
		String resBody = zapi.sendRequest(zapi.createRequest('GET', '/users/search.json', new Map<String, Object>{'query'=>urlEncode(email.toLowerCase())}));
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

	public UserWrapper getUser(Long userId) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/users/'+userId+'.json');
        return (UserWrapper)JSON.deserialize(zapi.sendRequest(req), UserWrapper.class);
    }

	public ZUser getCurrentUser() {
        HttpRequest req = zapi.createRequest('GET', '/users/me.json');
        UserWrapper wrapper = (UserWrapper)JSON.deserialize(zapi.sendRequest(req), UserWrapper.class);
        return wrapper.user;
    }

	public Map<String, Object> getUserRelatedInfo(Long userId) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/users/'+userId+'/related.json');
		return (Map<String, Object>)JSON.deserializeUntyped(zapi.sendRequest(req));
	}

	// /api/v2/users.json
	public UsersWrapper getUsers() {
        return getUsersHelper(zapi.createRequest('GET', '/users.json'));
    }
    public UsersWrapper getUsers(Map<String, Object> queryParams) {
        return getUsersHelper(zapi.createRequest('GET', '/users.json', queryParams));
    }

	public UsersWrapper getUsersByIds(Set<Long> userIds) {
		if (userIds == null || userIds.isEmpty()) { throw new ZendeskException('userIds parameter must not be null or empty'); }

        return getUsersHelper(zapi.createRequest('GET', '/users/show_many.json', new Map<String, Object>{'ids'=>toCSV(userIds)}));
    }

	public UsersWrapper getUsersByExternalIds(Set<String> externalIds) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter must not be null or empty'); }

        return getUsersHelper(zapi.createRequest('GET', '/users/show_many.json', new Map<String, Object>{'external_ids'=>toCSV(externalIds)}));
    }

	public UsersWrapper getUsersByGroup(Long groupId) {
		return getUsersByGroup(groupId, null);
    }
	public UsersWrapper getUsersByGroup(Long groupId, Map<String, Object> queryParams) {
		if (groupId == null) { throw new ZendeskException('groupId parameter must not be null'); }

        return getUsersHelper(zapi.createRequest('GET', '/groups/'+groupId+'/users.json', queryParams));
    }

	public UsersWrapper getUsersByOrganization(Long orgId) {
		return getUsersByOrganization(orgId, null);
    }
	public UsersWrapper getUsersByOrganization(Long orgId, Map<String, Object> queryParams) {
		if (orgId == null) { throw new ZendeskException('orgId parameter must not be null'); }

        return getUsersHelper(zapi.createRequest('GET', '/organizations/'+orgId+'/users.json', queryParams));
    }

	public UsersWrapper getUsers(String autoCompleteName) {
		if (String.isBlank(autoCompleteName) || autoCompleteName.length() < 2) { throw new ZendeskException('autoCompleteName parameter must at least 2 characters'); }

        return getUsersHelper(zapi.createRequest('GET', '/users/autocomplete.json', new Map<String, Object>{'name'=>urlEncode(autoCompleteName)}));
    }

	public UsersWrapper searchUsers(String externalId) {
		if (String.isBlank(externalId)) { throw new ZendeskException('externalId parameter must not be null or empty'); }

        return getUsersHelper(zapi.createRequest('GET', '/users/search.json', new Map<String, Object>{'external_id'=>urlEncode(externalId)}));
    }

	// Helper method for getting Users
	private UsersWrapper getUsersHelper(HttpRequest req) {
        return (UsersWrapper)JSON.deserialize(zapi.sendRequest(req), UsersWrapper.class);
    }

	public void deleteUser(Long userId) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

		zapi.sendRequest(zapi.createRequest('DELETE', '/users/'+userId+'.json'));
	}

	public void deleteUsers(Set<Long> userIds) {
		if (userIds == null || userIds.isEmpty()) { throw new ZendeskException('userIds parameter must not be null or empty'); }

		zapi.sendRequest(zapi.createRequest('DELETE', '/users/destroy_many.json', new Map<String, Object>{'ids'=>toCSV(userIds)}));
	}

	public void deleteUsers(Set<String> externalIds) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter must not be null or empty'); }

		zapi.sendRequest(zapi.createRequest('DELETE', '/users/destroy_many.json', new Map<String, Object>{'external_ids'=>toCSV(externalIds)}));
	}
}
