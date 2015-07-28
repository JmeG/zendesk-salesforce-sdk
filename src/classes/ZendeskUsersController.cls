public class ZendeskUsersController {

    private final static Integer PER_PAGE = 30;

    private String subdomain;
    private String username;
    private String pwdOrToken;
    private String authType;
    private ZendeskAPI zapi;
    private final Long orgId;
    private final Long groupId;

    public String pageMessage {get;set;}
    public List<UIUser> ui_users {get; private set;}

    public class UIUser {
        public ZendeskTypes.ZUser user {get; private set;}
        public UIUser(ZendeskTypes.ZUser u) {
            this.user = u;
        }
    }

    public ZendeskUsersController() {
        try {
            String orgIdStr = ApexPages.currentPage().getParameters().get('org_id');
            if (!String.isEmpty(orgIdStr)) {
                orgId = Long.valueOf(orgIdStr);
            }
            String groupIdStr = ApexPages.currentPage().getParameters().get('group_id');
            if (!String.isEmpty(groupIdStr)) {
                groupId = Long.valueOf(groupIdStr);
            }

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

    public Long previous_page {get;set;}
    public PageReference prevPage() {
        loadUsers(previous_page);
        return null;
    }

    public Long next_page {get;set;}
    public PageReference nextPage() {
        loadUsers(next_page);
        return null;
    }


    public void init() {
        loadUsers(null);
    }

    public void loadUsers(Long page) {
        ui_users = new List<UIUser>();

        // Get the ticket comments
        ZendeskUsersAPI users_api = new ZendeskUsersAPI(zapi);
        Map<String, Object> qParams = new Map<String, Object> {'per_page'=>PER_PAGE};
        if (page != null) {
            qParams.put('page', page);
        }
        ZendeskUsersAPI.UsersWrapper usersWrapper = null;
        if (orgId != null) {
            usersWrapper = users_api.getUsersByOrganization(orgId, qParams);
        } else if (groupId != null) {
            usersWrapper = users_api.getUsersByGroup(groupId, qParams);
        } else {
            throw new ZendeskException('org_id or group_id parameter must be specified');
        }

        previous_page = usersWrapper.previousPageNumber;
        next_page = usersWrapper.nextPageNumber;

        for (ZendeskTypes.ZUser user : usersWrapper.users) {
            ui_users.add(new UIUser(user));
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
