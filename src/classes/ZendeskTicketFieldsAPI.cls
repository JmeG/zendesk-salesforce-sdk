// This class provides functionality to call the Zendesk Ticket Fields API
global class ZendeskTicketFieldsAPI extends ZendeskResourceBase {

    private Map<Long, ZTicketField> fieldsMap {get; private set; }

    global class TicketFieldWrapper {
        global ZTicketField ticket_field {get;set;}
        global TicketFieldWrapper(ZTicketField ticket_field) { this.ticket_field = ticket_field; }
    }

    global class TicketFieldsWrapper extends ZendeskPagingBase {
        global List<ZTicketField> ticket_fields {get;set;}
        global TicketFieldsWrapper(List<ZTicketField> ticket_fields) { this.ticket_fields = ticket_fields; }
    }

    global ZendeskTicketFieldsAPI(ZendeskConnection zconn) {
        super(zconn);
        fieldsMap = new Map<Long, ZTicketField>();
    }

    global ZTicketField getField(Long fieldId) {
        if (fieldId == null) { throw new ZendeskException('fieldId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/ticket_fields/'+fieldId+'.json');
        TicketFieldWrapper wrapper = (TicketFieldWrapper)JSON.deserialize(zconn.sendRequest(req), TicketFieldWrapper.class);
        return wrapper.ticket_field;
    }

    global TicketFieldsWrapper getFields() {
        return getFields(null);
    }
    global TicketFieldsWrapper getFields(Map<String, Object> queryParams) {
        HttpRequest req = zconn.createRequest('GET', '/ticket_fields.json', queryParams);
        return (TicketFieldsWrapper)JSON.deserialize(zconn.sendRequest(req), TicketFieldsWrapper.class);
    }

    global void deleteField(Long fieldId) {
        if (fieldId == null) { throw new ZendeskException('fieldId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('DELETE', '/ticket_fields/'+fieldId+'.json');
        zconn.sendRequest(req);
    }

    global Long createField(ZTicketField zfield) {
        if (zfield == null) { throw new ZendeskException('zfield parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('POST', '/ticket_fields.json');
        req.setBody(JSON.serialize(new TicketFieldWrapper(zfield)));
        TicketFieldWrapper resultWrapper = (TicketFieldWrapper)JSON.deserialize(zconn.sendRequest(req), TicketFieldWrapper.class);
        return ((resultWrapper==null || resultWrapper.ticket_field == null) ? null : resultWrapper.ticket_field.id);
    }

    global void updateField(Long fieldId, ZTicketField zfield) {
        if (fieldId == null) { throw new ZendeskException('fieldId parameter cannot be null'); }
        if (zfield == null) { throw new ZendeskException('zfield parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/ticket_fields/'+fieldId+'.json');
        req.setBody(JSON.serialize(new TicketFieldWrapper(zfield), true));
        zconn.sendRequest(req);
    }

    // Retrieves all pages of ticket fields. Uses the field "id" as the map key
    global Map<Long, ZTicketField> getAllFields() {
        if (fieldsMap.isEmpty()) {
            loadAll();
        }
        return fieldsMap;
    }

    private void loadAll() {
        TicketFieldsWrapper wrapper = getFields();
        if (wrapper != null && wrapper.ticket_fields != null) {
            for (ZTicketField obj : wrapper.ticket_fields) {
                fieldsMap.put(obj.id, obj);
            }

            while (!String.isEmpty(wrapper.next_page)) {
                wrapper = getFields(new Map<String, Object>{'page'=>wrapper.nextPageNumber});
                for (ZTicketField obj : wrapper.ticket_fields) {
                    fieldsMap.put(obj.id, obj);
                }
            }
        }
    }
}
