public class ZendeskAccountOrgsController {

    public final static Integer PER_PAGE { get; private set; }
    static {
        PER_PAGE = 5;
    }

    private String subdomain;
    private String username;
    private String pwdOrToken;
    private String authType;

    public final Account acct;
    public String pageMessage { get; set; }

    private Map<Long, String> groupsMap = null;

    public List<UIOrg> ui_orgs { get; set; }
    public class UIOrg {
        public ZendeskTypes.ZOrganization org {get; private set;}
        public String groupName { get; set; }
        public UIOrg(ZendeskTypes.ZOrganization org) {
            this.org = org;
        }

        public String domains {
            get {
                if (org.domain_names != null) {
                    String str = '';
                    for (String d : org.domain_names) {
                        str += d + ', ';
                    }
                    str = str.removeEnd(', ');
                    return str;
                } else {
                    return null;
                }
            }
        }
    }

    public ZendeskAccountOrgsController(ApexPages.StandardController controller) {
        try {
            this.acct = (Account)controller.getRecord();

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
        loadOrgs(null);
    }

    public Long total_matches { get; set; }
    public Long previous_page { get; set; }
    public Long next_page { get; set; }
    public PageReference prevPage() {
        loadOrgs(previous_page);
        return null;
    }
    public PageReference nextPage() {
        loadOrgs(next_page);
        return null;
    }

    public void loadOrgs(Long page) {
        ui_orgs = new List<UIOrg>();
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            zconn.debugResponseStatus = true;
            zconn.debugResponseBody = true;
            zconn.debugRequest = true;

            // Search for the Organizations by external_id
            ZendeskOrganizationsAPI orgs_api = new ZendeskOrganizationsAPI(zconn);
            Map<String, Object> qparams = new Map<String, Object>{'sort_order'=>'desc', 'per_page'=>PER_PAGE};
            if (page != null) {
                qparams.put('page', page);
            }
            ZendeskOrganizationsAPI.OrganizationsWrapper wrapper = orgs_api.searchOrganizationsByExternalId(acct.Id, qparams);
            if (wrapper != null && wrapper.organizations != null && wrapper.organizations.size() > 0) {
                previous_page = wrapper.previousPageNumber;
                next_page = wrapper.nextPageNumber;
                total_matches = wrapper.count;

                // Only fetch the groups once
                if (groupsMap == null) {
                    groupsMap = new Map<Long, String>();
                    ZendeskGroupsAPI groups_api = new ZendeskGroupsAPI(zconn);
                    ZendeskGroupsAPI.GroupsWrapper groupsWrapper = groups_api.getGroups();
                    for (ZendeskTypes.ZGroup g : groupsWrapper.groups) {
                        groupsMap.put(g.id, g.name);
                    }
                }

                for (ZendeskTypes.ZOrganization zorg : wrapper.organizations) {
                    UIOrg ui_org = new UIOrg(zorg);

                    // Get the Group associated with the Organization
                    if (zorg.group_id != null && groupsMap != null && groupsMap.containsKey(zorg.group_id)) {
                        ui_org.groupName = groupsMap.get(zorg.group_id);
                    }

                    ui_orgs.add(ui_org);
                }
            }
            else {
                throw new ZendeskException('No Zendesk Organizations found with external_id ' + acct.Id);
            }
        } catch(Exception e) {
            pageMessage = e.getMessage();
        }
    }
}
