// This class provides functionality to call the Zendesk Ticket Forms API
global class ZendeskTicketFormsAPI extends ZendeskResourceBase {

    private Map<Long, ZTicketForm> ticketFormsMap;

    global class TicketFormWrapper {
        global ZTicketForm ticket_form {get;set;}
        global TicketFormWrapper(ZTicketForm ticket_form) { this.ticket_form = ticket_form; }
    }

    global class TicketFormsWrapper extends ZendeskPagingBase {
        global List<ZTicketForm> ticket_forms {get;set;}
        global TicketFormsWrapper(List<ZTicketForm> ticket_forms) { this.ticket_forms = ticket_forms; }
    }

    global ZendeskTicketFormsAPI(ZendeskConnection zconn) {
        super(zconn);
        ticketFormsMap = new Map<Long, ZTicketForm>();
    }

    global ZTicketForm getTicketForm(Long ticketFormId) {
        if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/ticket_forms/'+ticketFormId+'.json');
        TicketFormWrapper resultWrapper = (TicketFormWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), TicketFormWrapper.class);
        return resultWrapper.ticket_form;
    }

    global TicketFormsWrapper getTicketForms() {
        return getTicketForms(null);
    }
    global TicketFormsWrapper getTicketForms(Map<String, Object> queryParams) {
        HttpRequest req = zconn.createRequest('GET', '/ticket_forms.json', queryParams);
        return (TicketFormsWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), TicketFormsWrapper.class);
    }

    global void deleteTicketForm(Long ticketFormId) {
        if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('DELETE', '/ticket_forms/'+ticketFormId+'.json');
        zconn.sendRequest(req);
    }

    global Long createTicketForm(ZTicketForm ticketForm) {
        if (ticketForm == null) { throw new ZendeskException('ticketForm parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('POST', '/ticket_forms.json');
        req.setBody(unreplaceReservedWords(JSON.serialize(new TicketFormWrapper(ticketForm))));
        TicketFormWrapper resultWrapper = (TicketFormWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), TicketFormWrapper.class);
        return ((resultWrapper==null || resultWrapper.ticket_form==null) ? null : resultWrapper.ticket_form.id);
    }

    global void updateTicketForm(Long ticketFormId, ZTicketForm ticketForm) {
        if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter cannot be null'); }
        if (ticketForm == null) { throw new ZendeskException('ticketForm parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/ticket_forms/'+ticketFormId+'.json');
        req.setBody(unreplaceReservedWords(JSON.serialize(new TicketFormWrapper(ticketForm), true)));
        zconn.sendRequest(req);
    }

    global void reorderTicketForms(List<Long> orderedTicketFormIds) {
        if (orderedTicketFormIds == null || orderedTicketFormIds.size() < 2) { throw new ZendeskException('orderedTicketFormIds parameter contain at least 2 items'); }

        HttpRequest req = zconn.createRequest('PUT', '/ticket_forms/reorder.json');
        req.setBody('{"ticket_form_ids": ' + JSON.serialize(orderedTicketFormIds) + '}');
        zconn.sendRequest(req);
    }

    global Long cloneTicketForm(Long ticketFormId) {
        if (ticketFormId == null) { throw new ZendeskException('ticketFormId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('POST', '/ticket_forms/'+ticketFormId+'/clone.json');
        TicketFormWrapper resultWrapper = (TicketFormWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), TicketFormWrapper.class);
        return ((resultWrapper==null || resultWrapper.ticket_form==null) ? null : resultWrapper.ticket_form.id);
    }

    // Retrieves all pages of ticket forms. Uses the field "id" as the map key
    global Map<Long, ZTicketForm> getAllTicketForms() {
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
