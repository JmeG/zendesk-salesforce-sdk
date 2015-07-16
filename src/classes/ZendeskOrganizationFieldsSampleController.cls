public with sharing class ZendeskOrgFieldsSampleController {

	public String subdomain {get;set;}
	public String username {get;set;}
	public String pwdOrToken {get;set;}
	public String authType {get;set;}

	public String pageMessage {get;set;}
	public String searchText {get;set;}
	public Long organizationFieldId {get;set;}
	public Map<String, ZendeskOrganizationFields.ZOrganizationField> fieldsMap {get;set;}

	public ZendeskOrgFieldsSampleController() {}

	public PageReference getFields() {
		pageMessage = '';
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskOrganizationFields zfields = new ZendeskOrganizationFields(zapi);

			fieldsMap = zfields.getAllFields();
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}

	public PageReference findFieldByName() {
		pageMessage = '';
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskOrganizationFields zfields = new ZendeskOrganizationFields(zapi);

			fieldsMap = new Map<String, ZendeskOrganizationFields.ZOrganizationField>();
			ZendeskOrganizationFields.ZOrganizationField field = zfields.getOrganizationFieldByKey(searchText);
			if (field != null) {
				fieldsMap.put(field.key, field);
			}
			else {
				throw new ZendeskException('Field "' + searchText + '" not found');
			}
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
			ZendeskOrganizationFields zfields = new ZendeskOrganizationFields(zapi);

			fieldsMap = new Map<String, ZendeskOrganizationFields.ZOrganizationField>();
			ZendeskOrganizationFields.ZOrganizationField field = zfields.getOrganizationField(organizationFieldId);
			if (field != null) {
				fieldsMap.put(field.key, field);
			}
			else {
				throw new ZendeskException('Organization Field "' + organizationFieldId + '" not found');
			}
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}
}
