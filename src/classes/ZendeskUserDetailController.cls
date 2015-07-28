public class ZendeskUserDetailController {

    private String subdomain;
    private String username;
    private String pwdOrToken;
    private String authType;
    private ZendeskAPI zapi;
    private final Long userId;

    public String pageMessage {get;set;}
    public UIUser ui_user {get; private set;}

    public class UIUser{
        public String orgName {get;set;}

        public ZendeskTypes.ZUser user {get; private set;}
        public UIUser(ZendeskTypes.ZUser u) {
            this.user = u;
        }

        public String tags {
            get { return listToCSV(user.tags); }
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

    public void init() {
        loadUserDetails();
    }

    public PageReference loadUserDetails() {
        try {
            ui_user = null;

            ZendeskUsersAPI users_api = new ZendeskUsersAPI(zapi);
            ZendeskUsersAPI.UserWrapper userWrapper = users_api.getUser(userId);
            if (userWrapper != null && userWrapper.user != null) {
                ui_user = new UIUser(userWrapper.user);

                if (userWrapper.user.organization_id != null) {
                    ZendeskOrganizationsAPI orgs_api = new ZendeskOrganizationsAPI(zapi);
                    ZendeskOrganizationsAPI.OrganizationWrapper orgWrapper = orgs_api.getOrganization(userWrapper.user.organization_id);
                    if (orgWrapper != null && orgWrapper.organization != null) {
                        ui_user.orgName = orgWrapper.organization.name;
                    }
                }
            }
            else {
                throw new ZendeskException('No User found with id ' + userId);
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
