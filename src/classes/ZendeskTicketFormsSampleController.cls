public with sharing class ZendeskTicketFormsSampleController {

	public String subdomain {get;set;}
	public String username {get;set;}
	public String pwdOrToken {get;set;}
	public String authType {get;set;}

	public String pageMessage {get;set;}
	public Integer ticketFormId {get;set;}
	public Map<Integer, ZendeskTicketForms.ZTicketForm> formsMap {get;set;}

	public ZendeskTicketFormsSampleController() {}

	public PageReference getForms() {
		pageMessage = '';
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskTicketForms zforms = new ZendeskTicketForms(zapi);

			formsMap = zforms.getAllTicketForms();
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}

	public PageReference getFormById() {
		pageMessage = '';
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskTicketForms zforms = new ZendeskTicketForms(zapi);

			formsMap = new Map<Integer, ZendeskTicketForms.ZTicketForm>();
			ZendeskTicketForms.ZTicketForm tf = zforms.getTicketForm(ticketFormId);
			if (tf != null) {
				formsMap.put(tf.id, tf);
			}
			else {
				throw new ZendeskException('Ticket Form "' + ticketFormId + '" not found');
			}
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}
}
