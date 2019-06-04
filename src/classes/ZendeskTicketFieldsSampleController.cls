public class ZendeskTicketFieldsSampleController {

    public String pageMessage { get; set; }
    public Long ticketFieldId { get; set; }
    public Map<Long, ZendeskTypes.ZTicketField> fieldsMap { get; set; }

    public ZendeskTicketFieldsSampleController() {}

    public PageReference getFields() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = ZendeskControllerSettings.getConnection();
            ZendeskTicketFieldsAPI zfields = new ZendeskTicketFieldsAPI(zconn);

            fieldsMap = zfields.getAllFields();
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

    public PageReference getFieldByID() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = ZendeskControllerSettings.getConnection();
            ZendeskTicketFieldsAPI zfields = new ZendeskTicketFieldsAPI(zconn);

            fieldsMap = new Map<Long, ZendeskTypes.ZTicketField>();
            ZendeskTypes.ZTicketField field = zfields.getField(ticketFieldId);
            if (field != null) {
                fieldsMap.put(field.id, field);
            }
            else {
                throw new ZendeskException('Ticket Field "' + ticketFieldId + '" not found');
            }
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }
}
