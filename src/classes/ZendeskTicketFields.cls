// This class provides functionality to call the Zendesk API to interact with Ticket Field records
public with sharing class ZendeskTicketFields {

	private final ZendeskAPI zapi;
	private Map<String, ZTicketField> ticketFieldsMap {get; private set; }

	public class ZTicketField {
		public Integer id {get; private set;}
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
		public Integer id {get; private set;}
		public String name {get; set;}
		public String raw_name {get; set;}
		public String value {get; set;}
	}

	public class PagedTicketFieldsWrapper {
		public ZTicketField[] ticket_fields {get; set;}

		// Paging support
		public String next_page {get; set;}
		public Integer nextPageNumber { get { return ZendeskAPI.getPageNumber(next_page); } private set; }
		public String previous_page {get; set;}
		public Integer previousPageNumber { get { return ZendeskAPI.getPageNumber(previous_page); } private set; }
	}

	private class TicketFieldWrapper {
		public ZTicketField ticket_field {get;set;}
	}

	public ZendeskTicketFields(ZendeskAPI zapi) {
		this.zapi = zapi;
		ticketFieldsMap = new Map<String, ZTicketField>();
	}

	// TODO: "title" is not unique on Ticket Forms. Perhaps just return a List instead
	// Retrieves all pages of ticket fields. Uses the field "title" as the map key
	public Map<String, ZTicketField> getAllFields() {
        if (ticketFieldsMap.isEmpty()) {
            loadAll();
        }
        return ticketFieldsMap;
    }

	public ZTicketField getTicketField(Integer ticketFieldId) {
		HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/ticket_fields/' + String.valueOf(ticketFieldId) + '.json');
		HttpResponse res = new Http().send(queryReq);
		String resBody = res.getBody();

		ZTicketField ticketField = null;
		if (res.getStatusCode() == 200) {
			// Deserialize the response into a typed class
			TicketFieldWrapper wrapper = (TicketFieldWrapper)JSON.deserialize(resBody, TicketFieldWrapper.class);
			ticketField = wrapper.ticket_field;
		}

		return ticketField;
	}

	// non-native API method
	// TODO: since "title" is not unique should we even have this method?
	public ZTicketField getTicketField(String name) {
		// TODO: should we fetch all pages?
		if (ticketFieldsMap.isEmpty()) {
			loadAll();
		}

		ZTicketField obj = null;
		if (ticketFieldsMap.containsKey(name)) {
			obj = ticketFieldsMap.get(name);
		}

		return obj;
	}

	// TODO: "title" isn't guaranteed to be unique across custom fields so
	// this doesn't make a good map key
	private void loadAll() {
		PagedTicketFieldsWrapper wrapper = getTicketFields();
		if (wrapper != null && wrapper.ticket_fields != null) {
			for (ZTicketField obj : wrapper.ticket_fields) {
				ticketFieldsMap.put(obj.title, obj);
			}

			while (!String.isEmpty(wrapper.next_page)) {
				wrapper = getTicketFields(wrapper.nextPageNumber);
				for (ZTicketField obj : wrapper.ticket_fields) {
					ticketFieldsMap.put(obj.title, obj);
				}
			}
		}
	}

	// Get the first page of Ticket Fields
	public PagedTicketFieldsWrapper getTicketFields() {
		return getTicketFields(null);
	}

	// Get a specific page of User Fields
	public PagedTicketFieldsWrapper getTicketFields(Integer page) {
		HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/ticket_fields.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
		HttpResponse res = new Http().send(queryReq);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error getting Ticket Fields (' + res.getStatusCode() + ')');
		}

		// Deserialize the response into a typed class
		PagedTicketFieldsWrapper wrapper = (PagedTicketFieldsWrapper)JSON.deserialize(resBody, PagedTicketFieldsWrapper.class);

		return wrapper;
	}

	public void deleteTicketField(Integer ticketFieldId) {
		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/ticket_fields/' + String.valueOf(ticketFieldId) + '.json');
		HttpResponse res = new Http().send(req);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error deleting Ticket Field ' + ticketFieldId + ' (' + res.getStatusCode() + ')');
		}
	}
}
