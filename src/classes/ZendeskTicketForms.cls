// This class provides common functionality to call the Zendesk API to interact with Ticket Form records
public with sharing class ZendeskTicketForms {

	private final ZendeskAPI zapi;
	private Map<String, ZTicketForm> ticketFormsMap;

	public class ZTicketForm {
		public Integer id {get;set;}
		public String name {get;set;}
		public String raw_name {get;set;}
		public Boolean active {get;set;}
	}

	public class PagedTicketFormsWrapper {
		public ZTicketForm[] ticket_forms {get;set;}

		// "https://test.zendesk.com/api/v2/ticket_forms.json?page=2"
		public String next_page {get;set;}
		public Integer nextPageNumber {
			public get { return (String.isEmpty(next_page) ? null : Integer.valueOf(next_page.substringAfterLast('page=').substringBefore('&'))); }
			private set;
		}
	}

	public ZendeskTicketForms(ZendeskAPI zapi) {
		this.zapi = zapi;
		ticketFormsMap = new Map<String, ZTicketForm>();
	}

	// Retrieves all the ticket forms. Uses the field "raw_name" as the map key
	public Map<String, ZTicketForm> getAllTicketForms() {
        if (ticketFormsMap.isEmpty()) {
            loadAll();
        }
        return ticketFormsMap;
    }

	public ZTicketForm getTicketForm(String name) {
		// TODO: should we fetch all forms?
		if (ticketFormsMap.isEmpty()) {
			loadAll();
		}

		ZTicketForm obj = null;
		if (ticketFormsMap.containsKey(name)) {
			obj = ticketFormsMap.get(name);
		}

		return obj;
	}

	private void loadAll() {
		PagedTicketFormsWrapper wrapper = getTicketForms();
		System.debug('**wrapper=' + wrapper);
		if (wrapper != null && wrapper.ticket_forms != null) {
			for (ZTicketForm obj : wrapper.ticket_forms) {
				ticketFormsMap.put(obj.raw_name, obj);
			}

			while (!String.isEmpty(wrapper.next_page)) {
				System.debug('**wrapper.next_page=' + wrapper.next_page);
				wrapper = getTicketForms(wrapper.nextPageNumber);
				for (ZTicketForm obj : wrapper.ticket_forms) {
					ticketFormsMap.put(obj.raw_name, obj);
				}
			}
		}
	}

	public PagedTicketFormsWrapper getTicketForms() {
		return getTicketForms(null);
	}

	public PagedTicketFormsWrapper getTicketForms(Integer page) {
		Http h = new Http();
		HttpRequest queryReq = zapi.setupRequest('GET', ZendeskAPI.BASE_PATH + '/ticket_forms.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
		HttpResponse res = h.send(queryReq);
		System.debug('getTicketForms res: ' + res);
		String resBody = res.getBody();
		System.debug('resBody: ' + resBody);

		PagedTicketFormsWrapper wrapper = null;
		if (res.getStatusCode() == 200) {
			wrapper = (PagedTicketFormsWrapper)JSON.deserialize(resBody, PagedTicketFormsWrapper.class);
		}

		return wrapper;
	}
}
