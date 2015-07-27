// This class provides functionality to call the Zendesk Ticket Fields API
public class ZendeskTicketFieldsAPI extends ZendeskResourceBase {

	private Map<Long, ZTicketField> fieldsMap {get; private set; }

	private class TicketFieldWrapper {
		public ZTicketField ticket_field {get;set;}
		public TicketFieldWrapper(ZTicketField ticket_field) { this.ticket_field = ticket_field; }
	}

	public class TicketFieldsWrapper extends ZendeskPagingBase {
		public List<ZTicketField> ticket_fields {get;set;}
		public TicketFieldsWrapper(List<ZTicketField> ticket_fields) { this.ticket_fields = ticket_fields; }
	}

	public ZendeskTicketFieldsAPI(ZendeskAPI zapi) {
		super(zapi);
		fieldsMap = new Map<Long, ZTicketField>();
	}

	public ZTicketField getField(Long fieldId) {
		if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/ticket_fields/'+fieldId+'.json');
		TicketFieldWrapper wrapper = (TicketFieldWrapper)JSON.deserialize(zapi.sendRequest(req), TicketFieldWrapper.class);
		return wrapper.ticket_field;
	}

	public TicketFieldsWrapper getFields() {
		return getFields(null);
	}
	public TicketFieldsWrapper getFields(Map<String, Object> queryParams) {
		HttpRequest req = zapi.createRequest('GET', '/ticket_fields.json', queryParams);
		return (TicketFieldsWrapper)JSON.deserialize(zapi.sendRequest(req), TicketFieldsWrapper.class);
	}

	public void deleteField(Long fieldId) {
		if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('DELETE', '/ticket_fields/'+fieldId+'.json');
		zapi.sendRequest(req);
	}

	public Long createField(ZTicketField zfield) {
		if (zfield == null) { throw new ZendeskException('zfield parameter must not be null'); }

		HttpRequest req = zapi.createRequest('POST', '/ticket_fields.json');
		req.setBody(JSON.serialize(new TicketFieldWrapper(zfield)));
		TicketFieldWrapper resultWrapper = (TicketFieldWrapper)JSON.deserialize(zapi.sendRequest(req), TicketFieldWrapper.class);
		return ((resultWrapper==null || resultWrapper.ticket_field == null) ? null : resultWrapper.ticket_field.id);
	}

	public void updateField(Long fieldId, ZTicketField zfield) {
		if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }
		if (zfield == null) { throw new ZendeskException('zfield parameter must not be null'); }

		HttpRequest req = zapi.createRequest('PUT', '/ticket_fields/'+fieldId+'.json');
		req.setBody(stripJsonNulls(JSON.serialize(new TicketFieldWrapper(zfield))));
		zapi.sendRequest(req);
	}

	// Retrieves all pages of ticket fields. Uses the field "id" as the map key
	public Map<Long, ZTicketField> getAllFields() {
        if (fieldsMap.isEmpty()) {
            loadAll();
        }
        return fieldsMap;
    }

	private void loadAll() {
		TicketFieldsWrapper wrapper = getFields();
		if (wrapper != null && wrapper.ticket_fields != null) {
			for (ZTicketField obj : wrapper.ticket_fields) {
				fieldsMap.put(obj.id, obj);
			}

			while (!String.isEmpty(wrapper.next_page)) {
				wrapper = getFields(new Map<String, Object>{'page'=>wrapper.nextPageNumber});
				for (ZTicketField obj : wrapper.ticket_fields) {
					fieldsMap.put(obj.id, obj);
				}
			}
		}
	}
}
