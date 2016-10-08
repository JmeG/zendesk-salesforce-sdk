// This class provides functionality to call the Zendesk User Fields API
global class ZendeskUserFieldsAPI extends ZendeskResourceBase {

    global class UserFieldWrapper {
        global ZUserField user_field {get;set;}
        global UserFieldWrapper(ZUserField user_field) { this.user_field = user_field; }
    }

    global class UserFieldsWrapper extends ZendeskPagingBase {
        global List<ZUserField> user_fields {get;set;}
        global UserFieldsWrapper(List<ZUserField> user_fields) { this.user_fields = user_fields; }
    }

    global ZendeskUserFieldsAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    global ZUserField getField(Long fieldId) {
        if (fieldId == null) { throw new ZendeskException('fieldId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/user_fields/'+fieldId+'.json');
        UserFieldWrapper wrapper = (UserFieldWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), UserFieldWrapper.class);
        return wrapper.user_field;
    }

    // /api/v2/user_fields.json
    global UserFieldsWrapper getFields() {
        return getFields(null);
    }
    global UserFieldsWrapper getFields(Map<String, Object> queryParams) {
        HttpRequest req = zconn.createRequest('GET', '/user_fields.json', queryParams);
        return (UserFieldsWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), UserFieldsWrapper.class);
    }

    global void deleteField(Long fieldId) {
        if (fieldId == null) { throw new ZendeskException('fieldId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest('DELETE', '/user_fields/'+fieldId+'.json'));
    }

    global void reorderFields(List<Long> orderedFieldIds) {
        if (orderedFieldIds == null || orderedFieldIds.size() < 2) { throw new ZendeskException('orderedFieldIds parameter contain at least 2 items'); }

        HttpRequest req = zconn.createRequest('PUT', '/user_fields/reorder.json');
        req.setBody('{"user_field_ids": ' + JSON.serialize(orderedFieldIds) + '}');
        zconn.sendRequest(req);
    }

    global Long createField(ZUserField zfield) {
        if (zfield == null) { throw new ZendeskException('zfield parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('POST', '/user_fields.json');
        req.setBody(unreplaceReservedWords(JSON.serialize(new UserFieldWrapper(zfield))));
        UserFieldWrapper resultWrapper = (UserFieldWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), UserFieldWrapper.class);
        return ((resultWrapper==null || resultWrapper.user_field==null) ? null : resultWrapper.user_field.id);
    }

    global void updateField(Long fieldId, ZUserField zfield) {
        if (fieldId == null) { throw new ZendeskException('fieldId parameter cannot be null'); }
        if (zfield == null) { throw new ZendeskException('zfield parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/user_fields/'+fieldId+'.json');
        req.setBody(unreplaceReservedWords(JSON.serialize(new UserFieldWrapper(zfield), true)));
        zconn.sendRequest(req);
    }

    // Retrieves all pages of user fields. Uses the field "key" as the map key
    global Map<String, ZUserField> getAllFields() {
        Map<String, ZUserField> fieldsMap = new Map<String, ZUserField>();
        UserFieldsWrapper wrapper = getFields();
        if (wrapper != null && wrapper.user_fields != null) {
            for (ZUserField obj : wrapper.user_fields) {
                fieldsMap.put(obj.key, obj);
            }

            while (!String.isEmpty(wrapper.next_page)) {
                wrapper = getFields(new Map<String, Object>{'page'=>wrapper.nextPageNumber});
                for (ZUserField obj : wrapper.user_fields) {
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
