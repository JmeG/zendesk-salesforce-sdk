public with sharing class ZendeskGroupsSampleController {

	public String subdomain {get;set;}
	public String username {get;set;}
	public String pwdOrToken {get;set;}
	public String authType {get;set;}

	public String pageMessage {get;set;}
	public String searchText {get;set;}
	public Map<String, ZendeskGroups.ZGroup> groupsMap {get;set;}

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

	public PageReference findGroupByName() {
		pageMessage = '';
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskGroups zgroups = new ZendeskGroups(zapi);

			groupsMap = new Map<String, ZendeskGroups.ZGroup>();
			ZendeskGroups.ZGroup g = zgroups.getGroup(searchText);
			if (g != null) {
				groupsMap.put(g.name, g);
			}
			else {
				throw new ZendeskException('Group "' + searchText + '" not found');
			}
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}
}
