public with sharing class ZendeskGroupsSampleController {

	public String subdomain {get;set;}
	public String username {get;set;}
	public String pwdOrToken {get;set;}
	public String authType {get;set;}

	public String pageMessage {get;set;}
	public Long groupId {get;set;}
	public Long userId {get;set;}
	public Map<Long, ZendeskGroups.ZGroup> groupsMap {get;set;}

	public ZendeskGroupsSampleController() {}

	public PageReference getGroups() {
		pageMessage = '';
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskGroups zgroups = new ZendeskGroups(zapi);

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
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskGroups zgroups = new ZendeskGroups(zapi);

			groupsMap = new Map<Long, ZendeskGroups.ZGroup>();
			ZendeskGroups.ZGroup g = zgroups.getGroup(groupId);
			if (g != null) {
				groupsMap.put(g.id, g);
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
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskGroups zgroups = new ZendeskGroups(zapi);

			ZendeskGroups.GroupsWrapper wrapper = zgroups.getAssignableGroups();
			groupsMap = new Map<Long, ZendeskGroups.ZGroup>();
			for (ZendeskGroups.ZGroup grp : wrapper.groups) {
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
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskGroups zgroups = new ZendeskGroups(zapi);

			ZendeskGroups.GroupsWrapper wrapper = zgroups.getUserGroups(userId);
			groupsMap = new Map<Long, ZendeskGroups.ZGroup>();
			for (ZendeskGroups.ZGroup grp : wrapper.groups) {
				groupsMap.put(grp.id, grp);
			}
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}
}