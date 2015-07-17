// This class provides functionality to call the Zendesk Organization Fields API
// Currently upports the following API endpoints:
// GET    /api/v2/organization_fields.json
// GET    /api/v2/organization_fields/{id}.json
// DELETE /api/v2/organization_fields/{id}.json
// *************************************
// TODO: Implement the following methods
// POST   /api/v2/organization_fields.json
// PUT    /api/v2/organization_fields/{id}.json
// PUT    /api/v2/organization_fields/reorder.json
public with sharing class ZendeskOrganizationFields {

    private final ZendeskAPI zapi;
    private Map<String, ZOrganizationField> organizationFieldsMap {get; private set; }

    public class ZOrganizationField {
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

    public class PagedOrganizationFieldsWrapper {
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
        organizationFieldsMap = new Map<String, ZOrganizationField>();
    }

    public ZOrganizationField getOrganizationField(Long organizationFieldId) {
		if (organizationFieldId == null) { throw new ZendeskException('organizationFieldId parameter must not be null'); }

        HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/organization_fields/' + organizationFieldId + '.json');
        HttpResponse res = new Http().send(queryReq);

        if (!ZendeskAPI.isSuccess(res)) {
            throw new ZendeskException('Error getting Organization Field ' + organizationFieldId + ' (' + res.getStatusCode() + ')');
        }

        OrganizationFieldWrapper wrapper = (OrganizationFieldWrapper)JSON.deserialize(res.getBody(), OrganizationFieldWrapper.class);
        return wrapper.organization_field;
    }

    // Get the first page of Organization Fields
    public PagedOrganizationFieldsWrapper getOrganizationFields() {
        return getOrganizationFields(null);
    }

    // Get a specific page of Organization Fields
    public PagedOrganizationFieldsWrapper getOrganizationFields(Long page) {
        HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/organization_fields.json' + (page==null ? '' : '?page=' + page));
        HttpResponse res = new Http().send(queryReq);

        if (!ZendeskAPI.isSuccess(res)) {
            throw new ZendeskException('Error getting Organization Fields (' + res.getStatusCode() + ')');
        }

        PagedOrganizationFieldsWrapper wrapper = (PagedOrganizationFieldsWrapper)JSON.deserialize(res.getBody(), PagedOrganizationFieldsWrapper.class);
        return wrapper;
    }

    public void deleteOrganizationField(Long organizationFieldId) {
		if (organizationFieldId == null) { throw new ZendeskException('organizationFieldId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/organization_fields/' + organizationFieldId + '.json');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error deleting Organization Field ' + organizationFieldId + ' (' + res.getStatusCode() + ')');
		}
	}

    // non-native API method
    public ZOrganizationField getOrganizationFieldByKey(String key) {
        if (String.isBlank(key)) { throw new ZendeskException('key parameter must not be empty'); }

        if (organizationFieldsMap.isEmpty()) {
            loadAll();
        }

        ZOrganizationField obj = null;
        if (organizationFieldsMap.containsKey(key)) {
            obj = organizationFieldsMap.get(key);
        }

        return obj;
    }

    // Retrieves all pages of organization fields. Uses the field "key" as the map key
    public Map<String, ZOrganizationField> getAllFields() {
        if (organizationFieldsMap.isEmpty()) {
            loadAll();
        }
        return organizationFieldsMap;
    }

    // Returns a list of all custom Organization Fields in your account. Fields are returned in the order
    // that you specify in your Organization Fields configuration in Zendesk. Clients should cache this
    // resource for the duration of their API usage and map the key for each Organization Field to the values
    // returned under the organization_fields attribute on the Organization resource.
    private void loadAll() {
        PagedOrganizationFieldsWrapper wrapper = getOrganizationFields();
        if (wrapper != null && wrapper.organization_fields != null) {
            for (ZOrganizationField obj : wrapper.organization_fields) {
                organizationFieldsMap.put(obj.key, obj);
            }

            while (!String.isEmpty(wrapper.next_page)) {
                wrapper = getOrganizationFields(wrapper.nextPageNumber);
                for (ZOrganizationField obj : wrapper.organization_fields) {
                    organizationFieldsMap.put(obj.key, obj);
                }
            }
        }
    }

}