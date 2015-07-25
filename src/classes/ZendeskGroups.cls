// This class provides functionality to call the Zendesk Groups API
public class ZendeskGroups extends ZendeskResourceBase {

	private Map<Long, ZGroup> groupsMap;

	public class ZGroup {
		public Long id {get; private set;}
		public String name {get;set;}
		public Boolean deleted {get; private set;}
		public DateTime created_at {get; private set;}
		public DateTime updated_at {get; private set;}
	}

	public class GroupWrapper extends ZendeskSideLoadingBase {
		public ZGroup x_group {get;set;} // Use "x_group" in place of "group" which is a reserved keyword. Requires custom de/serialization.
	}

	public class GroupsWrapper extends ZendeskPagingBase {
		public List<ZGroup> groups {get;set;}
	}

	public ZendeskGroups(ZendeskAPI zapi) {
		super(zapi);
		groupsMap = new Map<Long, ZGroup>();
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

	// Get all assignable groups by page number
	public GroupsWrapper getAssignableGroups(Map<String, Object> queryParams) {
		return getGroupsInternal(zapi.createRequest('GET', '/groups/assignable.json', queryParams));
	}

	// Get the groups that a user is a member of
	public GroupsWrapper getUserGroups(Long userId) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

		return getUserGroups(userId, null);
	}

	// Get the groups that a user is a member of
	public GroupsWrapper getUserGroups(Long userId, Map<String, Object> queryParams) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

		return getGroupsInternal(zapi.createRequest('GET', '/users/'+userId+'/groups.json', queryParams));
	}

	// Private helper method to query multiple groups
	private GroupsWrapper getGroupsInternal(HttpRequest req) {
		return (GroupsWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), GroupsWrapper.class);
	}

	public GroupWrapper getGroup(Long groupId) {
		if (groupId == null) { throw new ZendeskException('groupId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/groups/'+groupId+'.json');
		return (GroupWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), GroupWrapper.class);
	}

	public Long createGroup(String name) {
		if (String.isBlank(name)) { throw new ZendeskException('name parameter must not be empty'); }

		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeFieldName('group');
		gen.writeStartObject();
		gen.writeObjectField('name', name);
		gen.writeEndObject();
		gen.writeEndObject();

		HttpRequest req = zapi.createRequest('POST', '/groups.json', gen.getAsString());
		GroupWrapper resultWrapper = (GroupWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), GroupWrapper.class);
		return ((resultWrapper==null || resultWrapper.x_group == null) ? null : resultWrapper.x_group.id);
	}

	public void updateGroupName(Long groupId, String newName) {
		if (groupId == null) { throw new ZendeskException('groupId parameter must not be null'); }
		if (String.isBlank(newName)) { throw new ZendeskException('name parameter must not be empty'); }

		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeFieldName('group');
		gen.writeStartObject();
		gen.writeObjectField('name', newName);
		gen.writeEndObject();
		gen.writeEndObject();

		HttpRequest req = zapi.createRequest('PUT', '/groups/'+groupId+'.json');
		req.setBody(gen.getAsString());
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

	// **currently not used. We'll use this if we serialize a ZGroup object for create/update calls
	// un-replace reserved keywords in the JSON string
    // Use when calling serialize()
	//private String unreplaceReservedWords(String str) {
	//	str = str.replaceAll('"x_group"\\s*:', '"group":');
	//	return str;
	//}
}
