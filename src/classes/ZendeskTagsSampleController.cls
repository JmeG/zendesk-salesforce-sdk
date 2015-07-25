public class ZendeskTagsSampleController {

    public String subdomain {get;set;}
    public String username {get;set;}
    public String pwdOrToken {get;set;}
    public String authType {get;set;}

    public String pageMessage {get;set;}
    public ZendeskTagsAPI.ListTags[] listTags {get;set;}

    public ZendeskTagsSampleController() {}

    public PageReference listTags() {
        pageMessage = '';
        try {
            ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
            ZendeskTagsAPI ztags = new ZendeskTagsAPI(zapi);

            ZendeskTagsAPI.ListTagsWrapper wrapper = ztags.listTags();
            listTags = wrapper.tags;
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }
}
