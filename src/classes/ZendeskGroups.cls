// This class provides functionality to call the Zendesk Groups API
public with sharing class ZendeskGroups {

	private final ZendeskAPI zapi;
	private Map<Long, ZGroup> groupsMap;

	public class ZGroup {
		public Long id {get; private set;}
		public String name {get; set;}
		public Boolean deleted {get; private set;}
		public DateTime created_at {get; private set;}
		public DateTime updated_at {get; private set;}
	}

	private class GroupWrapper {
		public ZGroup x_group {get; set;} // Use "x_group" in place of "group" which is a reserved keyword. Requires custom de/serialization.
	}

	public class PagedGroupsWrapper {
		public ZGroup[] groups {get;set;}

		// Paging support
		public String next_page {get; set;}
		public Long nextPageNumber { get { return ZendeskAPI.getPageNumber(next_page); } private set; }
		public String previous_page {get; set;}
		public Long previousPageNumber { get { return ZendeskAPI.getPageNumber(previous_page); } private set; }
	}

	public ZendeskGroups(ZendeskAPI zapi) {
		this.zapi = zapi;
		groupsMap = new Map<Long, ZGroup>();
	}

	public PagedGroupsWrapper getGroups() {
		return getGroups(null);
	}

	public PagedGroupsWrapper getGroups(Long page) {
		HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/groups.json' + (page==null ? '' : '?page=' + page));
		HttpResponse res = new Http().send(queryReq);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error getting Groups (' + res.getStatusCode() + ')');
		}

		PagedGroupsWrapper wrapper = (PagedGroupsWrapper)JSON.deserialize(replaceReservedWords(res.getBody()), PagedGroupsWrapper.class);
		return wrapper;
	}

	public ZGroup getGroup(Long groupId) {
		HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/groups/' + groupId + '.json');
		HttpResponse res = new Http().send(req);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error getting Group ' + groupId + ' (' + res.getStatusCode() + ')');
		}

		// use replaceReservedWords to work around JSON containing Salesforce keyword "group"
		GroupWrapper resultWrapper = (GroupWrapper)JSON.deserialize(replaceReservedWords(res.getBody()), GroupWrapper.class);
		return resultWrapper.x_group;
	}

	public void deleteGroup(Long groupId) {
		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/groups/' + groupId + '.json');
		HttpResponse res = new Http().send(req);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error deleting Group ' + groupId + ' (' + res.getStatusCode() + ')');
		}
	}

	// Retrieves all pages of groups. Uses the Group field "id" as the map key
	public Map<Long, ZGroup> getAllGroups() {
		if (groupsMap.isEmpty()) {
			loadAll();
		}
		return groupsMap;
	}

	private void loadAll() {
		PagedGroupsWrapper wrapper = getGroups();
		if (wrapper != null && wrapper.groups != null) {
			for (ZGroup obj : wrapper.groups) {
				groupsMap.put(obj.id, obj);
			}

			while (!String.isEmpty(wrapper.next_page)) {
				wrapper = getGroups(wrapper.nextPageNumber);
				for (ZGroup obj : wrapper.groups) {
					groupsMap.put(obj.id, obj);
				}
			}
		}
	}

	// replace reserved keywords in the JSON string and map them to field names prefixed with "x_"
	private String replaceReservedWords(String str) {
		str = str.replaceAll('"group"\\s*:', '"x_group":');
		return str;
	}

	// un-replace reserved keywords in the JSON string
	private String unreplaceReservedWords(String str) {
		str = str.replaceAll('"x_group"\\s*:', '"group":');
		return str;
	}
}
