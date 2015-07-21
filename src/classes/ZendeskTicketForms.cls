// This class provides functionality to call the Zendesk Ticket Forms API
// Currently upports the following API endpoints:
// GET    /api/v2/ticket_forms.json
// GET    /api/v2/ticket_forms/{id}.json
// POST   /api/v2/ticket_forms.json
// POST   /api/v2/ticket_forms/{id}/clone.json
// PUT    /api/v2/ticket_forms/{id}.json
// PUT    /api/v2/ticket_forms/reorder.json
// DELETE /api/v2/ticket_forms/{id}.json
public with sharing class ZendeskTicketForms {

	private final ZendeskAPI zapi;
	private Map<Long, ZTicketForm> ticketFormsMap;

	public class ZTicketForm {
		public Long id {get; private set;}
		public String name {get; set;}
		public String raw_name {get; set;}
		public String display_name {get; set;}
		public String raw_display_name {get; set;}
		public Boolean active {get; set;}
		public Boolean x_default {get; set;} // Use "x_default" in place of "default" which is a reserved keyword. Requires custom de/serialization.
		public Boolean end_user_visible {get; set;}
		public Long position {get; set;}
		public Long[] ticket_field_ids {get; set;}
	}

	private class TicketFormWrapper {
		public ZTicketForm ticket_form {get; set;}
	}

	public class TicketFormsWrapper {
		public ZTicketForm[] ticket_forms {get;set;}

		// Paging support
		public String next_page {get; set;}
		public Long nextPageNumber { get { return ZendeskAPI.getPageNumber(next_page); } private set; }
		public String previous_page {get; set;}
		public Long previousPageNumber { get { return ZendeskAPI.getPageNumber(previous_page); } private set; }
	}

	public ZendeskTicketForms(ZendeskAPI zapi) {
		this.zapi = zapi;
		ticketFormsMap = new Map<Long, ZTicketForm>();
	}

	// Get the first page of Ticket Forms
	public TicketFormsWrapper getTicketForms() {
		return getTicketForms(null);
	}

	// Get a specific page of Ticket Forms
	public TicketFormsWrapper getTicketForms(Long page) {
		HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/ticket_forms.json' + (page==null ? '' : '?page=' + page));
		HttpResponse res = new Http().send(queryReq);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error getting Ticket Forms (' + res.getStatusCode() + ')');
		}

		TicketFormsWrapper wrapper = (TicketFormsWrapper)JSON.deserialize(replaceReservedWords(res.getBody()), TicketFormsWrapper.class);
		return wrapper;
	}

	public ZTicketForm getTicketForm(Long ticketFormId) {
		if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/ticket_forms/' + ticketFormId + '.json');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error getting Ticket Form ' + ticketFormId + ' (' + res.getStatusCode() + ')');
		}

		TicketFormWrapper resultWrapper = (TicketFormWrapper)JSON.deserialize(replaceReservedWords(res.getBody()), TicketFormWrapper.class);
		return resultWrapper.ticket_form;
	}

	public void deleteTicketForm(Long ticketFormId) {
		if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/ticket_forms/' + ticketFormId + '.json');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error deleting Ticket Form ' + ticketFormId + ' (' + res.getStatusCode() + ')');
		}
	}

	public Long createTicketForm(ZTicketForm ticketForm) {
		if (ticketForm == null) { throw new ZendeskException('ticketForm parameter must not be null'); }

        HttpRequest req = zapi.createRequest('POST', ZendeskAPI.BASE_PATH + '/ticket_forms.json');
        String tformJson = JSON.serialize(ticketForm);
        req.setBody('{ "ticket_form": ' + tformJson + '}');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error creating Ticket Form (' + res.getStatusCode() + ')');
		}

        TicketFormWrapper resultWrapper = (TicketFormWrapper)JSON.deserialize(replaceReservedWords(res.getBody()), TicketFormWrapper.class);
		// return the ID of the new ticket form
		return ((resultWrapper==null || resultWrapper.ticket_form==null) ? null : resultWrapper.ticket_form.id);
	}

	public void updateTicketForm(Long ticketFormId, ZTicketForm ticketForm) {
		updateTicketForm(ticketFormId, ticketForm, null);
	}

    public void updateTicketForm(Long ticketFormId, ZTicketForm ticketForm, Set<String> fieldsToNull) {
		if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter must not be null'); }
        if (ticketForm == null) { throw new ZendeskException('ticketForm parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', ZendeskAPI.BASE_PATH + '/ticket_forms/' + ticketFormId + '.json');
		String tformJson = unreplaceReservedWords(ZendeskAPI.serializeJsonNoNulls(ticketForm, fieldsToNull));
		req.setBody('{ "ticket_form": ' + tformJson + ' }');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error updating Ticket Form (' + res.getStatusCode() + ')');
		}
	}

	public void reorderTicketForms(Long[] orderedTicketFormIds) {
        if (orderedTicketFormIds == null || orderedTicketFormIds.size() < 2) { throw new ZendeskException('orderedTicketFormIds parameter contain at least 2 items'); }

        HttpRequest req = zapi.createRequest('PUT', ZendeskAPI.BASE_PATH + '/ticket_forms/reorder.json');
        req.setBody('{ "ticket_form_ids": ' + JSON.serialize(orderedTicketFormIds) + '}');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error reordering Ticket Forms (' + res.getStatusCode() + ')');
		}
    }

	public Long cloneTicketForm(Long ticketFormId) {
		if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('POST', ZendeskAPI.BASE_PATH + '/ticket_forms/' + ticketFormId + '/clone.json');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error cloning Ticket Form ' + ticketFormId + ' (' + res.getStatusCode() + ')');
		}

        TicketFormWrapper resultWrapper = (TicketFormWrapper)JSON.deserialize(replaceReservedWords(res.getBody()), TicketFormWrapper.class);
		// return the ID of the new ticket form
		return ((resultWrapper==null || resultWrapper.ticket_form==null) ? null : resultWrapper.ticket_form.id);
	}

	// Retrieves all pages of ticket forms. Uses the field "id" as the map key
	public Map<Long, ZTicketForm> getAllTicketForms() {
        if (ticketFormsMap.isEmpty()) {
            loadAll();
        }
        return ticketFormsMap;
    }

	private void loadAll() {
		TicketFormsWrapper wrapper = getTicketForms();
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

	// replace reserved keywords in the JSON string and map them to field names prefixed with "x_"
	private String replaceReservedWords(String str) {
		str = str.replaceAll('"default"\\s*:', '"x_default":');
		return str;
	}

	// un-replace reserved keywords in the JSON string
	private String unreplaceReservedWords(String str) {
		str = str.replaceAll('"x_default"\\s*:', '"default":');
		return str;
	}
}
