// This class provides functionality to call the Zendesk User Fields API
// Currently upports the following API endpoints:
// GET    /api/v2/user_fields.json
// GET    /api/v2/user_fields/{id}.json
// DELETE /api/v2/user_fields/{id}.json
// *************************************
// TODO: Implement the following methods
// POST   /api/v2/user_fields.json
// PUT    /api/v2/user_fields/{id}.json
// PUT    /api/v2/user_fields/reorder.json
public with sharing class ZendeskUserFields {

    private final ZendeskAPI zapi;
    private Map<String, ZUserField> userFieldsMap {get; private set; }

    public class ZUserField {
	    public Long id {get; private set;}
        public String key {get; set;}
	    public String type {get; set;}
	    public String title {get; set;}
	    public String raw_title {get; set;}
	    public Boolean active {get; set;}
		public DateTime created_at {get; private set;}
		public DateTime updated_at {get; private set;}
	    public ZCustomFieldOption[] custom_field_options {get; set;}

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
		public Long id {get; set;}
		public String name {get; set;}
		public String raw_name {get; set;}
		public String value {get; set;}
	}

    public class PagedUserFieldsWrapper {
        public ZUserField[] user_fields {get; set;}

        // Paging support
		public String next_page {get; set;}
		public Long nextPageNumber { get { return ZendeskAPI.getPageNumber(next_page); } private set; }
		public String previous_page {get; set;}
		public Long previousPageNumber { get { return ZendeskAPI.getPageNumber(previous_page); } private set; }
    }

    private class UserFieldWrapper {
        public ZUserField user_field {get; set;}
    }

    public ZendeskUserFields(ZendeskAPI zapi) {
        this.zapi = zapi;
        userFieldsMap = new Map<String, ZUserField>();
    }

    public ZUserField getUserField(Long userFieldId) {
		if (userFieldId == null) { throw new ZendeskException('userFieldId parameter must not be null'); }

        HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/user_fields/' + userFieldId + '.json');
        HttpResponse res = new Http().send(queryReq);

        if (!ZendeskAPI.isSuccess(res)) {
            throw new ZendeskException('Error getting User Field ' + userFieldId + ' (' + res.getStatusCode() + ')');
        }

        UserFieldWrapper wrapper = (UserFieldWrapper)JSON.deserialize(res.getBody(), UserFieldWrapper.class);
        return wrapper.user_field;
    }

    // Get the first page of User Fields
    public PagedUserFieldsWrapper getUserFields() {
        return getUserFields(null);
    }

    // Get a specific page of User Fields
    public PagedUserFieldsWrapper getUserFields(Long page) {
        HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/user_fields.json' + (page==null ? '' : '?page=' + page));
        HttpResponse res = new Http().send(queryReq);

        if (!ZendeskAPI.isSuccess(res)) {
            throw new ZendeskException('Error getting User Fields (' + res.getStatusCode() + ')');
        }

        PagedUserFieldsWrapper wrapper = (PagedUserFieldsWrapper)JSON.deserialize(res.getBody(), PagedUserFieldsWrapper.class);
        return wrapper;
    }

    public void deleteUserField(Long userFieldId) {
		if (userFieldId == null) { throw new ZendeskException('userFieldId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/user_fields/' + userFieldId + '.json');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error deleting User Field ' + userFieldId + ' (' + res.getStatusCode() + ')');
		}
	}

    // non-native API method
    public ZUserField getUserFieldByKey(String key) {
        if (String.isBlank(key)) { throw new ZendeskException('key parameter must not be empty'); }

        if (userFieldsMap.isEmpty()) {
            loadAll();
        }

        ZUserField obj = null;
        if (userFieldsMap.containsKey(key)) {
            obj = userFieldsMap.get(key);
        }

        return obj;
    }

    // Retrieves all pages of user fields. Uses the field "key" as the map key
    public Map<String, ZUserField> getAllFields() {
        if (userFieldsMap.isEmpty()) {
            loadAll();
        }
        return userFieldsMap;
    }

    // Returns a list of all custom User Fields in your account. Fields are returned in the order
    // that you specify in your User Fields configuration in Zendesk. Clients should cache this
    // resource for the duration of their API usage and map the key for each User Field to the values
    // returned under the user_fields attribute on the User resource.
    private void loadAll() {
        PagedUserFieldsWrapper wrapper = getUserFields();
        if (wrapper != null && wrapper.user_fields != null) {
            for (ZUserField obj : wrapper.user_fields) {
                userFieldsMap.put(obj.key, obj);
            }

            while (!String.isEmpty(wrapper.next_page)) {
                wrapper = getUserFields(wrapper.nextPageNumber);
                for (ZUserField obj : wrapper.user_fields) {
                    userFieldsMap.put(obj.key, obj);
                }
            }
        }
    }

}
