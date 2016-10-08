public class ZendeskOrgSearchController {

    private final static Integer ORGS_PER_PAGE = 30;

    public String subdomain {get; private set;}
    private String username;
    private String pwdOrToken;
    private String authType;
    private ZendeskConnection zconn;

    public String pageMessage { get; set; }
    public String searchText { get; set; }
    public List<UIOrg> ui_orgs {get; private set;}

    public class UIOrg {
        public ZendeskTypes.ZOrganization org {get; private set;}
        public UIOrg(ZendeskTypes.ZOrganization org) {
            this.org = org;
        }

        public String domains {
            get { return listToCSV(org.domain_names).abbreviate(40); }
        }

        public String tags {
            get { return listToCSV(org.tags).abbreviate(50); }
        }
    }

    public ZendeskOrgSearchController() {
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
        try {
            ZendeskOrganizationsAPI orgs_api = new ZendeskOrganizationsAPI(zconn);
            ZendeskOrganizationsAPI.OrganizationsWrapper orgsWrapper = null;

            Map<String, Object> qparams = new Map<String, Object>{'per_page'=>ORGS_PER_PAGE};
            if (page != null) {
                qparams.put('page', page);
            }

            if (String.isEmpty(searchText) || searchText.length() < 2) {
                // Default to showing all orgs if no search text is specified
                orgsWrapper = orgs_api.getOrganizations(qparams);
            }
            else {
                orgsWrapper = orgs_api.autocompleteSearch(searchText, qparams);
            }

            previous_page = orgsWrapper.previousPageNumber;
            next_page = orgsWrapper.nextPageNumber;

            ui_orgs = new List<UIOrg>();
            for (ZendeskTypes.ZOrganization org : orgsWrapper.organizations) {
                ui_orgs.add(new UIOrg(org));
            }
        } catch(Exception e) {
            pageMessage = e.getMessage();
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
