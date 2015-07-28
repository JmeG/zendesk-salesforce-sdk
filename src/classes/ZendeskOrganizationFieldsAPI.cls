// This class provides functionality to call the Zendesk Organization Fields API
public class ZendeskOrganizationFieldsAPI extends ZendeskResourceBase {

    private class OrganizationFieldWrapper {
        public ZOrganizationField organization_field {get;set;}
		public OrganizationFieldWrapper(ZOrganizationField organization_field) { this.organization_field = organization_field; }
    }

    public class OrganizationFieldsWrapper extends ZendeskPagingBase {
        public List<ZOrganizationField> organization_fields {get;set;}
		public OrganizationFieldsWrapper(List<ZOrganizationField> organization_fields) { this.organization_fields = organization_fields; }
    }

    public ZendeskOrganizationFieldsAPI(ZendeskAPI zapi) {
        super(zapi);
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
        req.setBody(JSON.serialize(new OrganizationFieldWrapper(zfield)));
        OrganizationFieldWrapper resultWrapper = (OrganizationFieldWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), OrganizationFieldWrapper.class);
		return ((resultWrapper==null || resultWrapper.organization_field == null) ? null : resultWrapper.organization_field.id);
    }

    public void updateField(Long fieldId, ZOrganizationField zfield) {
        if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }
        if (zfield == null) { throw new ZendeskException('zfield parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', '/organization_fields/'+fieldId+'.json');
		req.setBody(unreplaceReservedWords(stripJsonNulls(JSON.serialize(new OrganizationFieldWrapper(zfield)))));
		zapi.sendRequest(req);
    }

    // Retrieves all pages of organization fields. Uses the field "key" as the map key
    public Map<String, ZOrganizationField> getAllFields() {
        Map<String, ZOrganizationField> fieldsMap = new Map<String, ZUserField>();
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
        return fieldsMap;
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
