public class ZendeskUserDetailController {

    public final static Integer TICKETS_PER_PAGE { get; private set; }
    static {
        TICKETS_PER_PAGE = 10;
    }

    private String subdomain;
    private String username;
    private String pwdOrToken;
    private String authType;
    private ZendeskConnection zconn;
    private final Long userId;

    public String pageMessage { get; set; }
    public UIUser ui_user {get; private set;}
    public List<UITicket> ui_tickets { get; set; }

    public class UIUser{
        public String orgName { get; set; }

        public ZendeskTypes.ZUser user {get; private set;}
        public UIUser(ZendeskTypes.ZUser u) {
            this.user = u;
        }

        public String tags {
            get { return listToCSV(user.tags); }
        }
    }

    public class UITicket {
        private Map<Long, String> usersMap;
        private Map<Long, String> groupsMap;

        public ZendeskTypes.ZTicket ticket {get; private set;}
        public UITicket(ZendeskTypes.ZTicket t, Map<Long, String> usersMap, Map<Long, String> groupsMap) {
            ticket = t;
            this.usersMap = usersMap;
            this.groupsMap = groupsMap;
        }

        public String requestedBy {
            get {
                if (ticket.requester_id != null && usersMap != null && usersMap.containsKey(ticket.requester_id)) {
                    return usersMap.get(ticket.requester_id);
                } else {
                    return null;
                }
            }
        }

        public String assignedTo {
            get {
                if (ticket.assignee_id != null && usersMap != null && usersMap.containsKey(ticket.assignee_id)) {
                    return usersMap.get(ticket.assignee_id);
                } else {
                    return null;
                }
            }
        }

        public String groupName {
            get {
                if (ticket.group_id != null && groupsMap != null && groupsMap.containsKey(ticket.group_id)) {
                    return groupsMap.get(ticket.group_id);
                } else {
                    return null;
                }
            }
        }
    }

    public ZendeskUserDetailController() {
        try {
            userId = Long.valueOf(ApexPages.currentPage().getParameters().get('id'));

            Zendesk_API__c settings = Zendesk_API__c.getInstance();
            if (settings != null) {
                subdomain = settings.Subdomain__c;
                username = settings.Username__c;
                pwdOrToken = settings.Password_or_Token__c;
                authType = settings.Authentication_Type__c;

                zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
                zconn.debugResponseStatus = true;
                zconn.debugResponseBody = true;
                zconn.debugRequest = true;
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
        loadUserDetails();
    }

    public PageReference loadUserDetails() {
        try {
            ui_user = null;

            ZendeskUsersAPI users_api = new ZendeskUsersAPI(zconn);
            ZendeskUsersAPI.UserWrapper userWrapper = users_api.getUser(userId);
            if (userWrapper != null && userWrapper.user != null) {
                ui_user = new UIUser(userWrapper.user);

                if (userWrapper.user.organization_id != null) {
                    ZendeskOrganizationsAPI orgs_api = new ZendeskOrganizationsAPI(zconn);
                    ZendeskOrganizationsAPI.OrganizationWrapper orgWrapper = orgs_api.getOrganization(userWrapper.user.organization_id);
                    if (orgWrapper != null && orgWrapper.organization != null) {
                        ui_user.orgName = orgWrapper.organization.name;
                    }
                }

                // Load the first page of tickets
                loadTickets(null);
            }
            else {
                throw new ZendeskException('No User found with id ' + userId);
            }
        } catch(Exception e) {
            pageMessage = e.getMessage();
        }

        return null;
    }

    public Integer total_ticket_pages {
        get {
            if (Math.mod(total_tickets, TICKETS_PER_PAGE) == 0) {
                return Integer.valueOf(total_tickets / TICKETS_PER_PAGE);
            } else {
                return Integer.valueOf(total_tickets / TICKETS_PER_PAGE) + 1;
            }
        }
    }
    public Long total_tickets { get; set; }
    public Long current_tickets_page {
        get {
            if (previous_tickets_page != null) return previous_tickets_page + 1;
            else if (next_tickets_page != null) return next_tickets_page - 1;
            else return 1;
        }
    }
    public Long previous_tickets_page { get; set; }
    public PageReference prevTicketPage() {
        loadTickets(previous_tickets_page);
        return null;
    }
    public Long next_tickets_page { get; set; }
    public PageReference nextTicketPage() {
        loadTickets(next_tickets_page);
        return null;
    }

    public void loadTickets(Long page) {
        ui_tickets = new List<UITicket>();

        // Get Tickets for the User
        ZendeskTicketsAPI tickets_api = new ZendeskTicketsAPI(zconn);
        Map<String, Object> qparams = new Map<String, Object>{'include'=>'users,groups', 'sort_order'=>'desc', 'per_page'=>TICKETS_PER_PAGE};
        if (page != null) {
            qparams.put('page', page);
        }
        ZendeskTicketsAPI.TicketsWrapper ticketsWrapper = tickets_api.getTicketsByRequesterId(userId, qparams);
        previous_tickets_page = ticketsWrapper.previousPageNumber;
        next_tickets_page = ticketsWrapper.nextPageNumber;
        total_tickets = ticketsWrapper.count;

        // Build a map of User name's related to the tickets
        Map<Long, String> ticketUsersMap = new Map<Long, String>();
        if (ticketsWrapper != null && ticketsWrapper.users != null && !ticketsWrapper.users.isEmpty()) {
            for (ZendeskTypes.ZUser u : ticketsWrapper.users) {
                ticketUsersMap.put(u.id, u.name);
            }
        }

        // Build a map of Group name's related to the tickets
        Map<Long, String> ticketGroupsMap = new Map<Long, String>();
        if (ticketsWrapper != null && ticketsWrapper.groups != null && !ticketsWrapper.groups.isEmpty()) {
            for (ZendeskTypes.ZGroup g : ticketsWrapper.groups) {
                ticketGroupsMap.put(g.id, g.name);
            }
        }

        if (ticketsWrapper != null && ticketsWrapper.tickets != null && !ticketsWrapper.tickets.isEmpty()) {
            for (ZendeskTypes.ZTicket t : ticketsWrapper.tickets) {
                ui_tickets.add(new UITicket(t, ticketUsersMap, ticketGroupsMap));
            }
        }
    }

    public static String listToCSV(List<String> strList) {
        if (strList != null) {
            String str = '';
            for (String t : strList) { str += t + ', '; }
            str = str.removeEnd(', ');
            return str;
        } else {
            return '';
        }
    }
}
