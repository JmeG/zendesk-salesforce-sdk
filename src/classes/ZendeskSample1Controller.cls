public with sharing class ZendeskSample1Controller {

	public String subdomain {get;set;}
	public String username {get;set;}
	public String pwdOrToken {get;set;}
	public String authType {get;set;}

	public ZendeskSample1Controller() {
		Zendesk_API__c settings = Zendesk_API__c.getOrgDefaults();
		if (settings != null) {
			subdomain = settings.Subdomain__c;
			username = settings.Username__c;
			pwdOrToken = settings.Password_or_Token__c;
			authType = settings.Authentication_Type__c;
		}
	}

	// This method simply exists so that changes to API fields are saved in the controller
	// without a postback
	public void changeAPIdetails() {
    	System.debug('changeAPIdetails');
	}
}
