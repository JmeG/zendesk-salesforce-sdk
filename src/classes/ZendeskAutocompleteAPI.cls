// This class provides functionality to call the Zendesk Autocomplete API
public class ZendeskAutocompleteAPI extends ZendeskResourceBase {

    public ZendeskAutocompleteAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    public ZendeskTagsAPI.TagsWrapper autocompleteTags(String name) {
        return autocompleteTags(name, null);
    }
    public ZendeskTagsAPI.TagsWrapper autocompleteTags(String name, Map<String, Object> additionalParams) {
        if (String.isEmpty(name)) { throw new ZendeskException('name parameter cannot be null or empty'); }

        if (additionalParams == null) { additionalParams = new Map<String, Object>(); }
        additionalParams.put('name', urlEncode(name));
        HttpRequest req = zconn.createRequest('GET', '/autocomplete/tags.json', additionalParams);
        return (ZendeskTagsAPI.TagsWrapper)JSON.deserialize(zconn.sendRequest(req), ZendeskTagsAPI.TagsWrapper.class);
    }
}