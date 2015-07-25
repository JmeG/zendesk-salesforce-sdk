public class ZendeskTicketFieldsSampleController {

	public String subdomain {get;set;}
	public String username {get;set;}
	public String pwdOrToken {get;set;}
	public String authType {get;set;}

	public String pageMessage {get;set;}
	public Long ticketFieldId {get;set;}
	public Map<Long, ZendeskTypes.ZTicketField> fieldsMap {get;set;}

	public ZendeskTicketFieldsSampleController() {}

	public PageReference getFields() {
		pageMessage = '';
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskTicketFieldsAPI zfields = new ZendeskTicketFieldsAPI(zapi);

			fieldsMap = zfields.getAllFields();
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}

	public PageReference getFieldByID() {
		pageMessage = '';
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskTicketFieldsAPI zfields = new ZendeskTicketFieldsAPI(zapi);

			fieldsMap = new Map<Long, ZendeskTypes.ZTicketField>();
			ZendeskTypes.ZTicketField field = zfields.getField(ticketFieldId);
			if (field != null) {
				fieldsMap.put(field.id, field);
			}
			else {
				throw new ZendeskException('Ticket Field "' + ticketFieldId + '" not found');
			}
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}
}
