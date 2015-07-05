// This class provides common functionality to call the Zendesk API to interact with Group records
public with sharing class ZendeskGroups {

    private final ZendeskAPI zapi;
    private Map<String, ZGroup> groupsMap;

    public class ZGroup {
		public Integer id {get;set;}
		public String name {get;set;}
	}

    public class PagedGroupsWrapper {
        public ZGroup[] groups {get;set;}

        // "https://test.zendesk.com/api/v2/groups.json?page=2"
        public String next_page {get;set;}
        public Integer nextPageNumber {
            public get { return (String.isEmpty(next_page) ? null : Integer.valueOf(next_page.substringAfterLast('page=').substringBefore('&'))); }
            private set;
        }
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

    public ZGroup getGroup(String name) {
		// TODO: should we pre-load all ticket field pages?
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
        System.debug('**wrapper=' + wrapper);
        if (wrapper != null && wrapper.groups != null) {
            for (ZGroup obj : wrapper.groups) {
                groupsMap.put(obj.name, obj);
            }

            while (!String.isEmpty(wrapper.next_page)) {
            	System.debug('**wrapper.next_page=' + wrapper.next_page);
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
        Http h = new Http();
        HttpRequest queryReq = zapi.setupRequest('GET', ZendeskAPI.BASE_PATH + '/groups.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
        HttpResponse res = h.send(queryReq);
        System.debug('getGroups res: ' + res);
        String resBody = res.getBody();
        System.debug('resBody: ' + resBody);

        PagedGroupsWrapper wrapper = null;
        if (res.getStatusCode() == 200) {
            wrapper = (PagedGroupsWrapper)JSON.deserialize(resBody, PagedGroupsWrapper.class);
        }

        return wrapper;
    }
}
