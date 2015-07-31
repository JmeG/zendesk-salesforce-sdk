// This class provides functionality to call the Zendesk Tags API
public class ZendeskTagsAPI extends ZendeskResourceBase {

	public enum Resource { tickets, topics, organizations, users }

	// Used to deserialize the result of a getTags() API call
	public class TagsWrapper extends ZendeskPagingBase {
		public List<String> tags {get;set;}
		public TagsWrapper(List<String> tags) { this.tags = tags; }
	}

	// Used to deserialize the result of a listTags() API call
	public class ListTagsWrapper extends ZendeskPagingBase {
		public List<ZTag> tags {get;set;}
		public ListTagsWrapper(List<ZTag> tags) { this.tags = tags; }
	}

	public ZendeskTagsAPI(ZendeskConnection zconn) {
		super(zconn);
	}

	public TagsWrapper autocompleteTags(String name) {
        return autocompleteTags(name, null);
    }
    public TagsWrapper autocompleteTags(String name, Map<String, Object> additionalParams) {
        if (String.isEmpty(name)) { throw new ZendeskException('name parameter cannot be null or empty'); }

        if (additionalParams == null) { additionalParams = new Map<String, Object>(); }
        additionalParams.put('name', urlEncode(name));
        HttpRequest req = zconn.createRequest('GET', '/autocomplete/tags.json', additionalParams);
        return (TagsWrapper)JSON.deserialize(zconn.sendRequest(req), TagsWrapper.class);
    }

	public ListTagsWrapper listTags() {
		HttpRequest req = zconn.createRequest('GET', '/tags.json');
		String resBody = zconn.sendRequest(req);

		return (ListTagsWrapper)JSON.deserialize(resBody, ListTagsWrapper.class);
	}

	public TagsWrapper getTags(Resource resourceType, Long recordId) {
		return getTags(resourceType, recordId, null);
	}
	public TagsWrapper getTags(Resource resourceType, Long recordId, Map<String, Object> queryParams) {
		if (recordId == null) { throw new ZendeskException('recordId parameter cannot be null'); }

		HttpRequest req = zconn.createRequest('GET', '/'+resourceType.name()+'/'+recordId+'/tags.json', queryParams);
		return (TagsWrapper)JSON.deserialize(zconn.sendRequest(req), TagsWrapper.class);
	}

	public void setTags(Resource resourceType, Long recordId, String[] tags) {
		if (recordId == null) { throw new ZendeskException('recordId parameter cannot be null'); }

		HttpRequest req = zconn.createRequest('POST', '/'+resourceType.name()+'/'+recordId+'/tags.json');
		req.setBody(JSON.serialize(new TagsWrapper(tags)));
		zconn.sendRequest(req);
	}

	public void addTags(Resource resourceType, Long recordId, String[] tags) {
		if (recordId == null) { throw new ZendeskException('recordId parameter cannot be null'); }

		HttpRequest req = zconn.createRequest('PUT', '/'+resourceType.name()+'/'+recordId+'/tags.json');
		req.setBody(JSON.serialize(new TagsWrapper(tags)));
		zconn.sendRequest(req);
	}

	public void removeTags(Resource resourceType, Long recordId, String[] tags) {
		if (recordId == null) { throw new ZendeskException('recordId parameter cannot be null'); }

		HttpRequest req = zconn.createRequest('DELETE', '/'+resourceType.name()+'/'+recordId+'/tags.json');
		req.setBody(JSON.serialize(new TagsWrapper(tags)));
		zconn.sendRequest(req);
	}
}
