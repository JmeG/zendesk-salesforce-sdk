// This class provides functionality to call the Zendesk API to interact with Group records
public with sharing class ZendeskGroups {

    private final ZendeskAPI zapi;
    private Map<String, ZGroup> groupsMap;

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
        groupsMap = new Map<String, ZGroup>();
    }

    // Retrieves all the groups. Uses the field "name" as the map key
	public Map<String, ZGroup> getAllGroups() {
        if (groupsMap.isEmpty()) {
            loadAll();
        }
        return groupsMap;
    }

    // non-native API method
    // Return the first Group where the name matches the "name" parameter
    public ZGroup getGroup(String name) {
		// TODO: should we fetch all pages?
        if (groupsMap.isEmpty()) {
            loadAll();
        }

        ZGroup obj = null;
        if (groupsMap.containsKey(name)) {
            obj = groupsMap.get(name);
        }

        return obj;
    }

    private void loadAll() {
        PagedGroupsWrapper wrapper = getGroups();
        if (wrapper != null && wrapper.groups != null) {
            for (ZGroup obj : wrapper.groups) {
                groupsMap.put(obj.name, obj);
            }

            while (!String.isEmpty(wrapper.next_page)) {
                wrapper = getGroups(wrapper.nextPageNumber);
                for (ZGroup obj : wrapper.groups) {
                    groupsMap.put(obj.name, obj);
                }
            }
        }
    }

    public PagedGroupsWrapper getGroups() {
        return getGroups(null);
    }

    public PagedGroupsWrapper getGroups(Integer page) {
        HttpRequest queryReq = zapi.setupRequest('GET', ZendeskAPI.BASE_PATH + '/groups.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
        HttpResponse res = new Http().send(queryReq);
        String resBody = res.getBody();

        PagedGroupsWrapper wrapper = null;
        if (res.getStatusCode() == 200) {
            // Deserialize the response into a typed class
            wrapper = (PagedGroupsWrapper)JSON.deserialize(resBody, PagedGroupsWrapper.class);
        }

        return wrapper;
    }

    public void deleteGroup(Integer groupId) {
		HttpRequest req = zapi.setupRequest('DELETE', ZendeskAPI.BASE_PATH + '/groups/' + String.valueOf(groupId) + '.json');
		HttpResponse res = new Http().send(req);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error occurred trying to delete group ' + groupId);
		}
	}
}
