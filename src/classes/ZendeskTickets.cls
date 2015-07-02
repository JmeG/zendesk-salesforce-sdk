// This class provides common functionality to call the Zendesk API to interact with Ticket records
public with sharing class ZendeskTickets {

	private final ZendeskAPI zapi;

	// Used to deserialize the result of a individual Ticket create/read/update API call
	private class SingleTicketWrapper {
		public ZendeskAPISchema.ZTicket ticket {get;set;}
	}

	public ZendeskTickets(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

	public ZendeskAPISchema.ZTicket getTicket(Integer ticketId) {
		Http h = new Http();
		HttpRequest req = zapi.setupRequest('GET', '/api/v2/tickets/' + String.valueOf(ticketId) + '.json');

		HttpResponse res;
		if (!Test.isRunningTest()) {
			res = h.send(req);
		} else {
			// fake response
			res = new HttpResponse();
			res.setStatusCode(200);
			res.setStatus('OK');
			res.setBody('{"ticket":{"url":"https://zendeskit.zendesk.com/api/v2/tickets/7675.json","id":7675,"external_id":null,"via":{"channel":"web","source":{"from":{},"to":{},"rel":null}},"created_at":"2013-07-24T23:19:49Z","updated_at":"2013-07-29T23:04:57Z","type":null,"subject":"testing api","description":"test","priority":null,"status":"closed","recipient":null,"requester_id":372418401,"submitter_id":372418401,"assignee_id":372418401,"organization_id":null,"group_id":20153691,"forum_topic_id":null,"problem_id":null,"has_incidents":false,"due_at":null,"ticket_form_id":null}}');
		}

		System.debug('getTicket res: ' + res);
		String resBody = res.getBody();
		System.debug('getTicket res body: ' + resBody);

		ZendeskAPISchema.ZTicket zticket = null;
		if (res.getStatusCode() == 200) {
			SingleTicketWrapper resultWrapper = (SingleTicketWrapper)JSON.deserialize(resBody, SingleTicketWrapper.class);
			zticket = resultWrapper.ticket;
		}

		return zticket;
	}

	public Integer createTicket(String type, String subject, String commentText, Integer requesterId) {
		return createTicket(type, subject, commentText, null, requesterId, null, null, null, null);
	}

	public Integer createTicket(String type, String subject, String commentText, String attachmentToken, Integer requesterId) {
		return createTicket(type, subject, commentText, attachmentToken, requesterId, null, null, null, null);
	}

	public Integer createTicket(String type, String subject, String commentText, Integer requesterId, List<ZendeskAPISchema.ZTicketCustomField> zcfList) {
		return createTicket(type, subject, commentText, null, requesterId, null, null, null, zcfList);
	}

	public Integer createTicket(String type, String subject, String commentText, String attachmentToken, Integer requesterId, List<ZendeskAPISchema.ZTicketCustomField> zcfList) {
		return createTicket(type, subject, commentText, attachmentToken, requesterId, null, null, null, zcfList);
	}

	public Integer createTicket(String type, String subject, String commentText, Integer requesterId, Integer groupId, Integer assigneeId, Integer ticketFormId, List<ZendeskAPISchema.ZTicketCustomField> zcfList) {
		return createTicket(type, subject, commentText, null, requesterId, groupId, assigneeId, ticketFormId, zcfList);
	}

	// Type can be one of: question, incident, problem, task
	public Integer createTicket(String type, String subject, String commentText, String attachmentToken, Integer requesterId, Integer groupId, Integer assigneeId, Integer ticketFormId, List<ZendeskAPISchema.ZTicketCustomField> zcfList) {
		ZendeskAPISchema.ZTicket zt = new ZendeskAPISchema.ZTicket();
		zt.type = type;
		zt.subject = subject;
		zt.custom_fields = zcfList;
		zt.requester_id = requesterId;
		zt.assignee_id = assigneeId;
		zt.ticket_form_id = ticketFormId;
		zt.group_id = groupId;

		zt.comment = new ZendeskAPISchema.ZTicketComment();
		zt.comment.body = commentText;
		zt.comment.uploads = attachmentToken;

		return createTicket(zt);
	}

	public Integer createTicket(ZendeskAPISchema.ZTicket zticket) {
		Http h = new Http();
		HttpRequest req = zapi.setupRequest('POST', '/api/v2/tickets.json');

		SingleTicketWrapper ticketWrapper = new SingleTicketWrapper();
		ticketWrapper.ticket = zticket;
		String reqBody = JSON.serialize(ticketWrapper);
		System.debug('**** json string = ' + reqBody);
		req.setBody(reqBody);

		HttpResponse res;
		if (!Test.isRunningTest()) {
			res = h.send(req);
		} else {
			// fake response
			res = new HttpResponse();
			res.setStatusCode(201);
			res.setStatus('OK');
			res.setBody('{"ticket":{"url":"https://zendeskit.zendesk.com/api/v2/tickets/7675.json","id":7675,"external_id":null,"via":{"channel":"web","source":{"from":{},"to":{},"rel":null}},"created_at":"2013-07-24T23:19:49Z","updated_at":"2013-07-29T23:04:57Z","type":null,"subject":"testing api","description":"test","priority":null,"status":"closed","recipient":null,"requester_id":372418401,"submitter_id":372418401,"assignee_id":372418401,"organization_id":null,"group_id":20153691,"forum_topic_id":null,"problem_id":null,"has_incidents":false,"due_at":null,"ticket_form_id":null}}');
		}

		System.debug('createTicket res: ' + res);
		String resBody = res.getBody();
		System.debug('**** res = ' + resBody);

		if (res.getStatusCode() != 201) {
			throw new ZendeskException('Error occurred trying to create ticket');
		}

		SingleTicketWrapper resultWrapper = (SingleTicketWrapper)JSON.deserialize(resBody, SingleTicketWrapper.class);
		System.debug('zticketResult=' + resultWrapper);

		return ((resultWrapper==null || resultWrapper.ticket == null) ? null : resultWrapper.ticket.id);
	}

	// NOTE: You must use Admin credentials to use this method
	public void deleteTicket(Integer ticketId) {
		Http h = new Http();
		HttpRequest req = zapi.setupRequest('DELETE', '/api/v2/tickets/' + String.valueOf(ticketId) + '.json');

		HttpResponse res;
		if (!Test.isRunningTest()) {
			res = h.send(req);
		} else {
			// fake response
			res = new HttpResponse();
			res.setStatusCode(200);
			res.setStatus('OK');
		}

		System.debug('deleteTicket res: ' + res);
		String resBody = res.getBody();
		System.debug('**** res = ' + resBody);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error occurred trying to delete ticket ' + ticketId);
		}
	}


/*
	public void addTicketComment(Integer ticketId, String commentText) {
		Http h = new Http();
		HttpRequest req = zapi.setupRequest('PUT', '/api/v2/tickets/' + String.valueOf(zticket.id) + '.json');

		// TODO: encode the commentText
		String ticketJson = '{ "ticket": { "id": ' + String.valueOf(ticketId) + ', "comment": { "body": "' + commentText + '" } } }';
		req.setBody(ticketJson);

		HttpResponse res;
		if (!Test.isRunningTest()) {
			res = h.send(req);
		} else {
			// fake response
			res = new HttpResponse();
			res.setStatusCode(200);
			res.setStatus('OK');
			res.setBody('{"ticket":{"url":"https://zendeskit.zendesk.com/api/v2/tickets/7675.json","id":7675,"external_id":null,"via":{"channel":"web","source":{"from":{},"to":{},"rel":null}},"created_at":"2013-07-24T23:19:49Z","updated_at":"2013-07-29T23:04:57Z","type":null,"subject":"testing api","description":"test","priority":null,"status":"closed","recipient":null,"requester_id":372418401,"submitter_id":372418401,"assignee_id":372418401,"organization_id":null,"group_id":20153691,"forum_topic_id":null,"problem_id":null,"has_incidents":false,"due_at":null,"ticket_form_id":null}}');
		}

		System.debug('updateTicket res: ' + res);
		String resBody = res.getBody();
		System.debug('**** res = ' + resBody);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error occurred trying to update ticket.');
		}
	}
*/

/*
	// NOTE: this isn't working correctly because when we serialize the ZTicket object it includes all fields
	// in the object that aren't populated with null values and the ZendeskAPI thinks it needs to update
	// those fields to NULL instead of ignore them.
	// We only want the JSON to include fields we are trying to update

	public void updateTicket(ZendeskAPISchema.ZTicket zticket) {
		Http h = new Http();
		HttpRequest req = zapi.setupRequest('PUT', '/api/v2/tickets/' + String.valueOf(zticket.id) + '.json');

		SingleTicketWrapper ticketWrapper = new SingleTicketWrapper();
		ticketWrapper.ticket = zticket;
		String reqBody = JSON.serialize(ticketWrapper);
		System.debug('**** json string = ' + reqBody);
		//req.setBody(reqBody);
		req.setBody('{ "ticket": { "id": 24, "comment": { "body": "new comment" } } } ');

		HttpResponse res;
		if (!Test.isRunningTest()) {
			res = h.send(req);
		} else {
			// fake response
			res = new HttpResponse();
			res.setStatusCode(200);
			res.setStatus('OK');
			res.setBody('{"ticket":{"url":"https://zendeskit.zendesk.com/api/v2/tickets/7675.json","id":7675,"external_id":null,"via":{"channel":"web","source":{"from":{},"to":{},"rel":null}},"created_at":"2013-07-24T23:19:49Z","updated_at":"2013-07-29T23:04:57Z","type":null,"subject":"testing api","description":"test","priority":null,"status":"closed","recipient":null,"requester_id":372418401,"submitter_id":372418401,"assignee_id":372418401,"organization_id":null,"group_id":20153691,"forum_topic_id":null,"problem_id":null,"has_incidents":false,"due_at":null,"ticket_form_id":null}}');
		}

		System.debug('updateTicket res: ' + res);
		String resBody = res.getBody();
		System.debug('**** res = ' + resBody);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error occurred trying to update ticket.');
		}
	}
*/

	/*
	public void updateTickets(Set<String> ticketIds, String commentText) {
		Http h = new Http();

		// Accepts a comma-separated list of up to 100 ticket ids.
		if (ticketIds.length() > 100) { throw new ZendeskException('More than 100 ticketIds is not supported'); }
		String endpoint = '/api/v2/tickets/update_many.json?ids=';
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
		System.debug('**** json string = ' + reqBody);

		HttpResponse res;
		if (!Test.isRunningTest()) {
			res = h.send(req);
		} else {
			// insert fake test response here.
			res = new HttpResponse();
			res.setStatusCode(200);
			res.setStatus('OK');
			res.setBody('test');
		}

		System.debug('**** res = ' + res.getBody());

		if (res.getStatusCode() != 200) {
			//error handling logic
		}
	}
	*/
}
