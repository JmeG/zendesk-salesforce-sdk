// This class provides functionality to call the Zendesk Autocomplete API
global class ZendeskAutocompleteAPI extends ZendeskResourceBase {

    global ZendeskAutocompleteAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    // NOTE: I'm not sure why there is a separate API just for tags autocomplete and not other entities.
    // I'm going to duplicate these methods in the ZendeskTagsAPI class for now.
    global ZendeskTagsAPI.TagsWrapper autocompleteTags(String name) {
        return autocompleteTags(name, null);
    }
    global ZendeskTagsAPI.TagsWrapper autocompleteTags(String name, Map<String, Object> additionalParams) {
        if (String.isEmpty(name)) { throw new ZendeskException('name parameter cannot be null or empty'); }

        if (additionalParams == null) { additionalParams = new Map<String, Object>(); }
        additionalParams.put('name', urlEncode(name));
        HttpRequest req = zconn.createRequest('GET', '/autocomplete/tags.json', additionalParams);
        return (ZendeskTagsAPI.TagsWrapper)JSON.deserialize(zconn.sendRequest(req), ZendeskTagsAPI.TagsWrapper.class);
    }
}
