public class ZendeskUserFieldsSampleController {

    public String subdomain { get; set; }
    public String username { get; set; }
    public String pwdOrToken { get; set; }
    public String authType { get; set; }

    public String pageMessage { get; set; }
    public String searchText { get; set; }
    public Long userFieldId { get; set; }
    public String fieldOrderCSV { get; set; }
    public Map<String, ZendeskTypes.ZUserField> fieldsMap { get; set; }

    public ZendeskUserFieldsSampleController() {}

    public PageReference getFields() {
        pageMessage = '';
        fieldsMap = new Map<String, ZendeskTypes.ZUserField>();
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskUserFieldsAPI zfields_api = new ZendeskUserFieldsAPI(zconn);

            fieldsMap = zfields_api.getAllFields();
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

    public PageReference findFieldByName() {
        pageMessage = '';
        fieldsMap = new Map<String, ZendeskTypes.ZUserField>();
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskUserFieldsAPI zfields_api = new ZendeskUserFieldsAPI(zconn);

            Map<String, ZendeskTypes.ZUserField> allFieldsMap = zfields_api.getAllFields();
            if (allFieldsMap.containsKey(searchText)) {
                ZendeskTypes.ZUserField field = allFieldsMap.get(searchText);
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
        fieldsMap = new Map<String, ZendeskTypes.ZUserField>();
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskUserFieldsAPI zfields_api = new ZendeskUserFieldsAPI(zconn);

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
        fieldsMap = new Map<String, ZendeskTypes.ZUserField>();
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskUserFieldsAPI zfields_api = new ZendeskUserFieldsAPI(zconn);

            String[] splits = fieldOrderCSV.split(',');
            List<Long> orderedFieldIds = new List<Long>();
            for (String s : splits) {
                orderedFieldIds.add(Long.valueOf(s.trim()));
            }
            zfields_api.reorderFields(orderedFieldIds);
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

}
