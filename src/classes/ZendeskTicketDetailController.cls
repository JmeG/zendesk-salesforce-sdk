public class ZendeskTicketDetailController {

    private final static Integer COMMENTS_PER_PAGE = 10;

    private String subdomain;
    private String username;
    private String pwdOrToken;
    private String authType;
    private ZendeskConnection zconn;
    private final Long ticketId;

    public String pageMessage { get; set; }
    public ZendeskTypes.ZTicketMetrics ticketMetrics { get; set; }
    public List<UITicketComment> ui_ticketComments { get; set; }
    public UITicket ui_ticket {get; private set;}

    public class UITicketComment {
        public ZendeskTypes.ZTicketComment comment {get; private set;}
        public UITicketComment(ZendeskTypes.ZTicketComment comment) {
            this.comment = comment;
        }

        public Boolean hasAttachments {
            get { return (comment.attachments != null && !comment.attachments.isEmpty()); }
        }

        public String authorName { get; set; }
    }

    public class UITicket {
        private Map<Long, String> userMap;
        private Map<Long, String> groupMap;
        public String orgName { get; set; }

        public ZendeskTypes.ZTicket ticket {get; private set;}
        public UITicket(ZendeskTypes.ZTicket t, Map<Long, String> userMap, Map<Long, String> groupMap) {
            ticket = t;
            this.userMap = userMap;
            this.groupMap = groupMap;
        }

        public String requestedBy {
            get {
                if (ticket.requester_id != null && userMap != null && userMap.containsKey(ticket.requester_id)) {
                    return userMap.get(ticket.requester_id);
                } else {
                    return null;
                }
            }
        }

        public String assignedTo {
            get {
                if (ticket.assignee_id != null && userMap != null && userMap.containsKey(ticket.assignee_id)) {
                    return userMap.get(ticket.assignee_id);
                } else {
                    return null;
                }
            }
        }

        public String groupName {
            get {
                if (ticket.group_id != null && groupMap != null && groupMap.containsKey(ticket.group_id)) {
                    return groupMap.get(ticket.group_id);
                } else {
                    return null;
                }
            }
        }

        public String createdVia {
            get {
                return (ticket.via != null && !String.isEmpty(ticket.via.channel) ? ticket.via.channel : null);
            }
        }

        public String tags {
            get { return listToCSV(ticket.tags); }
        }
    }

    public ZendeskTicketDetailController() {
        try {
            ticketId = Long.valueOf(ApexPages.currentPage().getParameters().get('id'));

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

    public Long previous_page { get; set; }
    public PageReference prevCommentsPage() {
        loadComments(previous_page);
        return null;
    }

    public Long next_page { get; set; }
    public PageReference nextCommentsPage() {
        loadComments(next_page);
        return null;
    }

    // Called on page load
    public void init() {
        loadTicketDetails();
    }

    public PageReference loadTicketDetails() {
        try {
            ui_ticket = null;
            ticketMetrics = null;
            ui_ticketComments = new List<UITicketComment>();

            ZendeskTicketsAPI tickets_api = new ZendeskTicketsAPI(zconn);
            ZendeskTicketsAPI.TicketWrapper ticketWrapper = tickets_api.getTicket(ticketId, new Map<String, Object>{'include'=>'users,groups,metric_sets'});
            if (ticketWrapper != null && ticketWrapper.ticket != null) {
                Map<Long, String> userMap = new Map<Long, String>();
                if (ticketWrapper.users != null && !ticketWrapper.users.isEmpty()) {
                    for (ZendeskTypes.ZUser u : ticketWrapper.users) {
                        userMap.put(u.id, u.name);
                    }
                }
                Map<Long, String> groupMap = new Map<Long, String>();
                if (ticketWrapper.groups != null && !ticketWrapper.groups.isEmpty()) {
                    for (ZendeskTypes.ZGroup g : ticketWrapper.groups) {
                        groupMap.put(g.id, g.name);
                    }
                }

                if (ticketWrapper.metric_sets != null) {
                    ticketMetrics = ticketWrapper.metric_sets[0];
                }

                ui_ticket = new UITicket(ticketWrapper.ticket, userMap, groupMap);

                if (ticketWrapper.ticket.organization_id != null) {
                    ZendeskOrganizationsAPI orgs_api = new ZendeskOrganizationsAPI(zconn);
                    ZendeskOrganizationsAPI.OrganizationWrapper orgwrapper = orgs_api.getOrganization(ticketWrapper.ticket.organization_id);
                    if (orgwrapper != null && orgwrapper.organization != null) {
                        ui_ticket.orgName = orgwrapper.organization.name;
                    }
                }

                // Load the first page of comments
                loadComments(null);
            }
            else {
                throw new ZendeskException('No Ticket found with id ' + ticketId);
            }
        } catch(Exception e) {
            pageMessage = e.getMessage();
        }

        return null;
    }

    public void loadComments(Long page) {
        ui_ticketComments = new List<UITicketComment>();

        // Get the ticket comments
        ZendeskTicketCommentsAPI comments_api = new ZendeskTicketCommentsAPI(zconn);
        Map<String, Object> qParams = new Map<String, Object> {'per_page'=>COMMENTS_PER_PAGE, 'include'=>'users'};
        if (page != null) {
            qParams.put('page', page);
        }
        ZendeskTicketCommentsAPI.TicketCommentsWrapper commentsWrapper = comments_api.getTicketComments(ticketId, qParams);

        previous_page = commentsWrapper.previousPageNumber;
        next_page = commentsWrapper.nextPageNumber;

        // Create a map of the side-loaded users
        Map<Long, String> usersMap = new Map<Long, String>();
        if (commentsWrapper.users != null) {
            for (ZendeskTypes.ZUser zu : commentsWrapper.users) {
                usersMap.put(zu.id, zu.name);
            }
        }

        for (ZendeskTypes.ZTicketComment comment : commentsWrapper.comments) {
            UITicketComment ui_comment = new UITicketComment(comment);
            if (usersMap.containsKey(comment.author_id)) {
                ui_comment.authorName = usersMap.get(comment.author_id);
            }
            ui_ticketComments.add(ui_comment);
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
