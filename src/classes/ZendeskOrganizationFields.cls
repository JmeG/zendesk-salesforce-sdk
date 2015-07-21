// This class provides functionality to call the Zendesk Organization Fields API
// Currently supports the following API endpoints:
// GET    /api/v2/organization_fields.json
// GET    /api/v2/organization_fields/{id}.json
// POST   /api/v2/organization_fields.json
// PUT    /api/v2/organization_fields/{id}.json
// PUT    /api/v2/organization_fields/reorder.json
// DELETE /api/v2/organization_fields/{id}.json
public with sharing class ZendeskOrganizationFields {

    private final ZendeskAPI zapi;
    private Map<String, ZOrganizationField> fieldsMap {get; private set; }

    public class ZOrganizationField {
        public Long id {get; private set;}
        public String key {get; set;}
	    public String type {get; set;}
	    public String title {get; set;}
	    public String raw_title {get; set;}
        //public String description {get; set;}
        //public String raw_description {get; set;}
	    public Long position {get; set;}
	    public Boolean active {get; set;}
	    //public Boolean x_system {get; set;} // NOTE: "system" is reserved
        //public String regexp_for_validation {get; set;}
	    //public String tag {get; set;}
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

    public class OrganizationFieldsWrapper {
        public ZOrganizationField[] organization_fields {get; set;}

        // Paging support
		public String next_page {get; set;}
		public Long nextPageNumber { get { return ZendeskAPI.getPageNumber(next_page); } private set; }
		public String previous_page {get; set;}
		public Long previousPageNumber { get { return ZendeskAPI.getPageNumber(previous_page); } private set; }
    }

    private class OrganizationFieldWrapper {
        public ZOrganizationField organization_field {get; set;}
    }

    public ZendeskOrganizationFields(ZendeskAPI zapi) {
        this.zapi = zapi;
        fieldsMap = new Map<String, ZOrganizationField>();
    }

    public ZOrganizationField getField(Long fieldId) {
		if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }

        HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/organization_fields/' + fieldId + '.json');
        HttpResponse res = new Http().send(queryReq);

        if (!ZendeskAPI.isSuccess(res)) {
            throw new ZendeskException('Error getting Field ' + fieldId + ' (' + res.getStatusCode() + ')');
        }

        OrganizationFieldWrapper wrapper = (OrganizationFieldWrapper)JSON.deserialize(replaceReservedWords(res.getBody()), OrganizationFieldWrapper.class);
        return wrapper.organization_field;
    }

    // Get the first page of Organization Fields
    public OrganizationFieldsWrapper getFields() {
        return getFields(null);
    }

    // Get a specific page of Organization Fields
    public OrganizationFieldsWrapper getFields(Long page) {
        HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/organization_fields.json' + (page==null ? '' : '?page=' + page));
        HttpResponse res = new Http().send(queryReq);

        if (!ZendeskAPI.isSuccess(res)) {
            throw new ZendeskException('Error getting Fields (' + res.getStatusCode() + ')');
        }

        OrganizationFieldsWrapper wrapper = (OrganizationFieldsWrapper)JSON.deserialize(replaceReservedWords(res.getBody()), OrganizationFieldsWrapper.class);
        return wrapper;
    }

    public void deleteField(Long fieldId) {
		if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/organization_fields/' + fieldId + '.json');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error deleting Field ' + fieldId + ' (' + res.getStatusCode() + ')');
		}
	}

    public void reorderFields(Long[] orderedFieldIds) {
        if (orderedFieldIds == null || orderedFieldIds.size() < 2) { throw new ZendeskException('orderedFieldIds parameter contain at least 2 items'); }

        HttpRequest req = zapi.createRequest('PUT', ZendeskAPI.BASE_PATH + '/organization_fields/reorder.json');
        req.setBody('{ "organization_field_ids": ' + JSON.serialize(orderedFieldIds) + '}');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error reordering Organization Fields (' + res.getStatusCode() + ')');
		}
    }

    public Long createField(ZOrganizationField zfield) {
        if (zfield == null) { throw new ZendeskException('zfield parameter must not be null'); }

        HttpRequest req = zapi.createRequest('POST', ZendeskAPI.BASE_PATH + '/organization_fields.json');
        String fieldJson = JSON.serialize(zfield);
        req.setBody('{ "organization_field": ' + fieldJson + '}');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error creating Field (' + res.getStatusCode() + ')');
		}

        OrganizationFieldWrapper resultWrapper = (OrganizationFieldWrapper)JSON.deserialize(replaceReservedWords(res.getBody()), OrganizationFieldWrapper.class);
		// return the ID of the new field
		return ((resultWrapper==null || resultWrapper.organization_field == null) ? null : resultWrapper.organization_field.id);
    }

    public void updateField(Long fieldId, ZOrganizationField zfield) {
        if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }
        if (zfield == null) { throw new ZendeskException('zfield parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', ZendeskAPI.BASE_PATH + '/organization_fields/' + fieldId + '.json');
		String fieldJson = unreplaceReservedWords(ZendeskAPI.stripJsonNulls(zfield));
		req.setBody('{ "organization_field": ' + fieldJson + ' }');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error updating Field (' + res.getStatusCode() + ')');
		}
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
                wrapper = getFields(wrapper.nextPageNumber);
                for (ZOrganizationField obj : wrapper.organization_fields) {
                    fieldsMap.put(obj.key, obj);
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
