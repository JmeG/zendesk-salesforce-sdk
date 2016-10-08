public class ZendeskSample1Controller {

    public String subdomain { get; set; }
    public String username { get; set; }
    public String pwdOrToken { get; set; }
    public String authType { get; set; }

    public String pageMessage { get; set; }

    public ZendeskSample1Controller() {
        Zendesk_API__c settings = Zendesk_API__c.getInstance();
        if (settings != null) {
            subdomain = settings.Subdomain__c;
            username = settings.Username__c;
            pwdOrToken = settings.Password_or_Token__c;
            authType = settings.Authentication_Type__c;
        }
    }

    // This method simply exists so that changes to API fields are saved in the controller
    // without a full postback
    public PageReference changeAPIdetails() {
        pageMessage = '';
        return null;
    }

    public PageReference validateLogin() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            if (zconn.canLogin()) {
                pageMessage = 'Successfully logged in';
            }
        }
        catch(Exception e) {
            pageMessage = 'Login failed ' + e.getMessage();
        }
        return null;
    }
}
