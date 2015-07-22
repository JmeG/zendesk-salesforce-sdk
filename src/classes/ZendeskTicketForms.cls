// This class provides functionality to call the Zendesk Ticket Forms API
// Currently supports the following API endpoints:
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

	public class TicketFormsWrapper extends ZendeskPagingSupport {
		public ZTicketForm[] ticket_forms {get;set;}
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
		HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/ticket_forms.json' + (page==null ? '' : '?page=' + page));
		String resBody = ZendeskAPI.sendRequest(req);

		return (TicketFormsWrapper)JSON.deserialize(replaceReservedWords(resBody), TicketFormsWrapper.class);
	}

	public ZTicketForm getTicketForm(Long ticketFormId) {
		if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/ticket_forms/' + ticketFormId + '.json');
		String resBody = ZendeskAPI.sendRequest(req);

		TicketFormWrapper resultWrapper = (TicketFormWrapper)JSON.deserialize(replaceReservedWords(resBody), TicketFormWrapper.class);
		return resultWrapper.ticket_form;
	}

	public void deleteTicketForm(Long ticketFormId) {
		if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/ticket_forms/' + ticketFormId + '.json');
		ZendeskAPI.sendRequest(req);
	}

	public Long createTicketForm(ZTicketForm ticketForm) {
		if (ticketForm == null) { throw new ZendeskException('ticketForm parameter must not be null'); }

        HttpRequest req = zapi.createRequest('POST', ZendeskAPI.BASE_PATH + '/ticket_forms.json');
        String tformJson = unreplaceReservedWords(JSON.serialize(ticketForm));
        req.setBody('{ "ticket_form": ' + tformJson + '}');
		String resBody = ZendeskAPI.sendRequest(req);

        TicketFormWrapper resultWrapper = (TicketFormWrapper)JSON.deserialize(replaceReservedWords(resBody), TicketFormWrapper.class);
		return ((resultWrapper==null || resultWrapper.ticket_form==null) ? null : resultWrapper.ticket_form.id);
	}

	public void updateTicketForm(Long ticketFormId, ZTicketForm ticketForm) {
		if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter must not be null'); }
        if (ticketForm == null) { throw new ZendeskException('ticketForm parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', ZendeskAPI.BASE_PATH + '/ticket_forms/' + ticketFormId + '.json');
		String tformJson = unreplaceReservedWords(ZendeskAPI.stripJsonNulls(JSON.serialize(ticketForm)));
		req.setBody('{ "ticket_form": ' + tformJson + ' }');
		ZendeskAPI.sendRequest(req);
	}

	public void reorderTicketForms(Long[] orderedTicketFormIds) {
        if (orderedTicketFormIds == null || orderedTicketFormIds.size() < 2) { throw new ZendeskException('orderedTicketFormIds parameter contain at least 2 items'); }

        HttpRequest req = zapi.createRequest('PUT', ZendeskAPI.BASE_PATH + '/ticket_forms/reorder.json');
        req.setBody('{ "ticket_form_ids": ' + JSON.serialize(orderedTicketFormIds) + '}');
		ZendeskAPI.sendRequest(req);
    }

	public Long cloneTicketForm(Long ticketFormId) {
		if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('POST', ZendeskAPI.BASE_PATH + '/ticket_forms/' + ticketFormId + '/clone.json');
		String resBody = ZendeskAPI.sendRequest(req);

        TicketFormWrapper resultWrapper = (TicketFormWrapper)JSON.deserialize(replaceReservedWords(resBody), TicketFormWrapper.class);
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
