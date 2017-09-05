// This class provides functionality to call the Zendesk Groups API
global class ZendeskGroupsAPI extends ZendeskResourceBase {

    private Map<Long, ZGroup> groupsMap;

    global class GroupWrapper extends ZendeskSideLoadingBase {
        global ZGroup x_group {get;set;} // Use "x_group" in place of "group" which is a reserved keyword. Requires custom de/serialization.
        global GroupWrapper(ZGroup x_group) { this.x_group = x_group; }
    }

    global class GroupsWrapper extends ZendeskPagingBase {
        global List<ZGroup> groups {get;set;}
        global GroupsWrapper(List<ZGroup> groups) { this.groups = groups; }
    }

    global ZendeskGroupsAPI(ZendeskConnection zconn) {
        super(zconn);
        groupsMap = new Map<Long, ZGroup>();
    }

    global GroupWrapper getGroup(Long groupId) {
        if (groupId == null) { throw new ZendeskException('groupId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest(
            HTTP_GET,
            '/groups/'+groupId+'.json'
        );
        return (GroupWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), GroupWrapper.class);
    }

    global GroupsWrapper getGroups() {
        return getGroups(null);
    }
    global GroupsWrapper getGroups(Map<String, Object> queryParams) {
        return getGroupsInternal(zconn.createRequest(
            HTTP_GET,
            '/groups.json',
            queryParams
        ));
    }

    // Get all assignable groups
    global GroupsWrapper getAssignableGroups() {
        return getAssignableGroups(null);
    }
    global GroupsWrapper getAssignableGroups(Map<String, Object> queryParams) {
        return getGroupsInternal(zconn.createRequest(
            HTTP_GET,
            '/groups/assignable.json',
            queryParams
        ));
    }

    // Get the groups that a user is a member of
    global GroupsWrapper getUserGroups(Long userId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }

        return getUserGroups(userId, null);
    }
    global GroupsWrapper getUserGroups(Long userId, Map<String, Object> queryParams) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }

        return getGroupsInternal(zconn.createRequest(
            HTTP_GET,
            '/users/'+userId+'/groups.json',
            queryParams
        ));
    }

    // Private helper method to query multiple groups
    private GroupsWrapper getGroupsInternal(HttpRequest req) {
        return (GroupsWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), GroupsWrapper.class);
    }

    // Simplified createGroup method that takes the only relevant parameter "name"
    global Long createGroup(String name) {
        if (String.isBlank(name)) { throw new ZendeskException('name parameter must not be empty'); }

        ZGroup g = new ZGroup();
        g.name = name;
        return createGroup(g);
    }

    global Long createGroup(ZGroup x_group) {
        if (x_group == null) { throw new ZendeskException('x_group parameter cannot be null'); }

        HttpRequest req = zconn.createRequest(
            HTTP_POST,
            '/groups.json',
            JSON.serialize(new GroupWrapper(x_group), true)
        );
        GroupWrapper resultWrapper = (GroupWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), GroupWrapper.class);
        return ((resultWrapper==null || resultWrapper.x_group == null) ? null : resultWrapper.x_group.id);
    }

    // Simplified method for updating a group name
    global void updateGroupName(Long groupId, String newName) {
        if (groupId == null) { throw new ZendeskException('groupId parameter cannot be null'); }
        if (String.isBlank(newName)) { throw new ZendeskException('newName parameter must not be empty'); }

        ZGroup g = new ZGroup();
        g.name = newName;
        updateGroup(groupId, g);
    }

    global void updateGroup(Long groupId, ZGroup x_group) {
        if (x_group == null) { throw new ZendeskException('x_group parameter cannot be null'); }

        HttpRequest req = zconn.createRequest(
            HTTP_PUT,
            '/groups/'+groupId+'.json',
            JSON.serialize(new GroupWrapper(x_group), true)
        );
        zconn.sendRequest(req);
    }

    global void deleteGroup(Long groupId) {
        if (groupId == null) { throw new ZendeskException('groupId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest(
            HTTP_DELETE,
            '/groups/'+groupId+'.json'
        ));
    }

    // Retrieves all pages of groups. Uses the Group field "id" as the map key
    global Map<Long, ZGroup> getAllGroups() {
        if (groupsMap.isEmpty()) {
            loadAll();
        }
        return groupsMap;
    }

    // Automatically loop through all the pages in the getGroups() response
    private void loadAll() {
        GroupsWrapper wrapper = getGroups();
        if (wrapper != null && wrapper.groups != null) {
            for (ZGroup obj : wrapper.groups) {
                groupsMap.put(obj.id, obj);
            }

            while (!String.isEmpty(wrapper.next_page)) {
                wrapper = getGroups(new Map<String, Object>{'page'=>wrapper.nextPageNumber});
                for (ZGroup obj : wrapper.groups) {
                    groupsMap.put(obj.id, obj);
                }
            }
        }
    }
}
