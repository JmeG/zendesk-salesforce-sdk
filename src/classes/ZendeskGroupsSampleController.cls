public class ZendeskGroupsSampleController {

    public String subdomain { get; set; }
    public String username { get; set; }
    public String pwdOrToken { get; set; }
    public String authType { get; set; }

    public String pageMessage { get; set; }
    public Long groupId { get; set; }
    public Long userId { get; set; }
    public Map<Long, ZendeskTypes.ZGroup> groupsMap { get; set; }

    public ZendeskGroupsSampleController() {}

    public PageReference getGroups() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskGroupsAPI zgroups = new ZendeskGroupsAPI(zconn);

            groupsMap = zgroups.getAllGroups();
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

    public PageReference getGroupById() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskGroupsAPI zgroups = new ZendeskGroupsAPI(zconn);

            groupsMap = new Map<Long, ZendeskTypes.ZGroup>();
            ZendeskGroupsAPI.GroupWrapper gw = zgroups.getGroup(groupId);
            if (gw != null && gw.x_group != null) {
                groupsMap.put(gw.x_group.id, gw.x_group);
            }
            else {
                throw new ZendeskException('Group "' + groupId + '" not found');
            }
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

    public PageReference getAssignableGroups() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskGroupsAPI zgroups = new ZendeskGroupsAPI(zconn);

            ZendeskGroupsAPI.GroupsWrapper wrapper = zgroups.getAssignableGroups();
            groupsMap = new Map<Long, ZendeskTypes.ZGroup>();
            for (ZendeskTypes.ZGroup grp : wrapper.groups) {
                groupsMap.put(grp.id, grp);
            }
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

    public PageReference getUserGroups() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskGroupsAPI zgroups = new ZendeskGroupsAPI(zconn);

            ZendeskGroupsAPI.GroupsWrapper wrapper = zgroups.getUserGroups(userId);
            groupsMap = new Map<Long, ZendeskTypes.ZGroup>();
            for (ZendeskTypes.ZGroup grp : wrapper.groups) {
                groupsMap.put(grp.id, grp);
            }
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }
}
