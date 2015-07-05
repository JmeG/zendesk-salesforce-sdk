// This class provides common functionality to call the Zendesk API to interact with User Field records
public with sharing class ZendeskUserFields {

    private final ZendeskAPI zapi;
    private Map<String, ZUserField> userFieldsMap {get; private set; }

    public class ZUserField {
	    public Integer id {get;set;}
	    public String type {get;set;}
	    public String title {get;set;}
	    public String raw_title {get;set;}
	    public Boolean active {get;set;}
	    public ZCustomFieldOption[] custom_field_options {get;set;}

	    // Get the picklist "value" matching the provided name
	    public String getOptionValue(String optname) {
	        return getOptionValue(optname, false);
	    }

	    public String getOptionValue(String optname, Boolean errorIfNotFound) {
	        String val = null;
	        if (custom_field_options != null) {
	            for (ZCustomFieldOption fo : custom_field_options) {
	                if (fo.name.equalsIgnoreCase(optname)) {
	                    val = fo.value;
	                    break;
	                }
	            }
	        }

	        if (String.isEmpty(val) && errorIfNotFound) { throw new ZendeskException('Option value "' + optname + '" not found for field "' + this.title + '"'); }
	        return val;
	    }
	}

    public class ZCustomFieldOption {
		public Integer id {get;set;}
		public String name {get;set;}
		public String raw_name {get;set;}
		public String value {get;set;}
	}

    public class PagedUserFieldsWrapper {
        public ZUserField[] user_fields {get;set;}

        // "https://test.zendesk.com/api/v2/user_fields.json?page=2"
        public String next_page {get;set;}
        public Integer nextPageNumber {
            public get { return (String.isEmpty(next_page) ? null : Integer.valueOf(next_page.substringAfterLast('page=').substringBefore('&'))); }
            private set;
        }
    }

    private class UserFieldWrapper {
        public ZUserField user_field {get;set;}
    }

    public ZendeskUserFields(ZendeskAPI zapi) {
        this.zapi = zapi;
        userFieldsMap = new Map<String, ZUserField>();
    }

    // Retrieves all the custom ticket fields. Uses the field "raw_title" as the map key
    public Map<String, ZUserField> getAllFields() {
        if (userFieldsMap.isEmpty()) {
            loadAll();
        }
        return userFieldsMap;
    }

    public ZUserField getUserField(Integer userFieldId) {
        Http h = new Http();
        HttpRequest queryReq = zapi.setupRequest('GET', ZendeskAPI.BASE_PATH + '/user_fields/' + String.valueOf(userFieldId) + '.json');
        HttpResponse res = h.send(queryReq);
        System.debug('getUserField res: ' + res);
        String resBody = res.getBody();
        System.debug('resBody: ' + resBody);

        ZUserField userField = null;
        if (res.getStatusCode() == 200) {
            UserFieldWrapper wrapper = (UserFieldWrapper)JSON.deserialize(resBody, UserFieldWrapper.class);
            userField = wrapper.user_field;
        }

        return userField;
    }

    public ZUserField getUserField(String name) {
		// TODO: should we pre-load all ticket field pages?
        if (userFieldsMap.isEmpty()) {
            loadAll();
        }

        ZUserField obj = null;
        if (userFieldsMap.containsKey(name)) {
            obj = userFieldsMap.get(name);
        }

        return obj;
    }

    // Returns a list of all custom User Fields in your account. Fields are returned in the order
    // that you specify in your User Fields configuration in Zendesk. Clients should cache this
    // resource for the duration of their API usage and map the key for each User Field to the values
    // returned under the user_fields attribute on the User resource.
    private void loadAll() {
        PagedUserFieldsWrapper wrapper = getUserFields();
        System.debug('**wrapper=' + wrapper);
        if (wrapper != null && wrapper.user_fields != null) {
            for (ZUserField obj : wrapper.user_fields) {
                userFieldsMap.put(obj.raw_title, obj);
            }

            while (!String.isEmpty(wrapper.next_page)) {
            	System.debug('**wrapper.next_page=' + wrapper.next_page);
                wrapper = getUserFields(wrapper.nextPageNumber);
                for (ZUserField obj : wrapper.user_fields) {
                    userFieldsMap.put(obj.raw_title, obj);
                }
            }
        }
    }

    public PagedUserFieldsWrapper getUserFields() {
        return getUserFields(null);
    }

    public PagedUserFieldsWrapper getUserFields(Integer page) {
        Http h = new Http();
        HttpRequest queryReq = zapi.setupRequest('GET', ZendeskAPI.BASE_PATH + '/user_fields.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
        HttpResponse res = h.send(queryReq);
        System.debug('getUserFields res: ' + res);
        String resBody = res.getBody();
        System.debug('resBody: ' + resBody);

        PagedUserFieldsWrapper wrapper = null;
        if (res.getStatusCode() == 200) {
            wrapper = (PagedUserFieldsWrapper)JSON.deserialize(resBody, PagedUserFieldsWrapper.class);
        }

        return wrapper;
    }
}
