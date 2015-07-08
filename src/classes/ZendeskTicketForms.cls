// This class provides functionality to call the Zendesk API to interact with Ticket Form records
public with sharing class ZendeskTicketForms {

	private final ZendeskAPI zapi;
	private Map<Integer, ZTicketForm> ticketFormsMap;

	public class ZTicketForm {
		public Integer id {get; private set;}
		public String name {get; set;}
		public String raw_name {get; set;}
		public Boolean active {get; set;}
		//public Boolean default {get; set;} // can't use since "default" is a keyword
	}

	private class TicketFormWrapper {
		public ZTicketForm ticket_form {get; set;}
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
		ticketFormsMap = new Map<Integer, ZTicketForm>();
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

		// Deserialize the response into a concrete class
		PagedTicketFormsWrapper wrapper = (PagedTicketFormsWrapper)JSON.deserialize(resBody, PagedTicketFormsWrapper.class);

		return wrapper;
	}

	public ZTicketForm getTicketForm(Integer ticketFormId) {
		HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/ticket_forms/' + String.valueOf(ticketFormId) + '.json');
		HttpResponse res = new Http().send(req);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error getting Ticket Form ' + ticketFormId + ' (' + res.getStatusCode() + ')');
		}

		// Deserialize the response into a concrete class
		TicketFormWrapper resultWrapper = (TicketFormWrapper)JSON.deserialize(resBody, TicketFormWrapper.class);

		return resultWrapper.ticket_form;
	}

	public void deleteTicketForm(Integer ticketFormId) {
		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/ticket_forms/' + String.valueOf(ticketFormId) + '.json');
		HttpResponse res = new Http().send(req);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error deleting Ticket Form ' + ticketFormId + ' (' + res.getStatusCode() + ')');
		}
	}

	// Retrieves all pages of ticket forms. Uses the field "id" as the map key
	public Map<Integer, ZTicketForm> getAllTicketForms() {
        if (ticketFormsMap.isEmpty()) {
            loadAll();
        }
        return ticketFormsMap;
    }

	private void loadAll() {
		PagedTicketFormsWrapper wrapper = getTicketForms();
		if (wrapper != null && wrapper.ticket_forms != null) {
			for (ZTicketForm obj : wrapper.ticket_forms) {
				ticketFormsMap.put(obj.id, obj);
			}

			while (!String.isEmpty(wrapper.next_page)) {
				wrapper = getTicketForms(wrapper.nextPageNumber);
				for (ZTicketForm obj : wrapper.ticket_forms) {
					ticketFormsMap.put(obj.id, obj);
				}
			}
		}
	}
}
