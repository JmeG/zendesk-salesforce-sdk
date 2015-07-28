public class ZendeskOrgDetailController {

    private final static Integer TICKETS_PER_PAGE = 20;

    private String subdomain;
    private String username;
    private String pwdOrToken;
    private String authType;
    private final Long orgId;
    private ZendeskAPI zapi;

    public String pageMessage {get;set;}
    public UIOrg ui_org {get; private set;}
    public List<UITicket> ui_tickets {get;set;}

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


    public ZendeskOrgDetailController() {
        try {
            orgId = Long.valueOf(ApexPages.currentPage().getParameters().get('id'));

            Zendesk_API__c settings = Zendesk_API__c.getInstance();
            if (settings != null) {
                subdomain = settings.Subdomain__c;
                username = settings.Username__c;
                pwdOrToken = settings.Password_or_Token__c;
                authType = settings.Authentication_Type__c;

                zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
                zapi.debugResponseStatus = true;
                zapi.debugResponseBody = true;
                zapi.debugRequest = true;
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

    public Long previous_page {get;set;}
    public PageReference prevTicketPage() {
        loadTickets(previous_page);
        return null;
    }

    public Long next_page {get;set;}
    public PageReference nextTicketPage() {
        loadTickets(next_page);
        return null;
    }

    public void loadTickets(Long page) {
        ui_tickets = new List<UITicket>();

        // Get Tickets for the Organization
        ZendeskTicketsAPI tickets_api = new ZendeskTicketsAPI(zapi);
        Map<String, Object> qparams = new Map<String, Object>{'include'=>'users,groups', 'sort_order'=>'desc', 'per_page'=>TICKETS_PER_PAGE};
        if (page != null) {
            qparams.put('page', page);
        }
        ZendeskTicketsAPI.TicketsWrapper ticketsWrapper = tickets_api.getTicketsByOrgId(orgId, qparams);
        previous_page = ticketsWrapper.previousPageNumber;
        next_page = ticketsWrapper.nextPageNumber;

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

    public PageReference loadOrgDetails() {
        try {
            ui_org = null;

            // Search for the Organization by external_id
            ZendeskOrganizationsAPI orgs_api = new ZendeskOrganizationsAPI(zapi);
            ZendeskOrganizationsAPI.OrganizationWrapper orgWrapper = orgs_api.getOrganization(orgId);
            if (orgWrapper != null && orgWrapper.organization != null) {
                ZendeskTypes.ZOrganization zorg = orgWrapper.organization;
                ui_org = new UIOrg(zorg);

                // Get the Group associated with the Organization
                if (zorg.group_id != null) {
                    ZendeskGroupsAPI groups_api = new ZendeskGroupsAPI(zapi);
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
