// This class provides functionality to call the Zendesk User Fields API
// Currently supports the following API endpoints:
// GET    /api/v2/user_fields.json
// GET    /api/v2/user_fields/{id}.json
// POST   /api/v2/user_fields.json
// PUT    /api/v2/user_fields/{id}.json
// PUT    /api/v2/user_fields/reorder.json
// DELETE /api/v2/user_fields/{id}.json
public class ZendeskUserFields extends ZendeskResourceBase {

    private Map<String, ZUserField> userFieldsMap {get; private set; }

    public class ZUserField {
	    public Long id {get; private set;}
        public String key {get;set;}
	    public String type {get;set;}
	    public String title {get;set;}
	    public String raw_title {get;set;}
	    public Long position {get;set;}
	    public Boolean active {get;set;}
        public String description {get;set;}
        public String raw_description {get;set;}
	    //public Boolean x_system {get;set;} // NOTE: "system" is reserved
        //public String regexp_for_validation {get;set;}
	    //public String tag {get;set;}
	    public List<ZCustomFieldOption> custom_field_options {get;set;}
		public DateTime created_at {get; private set;}
		public DateTime updated_at {get; private set;}

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
		public Long id {get;set;}
		public String name {get;set;}
		public String raw_name {get;set;}
		public String value {get;set;}
	}

    public class UserFieldsWrapper extends ZendeskPagingSupport {
        public List<ZUserField> user_fields {get;set;}
    }

    private class UserFieldWrapper {
        public ZUserField user_field {get;set;}
    }

    public ZendeskUserFields(ZendeskAPI zapi) {
        super(zapi);
        userFieldsMap = new Map<String, ZUserField>();
    }

    public ZUserField getField(Long fieldId) {
		if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/user_fields/' + fieldId + '.json');
        UserFieldWrapper wrapper = (UserFieldWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), UserFieldWrapper.class);
        return wrapper.user_field;
    }

    // Get the first page of User Fields
    public UserFieldsWrapper getFields() {
        return getFields(null);
    }

    // Get a specific page of User Fields
    public UserFieldsWrapper getFields(Long page) {
        HttpRequest req = zapi.createRequest('GET', '/user_fields.json' + (page==null ? '' : '?page=' + page));
        return (UserFieldsWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), UserFieldsWrapper.class);
    }

    public void deleteField(Long fieldId) {
		if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }

		zapi.sendRequest(zapi.createRequest('DELETE', '/user_fields/' + fieldId + '.json'));
	}

    public void reorderFields(List<Long> orderedFieldIds) {
        if (orderedFieldIds == null || orderedFieldIds.size() < 2) { throw new ZendeskException('orderedFieldIds parameter contain at least 2 items'); }

        HttpRequest req = zapi.createRequest('PUT', '/user_fields/reorder.json');
        req.setBody('{"user_field_ids": ' + JSON.serialize(orderedFieldIds) + '}');
		zapi.sendRequest(req);
    }

    public Long createField(ZUserField zfield) {
        if (zfield == null) { throw new ZendeskException('zfield parameter must not be null'); }

        HttpRequest req = zapi.createRequest('POST', '/user_fields.json');
        req.setBody('{"user_field": ' + unreplaceReservedWords(JSON.serialize(zfield)) + '}');
        UserFieldWrapper resultWrapper = (UserFieldWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), UserFieldWrapper.class);
		return ((resultWrapper==null || resultWrapper.user_field==null) ? null : resultWrapper.user_field.id);
    }

    public void updateField(Long fieldId, ZUserField zfield) {
        if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }
        if (zfield == null) { throw new ZendeskException('zfield parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', '/user_fields/' + fieldId + '.json');
		req.setBody('{"user_field": ' + unreplaceReservedWords(ZendeskAPI.stripJsonNulls(JSON.serialize(zfield))) + '}');
		zapi.sendRequest(req);
    }

    // non-native API method
    public ZUserField getFieldByKey(String key) {
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
        UserFieldsWrapper wrapper = getFields();
        if (wrapper != null && wrapper.user_fields != null) {
            for (ZUserField obj : wrapper.user_fields) {
                userFieldsMap.put(obj.key, obj);
            }

            while (!String.isEmpty(wrapper.next_page)) {
                wrapper = getFields(wrapper.nextPageNumber);
                for (ZUserField obj : wrapper.user_fields) {
                    userFieldsMap.put(obj.key, obj);
                }
            }
        }
    }

    // replace reserved keywords in the JSON string and map them to field names prefixed with "x_"
	private String replaceReservedWords(String str) {
		str = str.replaceAll('"system"\\s*:', '"x_system":');
		return str;
	}

	// un-replace reserved keywords in the JSON string
	private String unreplaceReservedWords(String str) {
		str = str.replaceAll('"x_system"\\s*:', '"system":');
		return str;
	}

}
