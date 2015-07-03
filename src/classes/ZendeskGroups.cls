// This class provides common functionality to call the Zendesk API to interact with Group records
public with sharing class ZendeskGroups {

    private final ZendeskAPI zapi;
    private Map<String, ZendeskAPISchema.ZGroup> resultsMap;

    private class ResultsWrapper {
        public ZendeskAPISchema.ZGroup[] groups {get;set;}

        // "https://support.zendesk.com/api/v2/groups.json?page=2"
        public String next_page {get;set;}
        public Integer nextPageNumber {
            public get { return (String.isEmpty(next_page) ? null : Integer.valueOf(next_page.substringAfterLast('page=').substringBefore('&'))); }
            private set;
        }
    }

    public ZendeskGroups(ZendeskAPI zapi) {
        this.zapi = zapi;
        resultsMap = new Map<String, ZendeskAPISchema.ZGroup>();
    }

    public ZendeskAPISchema.ZGroup getGroup(String name) {
        if (resultsMap.isEmpty()) {
            loadAll();
        }

        ZendeskAPISchema.ZGroup obj = null;
        if (resultsMap.containsKey(name)) {
            obj = resultsMap.get(name);
        }

        // Testing support
        if (Test.isRunningTest() && obj == null) {
            obj = resultsMap.get('Test');
        }

        return obj;
    }

    private void loadAll() {
        ResultsWrapper wrapper = getGroups();
        System.debug('**wrapper=' + wrapper);
        if (wrapper != null && wrapper.groups != null) {
            for (ZendeskAPISchema.ZGroup obj : wrapper.groups) {
                resultsMap.put(obj.name, obj);
            }

            while (!String.isEmpty(wrapper.next_page)) {
            	System.debug('**wrapper.next_page=' + wrapper.next_page);
                wrapper = getGroups(wrapper.nextPageNumber);
                for (ZendeskAPISchema.ZGroup obj : wrapper.groups) {
                    resultsMap.put(obj.name, obj);
                }
            }
        }
    }

    private ResultsWrapper getGroups() {
        return getGroups(null);
    }

    private ResultsWrapper getGroups(Integer page) {
        Http h = new Http();
        HttpRequest queryReq = zapi.setupRequest('GET', '/api/v2/groups.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
        HttpResponse res = new HttpResponse();
        if (!Test.isRunningTest()) {
            res = h.send(queryReq);
        } else {
            // fake response
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            if (page == null) {
                res.setBody('{ "groups": [ { "url": "https://support.zendesk.com/api/v2/groups/21641528.json", "id": 21641528, "name": "Test", "deleted": false, "created_at": "2014-03-07T22:59:22Z", "updated_at": "2014-03-07T22:59:22Z" } ], "next_page": "https://support.zendesk.com/api/v2/groups.json?page=2", "previous_page": null, "count": 1 }');
            } else {
                res.setBody('{ "groups": [ { "url": "https://support.zendesk.com/api/v2/groups/21641528.json", "id": 21641528, "name": "Test", "deleted": false, "created_at": "2014-03-07T22:59:22Z", "updated_at": "2014-03-07T22:59:22Z" } ], "next_page": null, "previous_page": null, "count": 1 }');
            }
        }
        System.debug('getGroups res: ' + res);
        String resBody = res.getBody();
        System.debug('resBody: ' + resBody);

        ResultsWrapper wrapper = null;
        if (res.getStatusCode() == 200) {
            wrapper = (ResultsWrapper)JSON.deserialize(resBody, ResultsWrapper.class);
        }

        return wrapper;
    }
}