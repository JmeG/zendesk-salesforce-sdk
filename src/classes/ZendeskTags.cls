// This class provides functionality to call the Zendesk Tags API
/*
Currently supports the following API endpoints:
GET    /api/v2/tags.json
GET    /api/v2/tickets/{id}/tags.json
GET    /api/v2/topics/{id}/tags.json
GET    /api/v2/organizations/{id}/tags.json
GET    /api/v2/users/{id}/tags.json
POST   /api/v2/tickets/{id}/tags.json
POST   /api/v2/topics/{id}/tags.json
POST   /api/v2/organizations/{id}/tags.json
POST   /api/v2/users/{id}/tags.json
PUT    /api/v2/tickets/{id}/tags.json
PUT    /api/v2/topics/{id}/tags.json
PUT    /api/v2/organizations/{id}/tags.json
PUT    /api/v2/users/{id}/tags.json
DELETE /api/v2/tickets/{id}/tags.json
DELETE /api/v2/topics/{id}/tags.json
DELETE /api/v2/organizations/{id}/tags.json
DELETE /api/v2/users/{id}/tags.json
*/
public with sharing class ZendeskTags {

	private final ZendeskAPI zapi;

	public enum Entity { tickets, topics, organizations, users }

	// Used to deserialize the result of a getTags() API call
	public class TagsWrapper extends ZendeskPagingSupport {
		public String[] tags {get; set;}
	}

	// Used to deserialize the result of a listTags() API call
	public class ListTagsWrapper extends ZendeskPagingSupport {
		public ListTags[] tags {get; set;}
	}

	public class ListTags {
		public String name {get; set;}
		public Long count {get; set;}
	}

	public ZendeskTags(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

	public ListTagsWrapper listTags() {
		HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/tags.json');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error listing Tags (' + res.getStatusCode() + ')');
		}

		ListTagsWrapper results = (ListTagsWrapper)JSON.deserialize(res.getBody(), ListTagsWrapper.class);
		return results;
	}

	public TagsWrapper getTags(Entity entityType, Long recordId) {
		return getTags(entityType, recordId, null);
	}

	public TagsWrapper getTags(Entity entityType, Long recordId, Long page) {
		if (recordId == null) { throw new ZendeskException('recordId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/' + entityType.name() + '/' + recordId + '/tags.json' + (page==null ? '' : '?page=' + page));
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error getting Tags (' + res.getStatusCode() + ')');
		}

		// { "tags": ["important", "customer"] }
		TagsWrapper wrapper = (TagsWrapper)JSON.deserialize(res.getBody(), TagsWrapper.class);
		return wrapper;
	}

	public void setTags(Entity entityType, Long recordId, String[] tags) {
		if (recordId == null) { throw new ZendeskException('recordId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('POST', ZendeskAPI.BASE_PATH + '/' + entityType.name() + '/' + recordId + '/tags.json');
		req.setBody('{ "tags": ' + JSON.serialize(tags) + ' }');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error setting Tags (' + res.getStatusCode() + ')');
		}
	}

	public void addTags(Entity entityType, Long recordId, String[] tags) {
		if (recordId == null) { throw new ZendeskException('recordId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('PUT', ZendeskAPI.BASE_PATH + '/' + entityType.name() + '/' + recordId + '/tags.json');
		req.setBody('{ "tags": ' + JSON.serialize(tags) + ' }');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error adding Tags (' + res.getStatusCode() + ')');
		}
	}

	public void removeTags(Entity entityType, Long recordId, String[] tags) {
		if (recordId == null) { throw new ZendeskException('recordId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/' + entityType.name() + '/' + recordId + '/tags.json');
		req.setBody('{ "tags": ' + JSON.serialize(tags) + ' }');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error removing Tags (' + res.getStatusCode() + ')');
		}
	}
}
