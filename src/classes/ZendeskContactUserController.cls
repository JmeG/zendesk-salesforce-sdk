public class ZendeskContactUserController {

    public final static Integer PER_PAGE { get; private set; }
    static {
        PER_PAGE = 5;
    }

    private String subdomain;
    private String username;
    private String pwdOrToken;
    private String authType;

    public final Contact con;
    public String pageMessage { get; set; }

    public UIUser ui_user { get; set; }
    public class UIUser {
        public ZendeskTypes.ZUser user {get; private set;}
        public UIUser(ZendeskTypes.ZUser user) {
            this.user = user;
        }
    }

    public ZendeskContactUserController(ApexPages.StandardController controller) {
        try {
            if (!Test.isRunningTest()) { controller.addFields(new List<String>{'Email'}); }

            this.con = (Contact)controller.getRecord();

            Zendesk_API__c settings = Zendesk_API__c.getInstance();
            if (settings != null) {
                subdomain = settings.Subdomain__c;
                username = settings.Username__c;
                pwdOrToken = settings.Password_or_Token__c;
                authType = settings.Authentication_Type__c;
            }
            else {
                pageMessage = 'Zendesk API settings are not configured';
            }
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
    }

    public void init() {
        findUser();
    }

    public void findUser() {
        ui_user = null;
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);

            // Search for the User by email address
            ZendeskUsersAPI users_api = new ZendeskUsersAPI(zconn);
            if (String.isEmpty(con.Email)) {
                throw new ZendeskException('Contact must have an Email address');
            }
            // NOTE: instead of looking up by Email you could do a lookup by ExternalID
            // users_api.searchUsersByExternalId(con.Id);
            ZendeskTypes.ZUser user = users_api.findUserByEmail(con.Email);
            if (user != null) {
                ui_user = new UIUser(user);
            } else {
                throw new ZendeskException('No Zendesk user found with email ' + con.Email);
            }

            /*
            ZendeskTicketsAPI tickets_api = new ZendeskTicketsAPI(zconn);
            ZendeskTicketsAPI.TicketsWrapper ticketsWrapper = tickets_api.getTicketsByRequesterId(user.id);
            if (ticketsWrapper != null && ticketsWrapper.tickets != null && ticketsWrapper.tickets.size() > 0) {
                for (ZendeskTypes.ZTicket ztik : ticketsWrapper.tickets) {
                    UITicket ui_ticket = new UITicket(ztik);
                    ui_tickets.add(ui_ticket);
                }
            }
            */
        } catch(Exception e) {
            pageMessage = e.getMessage();
        }
    }
}
