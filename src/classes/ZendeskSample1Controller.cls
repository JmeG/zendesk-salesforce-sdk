public class ZendeskSample1Controller {

    public String pageMessage { get; set; }
    public String namedCredentialName {
        get { return ZendeskControllerSettings.getNamedCredential(); }
        set;
    }

    public ZendeskSample1Controller() {
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
            ZendeskConnection zconn = ZendeskControllerSettings.getConnection();
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
