public class ZendeskOrgFieldsSampleController {

    public String subdomain { get; set; }
    public String username { get; set; }
    public String pwdOrToken { get; set; }
    public String authType { get; set; }

    public String pageMessage { get; set; }
    public String searchText { get; set; }
    public Long organizationFieldId { get; set; }
    public String fieldOrderCSV { get; set; }
    public Map<String, ZendeskTypes.ZOrganizationField> fieldsMap { get; set; }

    public ZendeskOrgFieldsSampleController() {}

    public PageReference getFields() {
        pageMessage = '';
        fieldsMap = new Map<String, ZendeskTypes.ZOrganizationField>();
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskOrganizationFieldsAPI zfields_api = new ZendeskOrganizationFieldsAPI(zconn);

            fieldsMap = zfields_api.getAllFields();
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

    public PageReference findFieldByName() {
        pageMessage = '';
        fieldsMap = new Map<String, ZendeskTypes.ZOrganizationField>();
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskOrganizationFieldsAPI zfields_api = new ZendeskOrganizationFieldsAPI(zconn);

            Map<String, ZendeskTypes.ZOrganizationField> allFieldsMap = zfields_api.getAllFields();
            if (allFieldsMap.containsKey(searchText)) {
                ZendeskTypes.ZOrganizationField field = allFieldsMap.get(searchText);
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
        fieldsMap = new Map<String, ZendeskTypes.ZOrganizationField>();
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskOrganizationFieldsAPI zfields_api = new ZendeskOrganizationFieldsAPI(zconn);

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
        fieldsMap = new Map<String, ZendeskTypes.ZOrganizationField>();
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskOrganizationFieldsAPI zfields_api = new ZendeskOrganizationFieldsAPI(zconn);

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
