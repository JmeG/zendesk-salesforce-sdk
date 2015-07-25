// This class provides functionality to call the Zendesk Tags API
public class ZendeskTagsAPI extends ZendeskResourceBase {

	public enum Resource { tickets, topics, organizations, users }

	// Used to deserialize the result of a getTags() API call
	public class TagsWrapper extends ZendeskPagingBase {
		public List<String> tags {get;set;}
	}

	// Used to deserialize the result of a listTags() API call
	public class ListTagsWrapper extends ZendeskPagingBase {
		public List<ListTags> tags {get;set;}
	}

	public class ListTags {
		public String name {get;set;}
		public Long count {get;set;}
	}

	public ZendeskTagsAPI(ZendeskAPI zapi) {
		super(zapi);
	}

	public ListTagsWrapper listTags() {
		HttpRequest req = zapi.createRequest('GET', '/tags.json');
		String resBody = zapi.sendRequest(req);

		return (ListTagsWrapper)JSON.deserialize(resBody, ListTagsWrapper.class);
	}

	public TagsWrapper getTags(Resource resourceType, Long recordId) {
		return getTags(resourceType, recordId, null);
	}

	public TagsWrapper getTags(Resource resourceType, Long recordId, Map<String, Object> queryParams) {
		if (recordId == null) { throw new ZendeskException('recordId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/'+resourceType.name()+'/'+recordId+'/tags.json', queryParams);
		return (TagsWrapper)JSON.deserialize(zapi.sendRequest(req), TagsWrapper.class);
	}

	public void setTags(Resource resourceType, Long recordId, String[] tags) {
		if (recordId == null) { throw new ZendeskException('recordId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('POST', '/'+resourceType.name()+'/'+recordId+'/tags.json');
		req.setBody('{"tags": ' + JSON.serialize(tags) + '}');
		zapi.sendRequest(req);
	}

	public void addTags(Resource resourceType, Long recordId, String[] tags) {
		if (recordId == null) { throw new ZendeskException('recordId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('PUT', '/'+resourceType.name()+'/'+recordId+'/tags.json');
		req.setBody('{"tags": ' + JSON.serialize(tags) + '}');
		zapi.sendRequest(req);
	}

	public void removeTags(Resource resourceType, Long recordId, String[] tags) {
		if (recordId == null) { throw new ZendeskException('recordId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('DELETE', '/'+resourceType.name()+'/'+recordId+'/tags.json');
		req.setBody('{"tags": ' + JSON.serialize(tags) + '}');
		zapi.sendRequest(req);
	}
}
