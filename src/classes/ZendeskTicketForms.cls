// This class provides functionality to call the Zendesk API to interact with Ticket Form records
public with sharing class ZendeskTicketForms {

	private final ZendeskAPI zapi;
	private Map<String, ZTicketForm> ticketFormsMap;

	public class ZTicketForm {
		public Integer id {get; private set;}
		public String name {get; set;}
		public String raw_name {get; set;}
		public Boolean active {get; set;}
		//public Boolean default {get; set;} // can't use since "default" is a keyword
	}

	public class PagedTicketFormsWrapper {
		public ZTicketForm[] ticket_forms {get;set;}

		// Paging support
		public String next_page {get; set;}
		public Integer nextPageNumber { get { return ZendeskAPI.getPageNumber(next_page); } private set; }
		public String previous_page {get; set;}
		public Integer previousPageNumber { get { return ZendeskAPI.getPageNumber(previous_page); } private set; }
	}

	public ZendeskTicketForms(ZendeskAPI zapi) {
		this.zapi = zapi;
		ticketFormsMap = new Map<String, ZTicketForm>();
	}

	// TODO: "name" is not unique on Ticket Forms. Perhaps just return a List instead
	// Retrieves all pages of ticket forms. Uses the field "name" as the map key
	public Map<String, ZTicketForm> getAllTicketForms() {
        if (ticketFormsMap.isEmpty()) {
            loadAll();
        }
        return ticketFormsMap;
    }

	// non-native API method.
	// TODO: since "name" is not unique should we even have this method?
	public ZTicketForm getTicketForm(String name) {
		// TODO: should we fetch all pages?
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
		if (wrapper != null && wrapper.ticket_forms != null) {
			for (ZTicketForm obj : wrapper.ticket_forms) {
				ticketFormsMap.put(obj.name, obj);
			}

			while (!String.isEmpty(wrapper.next_page)) {
				wrapper = getTicketForms(wrapper.nextPageNumber);
				for (ZTicketForm obj : wrapper.ticket_forms) {
					ticketFormsMap.put(obj.name, obj);
				}
			}
		}
	}

	// Get the first page of Ticket Forms
	public PagedTicketFormsWrapper getTicketForms() {
		return getTicketForms(null);
	}

	// Get a specific page of Ticket Forms
	public PagedTicketFormsWrapper getTicketForms(Integer page) {
		HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/ticket_forms.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
		HttpResponse res = new Http().send(queryReq);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error getting Ticket Forms (' + res.getStatusCode() + ')');
		}

		// Deserialize the response into a typed class
		PagedTicketFormsWrapper wrapper = (PagedTicketFormsWrapper)JSON.deserialize(resBody, PagedTicketFormsWrapper.class);

		return wrapper;
	}

	public void deleteTicketForm(Integer ticketFormId) {
		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/ticket_forms/' + String.valueOf(ticketFormId) + '.json');
		HttpResponse res = new Http().send(req);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error deleting Ticket Form ' + ticketFormId + ' (' + res.getStatusCode() + ')');
		}
	}
}
