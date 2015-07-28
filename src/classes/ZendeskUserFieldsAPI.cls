// This class provides functionality to call the Zendesk User Fields API
public class ZendeskUserFieldsAPI extends ZendeskResourceBase {

    private class UserFieldWrapper {
        public ZUserField user_field {get;set;}
		public UserFieldWrapper(ZUserField user_field) { this.user_field = user_field; }
    }

    public class UserFieldsWrapper extends ZendeskPagingBase {
        public List<ZUserField> user_fields {get;set;}
		public UserFieldsWrapper(List<ZUserField> user_fields) { this.user_fields = user_fields; }
    }

    public ZendeskUserFieldsAPI(ZendeskAPI zapi) {
        super(zapi);
    }

    public ZUserField getField(Long fieldId) {
		if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/user_fields/'+fieldId+'.json');
        UserFieldWrapper wrapper = (UserFieldWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), UserFieldWrapper.class);
        return wrapper.user_field;
    }

    // /api/v2/user_fields.json
    public UserFieldsWrapper getFields() {
        return getFields(null);
    }
    public UserFieldsWrapper getFields(Map<String, Object> queryParams) {
        HttpRequest req = zapi.createRequest('GET', '/user_fields.json', queryParams);
        return (UserFieldsWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), UserFieldsWrapper.class);
    }

    public void deleteField(Long fieldId) {
		if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }

		zapi.sendRequest(zapi.createRequest('DELETE', '/user_fields/'+fieldId+'.json'));
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
        req.setBody(unreplaceReservedWords(JSON.serialize(new UserFieldWrapper(zfield))));
        UserFieldWrapper resultWrapper = (UserFieldWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), UserFieldWrapper.class);
		return ((resultWrapper==null || resultWrapper.user_field==null) ? null : resultWrapper.user_field.id);
    }

    public void updateField(Long fieldId, ZUserField zfield) {
        if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }
        if (zfield == null) { throw new ZendeskException('zfield parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', '/user_fields/'+fieldId+'.json');
		req.setBody(unreplaceReservedWords(stripJsonNulls(JSON.serialize(new UserFieldWrapper(zfield)))));
		zapi.sendRequest(req);
    }

    // Retrieves all pages of user fields. Uses the field "key" as the map key
    public Map<String, ZUserField> getAllFields() {
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
