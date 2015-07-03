// This class provides common functionality to call the Zendesk API to interact with User Field records
public with sharing class ZendeskUserFields {

    private final ZendeskAPI zapi;
    public Map<String, ZendeskAPISchema.ZUserField> resultsMap {get; private set; }

    private class ResultsWrapper {
        public ZendeskAPISchema.ZUserField[] user_fields {get;set;}

        // "https://support.zendesk.com/api/v2/user_fields.json?page=2"
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
        HttpRequest queryReq = zapi.setupRequest('GET', '/api/v2/user_fields/' + String.valueOf(userFieldId) + '.json');
        HttpResponse res = new HttpResponse();
        if (!Test.isRunningTest()) {
            res = h.send(queryReq);
        } else {
            // fake response
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "user_field": { "url": "https://support.zendesk.com/api/v2/user_fields/21778153.json", "id": 21778153, "type": "tagger", "title": "Zendesk Plan", "raw_title": "Zendesk Plan", "description": "", "raw_description": "", "position": 7, "active": true, "required": false, "collapsed_for_agents": false, "regexp_for_validation": null, "title_in_portal": "Zendesk Plan", "raw_title_in_portal": "Zendesk Plan", "visible_in_portal": false, "editable_in_portal": false, "required_in_portal": false, "tag": null, "created_at": "2012-10-19T01:01:32Z", "updated_at": "2014-11-08T10:47:55Z", "removable": true, "custom_field_options": [ { "id": 21332256, "name": "Test", "raw_name": "Test", "value": "zdplan_test" } ] } } ');
        }
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
        HttpRequest queryReq = zapi.setupRequest('GET', '/api/v2/user_fields.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
        HttpResponse res = new HttpResponse();
        if (!Test.isRunningTest()) {
            res = h.send(queryReq);
        } else {
            // fake response
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            if (page == null) {
                res.setBody('{ "user_fields": [ { "url": "https://support.zendesk.com/api/v2/user_fields/23164018.json", "id": 23164018, "type": "text", "title": "Test", "raw_title": "Test", "description": "Test", "raw_description": "Test", "position": 9999, "active": false, "required": false, "collapsed_for_agents": false, "regexp_for_validation": null, "title_in_portal": "Test", "raw_title_in_portal": "Test", "visible_in_portal": false, "editable_in_portal": false, "required_in_portal": false, "tag": null, "created_at": "2013-08-28T05:57:11Z", "updated_at": "2013-08-29T07:11:23Z", "removable": true } ], "next_page": "https://support.zendesk.com/api/v2/user_fields.json?page=2", "previous_page": null, "count": 1 }');
            } else {
                res.setBody('{ "user_fields": [ { "url": "https://support.zendesk.com/api/v2/user_fields/23164018.json", "id": 23164018, "type": "text", "title": "Test", "raw_title": "Test", "description": "Test", "raw_description": "Test", "position": 9999, "active": false, "required": false, "collapsed_for_agents": false, "regexp_for_validation": null, "title_in_portal": "Test", "raw_title_in_portal": "Test", "visible_in_portal": false, "editable_in_portal": false, "required_in_portal": false, "tag": null, "created_at": "2013-08-28T05:57:11Z", "updated_at": "2013-08-29T07:11:23Z", "removable": true } ], "next_page": null, "previous_page": null, "count": 1 }');
            }
		}
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
