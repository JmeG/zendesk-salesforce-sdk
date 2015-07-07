// This class provides functionality to call the Zendesk API to interact with Ticket records
public with sharing class ZendeskTickets {

	private final ZendeskAPI zapi;

	public enum TicketType { question, incident, problem, task }
	public enum TicketPriority { low, normal, high, urgent }
	// TODO: we can't use "new" since it's a reserved keyword
	//public enum TicketStatus { new, open, pending, hold, solved, closed }

	public class ZTicket {
		public Integer id {get; private set;}
		public String url {get; private set;}
		public String external_id {get; set;}
		public TicketType type {get; set;}
		public String subject {get; set;}
		public String description {get; private set;} // readonly. first comment on ticket
		public TicketPriority priority {get; set;}
		public String status {get; set;}
		public String recipient {get; set;}
		public Integer requester_id {get; set;}
		public Integer submitter_id {get; set;}
		public Integer assignee_id {get; set;}
		public Integer organization_id {get; private set;}
		public Integer group_id {get; set;}
		public List<Integer> collaborator_ids {get; set;}
		public Integer forum_topic_id {get; set;}
		public Integer problem_id {get; set;}
		public Boolean has_incidents {get; private set;}
		public DateTime due_at {get; set;}
		public List<String> tags {get; set;}
		public ZTicketVia via {get; private set;}
		public List<ZTicketCustomField> custom_fields {get; set;}
		public ZTicketSatisfactionRating satisfaction_rating {get; private set;}
		public List<Integer> sharing_agreement_ids {get; private set;}
		public List<Integer> followup_ids {get; private set;}
		public Integer ticket_form_id {get; set;}
		public Integer brand_id {get; set;}
		public DateTime created_at {get; private set;}
		public DateTime updated_at {get; private set;}
		public ZTicketComment comment {get; set;} // use for adding the ticket comment
	}

	public class ZTicketCustomField {
		public Integer id {get; set;}
		public String value {get; set;}

		public ZTicketCustomField() {}
		public ZTicketCustomField(Integer id, String value) { this.id = id; this.value = value; }
	}

	public class ZTicketVia {
		public String channel {get; set;}
		//public String source {get; set;}
	}

	public class ZTicketSatisfactionRating {
		public Integer id {get; set;}
		public String score {get; set;}
		public String comment {get; set;}
	}

	public class ZTicketComment {
		public String body {get; set;}
		public String uploads {get; set;}
	}

	public class PagedTicketsWrapper {
		public ZTicket[] tickets {get;set;}

		// "https://test.zendesk.com/api/v2/tickets.json?page=2"
		public String next_page {get; set;}
		public Integer nextPageNumber {
			public get { return (String.isEmpty(next_page) ? null : Integer.valueOf(next_page.substringAfterLast('page=').substringBefore('&'))); }
			private set;
		}
	}

	// Used to deserialize the result of a individual Ticket create/read/update API call
	private class TicketWrapper {
		public ZTicket ticket {get; set;}
	}

	public ZendeskTickets(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

	public ZTicket getTicket(Integer ticketId) {
		HttpRequest req = zapi.setupRequest('GET', ZendeskAPI.BASE_PATH + '/tickets/' + String.valueOf(ticketId) + '.json');
		HttpResponse res = new Http().send(req);
		String resBody = res.getBody();

		ZTicket zticket = null;
		if (res.getStatusCode() == 200) {
			// Deserialize the response into a typed class
			TicketWrapper resultWrapper = (TicketWrapper)JSON.deserialize(resBody, TicketWrapper.class);
			zticket = resultWrapper.ticket;
		}

		return zticket;
	}

	public Integer createTicket(TicketType type, String subject, String commentText, Integer requesterId) {
		return createTicket(type, subject, commentText, null, requesterId, null, null, null, null);
	}

	public Integer createTicket(TicketType type, String subject, String commentText, String attachmentToken, Integer requesterId) {
		return createTicket(type, subject, commentText, attachmentToken, requesterId, null, null, null, null);
	}

	public Integer createTicket(TicketType type, String subject, String commentText, Integer requesterId, List<ZTicketCustomField> zcfList) {
		return createTicket(type, subject, commentText, null, requesterId, null, null, null, zcfList);
	}

	public Integer createTicket(TicketType type, String subject, String commentText, String attachmentToken, Integer requesterId, List<ZTicketCustomField> zcfList) {
		return createTicket(type, subject, commentText, attachmentToken, requesterId, null, null, null, zcfList);
	}

	public Integer createTicket(TicketType type, String subject, String commentText, Integer requesterId, Integer groupId, Integer assigneeId, Integer ticketFormId, List<ZTicketCustomField> zcfList) {
		return createTicket(type, subject, commentText, null, requesterId, groupId, assigneeId, ticketFormId, zcfList);
	}

	// Type can be one of: question, incident, problem, task
	public Integer createTicket(TicketType type, String subject, String commentText, String attachmentToken, Integer requesterId, Integer groupId, Integer assigneeId, Integer ticketFormId, List<ZTicketCustomField> zcfList) {
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

	public Integer createTicket(ZTicket zticket) {
		TicketWrapper newTicketWrapper = new TicketWrapper();
		newTicketWrapper.ticket = zticket;

		HttpRequest req = zapi.setupRequest('POST', ZendeskAPI.BASE_PATH + '/tickets.json');
		String reqBody = JSON.serialize(newTicketWrapper);
		req.setBody(reqBody);
		HttpResponse res = new Http().send(req);
		String resBody = res.getBody();

		if (res.getStatusCode() != 201) {
			throw new ZendeskException('Error occurred trying to create ticket');
		}

		// Deserialize the response into a typed class
		// Find the ID of the new Ticket
		TicketWrapper resultWrapper = (TicketWrapper)JSON.deserialize(resBody, TicketWrapper.class);

		return ((resultWrapper==null || resultWrapper.ticket == null) ? null : resultWrapper.ticket.id);
	}

	// NOTE: You must use Admin credentials to use this method
	public void deleteTicket(Integer ticketId) {
		HttpRequest req = zapi.setupRequest('DELETE', ZendeskAPI.BASE_PATH + '/tickets/' + String.valueOf(ticketId) + '.json');
		HttpResponse res = new Http().send(req);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error occurred trying to delete ticket ' + ticketId);
		}
	}

	// /api/v2/tickets.json
	public PagedTicketsWrapper getTickets() {
        return getTickets(null);
    }

	// /api/v2/tickets.json
    public PagedTicketsWrapper getTickets(Integer page) {
        return getTickets(page, '/tickets.json');
    }

	// /api/v2/organizations/{organization_id}/tickets.json
	public PagedTicketsWrapper getTicketsByOrgId(Integer orgId) {
        return getTicketsByOrgId(orgId, null);
    }

	// /api/v2/organizations/{organization_id}/tickets.json
	public PagedTicketsWrapper getTicketsByOrgId(Integer orgId, Integer page) {
        return getTickets(page, '/organizations/' + String.valueOf(orgId) + '/tickets.json');
    }

	// /api/v2/users/{user_id}/tickets/requested.json
	public PagedTicketsWrapper getTicketsByRequesterId(Integer requesterId) {
        return getTicketsByRequesterId(requesterId, null);
    }

	// /api/v2/users/{user_id}/tickets/requested.json
	public PagedTicketsWrapper getTicketsByRequesterId(Integer requesterId, Integer page) {
        return getTickets(page, '/users/' + String.valueOf(requesterId) + '/tickets/requested.json');
    }

	// /api/v2/users/{user_id}/tickets/ccd.json
	public PagedTicketsWrapper getTicketsByCCUserId(Integer userId) {
        return getTicketsByCCUserId(userId, null);
    }

	// /api/v2/users/{user_id}/tickets/ccd.json
	public PagedTicketsWrapper getTicketsByCCUserId(Integer userId, Integer page) {
        return getTickets(page, '/users/' + String.valueOf(userId) + '/tickets/ccd.json');
    }

	// /api/v2/users/{user_id}/tickets/assigned.json
	public PagedTicketsWrapper getTicketsByAssigneeId(Integer assigneeId) {
        return getTicketsByAssigneeId(assigneeId, null);
    }

	// /api/v2/users/{user_id}/tickets/assigned.json
	public PagedTicketsWrapper getTicketsByAssigneeId(Integer assigneeId, Integer page) {
        return getTickets(page, '/users/' + String.valueOf(assigneeId) + '/tickets/assigned.json');
    }

	// /api/v2/tickets/recent.json
	public PagedTicketsWrapper getRecentTickets() {
        return getRecentTickets(null);
    }

	// /api/v2/tickets/recent.json
	public PagedTicketsWrapper getRecentTickets(Integer page) {
        return getTickets(page, '/users/tickets/recent.json');
    }

	// Get a specific page of Tickets
	private PagedTicketsWrapper getTickets(Integer page, String apiPath) {
        HttpRequest queryReq = zapi.setupRequest('GET', ZendeskAPI.BASE_PATH + '/tickets.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
        HttpResponse res = new Http().send(queryReq);
        String resBody = res.getBody();

        PagedTicketsWrapper wrapper = null;
        if (res.getStatusCode() == 200) {
			// Deserialize the response into a typed class
            wrapper = (PagedTicketsWrapper)JSON.deserialize(resBody, PagedTicketsWrapper.class);
        }

        return wrapper;
    }

/*
	public void addTicketComment(Integer ticketId, String commentText) {
		HttpRequest req = zapi.setupRequest('PUT', ZendeskAPI.BASE_PATH + '/tickets/' + String.valueOf(zticket.id) + '.json');

		// TODO: encode the commentText
		String ticketJson = '{ "ticket": { "id": ' + String.valueOf(ticketId) + ', "comment": { "body": "' + commentText + '" } } }';
		req.setBody(ticketJson);

		HttpResponse res = new Http().send(req);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error occurred trying to update ticket.');
		}
	}
*/

/*
	// NOTE: this isn't working correctly because when we serialize the ZTicket object it includes all fields
	// in the object that aren't populated with null values and the ZendeskAPI thinks it needs to update
	// those fields to NULL instead of ignoring them.
	// We only want the JSON to include fields we are trying to update
	public void updateTicket(ZTicket zticket) {
		HttpRequest req = zapi.setupRequest('PUT', ZendeskAPI.BASE_PATH + '/tickets/' + String.valueOf(zticket.id) + '.json');

		TicketWrapper ticketWrapper = new TicketWrapper();
		ticketWrapper.ticket = zticket;
		String reqBody = JSON.serialize(ticketWrapper);
		req.setBody('{ "ticket": { "id": 24, "comment": { "body": "new comment" } } } ');

		HttpResponse res = new Http().send(req);
		String resBody = res.getBody();

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error occurred trying to update ticket.');
		}
	}
*/

	/*
	public void updateTickets(Set<String> ticketIds, String commentText) {
		// Accepts a comma-separated list of up to 100 ticket ids.
		if (ticketIds.length() > 100) { throw new ZendeskException('More than 100 ticketIds is not supported'); }
		String endpoint = ZendeskAPI.BASE_PATH + '/tickets/update_many.json?ids=';
		for (String cur : ticketIds) {
			endpoint += cur + ',';
		}
		endpoint = endpoint.substring(0, endpoint.length()-1);
		HttpRequest req = setupRequest('PUT', endpoint);

		ZendeskNewTicket.ZendeskComment zc = new ZendeskNewTicket.ZendeskComment();
		zc.body = commentText;
		ZendeskNewTicket zt = new ZendeskNewTicket();
		zt.comment = zc;

		String reqBody = JSON.serialize(zt);
		reqBody = '{"ticket":' + reqBody + '}';
		req.setBody(reqBody);
		HttpResponse res = new Http().send(req);

		if (res.getStatusCode() != 200) {
			//error handling logic
		}
	}
	*/
}
