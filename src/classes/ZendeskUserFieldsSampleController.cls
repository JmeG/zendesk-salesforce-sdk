public class ZendeskUserFieldsSampleController {

	public String subdomain {get;set;}
	public String username {get;set;}
	public String pwdOrToken {get;set;}
	public String authType {get;set;}

	public String pageMessage {get;set;}
	public String searchText {get;set;}
	public Long userFieldId {get;set;}
	public String fieldOrderCSV {get;set;}
	public Map<String, ZendeskTypes.ZUserField> fieldsMap {get;set;}

	public ZendeskUserFieldsSampleController() {}

	public PageReference getFields() {
		pageMessage = '';
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskUserFieldsAPI zfields_api = new ZendeskUserFieldsAPI(zapi);

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
			ZendeskUserFieldsAPI zfields_api = new ZendeskUserFieldsAPI(zapi);

			fieldsMap = new Map<String, ZendeskTypes.ZUserField>();
			ZendeskTypes.ZUserField field = zfields_api.getFieldByKey(searchText);
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
			ZendeskUserFieldsAPI zfields_api = new ZendeskUserFieldsAPI(zapi);

			fieldsMap = new Map<String, ZendeskTypes.ZUserField>();
			ZendeskTypes.ZUserField field = zfields_api.getField(userFieldId);
			if (field != null) {
				fieldsMap.put(field.key, field);
			}
			else {
				throw new ZendeskException('User Field "' + userFieldId + '" not found');
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
			ZendeskUserFieldsAPI zfields_api = new ZendeskUserFieldsAPI(zapi);

			String[] splits = fieldOrderCSV.split(',');
			List<Long> orderedFieldIds = new List<Long>();
			for (String s : splits) {
				orderedFieldIds.add(Long.valueOf(s.trim()));
			}
			zfields_api.reorderFields(orderedFieldIds);

			// clear the fields list
			fieldsMap = new Map<String, ZendeskTypes.ZUserField>();
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}

}
