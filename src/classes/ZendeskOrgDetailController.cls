public class ZendeskOrgDetailController {

    private final static Integer TICKETS_PER_PAGE = 10;
    private final static Integer USERS_PER_PAGE = 10;

    public String subdomain {get;set;}
    private String username;
    private String pwdOrToken;
    private String authType;
    private final Long orgId;
    private ZendeskConnection zconn;

    public String pageMessage {get;set;}
    public UIOrg ui_org {get; private set;}
    public List<UITicket> ui_tickets {get;set;}
    public List<UIUser> ui_users {get;set;}

    public class UIOrg {
        public ZendeskTypes.ZOrganization org {get; private set;}
        public UIOrg(ZendeskTypes.ZOrganization org) {
            this.org = org;
        }

        public String domains {
            get { return listToCSV(org.domain_names); }
        }

        public String tags {
            get { return listToCSV(org.tags); }
        }

        public String groupName {get;set;}
        public Integer usersCount {get;set;}
        public Integer ticketsCount {get;set;}
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

    public class UIUser {
        public ZendeskTypes.ZUser user {get; private set;}
        public UIUser(ZendeskTypes.ZUser u) {
            user = u;
        }
    }


    public ZendeskOrgDetailController() {
        try {
            orgId = Long.valueOf(ApexPages.currentPage().getParameters().get('id'));

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

    // Called on page load
    public void init() {
        loadOrgDetails();
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
    public Long total_tickets {get;set;}
    public Long current_tickets_page {
        get {
            if (previous_tickets_page != null) return previous_tickets_page + 1;
            else if (next_tickets_page != null) return next_tickets_page - 1;
            else return 1;
        }
    }

    public Long previous_tickets_page {get;set;}
    public PageReference prevTicketPage() {
        loadTickets(previous_tickets_page);
        return null;
    }

    public Long next_tickets_page {get;set;}
    public PageReference nextTicketPage() {
        loadTickets(next_tickets_page);
        return null;
    }

    public void loadTickets(Long page) {
        ui_tickets = new List<UITicket>();

        // Get Tickets for the Organization
        ZendeskTicketsAPI tickets_api = new ZendeskTicketsAPI(zconn);
        Map<String, Object> qparams = new Map<String, Object>{'include'=>'users,groups', 'sort_order'=>'desc', 'per_page'=>TICKETS_PER_PAGE};
        if (page != null) {
            qparams.put('page', page);
        }
        ZendeskTicketsAPI.TicketsWrapper ticketsWrapper = tickets_api.getTicketsByOrgId(orgId, qparams);
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

    public Integer total_user_pages {
        get {
            if (Math.mod(total_users, USERS_PER_PAGE) == 0) {
                return Integer.valueOf(total_users / USERS_PER_PAGE);
            } else {
                return Integer.valueOf(total_users / USERS_PER_PAGE) + 1;
            }
        }
    }
    public Long total_users {get;set;}
    public Long current_users_page {
        get {
            if (previous_users_page != null) return previous_users_page + 1;
            else if (next_users_page != null) return next_users_page - 1;
            else return 1;
        }
    }

    public Long previous_users_page {get;set;}
    public PageReference prevUserPage() {
        loadUsers(previous_users_page);
        return null;
    }

    public Long next_users_page {get;set;}
    public PageReference nextUserPage() {
        loadUsers(next_users_page);
        return null;
    }

    public void loadUsers(Long page) {
        ui_users = new List<UIUser>();

        // Get Users for the Organization
        ZendeskUsersAPI users_api = new ZendeskUsersAPI(zconn);
        Map<String, Object> qparams = new Map<String, Object>{'sort_order'=>'desc', 'per_page'=>USERS_PER_PAGE};
        if (page != null) {
            qparams.put('page', page);
        }
        ZendeskUsersAPI.UsersWrapper usersWrapper = users_api.getUsersByOrganization(orgId, qparams);
        previous_users_page = usersWrapper.previousPageNumber;
        next_users_page = usersWrapper.nextPageNumber;
        total_users = usersWrapper.count;

        if (usersWrapper != null && usersWrapper.users != null && !usersWrapper.users.isEmpty()) {
            for (ZendeskTypes.ZUser u : usersWrapper.users) {
                ui_users.add(new UIUser(u));
            }
        }
    }

    public PageReference loadOrgDetails() {
        try {
            ui_org = null;

            // Search for the Organization by external_id
            ZendeskOrganizationsAPI orgs_api = new ZendeskOrganizationsAPI(zconn);
            ZendeskOrganizationsAPI.OrganizationWrapper orgWrapper = orgs_api.getOrganization(orgId);
            if (orgWrapper != null && orgWrapper.organization != null) {
                ZendeskTypes.ZOrganization zorg = orgWrapper.organization;
                ui_org = new UIOrg(zorg);

                // Get the Group associated with the Organization
                if (zorg.group_id != null) {
                    ZendeskGroupsAPI groups_api = new ZendeskGroupsAPI(zconn);
                    ZendeskGroupsAPI.GroupWrapper groupWrapper = groups_api.getGroup(zorg.group_id);
                    if (groupWrapper != null && groupWrapper.x_group != null) {
                        ui_org.groupName = groupWrapper.x_group.name;
                    }
                }

                // Get Org Related Info
                Map<String, Object> orgRelatedInfo = orgs_api.getOrganizationRelatedInfo(orgId);
                if (orgRelatedInfo != null) {
                    // {"organization_related":{"users_count":1,"tickets_count":3}}
                    if (orgRelatedInfo.containsKey('organization_related')) {
                        Map<String, Object> related = (Map<String, Object>)orgRelatedInfo.get('organization_related');
                        if (related != null && related.containsKey('users_count')) {
                            ui_org.usersCount = (Integer)related.get('users_count');
                        }
                        if (related != null && related.containsKey('tickets_count')) {
                            ui_org.ticketsCount = (Integer)related.get('tickets_count');
                        }
                    }
                }

                // Load the first page of tickets
                loadTickets(null);

                // Load the first page of users
                loadUsers(null);
            }
            else {
                throw new ZendeskException('No Organization found with id ' + orgId);
            }
        } catch(Exception e) {
            pageMessage = e.getMessage();
        }

        return null;
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
