// This class provides functionality to call the Zendesk API to interact with Ticket Field records
public with sharing class ZendeskTicketFields {

	private final ZendeskAPI zapi;
	private Map<Long, ZTicketField> ticketFieldsMap {get; private set; }

	public class ZTicketField {
		public Long id {get; private set;}
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
		public Long id {get; private set;}
		public String name {get; set;}
		public String raw_name {get; set;}
		public String value {get; set;}
	}

	public class PagedTicketFieldsWrapper {
		public ZTicketField[] ticket_fields {get; set;}

		// Paging support
		public String next_page {get; set;}
		public Long nextPageNumber { get { return ZendeskAPI.getPageNumber(next_page); } private set; }
		public String previous_page {get; set;}
		public Long previousPageNumber { get { return ZendeskAPI.getPageNumber(previous_page); } private set; }
	}

	private class TicketFieldWrapper {
		public ZTicketField ticket_field {get;set;}
	}

	public ZendeskTicketFields(ZendeskAPI zapi) {
		this.zapi = zapi;
		ticketFieldsMap = new Map<Long, ZTicketField>();
	}

	public ZTicketField getTicketField(Long ticketFieldId) {
		HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/ticket_fields/' + ticketFieldId + '.json');
		HttpResponse res = new Http().send(queryReq);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error getting Ticket Field ' + ticketFieldId + ' (' + res.getStatusCode() + ')');
		}

		TicketFieldWrapper wrapper = (TicketFieldWrapper)JSON.deserialize(res.getBody(), TicketFieldWrapper.class);
		return wrapper.ticket_field;
	}

	// Get the first page of Ticket Fields
	public PagedTicketFieldsWrapper getTicketFields() {
		return getTicketFields(null);
	}

	// Get a specific page of User Fields
	public PagedTicketFieldsWrapper getTicketFields(Long page) {
		HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/ticket_fields.json' + (page==null ? '' : '?page=' + page));
		HttpResponse res = new Http().send(queryReq);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error getting Ticket Fields (' + res.getStatusCode() + ')');
		}

		PagedTicketFieldsWrapper wrapper = (PagedTicketFieldsWrapper)JSON.deserialize(res.getBody(), PagedTicketFieldsWrapper.class);
		return wrapper;
	}

	public void deleteTicketField(Long ticketFieldId) {
		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/ticket_fields/' + ticketFieldId + '.json');
		HttpResponse res = new Http().send(req);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error deleting Ticket Field ' + ticketFieldId + ' (' + res.getStatusCode() + ')');
		}
	}

	// Retrieves all pages of ticket fields. Uses the field "id" as the map key
	public Map<Long, ZTicketField> getAllFields() {
        if (ticketFieldsMap.isEmpty()) {
            loadAll();
        }
        return ticketFieldsMap;
    }

	private void loadAll() {
		PagedTicketFieldsWrapper wrapper = getTicketFields();
		if (wrapper != null && wrapper.ticket_fields != null) {
			for (ZTicketField obj : wrapper.ticket_fields) {
				ticketFieldsMap.put(obj.id, obj);
			}

			while (!String.isEmpty(wrapper.next_page)) {
				wrapper = getTicketFields(wrapper.nextPageNumber);
				for (ZTicketField obj : wrapper.ticket_fields) {
					ticketFieldsMap.put(obj.id, obj);
				}
			}
		}
	}
}
