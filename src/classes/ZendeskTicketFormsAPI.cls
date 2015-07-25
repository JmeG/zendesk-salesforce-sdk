// This class provides functionality to call the Zendesk Ticket Forms API
public class ZendeskTicketFormsAPI extends ZendeskResourceBase {

	private Map<Long, ZTicketForm> ticketFormsMap;

	private class TicketFormWrapper {
		public ZTicketForm ticket_form {get;set;}
	}

	public class TicketFormsWrapper extends ZendeskPagingBase {
		public List<ZTicketForm> ticket_forms {get;set;}
	}

	public ZendeskTicketFormsAPI(ZendeskAPI zapi) {
		super(zapi);
		ticketFormsMap = new Map<Long, ZTicketForm>();
	}

	public TicketFormsWrapper getTicketForms() {
		return getTicketForms(null);
	}

	public TicketFormsWrapper getTicketForms(Map<String, Object> queryParams) {
		HttpRequest req = zapi.createRequest('GET', '/ticket_forms.json', queryParams);
		return (TicketFormsWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), TicketFormsWrapper.class);
	}

	public ZTicketForm getTicketForm(Long ticketFormId) {
		if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/ticket_forms/'+ticketFormId+'.json');
		TicketFormWrapper resultWrapper = (TicketFormWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), TicketFormWrapper.class);
		return resultWrapper.ticket_form;
	}

	public void deleteTicketForm(Long ticketFormId) {
		if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('DELETE', '/ticket_forms/'+ticketFormId+'.json');
		zapi.sendRequest(req);
	}

	public Long createTicketForm(ZTicketForm ticketForm) {
		if (ticketForm == null) { throw new ZendeskException('ticketForm parameter must not be null'); }

        HttpRequest req = zapi.createRequest('POST', '/ticket_forms.json');
        req.setBody('{"ticket_form": ' + unreplaceReservedWords(JSON.serialize(ticketForm)) + '}');
        TicketFormWrapper resultWrapper = (TicketFormWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), TicketFormWrapper.class);
		return ((resultWrapper==null || resultWrapper.ticket_form==null) ? null : resultWrapper.ticket_form.id);
	}

	public void updateTicketForm(Long ticketFormId, ZTicketForm ticketForm) {
		if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter must not be null'); }
        if (ticketForm == null) { throw new ZendeskException('ticketForm parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', '/ticket_forms/'+ticketFormId+'.json');
		req.setBody('{"ticket_form": ' + unreplaceReservedWords(stripJsonNulls(JSON.serialize(ticketForm))) + '}');
		zapi.sendRequest(req);
	}

	public void reorderTicketForms(List<Long> orderedTicketFormIds) {
        if (orderedTicketFormIds == null || orderedTicketFormIds.size() < 2) { throw new ZendeskException('orderedTicketFormIds parameter contain at least 2 items'); }

        HttpRequest req = zapi.createRequest('PUT', '/ticket_forms/reorder.json');
        req.setBody('{"ticket_form_ids": ' + JSON.serialize(orderedTicketFormIds) + '}');
		zapi.sendRequest(req);
    }

	public Long cloneTicketForm(Long ticketFormId) {
		if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('POST', '/ticket_forms/'+ticketFormId+'/clone.json');
        TicketFormWrapper resultWrapper = (TicketFormWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), TicketFormWrapper.class);
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
				wrapper = getTicketForms(new Map<String, Object>{'page'=>wrapper.nextPageNumber});
				for (ZTicketForm obj : wrapper.ticket_forms) {
					ticketFormsMap.put(obj.id, obj);
				}
			}
		}
	}

	// replace reserved keywords in the JSON string and map them to field names prefixed with "x_"
    // Use when calling deserialize()
	private String replaceReservedWords(String str) {
		str = str.replaceAll('"default"\\s*:', '"x_default":');
		return str;
	}

	// un-replace reserved keywords in the JSON string
    // Use when calling serialize()
	private String unreplaceReservedWords(String str) {
		str = str.replaceAll('"x_default"\\s*:', '"default":');
		return str;
	}
}
