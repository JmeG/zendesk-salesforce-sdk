public class ZendeskTagsSampleController {

    public String subdomain { get; set; }
    public String username { get; set; }
    public String pwdOrToken { get; set; }
    public String authType { get; set; }

    public String pageMessage { get; set; }
    public ZendeskTypes.ZTag[] listTags { get; set; }

    public ZendeskTagsSampleController() {}

    public PageReference listTags() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskTagsAPI ztags_api = new ZendeskTagsAPI(zconn);

            ZendeskTagsAPI.ListTagsWrapper wrapper = ztags_api.listTags();
            listTags = wrapper.tags;
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }
}
