// This class provides common functionality to call the Zendesk API to interact with Ticket Field records
public with sharing class ZendeskTicketFields {

	private final ZendeskAPI zapi;
	private Map<String, ZTicketField> ticketFieldsMap {get; private set; }

	public class ZTicketField {
		public Integer id {get;set;}
		public String type {get;set;}
		public String title {get;set;}
		public String raw_title {get;set;}
		public Boolean active {get;set;}
		public ZCustomFieldOption[] custom_field_options {get;set;}

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

			if (String.isEmpty(val) && errorIfNotFound && !Test.isRunningTest()) { throw new ZendeskException('Option value "' + optname + '" not found for field "' + this.title + '"'); }
			return val;
		}
	}

	public class ZCustomFieldOption {
		public Integer id {get;set;}
		public String name {get;set;}
		public String raw_name {get;set;}
		public String value {get;set;}
	}

	public class PagedTicketFieldsWrapper {
		public ZTicketField[] ticket_fields {get;set;}

		// "https://test.zendesk.com/api/v2/ticket_fields.json?page=2"
		public String next_page {get;set;}
		public Integer nextPageNumber {
			public get { return (String.isEmpty(next_page) ? null : Integer.valueOf(next_page.substringAfterLast('page=').substringBefore('&'))); }
			private set;
		}
	}

	private class TicketFieldWrapper {
		public ZTicketField ticket_field {get;set;}
	}

	public ZendeskTicketFields(ZendeskAPI zapi) {
		this.zapi = zapi;
		ticketFieldsMap = new Map<String, ZTicketField>();
	}

	// Retrieves all the custom ticket fields. Uses the field "raw_title" as the map key
	public Map<String, ZTicketField> getAllFields() {
        if (ticketFieldsMap.isEmpty()) {
            loadAll();
        }
        return ticketFieldsMap;
    }

	public ZTicketField getTicketField(Integer ticketFieldId) {
		Http h = new Http();
		HttpRequest queryReq = zapi.setupRequest('GET', ZendeskAPI.BASE_PATH + '/ticket_fields/' + String.valueOf(ticketFieldId) + '.json');
		HttpResponse res = h.send(queryReq);
		System.debug('getTicketField res: ' + res);
		String resBody = res.getBody();
		System.debug('resBody: ' + resBody);

		ZTicketField ticketField = null;
		if (res.getStatusCode() == 200) {
			TicketFieldWrapper wrapper = (TicketFieldWrapper)JSON.deserialize(resBody, TicketFieldWrapper.class);
			ticketField = wrapper.ticket_field;
		}

		return ticketField;
	}

	public ZTicketField getTicketField(String name) {
		// TODO: should we pre-load all ticket field pages?
		if (ticketFieldsMap.isEmpty()) {
			loadAll();
		}

		ZTicketField obj = null;
		if (ticketFieldsMap.containsKey(name)) {
			obj = ticketFieldsMap.get(name);
		}

		return obj;
	}

	private void loadAll() {
		PagedTicketFieldsWrapper wrapper = getTicketFields();
		System.debug('**wrapper=' + wrapper);
		if (wrapper != null && wrapper.ticket_fields != null) {
			for (ZTicketField obj : wrapper.ticket_fields) {
				ticketFieldsMap.put(obj.raw_title, obj);
			}

			while (!String.isEmpty(wrapper.next_page)) {
				System.debug('**wrapper.next_page=' + wrapper.next_page);
				wrapper = getTicketFields(wrapper.nextPageNumber);
				for (ZTicketField obj : wrapper.ticket_fields) {
					ticketFieldsMap.put(obj.raw_title, obj);
				}
			}
		}
	}

	public PagedTicketFieldsWrapper getTicketFields() {
		return getTicketFields(null);
	}

	public PagedTicketFieldsWrapper getTicketFields(Integer page) {
		Http h = new Http();
		HttpRequest queryReq = zapi.setupRequest('GET', ZendeskAPI.BASE_PATH + '/ticket_fields.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
		HttpResponse res = h.send(queryReq);
		System.debug('getTicketFields res: ' + res);
		String resBody = res.getBody();
		System.debug('resBody: ' + resBody);

		PagedTicketFieldsWrapper wrapper = null;
		if (res.getStatusCode() == 200) {
			wrapper = (PagedTicketFieldsWrapper)JSON.deserialize(resBody, PagedTicketFieldsWrapper.class);
		}

		return wrapper;
	}
}
