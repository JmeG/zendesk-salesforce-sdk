// This class provides functionality to call the Zendesk Groups API
public class ZendeskGroupsAPI extends ZendeskResourceBase {

	private Map<Long, ZGroup> groupsMap;

	public class GroupWrapper extends ZendeskSideLoadingBase {
		public ZGroup x_group {get;set;} // Use "x_group" in place of "group" which is a reserved keyword. Requires custom de/serialization.
		public GroupWrapper(ZGroup x_group) { this.x_group = x_group; }
	}

	public class GroupsWrapper extends ZendeskPagingBase {
		public List<ZGroup> groups {get;set;}
		public GroupsWrapper(List<ZGroup> groups) { this.groups = groups; }
	}

	public ZendeskGroupsAPI(ZendeskAPI zapi) {
		super(zapi);
		groupsMap = new Map<Long, ZGroup>();
	}

	public GroupWrapper getGroup(Long groupId) {
		if (groupId == null) { throw new ZendeskException('groupId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/groups/'+groupId+'.json');
		return (GroupWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), GroupWrapper.class);
	}

	public GroupsWrapper getGroups() {
		return getGroups(null);
	}
	public GroupsWrapper getGroups(Map<String, Object> queryParams) {
		return getGroupsInternal(zapi.createRequest('GET', '/groups.json', queryParams));
	}

	// Get all assignable groups
	public GroupsWrapper getAssignableGroups() {
		return getAssignableGroups(null);
	}
	public GroupsWrapper getAssignableGroups(Map<String, Object> queryParams) {
		return getGroupsInternal(zapi.createRequest('GET', '/groups/assignable.json', queryParams));
	}

	// Get the groups that a user is a member of
	public GroupsWrapper getUserGroups(Long userId) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

		return getUserGroups(userId, null);
	}
	public GroupsWrapper getUserGroups(Long userId, Map<String, Object> queryParams) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

		return getGroupsInternal(zapi.createRequest('GET', '/users/'+userId+'/groups.json', queryParams));
	}

	// Private helper method to query multiple groups
	private GroupsWrapper getGroupsInternal(HttpRequest req) {
		return (GroupsWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), GroupsWrapper.class);
	}

	// Simplified createGroup method that takes the only relevant parameter "name"
	public Long createGroup(String name) {
		if (String.isBlank(name)) { throw new ZendeskException('name parameter must not be empty'); }

		ZGroup g = new ZGroup();
		g.name = name;
		return createGroup(g);
	}

	public Long createGroup(ZGroup x_group) {
		if (x_group == null) { throw new ZendeskException('x_group parameter must not be null'); }

		HttpRequest req = zapi.createRequest('POST', '/groups.json');
		req.setBody(stripJsonNulls(unreplaceReservedWords(JSON.serialize(new GroupWrapper(x_group)))));
		GroupWrapper resultWrapper = (GroupWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), GroupWrapper.class);
		return ((resultWrapper==null || resultWrapper.x_group == null) ? null : resultWrapper.x_group.id);
	}

	// Simplified method for updating a group name
	public void updateGroupName(Long groupId, String newName) {
		if (groupId == null) { throw new ZendeskException('groupId parameter must not be null'); }
		if (String.isBlank(newName)) { throw new ZendeskException('newName parameter must not be empty'); }

		ZGroup g = new ZGroup();
		g.name = newName;
		updateGroup(groupId, g);
	}

	public void updateGroup(Long groupId, ZGroup x_group) {
		if (x_group == null) { throw new ZendeskException('x_group parameter must not be null'); }

		HttpRequest req = zapi.createRequest('PUT', '/groups/'+groupId+'.json');
		req.setBody(stripJsonNulls(unreplaceReservedWords(JSON.serialize(new GroupWrapper(x_group)))));
		zapi.sendRequest(req);
	}

	public void deleteGroup(Long groupId) {
		if (groupId == null) { throw new ZendeskException('groupId parameter must not be null'); }

		zapi.sendRequest(zapi.createRequest('DELETE', '/groups/'+groupId+'.json'));
	}

	// Retrieves all pages of groups. Uses the Group field "id" as the map key
	public Map<Long, ZGroup> getAllGroups() {
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

	// replace reserved keywords in the JSON string and map them to field names prefixed with "x_"
    // Use when calling deserialize()
	private String replaceReservedWords(String str) {
		str = str.replaceAll('"group"\\s*:', '"x_group":');
		return str;
	}

	// un-replace reserved keywords in the JSON string
    // Use when calling serialize()
	private String unreplaceReservedWords(String str) {
		str = str.replaceAll('"x_group"\\s*:', '"group":');
		return str;
	}
}
