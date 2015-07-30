public class ZendeskOrganizationsSampleController {

	public String subdomain {get;set;}
	public String username {get;set;}
	public String pwdOrToken {get;set;}
	public String authType {get;set;}

	public String pageMessage {get;set;}
	public Long organizationId {get;set;}
	public ZendeskTypes.ZOrganization[] organizations {get;set;}

	public ZendeskOrganizationsSampleController() {}

	public PageReference getOrganizations() {
		pageMessage = '';
		organizations = null;
		try {
			ZendeskConnection zconn = new ZendeskConnection(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskConnection.AuthType.Password : ZendeskConnection.AuthType.Token));
			ZendeskOrganizationsAPI zorganizations = new ZendeskOrganizationsAPI(zconn);

			ZendeskOrganizationsAPI.OrganizationsWrapper wrapper = zorganizations.getOrganizations();
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
			ZendeskConnection zconn = new ZendeskConnection(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskConnection.AuthType.Password : ZendeskConnection.AuthType.Token));
			ZendeskOrganizationsAPI zorganizations = new ZendeskOrganizationsAPI(zconn);

			ZendeskOrganizationsAPI.OrganizationWrapper wrapper = zorganizations.getOrganization(organizationId);
			if (wrapper != null && wrapper.organization != null) {
				organizations = new ZendeskTypes.ZOrganization[]{ wrapper.organization };
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
