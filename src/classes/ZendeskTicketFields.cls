// This class provides functionality to call the Zendesk Ticket Fields API
// Currently supports the following API endpoints:
// GET    /api/v2/ticket_fields.json
// GET    /api/v2/ticket_fields/{id}.json
// POST   /api/v2/ticket_fields.json
// PUT    /api/v2/ticket_fields/{id}.json
// DELETE /api/v2/ticket_fields/{id}.json
public class ZendeskTicketFields extends ZendeskResourceBase {

	private Map<Long, ZTicketField> fieldsMap {get; private set; }

	public class ZTicketField {
		public Long id {get; private set;}
		public String type {get;set;}
		public String title {get;set;}
		public String raw_title {get;set;}
		public Boolean active {get;set;}
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
		public Long id {get; private set;}
		public String name {get;set;}
		public String raw_name {get;set;}
		public String value {get;set;}
	}

	public class TicketFieldsWrapper extends ZendeskPagingSupport {
		public List<ZTicketField> ticket_fields {get;set;}
	}

	private class TicketFieldWrapper {
		public ZTicketField ticket_field {get;set;}
	}

	public ZendeskTicketFields(ZendeskAPI zapi) {
		super(zapi);
		fieldsMap = new Map<Long, ZTicketField>();
	}

	public ZTicketField getField(Long fieldId) {
		if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/ticket_fields/' + fieldId + '.json');
		TicketFieldWrapper wrapper = (TicketFieldWrapper)JSON.deserialize(zapi.sendRequest(req), TicketFieldWrapper.class);
		return wrapper.ticket_field;
	}

	// Get the first page of Ticket Fields
	public TicketFieldsWrapper getFields() {
		return getFields(null);
	}

	// Get a specific page of User Fields
	public TicketFieldsWrapper getFields(Long page) {
		HttpRequest req = zapi.createRequest('GET', '/ticket_fields.json' + (page==null ? '' : '?page=' + page));
		return (TicketFieldsWrapper)JSON.deserialize(zapi.sendRequest(req), TicketFieldsWrapper.class);
	}

	public void deleteField(Long fieldId) {
		if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('DELETE', '/ticket_fields/' + fieldId + '.json');
		zapi.sendRequest(req);
	}

	public Long createField(ZTicketField zfield) {
		if (zfield == null) { throw new ZendeskException('zfield parameter must not be null'); }

		HttpRequest req = zapi.createRequest('POST', '/ticket_fields/.json');
		req.setBody('{ "ticket_field": ' + JSON.serialize(zfield) + ' }');
		TicketFieldWrapper resultWrapper = (TicketFieldWrapper)JSON.deserialize(zapi.sendRequest(req), TicketFieldWrapper.class);
		return ((resultWrapper==null || resultWrapper.ticket_field == null) ? null : resultWrapper.ticket_field.id);
	}

	public void updateField(Long fieldId, ZTicketField zfield) {
		if (fieldId == null) { throw new ZendeskException('fieldId parameter must not be null'); }
		if (zfield == null) { throw new ZendeskException('zfield parameter must not be null'); }

		HttpRequest req = zapi.createRequest('PUT', '/ticket_fields/' + fieldId + '.json');
		req.setBody('{ "ticket_field": ' + stripJsonNulls(JSON.serialize(zfield)) + ' }');
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
				wrapper = getFields(wrapper.nextPageNumber);
				for (ZTicketField obj : wrapper.ticket_fields) {
					fieldsMap.put(obj.id, obj);
				}
			}
		}
	}
}
