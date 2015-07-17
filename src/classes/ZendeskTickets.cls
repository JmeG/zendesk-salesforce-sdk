// This class provides functionality to call the Zendesk Tickets API
// Currently upports the following API endpoints:
// GET    /api/v2/tickets.json
// GET    /api/v2/users/{user_id}/tickets/requested.json
// GET    /api/v2/users/{user_id}/tickets/ccd.json
// GET    /api/v2/users/{user_id}/tickets/assigned.json
// GET    /api/v2/tickets/recent.json
// GET    /api/v2/tickets/{id}.json
// POST   /api/v2/tickets.json
// PUT    /api/v2/tickets/{id}.json
// DELETE /api/v2/tickets/{id}.json
// *************************************
// TODO: Implement the following methods
// GET /api/v2/organizations/{organization_id}/tickets.json
// GET /api/v2/tickets/show_many.json?ids={ids}
// GET /api/v2/tickets/{id}/related.json
// GET /api/v2/tickets/{id}/collaborators.json
// GET /api/v2/tickets/{id}/incidents.json
// GET /api/v2/problems.json
// GET /api/v2/channels/twitter/tickets/{id}/statuses.js
// POST /api/v2/tickets/create_many.json
// POST /api/v2/problems/autocomplete.json?text={name}
// POST /api/v2/channels/twitter/tickets.json
// POST /api/v2/tickets/{id}/merge.json
// PUT /api/v2/tickets/update_many.json
// PUT /api/v2/tickets/update_many.json?ids={ids}
// PUT /api/v2/tickets/{id}/mark_as_spam.json
// PUT /api/v2/tickets/mark_many_as_spam.json?ids={ids}on
// DELETE /api/v2/tickets/destroy_many.json?ids={ids}
public with sharing class ZendeskTickets {

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
		public Long id {get; private set;}
		public String url {get; private set;}
		public String external_id {get; set;}
		public TicketType type {get; set;}
		public String subject {get; set;}
		public String description {get; private set;} // readonly. first comment on ticket
		public TicketPriority priority {get; set;}
		public String status {get; set;}
		public String recipient {get; set;}
		public Long requester_id {get; set;}
		public ZTicketRequester requester {get; set;} // optional when creating a new ticket in place of requester_id
		public Long submitter_id {get; set;}
		public Long assignee_id {get; set;}
		public Long organization_id {get; private set;}
		public Long group_id {get; set;}
		public List<Long> collaborator_ids {get; set;}
		public Long forum_topic_id {get; set;}
		public Long problem_id {get; set;}
		public Boolean has_incidents {get; private set;}
		public DateTime due_at {get; set;}
		public List<String> tags {get; set;}
		public ZTicketVia via {get; private set;}
		public List<ZTicketCustomField> custom_fields {get; set;}
		public ZTicketSatisfactionRating satisfaction_rating {get; private set;}
		public List<Long> sharing_agreement_ids {get; private set;}
		public List<Long> followup_ids {get; private set;}
		public Long ticket_form_id {get; set;}
		public Long brand_id {get; set;}
		public DateTime created_at {get; private set;}
		public DateTime updated_at {get; private set;}
		public ZTicketComment comment {get; set;} // use for adding the ticket comment
	}

	public class ZTicketCustomField {
		public Long id {get; set;}
		public String value {get; set;}

		public ZTicketCustomField() {}
		public ZTicketCustomField(Long id, String value) { this.id = id; this.value = value; }
	}

	public class ZTicketVia {
		public String channel {get; set;}
		//public String source {get; set;}
	}

	public class ZTicketSatisfactionRating {
		public Long id {get; set;}
		public String score {get; set;}
		public String comment {get; set;}
	}

	public class ZTicketComment {
		public String body {get; set;}
		public Boolean x_public {get; set;}  // Use "x_public" in place of "public" which is a reserved keyword. Requires custom de/serialization.
		public String uploads {get; set;}
	}

	// { "locale_id": 8, "name": "Pablo", "email": "pablito@example.org" }
	public class ZTicketRequester {
		public Long locale_id {get; set;}
		public String name {get; set;}
		public String email {get; set;}
	}

	public class PagedTicketsWrapper {
		public ZTicket[] tickets {get;set;}

		// Paging support
		public String next_page {get; set;}
		public Long nextPageNumber { get { return ZendeskAPI.getPageNumber(next_page); } private set; }
		public String previous_page {get; set;}
		public Long previousPageNumber { get { return ZendeskAPI.getPageNumber(previous_page); } private set; }
	}

	// Used to deserialize the result of a individual Ticket create/read/update API call
	private class TicketWrapper {
		public ZTicket ticket {get; set;}
	}

	public ZendeskTickets(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

	public ZTicket getTicket(Long ticketId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/tickets/' + ticketId + '.json');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error getting Ticket ' + ticketId + ' (' + res.getStatusCode() + ')');
		}

		TicketWrapper resultWrapper = (TicketWrapper)JSON.deserialize(res.getBody(), TicketWrapper.class);
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

	// Type can be one of: question, incident, problem, task
	public Long createTicket(TicketType type, String subject, String commentText, String attachmentToken, Long requesterId, Long groupId, Long assigneeId, Long ticketFormId, List<ZTicketCustomField> zcfList) {
		ZTicket zt = new ZTicket();
		//zt.type = type.name();
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

		TicketWrapper newTicketWrapper = new TicketWrapper();
		newTicketWrapper.ticket = zticket;

		HttpRequest req = zapi.createRequest('POST', ZendeskAPI.BASE_PATH + '/tickets.json');
		String reqBody = JSON.serialize(newTicketWrapper);
		req.setBody(reqBody);
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error creating Ticket (' + res.getStatusCode() + ')');
		}

		TicketWrapper resultWrapper = (TicketWrapper)JSON.deserialize(res.getBody(), TicketWrapper.class);
		// Return the ID of the new Ticket
		return ((resultWrapper==null || resultWrapper.ticket == null) ? null : resultWrapper.ticket.id);
	}

/*
	public void createManyTickets(List<ZTicket> ztickets) {
		PagedTicketsWrapper wrapper = new PagedTicketsWrapper();
		wrapper.tickets = ztickets;

		HttpRequest req = zapi.createRequest('POST', ZendeskAPI.BASE_PATH + '/tickets/create_many.json');
		req.setBody(JSON.serialize(newTicketWrapper));
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error creating Ticket (' + res.getStatusCode() + ')');
		}

		System.debug('**createMany response=' = res.getBody());
		//TicketWrapper resultWrapper = (TicketWrapper)JSON.deserialize(res.getBody(), TicketWrapper.class);
	}
*/

	// /api/v2/tickets.json
	public PagedTicketsWrapper getTickets() {
        return getTickets(null);
    }

	// /api/v2/tickets.json
    public PagedTicketsWrapper getTickets(Long page) {
        return getTickets(page, '/tickets.json');
    }

	// /api/v2/organizations/{organization_id}/tickets.json
	public PagedTicketsWrapper getTicketsByOrgId(Long orgId) {
        return getTicketsByOrgId(orgId, null);
    }

	// /api/v2/organizations/{organization_id}/tickets.json
	public PagedTicketsWrapper getTicketsByOrgId(Long orgId, Long page) {
		if (orgId == null) { throw new ZendeskException('orgId parameter must not be null'); }

        return getTickets(page, '/organizations/' + orgId + '/tickets.json');
    }

	// /api/v2/users/{user_id}/tickets/requested.json
	public PagedTicketsWrapper getTicketsByRequesterId(Long requesterId) {
        return getTicketsByRequesterId(requesterId, null);
    }

	// /api/v2/users/{user_id}/tickets/requested.json
	public PagedTicketsWrapper getTicketsByRequesterId(Long requesterId, Long page) {
		if (requesterId == null) { throw new ZendeskException('requesterId parameter must not be null'); }

        return getTickets(page, '/users/' + requesterId + '/tickets/requested.json');
    }

	// /api/v2/users/{user_id}/tickets/ccd.json
	public PagedTicketsWrapper getTicketsByCCUserId(Long userId) {
        return getTicketsByCCUserId(userId, null);
    }

	// /api/v2/users/{user_id}/tickets/ccd.json
	public PagedTicketsWrapper getTicketsByCCUserId(Long userId, Long page) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

        return getTickets(page, '/users/' + userId + '/tickets/ccd.json');
    }

	// /api/v2/users/{user_id}/tickets/assigned.json
	public PagedTicketsWrapper getTicketsByAssigneeId(Long assigneeId) {
        return getTicketsByAssigneeId(assigneeId, null);
    }

	// /api/v2/users/{user_id}/tickets/assigned.json
	public PagedTicketsWrapper getTicketsByAssigneeId(Long assigneeId, Long page) {
		if (assigneeId == null) { throw new ZendeskException('assigneeId parameter must not be null'); }

        return getTickets(page, '/users/' + assigneeId + '/tickets/assigned.json');
    }

	// /api/v2/tickets/recent.json
	public PagedTicketsWrapper getRecentTickets() {
        return getRecentTickets(null);
    }

	// /api/v2/tickets/recent.json
	public PagedTicketsWrapper getRecentTickets(Long page) {
        return getTickets(page, '/users/tickets/recent.json');
    }

	// Get a specific page of Tickets
	private PagedTicketsWrapper getTickets(Long page, String apiPath) {
        HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/tickets.json' + (page==null ? '' : '?page=' + page));
        HttpResponse res = new Http().send(queryReq);

        if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error getting Tickets (' + res.getStatusCode() + ')');
		}

        PagedTicketsWrapper wrapper = (PagedTicketsWrapper)JSON.deserialize(res.getBody(), PagedTicketsWrapper.class);
        return wrapper;
    }

	public void deleteTicket(Long ticketId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/tickets/' + ticketId + '.json');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error deleting Ticket ' + ticketId + ' (' + res.getStatusCode() + ')');
		}
	}

	public void updateTicket(Long ticketId, ZTicket zticket) {
		updateTicket(ticketId, zticket, null);
	}

	public void updateTicket(Long ticketId, ZTicket zticket, Set<String> fieldsToNull) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }
		if (zticket == null) { throw new ZendeskException('zticket parameter must not be null'); }

		HttpRequest req = zapi.createRequest('PUT', ZendeskAPI.BASE_PATH + '/tickets/' + ticketId + '.json');
		String ticketJson = unreplaceReservedWords(ZendeskAPI.serializeJsonNoNulls(zticket, fieldsToNull));
		req.setBody('{ "ticket": ' + ticketJson + ' }');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error updating Ticket (' + res.getStatusCode() + ')');
		}
	}

	/*
	public void updateTickets(Set<String> ticketIds, String commentText) {
		// Accepts a comma-separated list of up to 100 ticket ids.
		if (ticketIds.length() > 100) { throw new ZendeskException('More than 100 ticketIds is not supported'); }
		String endpoint = ZendeskAPI.BASE_PATH + '/tickets/update_many.json?ids=';
		for (String cur : ticketIds) {
			endpoint += cur + ',';
		}
		endpoint = endpoint.substring(0, endpoint.length()-1);
		HttpRequest req = createRequest('PUT', endpoint);

		ZendeskNewTicket.ZendeskComment zc = new ZendeskNewTicket.ZendeskComment();
		zc.body = commentText;
		ZendeskNewTicket zt = new ZendeskNewTicket();
		zt.comment = zc;

		String reqBody = JSON.serialize(zt);
		reqBody = '{"ticket":' + reqBody + '}';
		req.setBody(reqBody);
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error updating tickets + ' (' + res.getStatusCode() + ')');
		}
	}
	*/

	// helper method to add a new comment to a ticket
	public void addTicketComment(Long ticketId, String commentText, Boolean isPublic) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }
		if (String.isBlank(commentText)) { throw new ZendeskException('commentText parameter must not be empty'); }

		/*
		// Manually build the update ticket JSON since we can't serialize a TicketComment
		// object due to "public" being a reserved keyword
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeFieldName('ticket');
		gen.writeStartObject();
		gen.writeFieldName('comment');
		gen.writeStartObject();
		gen.writeObjectField('body', commentText);
		gen.writeObjectField('public', isPublic);
		gen.writeEndObject();
		gen.writeEndObject();
		gen.writeEndObject();
		String ticketJson = gen.getAsString();
		*/

		ZTicket ticket = new ZTicket();
		ticket.comment = new ZTicketComment();
		ticket.comment.body = commentText;
		ticket.comment.x_public = isPublic;
		// Use custom serialize() method to remove all NULL fields from the JSON
		String ticketJson = unreplaceReservedWords(ZendeskAPI.serializeJsonNoNulls(ticket));

		HttpRequest req = zapi.createRequest('PUT', ZendeskAPI.BASE_PATH + '/tickets/' + ticketId + '.json');
		req.setBody('{ "ticket": ' + ticketJson + ' }');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			System.debug(res.getBody());
			throw new ZendeskException('Error updating ticket (' + res.getStatusCode() + ')');
		}
	}

	// helper method to add a new comment to a ticket and change its status
	public void addTicketCommentAndChangeStatus(Long ticketId, String commentText, Boolean isPublic, TicketStatus status) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }
		if (String.isBlank(commentText)) { throw new ZendeskException('commentText parameter must not be empty'); }
		if (status == null) { throw new ZendeskException('status parameter must not be null'); }
		/*
		// Manually build the update ticket JSON since we can't serialize a TicketComment
		// object due to "public" being a reserved keyword
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeFieldName('ticket');
		gen.writeStartObject();
		gen.writeFieldName('comment');
		gen.writeStartObject();
		gen.writeObjectField('body', commentText);
		gen.writeObjectField('public', isPublic);
		gen.writeEndObject();
		gen.writeObjectField('status', status.status);
		gen.writeEndObject();
		gen.writeEndObject();
		String ticketJson = gen.getAsString();
		*/

		ZTicket ticket = new ZTicket();
		ticket.comment = new ZTicketComment();
		ticket.comment.body = commentText;
		ticket.comment.x_public = isPublic;
		ticket.status = status.status;
		// Use custom serialize() method to remove all NULL fields from the JSON
		String ticketJson = unreplaceReservedWords(ZendeskAPI.serializeJsonNoNulls(ticket));

		HttpRequest req = zapi.createRequest('PUT', ZendeskAPI.BASE_PATH + '/tickets/' + ticketId + '.json');
		req.setBody('{ "ticket": ' + ticketJson + ' }');
		HttpResponse res = new Http().send(req);

		if (!ZendeskAPI.isSuccess(res)) {
			System.debug(res.getBody());
			throw new ZendeskException('Error updating ticket (' + res.getStatusCode() + ')');
		}
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
