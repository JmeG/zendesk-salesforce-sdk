public class ZendeskTicketFormsSampleController {

    public String pageMessage { get; set; }
    public Long ticketFormId { get; set; }
    public Map<Long, ZendeskTypes.ZTicketForm> formsMap { get; set; }

    public ZendeskTicketFormsSampleController() {}

    public PageReference getForms() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = ZendeskControllerSettings.getConnection();
            ZendeskTicketFormsAPI zforms = new ZendeskTicketFormsAPI(zconn);

            formsMap = zforms.getAllTicketForms();
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

    public PageReference getFormById() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = ZendeskControllerSettings.getConnection();
            ZendeskTicketFormsAPI zforms = new ZendeskTicketFormsAPI(zconn);

            formsMap = new Map<Long, ZendeskTypes.ZTicketForm>();
            ZendeskTypes.ZTicketForm tf = zforms.getTicketForm(ticketFormId);
            if (tf != null) {
                formsMap.put(tf.id, tf);
            }
            else {
                throw new ZendeskException('Ticket Form "' + ticketFormId + '" not found');
            }
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }
}
