// This class provides functionality to call the Zendesk Organization Fields API
public class ZendeskOrganizationFieldsAPI extends ZendeskResourceBase {

    private Map<String, ZOrganizationField> fieldsMap {get; private set; }

    public class ZOrganizationField {
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

    public class OrganizationFieldsWrapper extends ZendeskPagingBase {
        public List<ZOrganizationField> organization_fields {get;set;}
    }

    private class OrganizationFieldWrapper {
        public ZOrganizationField organization_field {get;set;}
    }

    public ZendeskOrganizationFieldsAPI(ZendeskAPI zapi) {
        super(zapi);
        fieldsMap = new Map<String, ZOrganizationField>();
    }

    public ZOrganizationField getField(Long fieldId) {
		if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/organization_fields/'+fieldId+'.json');
        OrganizationFieldWrapper wrapper = (OrganizationFieldWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), OrganizationFieldWrapper.class);
        return wrapper.organization_field;
    }

    public OrganizationFieldsWrapper getFields() {
        return getFields(null);
    }

    public OrganizationFieldsWrapper getFields(Map<String, Object> queryParams) {
        HttpRequest req = zapi.createRequest('GET', '/organization_fields.json', queryParams);
        return (OrganizationFieldsWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), OrganizationFieldsWrapper.class);
    }

    public void deleteField(Long fieldId) {
		if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }

		zapi.sendRequest(zapi.createRequest('DELETE', '/organization_fields/'+fieldId+'.json'));
	}

    public void reorderFields(List<Long> orderedFieldIds) {
        if (orderedFieldIds == null || orderedFieldIds.size() < 2) { throw new ZendeskException('orderedFieldIds parameter contain at least 2 items'); }

        HttpRequest req = zapi.createRequest('PUT', '/organization_fields/reorder.json');
        req.setBody('{ "organization_field_ids": ' + JSON.serialize(orderedFieldIds) + '}');
		zapi.sendRequest(req);
    }

    public Long createField(ZOrganizationField zfield) {
        if (zfield == null) { throw new ZendeskException('zfield parameter must not be null'); }

        HttpRequest req = zapi.createRequest('POST', '/organization_fields.json');
        req.setBody('{ "organization_field": ' + JSON.serialize(zfield) + '}');
        OrganizationFieldWrapper resultWrapper = (OrganizationFieldWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), OrganizationFieldWrapper.class);
		return ((resultWrapper==null || resultWrapper.organization_field == null) ? null : resultWrapper.organization_field.id);
    }

    public void updateField(Long fieldId, ZOrganizationField zfield) {
        if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }
        if (zfield == null) { throw new ZendeskException('zfield parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', '/organization_fields/'+fieldId+'.json');
		String fieldJson = unreplaceReservedWords(stripJsonNulls(JSON.serialize(zfield)));
		req.setBody('{ "organization_field": ' + fieldJson + '}');
		zapi.sendRequest(req);
    }

    // non-native API method
    public ZOrganizationField getFieldByKey(String key) {
        if (String.isBlank(key)) { throw new ZendeskException('key parameter must not be empty'); }

        if (fieldsMap.isEmpty()) {
            loadAll();
        }

        ZOrganizationField obj = null;
        if (fieldsMap.containsKey(key)) {
            obj = fieldsMap.get(key);
        }

        return obj;
    }

    // Retrieves all pages of organization fields. Uses the field "key" as the map key
    public Map<String, ZOrganizationField> getAllFields() {
        if (fieldsMap.isEmpty()) {
            loadAll();
        }
        return fieldsMap;
    }

    // Returns a list of all custom Organization Fields in your account. Fields are returned in the order
    // that you specify in your Organization Fields configuration in Zendesk. Clients should cache this
    // resource for the duration of their API usage and map the key for each Organization Field to the values
    // returned under the organization_fields attribute on the Organization resource.
    private void loadAll() {
        OrganizationFieldsWrapper wrapper = getFields();
        if (wrapper != null && wrapper.organization_fields != null) {
            for (ZOrganizationField obj : wrapper.organization_fields) {
                fieldsMap.put(obj.key, obj);
            }

            while (!String.isEmpty(wrapper.next_page)) {
                wrapper = getFields(new Map<String, Object>{'page'=>wrapper.nextPageNumber});
                for (ZOrganizationField obj : wrapper.organization_fields) {
                    fieldsMap.put(obj.key, obj);
                }
            }
        }
    }

    // replace reserved keywords in the JSON string and map them to field names prefixed with "x_"
    // Use when calling deserialize()
	private String replaceReservedWords(String str) {
		str = str.replaceAll('"system"\\s*:', '"x_system":');
		return str;
	}

	// un-replace reserved keywords in the JSON string
    // Use when calling serialize()
	private String unreplaceReservedWords(String str) {
		str = str.replaceAll('"x_system"\\s*:', '"system":');
		return str;
	}

}
