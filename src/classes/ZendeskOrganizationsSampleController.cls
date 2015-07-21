public with sharing class ZendeskOrganizationsSampleController {

	public String subdomain {get;set;}
	public String username {get;set;}
	public String pwdOrToken {get;set;}
	public String authType {get;set;}

	public String pageMessage {get;set;}
	public Long organizationId {get;set;}
	public ZendeskOrganizations.ZOrganization[] organizations {get;set;}

	public ZendeskOrganizationsSampleController() {}

	public PageReference getOrganizations() {
		pageMessage = '';
		organizations = null;
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskOrganizations zorganizations = new ZendeskOrganizations(zapi);

			ZendeskOrganizations.OrganizationsWrapper wrapper = zorganizations.getOrganizations();
			organizations = wrapper.organizations;
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}

	public PageReference getOrganizationById() {
		pageMessage = '';
		organizations = null;
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskOrganizations zorganizations = new ZendeskOrganizations(zapi);

			ZendeskOrganizations.ZOrganization org = zorganizations.getOrganization(organizationId);
			if (org != null) {
				organizations = new ZendeskOrganizations.ZOrganization[]{ org };
			}
			else {
				throw new ZendeskException('Organization "' + organizationId + '" not found');
			}
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}

}