public class ZendeskSearchController {

    private final static Integer PER_PAGE = 30;

    public String subdomain {get; private set;}
    private String username;
    private String pwdOrToken;
    private String authType;
    private ZendeskConnection zconn;

    public String pageMessage { get; set; }
    public String searchText { get; set; }
    public List<UISearchRseult> ui_searchResults {get; private set;}

    public class UISearchRseult {
        public Object obj {get; private set;}
        public UISearchRseult(Object obj) {
            this.obj = obj;
        }

        public String resultType {
            get {
                if (obj instanceof ZendeskTypes.ZTicket) { return 'ticket'; }
                else if (obj instanceof ZendeskTypes.ZUser) { return 'user'; }
                else if (obj instanceof ZendeskTypes.ZOrganization) { return 'organization'; }
                else if (obj instanceof ZendeskTypes.ZGroup) { return 'group'; }
                else if (obj instanceof ZendeskTypes.ZTopic) { return 'topic'; }
                else { return 'unknown'; }
            }
        }

        public Long resultId {
            get {
                if (obj instanceof ZendeskTypes.ZTicket) {
                    ZendeskTypes.ZTicket zt = (ZendeskTypes.ZTicket)obj;
                    return zt.id;
                } else if (obj instanceof ZendeskTypes.ZUser) {
                    ZendeskTypes.ZUser zu = (ZendeskTypes.ZUser)obj;
                    return zu.id;
                } else if (obj instanceof ZendeskTypes.ZOrganization) {
                    ZendeskTypes.ZOrganization zo = (ZendeskTypes.ZOrganization)obj;
                    return zo.id;
                } else if (obj instanceof ZendeskTypes.ZGroup) {
                    ZendeskTypes.ZGroup zg = (ZendeskTypes.ZGroup)obj;
                    return zg.id;
                } else if (obj instanceof ZendeskTypes.ZTopic) {
                    ZendeskTypes.ZTopic zt = (ZendeskTypes.ZTopic)obj;
                    return zt.id;
                } else {
                    return null;
                }
            }
        }

        public String resultName {
            get {
                if (obj instanceof ZendeskTypes.ZTicket) {
                    ZendeskTypes.ZTicket zt = (ZendeskTypes.ZTicket)obj;
                    return zt.subject;
                } else if (obj instanceof ZendeskTypes.ZUser) {
                    ZendeskTypes.ZUser zu = (ZendeskTypes.ZUser)obj;
                    return zu.name;
                } else if (obj instanceof ZendeskTypes.ZOrganization) {
                    ZendeskTypes.ZOrganization zo = (ZendeskTypes.ZOrganization)obj;
                    return zo.name;
                } else if (obj instanceof ZendeskTypes.ZGroup) {
                    ZendeskTypes.ZGroup zg = (ZendeskTypes.ZGroup)obj;
                    return zg.name;
                } else if (obj instanceof ZendeskTypes.ZTopic) {
                    ZendeskTypes.ZTopic zt = (ZendeskTypes.ZTopic)obj;
                    return zt.title;
                } else {
                    return 'unknown';
                }
            }
        }

        public String resultLink {
            get {
                if (obj instanceof ZendeskTypes.ZTicket) {
                    ZendeskTypes.ZTicket zt = (ZendeskTypes.ZTicket)obj;
                    return '/apex/ZendeskTicketDetail?id=' + zt.id;
                } else if (obj instanceof ZendeskTypes.ZUser) {
                    ZendeskTypes.ZUser zu = (ZendeskTypes.ZUser)obj;
                    return '/apex/ZendeskUserDetail?id=' + zu.id;
                } else if (obj instanceof ZendeskTypes.ZOrganization) {
                    ZendeskTypes.ZOrganization zo = (ZendeskTypes.ZOrganization)obj;
                    return '/apex/ZendeskOrgDetail?id=' + zo.id;
                } else {
                    return null;
                }
            }
        }

        public DateTime createdDate {
            get {
                if (obj instanceof ZendeskTypes.ZTicket) {
                    ZendeskTypes.ZTicket zt = (ZendeskTypes.ZTicket)obj;
                    return zt.created_at;
                } else if (obj instanceof ZendeskTypes.ZUser) {
                    ZendeskTypes.ZUser zu = (ZendeskTypes.ZUser)obj;
                    return zu.created_at;
                } else if (obj instanceof ZendeskTypes.ZOrganization) {
                    ZendeskTypes.ZOrganization zo = (ZendeskTypes.ZOrganization)obj;
                    return zo.created_at;
                } else if (obj instanceof ZendeskTypes.ZGroup) {
                    ZendeskTypes.ZGroup zg = (ZendeskTypes.ZGroup)obj;
                    return zg.created_at;
                } else {
                    return null;
                }
            }
        }
    }

    public ZendeskSearchController() {
        try {
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
    public PageReference prevPage() {
        doSearch(previous_page);
        return null;
    }

    public Long next_page { get; set; }
    public PageReference nextPage() {
        doSearch(next_page);
        return null;
    }

    public PageReference search() {
        doSearch(null);
        return null;
    }

    public void doSearch(Long page) {
        ui_searchResults = new List<UISearchRseult>();
        try {
            if (!String.isEmpty(searchText)) {
                Map<String, Object> qparams = new Map<String, Object>{'per_page'=>PER_PAGE};
                if (page != null) {
                    qparams.put('page', page);
                }

                ZendeskSearchAPI search_api = new ZendeskSearchAPI(zconn);
                ZendeskSearchAPI.SearchResultsWrapper resultsWrapper = search_api.search(searchText, qparams);
                previous_page = resultsWrapper.previousPageNumber;
                next_page = resultsWrapper.nextPageNumber;

                for (Object obj : resultsWrapper.objResults) {
                    ui_searchResults.add(new UISearchRseult(obj));
                }
            }
        } catch(Exception e) {
            pageMessage = e.getMessage();
        }
    }
}
