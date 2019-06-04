public class ZendeskTagsSampleController {

    public String pageMessage { get; set; }
    public ZendeskTypes.ZTag[] listTags { get; set; }

    public ZendeskTagsSampleController() {}

    public PageReference listTags() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = ZendeskControllerSettings.getConnection();
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
