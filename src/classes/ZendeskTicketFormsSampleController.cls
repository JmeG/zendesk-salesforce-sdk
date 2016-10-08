public class ZendeskTicketFormsSampleController {

    public String subdomain { get; set; }
    public String username { get; set; }
    public String pwdOrToken { get; set; }
    public String authType { get; set; }

    public String pageMessage { get; set; }
    public Long ticketFormId { get; set; }
    public Map<Long, ZendeskTypes.ZTicketForm> formsMap { get; set; }

    public ZendeskTicketFormsSampleController() {}

    public PageReference getForms() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
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
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
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
