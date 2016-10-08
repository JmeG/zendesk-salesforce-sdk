// This class provides functionality to call the Zendesk Users API
// *************************************
// TODO: Implement the following methods
// POST  /api/v2/users/{user_id}/password.json
// PUT   /api/v2/users/{user_id}/password.json
// PUT   /api/v2/users/me/merge.json
global class ZendeskUsersAPI extends ZendeskResourceBase {

    global class UserWrapper extends ZendeskSideLoadingBase {
        global ZUser user {get;set;}
        global UserWrapper(ZUser user) { this.user = user; }
    }

    global class UsersWrapper extends ZendeskPagingBase {
        global List<ZUser> users {get;set;}
        global UsersWrapper(List<ZUser> users) { this.users = users; }
    }

    global ZendeskUsersAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    global Long createUser(String name, String email) {
        if (String.isBlank(name)) { throw new ZendeskException('name parameter must not be empty'); }
        if (String.isBlank(email)) { throw new ZendeskException('email parameter must not be empty'); }

        ZUser zuser = new ZUser();
        zuser.name = name;
        zuser.email = email;

        return createUser(zuser);
    }

    global Long createUser(ZUser zuser) {
        if (zuser == null) { throw new ZendeskException('zuser parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('POST', '/users.json');
        req.setBody(stripJsonNulls(JSON.serialize(new UserWrapper(zuser))));
        UserWrapper resultWrapper = (UserWrapper)JSON.deserialize(zconn.sendRequest(req), UserWrapper.class);
        return ((resultWrapper==null || resultWrapper.user == null) ? null : resultWrapper.user.id);
    }

    global ZendeskTypes.ZJobStatus createUsers(List<ZUser> zusers) {
        if (zusers == null || zusers.isEmpty()) { throw new ZendeskException('zusers parameter cannot be null or empty'); }

        HttpRequest req = zconn.createRequest('POST', '/users/create_many.json');
        req.setBody(stripJsonNulls(JSON.serialize(new UsersWrapper(zusers))));
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    global void updateUser(Long userId, ZUser zuser) {
        if (zuser == null) { throw new ZendeskException('zuser parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/users/'+userId+'.json');
        req.setBody(stripJsonNulls(JSON.serialize(new UserWrapper(zuser))));
        zconn.sendRequest(req);
    }

    global ZendeskTypes.ZJobStatus updateUsers(List<ZUser> zusers) {
        if (zusers == null || zusers.isEmpty()) { throw new ZendeskException('zusers parameter cannot be null or empty'); }
        for (ZUser zuser : zusers) {
            if (zuser.id == null && String.isEmpty(zuser.external_id)) { throw new ZendeskException('Each user must have either an id or external_id populated'); }
        }

        HttpRequest req = zconn.createRequest('PUT', '/users/update_many.json');
        req.setBody(stripJsonNulls(JSON.serialize(new UsersWrapper(zusers))));
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    global ZendeskTypes.ZJobStatus updateUsers(Set<Long> userIds, ZUser zuser) {
        if (userIds == null || userIds.isEmpty()) { throw new ZendeskException('userIds parameter cannot be null or empty'); }
        if (zuser == null) { throw new ZendeskException('zuser parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/users/update_many.json?ids=' + toCSV(userIds));
        req.setBody(stripJsonNulls(JSON.serialize(new UserWrapper(zuser))));
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    global ZendeskTypes.ZJobStatus updateUsers(Set<String> externalIds, ZUser zuser) {
        if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter cannot be null or empty'); }
        if (zuser == null) { throw new ZendeskException('zuser parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/users/update_many.json?external_ids=' + toCSV(externalIds));
        req.setBody(stripJsonNulls(JSON.serialize(new UserWrapper(zuser))));
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    global void mergeUsers(Long sourceUserId, Long targetUserId) {
        if (sourceUserId == null) { throw new ZendeskException('sourceUserId parameter cannot be null'); }
        if (targetUserId == null) { throw new ZendeskException('targetUserId parameter cannot be null'); }

        ZUser u = new ZUser();
        u.id = targetUserId;

        HttpRequest req = zconn.createRequest('PUT', '/users/'+sourceUserId+'/merge.json');
        req.setBody(stripJsonNulls(JSON.serialize(new UserWrapper(u))));
        zconn.sendRequest(req);
    }

    global Long getUserIdByEmail(String email) {
        if (String.isBlank(email)) { throw new ZendeskException('email parameter must not be empty'); }

        ZUser user = findUserByEmail(email);
        return (user == null ? null : user.id);
    }

    // This can be a partial or complete Name or Email address
    global UsersWrapper findUsersByNameOrEmail(String nameOrEmail) {
        if (String.isBlank(nameOrEmail)) { throw new ZendeskException('nameOrEmail parameter must not be empty'); }

        HttpRequest req = zconn.createRequest('GET', '/users/search.json?query=' + urlEncode(nameOrEmail));
        return (UsersWrapper)JSON.deserialize(zconn.sendRequest(req), UsersWrapper.class);
    }

    global ZUser findUserByEmail(String email) {
        if (String.isBlank(email)) { throw new ZendeskException('email parameter must not be empty'); }

        String resBody = zconn.sendRequest(zconn.createRequest('GET', '/users/search.json', new Map<String, Object>{'query'=>urlEncode(email)}));
        UsersWrapper wrapper = (UsersWrapper)JSON.deserialize(resBody, UsersWrapper.class);
        ZUser user = null;
        if (wrapper != null && wrapper.users != null) {
            // Look for a user with an exact email match
            for (ZUser u : wrapper.users) {
                if (u.email != null && u.email.equalsIgnoreCase(email)) {
                    user = u;
                    break;
                }
            }
        }

        return user;
    }

    global UserWrapper getUser(Long userId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/users/'+userId+'.json');
        return (UserWrapper)JSON.deserialize(zconn.sendRequest(req), UserWrapper.class);
    }

    global ZUser getCurrentUser() {
        HttpRequest req = zconn.createRequest('GET', '/users/me.json');
        UserWrapper wrapper = (UserWrapper)JSON.deserialize(zconn.sendRequest(req), UserWrapper.class);
        return wrapper.user;
    }

    global Map<String, Object> getUserRelatedInfo(Long userId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/users/'+userId+'/related.json');
        return (Map<String, Object>)JSON.deserializeUntyped(zconn.sendRequest(req));
    }

    // /api/v2/users.json
    global UsersWrapper getUsers() {
        return getUsersHelper(zconn.createRequest('GET', '/users.json'));
    }
    global UsersWrapper getUsers(Map<String, Object> queryParams) {
        return getUsersHelper(zconn.createRequest('GET', '/users.json', queryParams));
    }

    global UsersWrapper getUsersByIds(Set<Long> userIds) {
        if (userIds == null || userIds.isEmpty()) { throw new ZendeskException('userIds parameter cannot be null or empty'); }

        return getUsersHelper(zconn.createRequest('GET', '/users/show_many.json', new Map<String, Object>{'ids'=>toCSV(userIds)}));
    }

    global UsersWrapper getUsersByExternalIds(Set<String> externalIds) {
        if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter cannot be null or empty'); }

        return getUsersHelper(zconn.createRequest('GET', '/users/show_many.json', new Map<String, Object>{'external_ids'=>toCSV(externalIds)}));
    }

    global UsersWrapper getUsersByGroup(Long groupId) {
        return getUsersByGroup(groupId, null);
    }
    global UsersWrapper getUsersByGroup(Long groupId, Map<String, Object> queryParams) {
        if (groupId == null) { throw new ZendeskException('groupId parameter cannot be null'); }

        return getUsersHelper(zconn.createRequest('GET', '/groups/'+groupId+'/users.json', queryParams));
    }

    global UsersWrapper getUsersByOrganization(Long orgId) {
        return getUsersByOrganization(orgId, null);
    }
    global UsersWrapper getUsersByOrganization(Long orgId, Map<String, Object> queryParams) {
        if (orgId == null) { throw new ZendeskException('orgId parameter cannot be null'); }

        return getUsersHelper(zconn.createRequest('GET', '/organizations/'+orgId+'/users.json', queryParams));
    }

    global UsersWrapper autocompleteSearch(String name) {
        if (String.isBlank(name) || name.length() < 2) { throw new ZendeskException('name parameter must at least 2 characters'); }

        return getUsersHelper(zconn.createRequest('GET', '/users/autocomplete.json', new Map<String, Object>{'name'=>urlEncode(name)}));
    }

    global UsersWrapper searchUsersByExternalId(String externalId) {
        if (String.isBlank(externalId)) { throw new ZendeskException('externalId parameter cannot be null or empty'); }

        return getUsersHelper(zconn.createRequest('GET', '/users/search.json', new Map<String, Object>{'external_id'=>urlEncode(externalId)}));
    }

    // Helper method for getting Users
    private UsersWrapper getUsersHelper(HttpRequest req) {
        return (UsersWrapper)JSON.deserialize(zconn.sendRequest(req), UsersWrapper.class);
    }

    global void deleteUser(Long userId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest('DELETE', '/users/'+userId+'.json'));
    }

    global void deleteUsers(Set<Long> userIds) {
        if (userIds == null || userIds.isEmpty()) { throw new ZendeskException('userIds parameter cannot be null or empty'); }

        zconn.sendRequest(zconn.createRequest('DELETE', '/users/destroy_many.json', new Map<String, Object>{'ids'=>toCSV(userIds)}));
    }

    global void deleteUsers(Set<String> externalIds) {
        if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter cannot be null or empty'); }

        zconn.sendRequest(zconn.createRequest('DELETE', '/users/destroy_many.json', new Map<String, Object>{'external_ids'=>toCSV(externalIds)}));
    }
}
