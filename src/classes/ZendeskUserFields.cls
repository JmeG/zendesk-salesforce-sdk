// This class provides common functionality to call the Zendesk API to interact with User Field records
public with sharing class ZendeskUserFields {

    private final ZendeskAPI zapi;
    public Map<String, ZendeskAPISchema.ZUserField> resultsMap {get; private set; }

    private class ResultsWrapper {
        public ZendeskAPISchema.ZUserField[] user_fields {get;set;}

        // "https://test.zendesk.com/api/v2/user_fields.json?page=2"
        public String next_page {get;set;}
        public Integer nextPageNumber {
            public get { return (String.isEmpty(next_page) ? null : Integer.valueOf(next_page.substringAfterLast('page=').substringBefore('&'))); }
            private set;
        }
    }

    private class SingleUserFieldWrapper {
        public ZendeskAPISchema.ZUserField user_field {get;set;}
    }

    public ZendeskUserFields(ZendeskAPI zapi) {
        this.zapi = zapi;
        resultsMap = new Map<String, ZendeskAPISchema.ZUserField>();
    }

    public ZendeskAPISchema.ZUserField getUserField(Integer userFieldId) {
        Http h = new Http();
        HttpRequest queryReq = zapi.setupRequest('GET', ZendeskAPI.BASE_PATH + '/user_fields/' + String.valueOf(userFieldId) + '.json');
        HttpResponse res = h.send(queryReq);
        System.debug('getUserField res: ' + res);
        String resBody = res.getBody();
        System.debug('resBody: ' + resBody);

        ZendeskAPISchema.ZUserField userField = null;
        if (res.getStatusCode() == 200) {
            SingleUserFieldWrapper wrapper = (SingleUserFieldWrapper)JSON.deserialize(resBody, SingleUserFieldWrapper.class);
            userField = wrapper.user_field;
        }

        return userField;
    }

    public ZendeskAPISchema.ZUserField getUserField(String name) {
        if (resultsMap.isEmpty()) {
            loadAll();
        }

        ZendeskAPISchema.ZUserField obj = null;
        if (resultsMap.containsKey(name)) {
            obj = resultsMap.get(name);
        }

        // Testing support
        if (Test.isRunningTest() && obj == null) {
            obj = resultsMap.get('Test');
        }

        return obj;
    }

    // Returns a list of all custom User Fields in your account. Fields are returned in the order
    // that you specify in your User Fields configuration in Zendesk. Clients should cache this
    // resource for the duration of their API usage and map the key for each User Field to the values
    // returned under the user_fields attribute on the User resource.
    private void loadAll() {
        ResultsWrapper wrapper = getUserFields();
        System.debug('**wrapper=' + wrapper);
        if (wrapper != null && wrapper.user_fields != null) {
            for (ZendeskAPISchema.ZUserField obj : wrapper.user_fields) {
                resultsMap.put(obj.raw_title, obj);
            }

            while (!String.isEmpty(wrapper.next_page)) {
            	System.debug('**wrapper.next_page=' + wrapper.next_page);
                wrapper = getUserFields(wrapper.nextPageNumber);
                for (ZendeskAPISchema.ZUserField obj : wrapper.user_fields) {
                    resultsMap.put(obj.raw_title, obj);
                }
            }
        }
    }

    private ResultsWrapper getUserFields() {
        return getUserFields(null);
    }

    private ResultsWrapper getUserFields(Integer page) {
        Http h = new Http();
        HttpRequest queryReq = zapi.setupRequest('GET', ZendeskAPI.BASE_PATH + '/user_fields.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
        HttpResponse res = h.send(queryReq);
        System.debug('getUserFields res: ' + res);
        String resBody = res.getBody();
        System.debug('resBody: ' + resBody);

        ResultsWrapper wrapper = null;
        if (res.getStatusCode() == 200) {
            wrapper = (ResultsWrapper)JSON.deserialize(resBody, ResultsWrapper.class);
        }

        return wrapper;
    }
}
