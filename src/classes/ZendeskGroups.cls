// This class provides functionality to call the Zendesk Groups API
public with sharing class ZendeskGroups {

	private final ZendeskAPI zapi;
	private Map<Integer, ZGroup> groupsMap;

	public class ZGroup {
		public Integer id {get; private set;}
		public String name {get; set;}
		public Boolean deleted {get; private set;}
		public DateTime created_at {get; private set;}
		public DateTime updated_at {get; private set;}
	}

	public class PagedGroupsWrapper {
		public ZGroup[] groups {get;set;}

		// Paging support
		public String next_page {get; set;}
		public Integer nextPageNumber { get { return ZendeskAPI.getPageNumber(next_page); } private set; }
		public String previous_page {get; set;}
		public Integer previousPageNumber { get { return ZendeskAPI.getPageNumber(previous_page); } private set; }
	}

	public ZendeskGroups(ZendeskAPI zapi) {
		this.zapi = zapi;
		groupsMap = new Map<Integer, ZGroup>();
	}

	public PagedGroupsWrapper getGroups() {
		return getGroups(null);
	}

	public PagedGroupsWrapper getGroups(Integer page) {
		HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/groups.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
		HttpResponse res = new Http().send(queryReq);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error getting Groups (' + res.getStatusCode() + ')');
		}

		// Deserialize the response into a concrete class
		PagedGroupsWrapper wrapper = (PagedGroupsWrapper)JSON.deserialize(resBody, PagedGroupsWrapper.class);

		return wrapper;
	}

	public ZGroup getGroup(Integer groupId) {
		HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/groups/' + String.valueOf(groupId) + '.json');
		HttpResponse res = new Http().send(req);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error getting Group ' + groupId + ' (' + res.getStatusCode() + ')');
		}

		// NOTE: We can't deserialize the response directly into a concrete class because "group"
		// is a Salesforce keyword so we can't define a class that has "group" as a parameter name
		// Here is our workaround
		ZGroup zgroupObj = null;
		Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(resBody);
		if (objMap.containsKey('group')) {
			zgroupObj = (ZGroup)JSON.deserialize(JSON.serialize(objMap.get('group')), ZGroup.class);
		} else {
			throw new ZendeskException('Unexpected content in Group response');
		}

		return zgroupObj;
	}

	public void deleteGroup(Integer groupId) {
		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/groups/' + String.valueOf(groupId) + '.json');
		HttpResponse res = new Http().send(req);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error deleting Group ' + groupId + ' (' + res.getStatusCode() + ')');
		}
	}

	// Retrieves all pages of groups. Uses the Group field "id" as the map key
	public Map<Integer, ZGroup> getAllGroups() {
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
}
