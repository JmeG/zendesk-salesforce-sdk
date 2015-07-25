public class ZendeskOrgFieldsSampleController {

	public String subdomain {get;set;}
	public String username {get;set;}
	public String pwdOrToken {get;set;}
	public String authType {get;set;}

	public String pageMessage {get;set;}
	public String searchText {get;set;}
	public Long organizationFieldId {get;set;}
	public String fieldOrderCSV {get;set;}
	public Map<String, ZendeskTypes.ZOrganizationField> fieldsMap {get;set;}

	public ZendeskOrgFieldsSampleController() {}

	public PageReference getFields() {
		pageMessage = '';
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskOrganizationFieldsAPI zfields_api = new ZendeskOrganizationFieldsAPI(zapi);

			fieldsMap = zfields_api.getAllFields();
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
			ZendeskOrganizationFieldsAPI zfields_api = new ZendeskOrganizationFieldsAPI(zapi);

			fieldsMap = new Map<String, ZendeskTypes.ZOrganizationField>();
			ZendeskTypes.ZOrganizationField field = zfields_api.getFieldByKey(searchText);
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
			ZendeskOrganizationFieldsAPI zfields_api = new ZendeskOrganizationFieldsAPI(zapi);

			fieldsMap = new Map<String, ZendeskTypes.ZOrganizationField>();
			ZendeskTypes.ZOrganizationField field = zfields_api.getField(organizationFieldId);
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

	public PageReference reorderFields() {
		pageMessage = '';
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskOrganizationFieldsAPI zfields_api = new ZendeskOrganizationFieldsAPI(zapi);

			String[] splits = fieldOrderCSV.split(',');
			List<Long> orderedFieldIds = new List<Long>();
			for (String s : splits) {
				orderedFieldIds.add(Long.valueOf(s.trim()));
			}
			zfields_api.reorderFields(orderedFieldIds);

			// clear the fields list
			fieldsMap = new Map<String, ZendeskTypes.ZOrganizationField>();
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}

}
