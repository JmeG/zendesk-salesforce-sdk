// This class provides functionality to call the Zendesk Organization Fields API
global class ZendeskOrganizationFieldsAPI extends ZendeskResourceBase {

    global class OrganizationFieldWrapper {
        global ZOrganizationField organization_field {get;set;}
        global OrganizationFieldWrapper(ZOrganizationField organization_field) { this.organization_field = organization_field; }
    }

    global class OrganizationFieldsWrapper extends ZendeskPagingBase {
        global List<ZOrganizationField> organization_fields {get;set;}
        global OrganizationFieldsWrapper(List<ZOrganizationField> organization_fields) { this.organization_fields = organization_fields; }
    }

    global ZendeskOrganizationFieldsAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    global ZOrganizationField getField(Long fieldId) {
        if (fieldId == null) { throw new ZendeskException('fieldId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/organization_fields/'+fieldId+'.json');
        OrganizationFieldWrapper wrapper = (OrganizationFieldWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), OrganizationFieldWrapper.class);
        return wrapper.organization_field;
    }

    global OrganizationFieldsWrapper getFields() {
        return getFields(null);
    }
    global OrganizationFieldsWrapper getFields(Map<String, Object> queryParams) {
        HttpRequest req = zconn.createRequest('GET', '/organization_fields.json', queryParams);
        return (OrganizationFieldsWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), OrganizationFieldsWrapper.class);
    }

    global void deleteField(Long fieldId) {
        if (fieldId == null) { throw new ZendeskException('fieldId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest('DELETE', '/organization_fields/'+fieldId+'.json'));
    }

    global void reorderFields(List<Long> orderedFieldIds) {
        if (orderedFieldIds == null || orderedFieldIds.size() < 2) { throw new ZendeskException('orderedFieldIds parameter contain at least 2 items'); }

        HttpRequest req = zconn.createRequest('PUT', '/organization_fields/reorder.json');
        req.setBody('{ "organization_field_ids": ' + JSON.serialize(orderedFieldIds) + '}');
        zconn.sendRequest(req);
    }

    global Long createField(ZOrganizationField zfield) {
        if (zfield == null) { throw new ZendeskException('zfield parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('POST', '/organization_fields.json');
        req.setBody(JSON.serialize(new OrganizationFieldWrapper(zfield)));
        OrganizationFieldWrapper resultWrapper = (OrganizationFieldWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), OrganizationFieldWrapper.class);
        return ((resultWrapper==null || resultWrapper.organization_field == null) ? null : resultWrapper.organization_field.id);
    }

    global void updateField(Long fieldId, ZOrganizationField zfield) {
        if (fieldId == null) { throw new ZendeskException('fieldId parameter cannot be null'); }
        if (zfield == null) { throw new ZendeskException('zfield parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/organization_fields/'+fieldId+'.json');
        req.setBody(unreplaceReservedWords(JSON.serialize(new OrganizationFieldWrapper(zfield), true)));
        zconn.sendRequest(req);
    }

    // Retrieves all pages of organization fields. Uses the field "key" as the map key
    global Map<String, ZOrganizationField> getAllFields() {
        Map<String, ZOrganizationField> fieldsMap = new Map<String, ZOrganizationField>();
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
