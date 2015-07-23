// This class provides functionality to call the Zendesk Tickets API
// Currently supports the following API endpoints:
// GET    /api/v2/tickets.json
// GET    /api/v2/tickets/recent.json
// GET    /api/v2/tickets/{id}.json
// GET    /api/v2/tickets/{id}/related.json
// GET    /api/v2/tickets/show_many.json?ids={ids}
// GET    /api/v2/tickets/{id}/incidents.json
// GET    /api/v2/tickets/{id}/collaborators.json
// GET    /api/v2/users/{user_id}/tickets/requested.json
// GET    /api/v2/users/{user_id}/tickets/ccd.json
// GET    /api/v2/users/{user_id}/tickets/assigned.json
// GET    /api/v2/organizations/{organization_id}/tickets.json
// GET    /api/v2/problems.json
// GET    /api/v2/channels/twitter/tickets/{id}/statuses.js
// POST   /api/v2/tickets.json
// POST   /api/v2/tickets/create_many.json
// POST   /api/v2/tickets/{id}/merge.json
// POST   /api/v2/problems/autocomplete.json?text={name}
// POST   /api/v2/channels/twitter/tickets.json
// PUT    /api/v2/tickets/{id}.json
// PUT    /api/v2/tickets/update_many.json
// PUT    /api/v2/tickets/update_many.json?ids={ids}
// PUT    /api/v2/tickets/{id}/mark_as_spam.json
// PUT    /api/v2/tickets/mark_many_as_spam.json?ids={ids}
// DELETE /api/v2/tickets/{id}.json
// DELETE /api/v2/tickets/destroy_many.json?ids={ids}
public class ZendeskTickets {

	private final ZendeskAPI zapi;

	public enum TicketType { question, incident, problem, task }
	public enum TicketPriority { low, normal, high, urgent }

	// NOTE: we can't use "new" since it's a reserved keyword
	//public enum TicketStatus { new, open, pending, hold, solved, closed }
	public class TicketStatus {
		public String status {get; private set;}
		public TicketStatus(String status) {
			if (status == 'new' || status == 'open' || status == 'pending'
			|| status == 'hold' || status == 'solved' || status == 'closed') {
				this.status = status;
			} else {
				throw new ZendeskException('Invalid Ticket Status "' + status + '"');
			}
		}
	}

	public class ZTicket {
		public Long id {get;set;}
		public String url {get;set;}
		public String external_id {get;set;}
		public TicketType type {get;set;}
		public String subject {get;set;}
		public TicketPriority priority {get;set;}
		public String status {get;set;}
		public String recipient {get;set;}
		public Long requester_id {get;set;}
		public ZTicketRequester requester {get;set;} // optional when creating a new ticket in place of requester_id
		public Long submitter_id {get;set;}
		public Long assignee_id {get;set;}
		public Long group_id {get;set;}
		public List<Long> collaborator_ids {get;set;}
		public Long forum_topic_id {get;set;}
		public Long problem_id {get;set;}
		public DateTime due_at {get;set;}
		public List<String> tags {get;set;}
		public List<ZTicketCustomField> custom_fields {get;set;}
		public Long ticket_form_id {get;set;}
		public Long brand_id {get;set;}
		public ZTicketComment comment {get;set;} // use for adding the ticket comment
		public String description {get; private set;} // readonly. first comment on ticket
		public Long organization_id {get; private set;}
		public ZTicketVia via {get; private set;}
		public ZTicketSatisfactionRating satisfaction_rating {get; private set;}
		public List<Long> sharing_agreement_ids {get; private set;}
		public List<Long> followup_ids {get; private set;}
		public Boolean has_incidents {get; private set;}
		public DateTime created_at {get; private set;}
		public DateTime updated_at {get; private set;}
	}

	public class ZTicketCustomField {
		public Long id {get;set;}
		public String value {get;set;}

		public ZTicketCustomField() {}
		public ZTicketCustomField(Long id, String value) { this.id = id; this.value = value; }
	}

	public class ZTicketVia {
		public String channel {get;set;}
		//public String source {get;set;}
	}

	public class ZTicketSatisfactionRating {
		public Long id {get;set;}
		public String score {get;set;}
		public String comment {get;set;}
	}

	public class ZTicketComment {
		public String body {get;set;}
		public Boolean x_public {get;set;}  // Use "x_public" in place of "public" which is a reserved keyword. Requires custom de/serialization.
		public String uploads {get;set;}
	}

	// { "locale_id": 8, "name": "Pablo", "email": "pablito@example.org" }
	public class ZTicketRequester {
		public Long locale_id {get;set;}
		public String name {get;set;}
		public String email {get;set;}
	}

	public class TicketsWrapper extends ZendeskPagingSupport {
		public List<ZTicket> tickets {get;set;}
	}

	// Used to deserialize the result of a individual Ticket create/read/update API call
	private class TicketWrapper {
		public ZTicket ticket {get;set;}
	}

	public ZendeskTickets(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

	public ZTicket getTicket(Long ticketId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/tickets/' + ticketId + '.json');
		String resBody = zapi.sendRequest(req);

		TicketWrapper resultWrapper = (TicketWrapper)JSON.deserialize(resBody, TicketWrapper.class);
		return resultWrapper.ticket;
	}

	public Long createTicket(TicketType type, String subject, String commentText, Long requesterId) {
		return createTicket(type, subject, commentText, null, requesterId, null, null, null, null);
	}

	public Long createTicket(TicketType type, String subject, String commentText, String attachmentToken, Long requesterId) {
		return createTicket(type, subject, commentText, attachmentToken, requesterId, null, null, null, null);
	}

	public Long createTicket(TicketType type, String subject, String commentText, Long requesterId, List<ZTicketCustomField> zcfList) {
		return createTicket(type, subject, commentText, null, requesterId, null, null, null, zcfList);
	}

	public Long createTicket(TicketType type, String subject, String commentText, String attachmentToken, Long requesterId, List<ZTicketCustomField> zcfList) {
		return createTicket(type, subject, commentText, attachmentToken, requesterId, null, null, null, zcfList);
	}

	public Long createTicket(TicketType type, String subject, String commentText, Long requesterId, Long groupId, Long assigneeId, Long ticketFormId, List<ZTicketCustomField> zcfList) {
		return createTicket(type, subject, commentText, null, requesterId, groupId, assigneeId, ticketFormId, zcfList);
	}

	public Long createTicket(TicketType type, String subject, String commentText, String attachmentToken, Long requesterId, Long groupId, Long assigneeId, Long ticketFormId, List<ZTicketCustomField> zcfList) {
		ZTicket zt = new ZTicket();
		zt.type = type;
		zt.subject = subject;
		zt.custom_fields = zcfList;
		zt.requester_id = requesterId;
		zt.assignee_id = assigneeId;
		zt.ticket_form_id = ticketFormId;
		zt.group_id = groupId;
		zt.comment = new ZTicketComment();
		zt.comment.body = commentText;
		zt.comment.uploads = attachmentToken;

		return createTicket(zt);
	}

	public Long createTicket(ZTicket zticket) {
		if (zticket == null) { throw new ZendeskException('zticket parameter must not be null'); }

		HttpRequest req = zapi.createRequest('POST', '/tickets.json');
		req.setBody('{ "ticket": ' + unreplaceReservedWords(ZendeskAPI.stripJsonNulls(JSON.serialize(zticket))) + ' }');
		String resBody = zapi.sendRequest(req);

		TicketWrapper resultWrapper = (TicketWrapper)JSON.deserialize(replaceReservedWords(resBody), TicketWrapper.class);
		return ((resultWrapper==null || resultWrapper.ticket == null) ? null : resultWrapper.ticket.id);
	}

	public Long createTicketFromTweet(Long twitterMessageId, Long monitoredTwitterHandleId) {
		if (twitterMessageId == null) { throw new ZendeskException('twitterMessageId parameter must not be null'); }
		if (monitoredTwitterHandleId == null) { throw new ZendeskException('monitoredTwitterHandleId parameter must not be null'); }

		// {"ticket": {"twitter_status_message_id": 8605426295771136, "monitored_twitter_handle_id": 45}}'
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeFieldName('ticket');
		gen.writeStartObject();
		gen.writeNumberField('twitter_status_message_id', twitterMessageId);
        gen.writeNumberField('monitored_twitter_handle_id', monitoredTwitterHandleId);
		gen.writeEndObject();
		gen.writeEndObject();

		HttpRequest req = zapi.createRequest('POST', '/channels/twitter/tickets.json');
		req.setBody(gen.getAsString());
		String resBody = zapi.sendRequest(req);

		TicketWrapper resultWrapper = (TicketWrapper)JSON.deserialize(replaceReservedWords(resBody), TicketWrapper.class);
		return ((resultWrapper==null || resultWrapper.ticket == null) ? null : resultWrapper.ticket.id);
	}

	public ZendeskJobStatuses.JobStatus createTickets(List<ZTicket> ztickets) {
		if (ztickets == null || ztickets.isEmpty()) { throw new ZendeskException('ztickets parameter must not be null or empty'); }

		HttpRequest req = zapi.createRequest('POST', '/tickets/create_many.json');
		req.setBody('{ "tickets": ' + unreplaceReservedWords(ZendeskAPI.stripJsonNulls(JSON.serialize(ztickets))) + ' }');
		String resBody = zapi.sendRequest(req);

		return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
	}

	// /api/v2/tickets.json
	public TicketsWrapper getTickets() {
		HttpRequest req = zapi.createRequest('GET', '/tickets.json');
        return getTickets(req);
    }

	// /api/v2/tickets.json
    public TicketsWrapper getTickets(Long page) {
		HttpRequest req = zapi.createRequest('GET', '/tickets.json' + (page==null ? '' : '?page=' + page));
        return getTickets(req);
    }

	// /api/v2/organizations/{organization_id}/tickets.json
	public TicketsWrapper getTicketsByOrgId(Long orgId) {
        return getTicketsByOrgId(orgId, null);
    }

	// /api/v2/organizations/{organization_id}/tickets.json
	public TicketsWrapper getTicketsByOrgId(Long orgId, Long page) {
		if (orgId == null) { throw new ZendeskException('orgId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/organizations/' + orgId + '/tickets.json' + (page==null ? '' : '?page=' + page));
        return getTickets(req);
    }

	// /api/v2/users/{user_id}/tickets/requested.json
	public TicketsWrapper getTicketsByRequesterId(Long requesterId) {
        return getTicketsByRequesterId(requesterId, null);
    }

	// /api/v2/users/{user_id}/tickets/requested.json
	public TicketsWrapper getTicketsByRequesterId(Long requesterId, Long page) {
		if (requesterId == null) { throw new ZendeskException('requesterId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/users/' + requesterId + '/tickets/requested.json' + (page==null ? '' : '?page=' + page));
        return getTickets(req);
    }

	// /api/v2/users/{user_id}/tickets/ccd.json
	public TicketsWrapper getTicketsByCCUserId(Long userId) {
        return getTicketsByCCUserId(userId, null);
    }

	// /api/v2/users/{user_id}/tickets/ccd.json
	public TicketsWrapper getTicketsByCCUserId(Long userId, Long page) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/users/' + userId + '/tickets/ccd.json' + (page==null ? '' : '?page=' + page));
        return getTickets(req);
    }

	// /api/v2/users/{user_id}/tickets/assigned.json
	public TicketsWrapper getTicketsByAssigneeId(Long assigneeId) {
        return getTicketsByAssigneeId(assigneeId, null);
    }

	// /api/v2/users/{user_id}/tickets/assigned.json
	public TicketsWrapper getTicketsByAssigneeId(Long assigneeId, Long page) {
		if (assigneeId == null) { throw new ZendeskException('assigneeId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/users/' + assigneeId + '/tickets/assigned.json' + (page==null ? '' : '?page=' + page));
        return getTickets(req);
    }

	// /api/v2/tickets/recent.json
	public TicketsWrapper getRecentTickets() {
		return getRecentTickets(null);
    }

	// /api/v2/tickets/recent.json
	public TicketsWrapper getRecentTickets(Long page) {
		HttpRequest req = zapi.createRequest('GET', '/users/tickets/recent.json' + (page==null ? '' : '?page=' + page));
        return getTickets(req);
    }

	// /api/v2/tickets/show_many.json?ids={ids}
	public TicketsWrapper getTicketsByIds(Set<Long> ticketIds) {
		if (ticketIds == null || ticketIds.isEmpty()) { throw new ZendeskException('ticketIds parameter must not be null or empty'); }

        HttpRequest req = zapi.createRequest('GET', '/tickets/show_many.json?ids=' + ZendeskAPI.toCSV(ticketIds));
        return getTickets(req);
    }

	// /api/v2/tickets/{id}/incidents.json
	public TicketsWrapper getTicketIncidents(Long ticketId) {
        return getTicketIncidents(ticketId, null);
    }

	// /api/v2/tickets/{id}/incidents.json
	public TicketsWrapper getTicketIncidents(Long ticketId, Long page) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/tickets/' + ticketId + '/incidents.json' + (page==null ? '' : '?page=' + page));
        return getTickets(req);
    }

	// /api/v2/problems.json
	public TicketsWrapper getTicketProblems() {
        return getTicketProblems(null);
    }

	// /api/v2/problems.json
	public TicketsWrapper getTicketProblems(Long page) {
		HttpRequest req = zapi.createRequest('GET', '/tickets/problem.json' + (page==null ? '' : '?page=' + page));
        return getTickets(req);
    }

	// Helper method for getting tickets
	private TicketsWrapper getTickets(HttpRequest req) {
        String resBody = zapi.sendRequest(req);

        return (TicketsWrapper)JSON.deserialize(resBody, TicketsWrapper.class);
    }

	public ZendeskUsers.UsersWrapper getTicketCollaborators(Long ticketId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/tickets/' + ticketId + '/collaborators.json');
		String resBody = zapi.sendRequest(req);

		return (ZendeskUsers.UsersWrapper)JSON.deserialize(resBody, ZendeskUsers.UsersWrapper.class);
    }

	public Map<String, Object> getTwicketStatus(Long ticketId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/channels/twitter/tickets/' + ticketId + '/statuses.json');
        String resBody = zapi.sendRequest(req);

		return (Map<String, Object>)JSON.deserializeUntyped(resBody);
	}

	public void updateTicket(Long ticketId, ZTicket zticket) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }
		if (zticket == null) { throw new ZendeskException('zticket parameter must not be null'); }

		HttpRequest req = zapi.createRequest('PUT', '/tickets/' + ticketId + '.json');
		req.setBody('{ "ticket": ' + unreplaceReservedWords(ZendeskAPI.stripJsonNulls(JSON.serialize(zticket))) + ' }');
		zapi.sendRequest(req);
	}

	public ZendeskJobStatuses.JobStatus updateTickets(List<ZTicket> ztickets) {
		if (ztickets == null || ztickets.isEmpty()) { throw new ZendeskException('ztickets parameter must not be null or empty'); }
		for (ZTicket zticket : ztickets) {
			if (zticket.id == null) { throw new ZendeskException('Each Ticket must have an id populated'); }
		}

		HttpRequest req = zapi.createRequest('PUT', '/tickets/update_many.json');
		req.setBody('{ "tickets": ' + unreplaceReservedWords(ZendeskAPI.stripJsonNulls(JSON.serialize(ztickets))) + ' }');
		String resBody = zapi.sendRequest(req);

		return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
	}

	public ZendeskJobStatuses.JobStatus updateTickets(Set<Long> ticketIds, ZTicket zticket) {
		if (ticketIds == null || ticketIds.isEmpty()) { throw new ZendeskException('ticketIds parameter must not be null or empty'); }
        if (zticket == null) { throw new ZendeskException('zticket parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', '/tickets/update_many.json?ids=' + ZendeskAPI.toCSV(ticketIds));
		req.setBody('{ "ticket": ' + unreplaceReservedWords(ZendeskAPI.stripJsonNulls(JSON.serialize(zticket))) + ' }');
		String resBody = zapi.sendRequest(req);

		return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
	}

	// helper method to add a new comment to a ticket
	public void addTicketComment(Long ticketId, String commentText, Boolean isPublic) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }
		if (String.isBlank(commentText)) { throw new ZendeskException('commentText parameter must not be empty'); }

		ZTicket ticket = new ZTicket();
		ticket.comment = new ZTicketComment();
		ticket.comment.body = commentText;
		ticket.comment.x_public = isPublic;

		HttpRequest req = zapi.createRequest('PUT', '/tickets/' + ticketId + '.json');
		req.setBody('{ "ticket": ' + unreplaceReservedWords(ZendeskAPI.stripJsonNulls(JSON.serialize(ticket))) + ' }');
		zapi.sendRequest(req);
	}

	// helper method to add a new comment to a ticket and change its status
	public void addTicketCommentAndChangeStatus(Long ticketId, String commentText, Boolean isPublic, TicketStatus status) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }
		if (String.isBlank(commentText)) { throw new ZendeskException('commentText parameter must not be empty'); }
		if (status == null) { throw new ZendeskException('status parameter must not be null'); }

		ZTicket ticket = new ZTicket();
		ticket.comment = new ZTicketComment();
		ticket.comment.body = commentText;
		ticket.comment.x_public = isPublic;
		ticket.status = status.status;

		HttpRequest req = zapi.createRequest('PUT', '/tickets/' + ticketId + '.json');
		req.setBody('{ "ticket": ' + unreplaceReservedWords(ZendeskAPI.stripJsonNulls(JSON.serialize(ticket))) + ' }');
		zapi.sendRequest(req);
	}

	public ZendeskJobStatuses.JobStatus mergeTickets(Set<Long> sourceTicketIds, String sourceComment, Long targetTicketId, String targetComment) {
		if (sourceTicketIds == null || sourceTicketIds.isEmpty()) { throw new ZendeskException('sourceTicketIds parameter must not be null or empty'); }
		if (targetTicketId == null) { throw new ZendeskException('targetTicketId parameter must not be null'); }

		// { "ids": [123, 234], "target_comment": "Closing in favor of #111",, "source_comment": "Combining with #123, #456" }
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
        gen.writeObjectField('ids', sourceTicketIds);
		if (!String.isEmpty(targetComment)) { gen.writeStringField('target_comment', targetComment); }
        if (!String.isEmpty(sourceComment)) { gen.writeStringField('source_comment', sourceComment); }
        gen.writeEndObject();

		HttpRequest req = zapi.createRequest('POST', '/tickets/' + targetTicketId + '/merge.json');
		req.setBody(gen.getAsString());
		String resBody = zapi.sendRequest(req);

		return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
	}

	public void deleteTicket(Long ticketId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('DELETE', '/tickets/' + ticketId + '.json');
		zapi.sendRequest(req);
	}

	public void deleteTickets(Set<Long> ticketIds) {
		if (ticketIds == null || ticketIds.isEmpty()) { throw new ZendeskException('ticketIds parameter must not be null or empty'); }

		HttpRequest req = zapi.createRequest('DELETE', '/tickets/destroy_many.json?ids=' + ZendeskAPI.toCSV(ticketIds));
		zapi.sendRequest(req);
	}

	public Map<String, Object> getTicketRelatedInfo(Long ticketId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/tickets/' + ticketId + '/related.json');
        String resBody = zapi.sendRequest(req);

		return (Map<String, Object>)JSON.deserializeUntyped(resBody);
	}

	public void markTicketAsSpam(Long ticketId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('PUT', '/tickets/' + ticketId + '/mark_as_spam.json');
		zapi.sendRequest(req);
	}

	public ZendeskJobStatuses.JobStatus markTicketsAsSpam(Set<Long> ticketIds) {
		if (ticketIds == null || ticketIds.isEmpty()) { throw new ZendeskException('ticketIds parameter must not be null or empty'); }

		HttpRequest req = zapi.createRequest('PUT', '/tickets/mark_many_as_spam.json?ids=' + ZendeskAPI.toCSV(ticketIds));
		String resBody = zapi.sendRequest(req);

		return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
	}

	public TicketsWrapper autoCompleteProblems(String autoCompleteText) {
		if (String.isBlank(autoCompleteText) || autoCompleteText.length() < 2) { throw new ZendeskException('autoCompleteText parameter must at least 2 characters'); }

		HttpRequest req = zapi.createRequest('POST', '/problems/autocomplete.json?text=' + autoCompleteText);
		String resBody = zapi.sendRequest(req);

		return (TicketsWrapper)JSON.deserialize(resBody, TicketsWrapper.class);
    }

	// replace reserved keywords in the JSON string and map them to field names prefixed with "x_"
	private String replaceReservedWords(String str) {
		str = str.replaceAll('"public"\\s*:', '"x_public":');
		return str;
	}

	// un-replace reserved keywords in the JSON string
	private String unreplaceReservedWords(String str) {
		str = str.replaceAll('"x_public"\\s*:', '"public":');
		return str;
	}

}
