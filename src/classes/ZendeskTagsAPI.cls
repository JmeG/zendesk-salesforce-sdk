// This class provides functionality to call the Zendesk Tags API
global class ZendeskTagsAPI extends ZendeskResourceBase {

    global enum Resource { tickets, topics, organizations, users }

    // Used to deserialize the result of a getTags() API call
    global class TagsWrapper extends ZendeskPagingBase {
        global List<String> tags { get; set; }
        global TagsWrapper(List<String> tags) { this.tags = tags; }
    }

    // Used to deserialize the result of a listTags() API call
    global class ListTagsWrapper extends ZendeskPagingBase {
        global List<ZTag> tags { get; set; }
        global ListTagsWrapper(List<ZTag> tags) { this.tags = tags; }
    }

    global ZendeskTagsAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    global TagsWrapper autocompleteTags(String name) {
        return autocompleteTags(name, null);
    }
    global TagsWrapper autocompleteTags(String name, Map<String, Object> additionalParams) {
        if (String.isEmpty(name)) { throw new ZendeskException('name parameter cannot be null or empty'); }

        if (additionalParams == null) { additionalParams = new Map<String, Object>(); }
        additionalParams.put('name', urlEncode(name));
        HttpRequest req = zconn.createRequest('GET', '/autocomplete/tags.json', additionalParams);
        return (TagsWrapper)JSON.deserialize(zconn.sendRequest(req), TagsWrapper.class);
    }

    global ListTagsWrapper listTags() {
        HttpRequest req = zconn.createRequest('GET', '/tags.json');
        String resBody = zconn.sendRequest(req);

        return (ListTagsWrapper)JSON.deserialize(resBody, ListTagsWrapper.class);
    }

    global TagsWrapper getTags(Resource resourceType, Long recordId) {
        return getTags(resourceType, recordId, null);
    }
    global TagsWrapper getTags(Resource resourceType, Long recordId, Map<String, Object> queryParams) {
        if (recordId == null) { throw new ZendeskException('recordId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/'+resourceType.name()+'/'+recordId+'/tags.json', queryParams);
        return (TagsWrapper)JSON.deserialize(zconn.sendRequest(req), TagsWrapper.class);
    }

    global void setTags(Resource resourceType, Long recordId, String[] tags) {
        if (recordId == null) { throw new ZendeskException('recordId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('POST', '/'+resourceType.name()+'/'+recordId+'/tags.json');
        req.setBody(JSON.serialize(new TagsWrapper(tags)));
        zconn.sendRequest(req);
    }

    global void addTags(Resource resourceType, Long recordId, String[] tags) {
        if (recordId == null) { throw new ZendeskException('recordId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/'+resourceType.name()+'/'+recordId+'/tags.json');
        req.setBody(JSON.serialize(new TagsWrapper(tags)));
        zconn.sendRequest(req);
    }

    global void removeTags(Resource resourceType, Long recordId, String[] tags) {
        if (recordId == null) { throw new ZendeskException('recordId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('DELETE', '/'+resourceType.name()+'/'+recordId+'/tags.json');
        req.setBody(JSON.serialize(new TagsWrapper(tags)));
        zconn.sendRequest(req);
    }
}
