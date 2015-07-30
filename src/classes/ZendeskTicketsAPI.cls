// This class provides functionality to call the Zendesk Tickets API
public class ZendeskTicketsAPI extends ZendeskResourceBase {

	public class TicketWrapper extends ZendeskSideLoadingBase {
		public ZTicket ticket {get;set;}
		public TicketWrapper(ZTicket ticket) { this.ticket = ticket; }
	}

	public class TicketsWrapper extends ZendeskPagingBase {
		public List<ZTicket> tickets {get;set;}
		public TicketsWrapper(List<ZTicket> tickets) { this.tickets = tickets; }
	}

	public ZendeskTicketsAPI(ZendeskConnection zconn) {
		super(zconn);
	}

	public TicketWrapper getTicket(Long ticketId) {
		return getTicket(ticketId, null);
	}
	public TicketWrapper getTicket(Long ticketId, Map<String, Object> queryParams) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

		HttpRequest req = zconn.createRequest('GET', '/tickets/'+ticketId+'.json', queryParams);
		return (TicketWrapper)JSON.deserialize(zconn.sendRequest(req), TicketWrapper.class);
	}

	// /api/v2/tickets.json
	public TicketsWrapper getTickets() {
        return getTickets(null);
    }
    public TicketsWrapper getTickets(Map<String, Object> queryParams) {
        return getTicketsHelper(zconn.createRequest('GET', '/tickets.json', queryParams));
    }

	// /api/v2/organizations/{organization_id}/tickets.json
	public TicketsWrapper getTicketsByOrgId(Long orgId) {
        return getTicketsByOrgId(orgId, null);
    }
	public TicketsWrapper getTicketsByOrgId(Long orgId, Map<String, Object> queryParams) {
		if (orgId == null) { throw new ZendeskException('orgId parameter cannot be null'); }

        return getTicketsHelper(zconn.createRequest('GET', '/organizations/'+orgId+'/tickets.json', queryParams));
    }

	// /api/v2/users/{user_id}/tickets/requested.json
	public TicketsWrapper getTicketsByRequesterId(Long requesterId) {
        return getTicketsByRequesterId(requesterId, null);
    }
	public TicketsWrapper getTicketsByRequesterId(Long requesterId, Map<String, Object> queryParams) {
		if (requesterId == null) { throw new ZendeskException('requesterId parameter cannot be null'); }

        return getTicketsHelper(zconn.createRequest('GET', '/users/'+requesterId+'/tickets/requested.json', queryParams));
    }

	// /api/v2/users/{user_id}/tickets/ccd.json
	public TicketsWrapper getTicketsByCCUserId(Long userId) {
        return getTicketsByCCUserId(userId, null);
    }
	public TicketsWrapper getTicketsByCCUserId(Long userId, Map<String, Object> queryParams) {
		if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }

        return getTicketsHelper(zconn.createRequest('GET', '/users/'+userId+'/tickets/ccd.json', queryParams));
    }

	// /api/v2/users/{user_id}/tickets/assigned.json
	public TicketsWrapper getTicketsByAssigneeId(Long assigneeId) {
        return getTicketsByAssigneeId(assigneeId, null);
    }
	public TicketsWrapper getTicketsByAssigneeId(Long assigneeId, Map<String, Object> queryParams) {
		if (assigneeId == null) { throw new ZendeskException('assigneeId parameter cannot be null'); }

        return getTicketsHelper(zconn.createRequest('GET', '/users/'+assigneeId+'/tickets/assigned.json', queryParams));
    }

	// /api/v2/tickets/recent.json
	public TicketsWrapper getRecentTickets() {
		return getRecentTickets(null);
    }
	public TicketsWrapper getRecentTickets(Map<String, Object> queryParams) {
        return getTicketsHelper(zconn.createRequest('GET', '/users/tickets/recent.json', queryParams));
    }

	// /api/v2/tickets/show_many.json?ids={ids}
	public TicketsWrapper getTicketsByIds(Set<Long> ticketIds) {
		if (ticketIds == null || ticketIds.isEmpty()) { throw new ZendeskException('ticketIds parameter cannot be null or empty'); }

        return getTicketsHelper(zconn.createRequest('GET', '/tickets/show_many.json', new Map<String, Object>{'ids'=>toCSV(ticketIds)}));
    }

	// /api/v2/tickets/{id}/incidents.json
	public TicketsWrapper getTicketIncidents(Long ticketId) {
        return getTicketIncidents(ticketId, null);
    }
	public TicketsWrapper getTicketIncidents(Long ticketId, Map<String, Object> queryParams) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

        return getTicketsHelper(zconn.createRequest('GET', '/tickets/'+ticketId+'/incidents.json', queryParams));
    }

	// /api/v2/problems.json
	public TicketsWrapper getTicketProblems() {
        return getTicketProblems(null);
    }
	public TicketsWrapper getTicketProblems(Map<String, Object> queryParams) {
        return getTicketsHelper(zconn.createRequest('GET', '/tickets/problem.json', queryParams));
    }

	// Helper method for getting tickets
	private TicketsWrapper getTicketsHelper(HttpRequest req) {
        return (TicketsWrapper)JSON.deserialize(zconn.sendRequest(req), TicketsWrapper.class);
    }

	public ZendeskUsersAPI.UsersWrapper getTicketCollaborators(Long ticketId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

		HttpRequest req = zconn.createRequest('GET', '/tickets/'+ticketId+'/collaborators.json');
		return (ZendeskUsersAPI.UsersWrapper)JSON.deserialize(zconn.sendRequest(req), ZendeskUsersAPI.UsersWrapper.class);
    }

	public Map<String, Object> getTwicketStatus(Long ticketId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/channels/twitter/tickets/'+ticketId+'/statuses.json');
		return (Map<String, Object>)JSON.deserializeUntyped(zconn.sendRequest(req));
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
		if (zticket == null) { throw new ZendeskException('zticket parameter cannot be null'); }

		HttpRequest req = zconn.createRequest('POST', '/tickets.json');
		req.setBody(unreplaceReservedWords(stripJsonNulls(JSON.serialize(new TicketWrapper(zticket)))));
		TicketWrapper resultWrapper = (TicketWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), TicketWrapper.class);
		return ((resultWrapper==null || resultWrapper.ticket == null) ? null : resultWrapper.ticket.id);
	}

	public Long createTicketFromTweet(Long twitterMessageId, Long monitoredTwitterHandleId) {
		if (twitterMessageId == null) { throw new ZendeskException('twitterMessageId parameter cannot be null'); }
		if (monitoredTwitterHandleId == null) { throw new ZendeskException('monitoredTwitterHandleId parameter cannot be null'); }

		// {"ticket": {"twitter_status_message_id": 8605426295771136, "monitored_twitter_handle_id": 45}}'
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeFieldName('ticket');
		gen.writeStartObject();
		gen.writeNumberField('twitter_status_message_id', twitterMessageId);
        gen.writeNumberField('monitored_twitter_handle_id', monitoredTwitterHandleId);
		gen.writeEndObject();
		gen.writeEndObject();

		HttpRequest req = zconn.createRequest('POST', '/channels/twitter/tickets.json', gen.getAsString());
		TicketWrapper resultWrapper = (TicketWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), TicketWrapper.class);
		return ((resultWrapper==null || resultWrapper.ticket == null) ? null : resultWrapper.ticket.id);
	}

	public ZendeskTypes.ZJobStatus createTickets(List<ZTicket> ztickets) {
		if (ztickets == null || ztickets.isEmpty()) { throw new ZendeskException('ztickets parameter cannot be null or empty'); }

		HttpRequest req = zconn.createRequest('POST', '/tickets/create_many.json');
		req.setBody(unreplaceReservedWords(stripJsonNulls(JSON.serialize(new TicketsWrapper(ztickets)))));
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zconn.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public void updateTicket(Long ticketId, ZTicket zticket) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }
		if (zticket == null) { throw new ZendeskException('zticket parameter cannot be null'); }

		HttpRequest req = zconn.createRequest('PUT', '/tickets/'+ticketId+'.json');
		req.setBody(unreplaceReservedWords(stripJsonNulls(JSON.serialize(new TicketWrapper(zticket)))));
		zconn.sendRequest(req);
	}

	public ZendeskTypes.ZJobStatus updateTickets(List<ZTicket> ztickets) {
		if (ztickets == null || ztickets.isEmpty()) { throw new ZendeskException('ztickets parameter cannot be null or empty'); }
		for (ZTicket zticket : ztickets) {
			if (zticket.id == null) { throw new ZendeskException('Each Ticket must have an id populated'); }
		}

		HttpRequest req = zconn.createRequest('PUT', '/tickets/update_many.json');
		req.setBody(unreplaceReservedWords(stripJsonNulls(JSON.serialize(new TicketsWrapper(ztickets)))));
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zconn.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public ZendeskTypes.ZJobStatus updateTickets(Set<Long> ticketIds, ZTicket zticket) {
		if (ticketIds == null || ticketIds.isEmpty()) { throw new ZendeskException('ticketIds parameter cannot be null or empty'); }
        if (zticket == null) { throw new ZendeskException('zticket parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/tickets/update_many.json', new Map<String, Object>{'ids'=>toCSV(ticketIds)});
		req.setBody(unreplaceReservedWords(stripJsonNulls(JSON.serialize(new TicketWrapper(zticket)))));
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zconn.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	// helper method to add a new comment to a ticket
	public void addTicketComment(Long ticketId, String commentText, Boolean isPublic) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }
		if (String.isBlank(commentText)) { throw new ZendeskException('commentText parameter must not be empty'); }

		ZTicket ticket = new ZTicket();
		ticket.comment = new ZTicketComment();
		ticket.comment.body = commentText;
		ticket.comment.x_public = isPublic;

		HttpRequest req = zconn.createRequest('PUT', '/tickets/'+ticketId+'.json');
		req.setBody(unreplaceReservedWords(stripJsonNulls(JSON.serialize(new TicketWrapper(ticket)))));
		zconn.sendRequest(req);
	}

	// helper method to add a new comment to a ticket and change its status
	public void addTicketCommentAndChangeStatus(Long ticketId, String commentText, Boolean isPublic, TicketStatus status) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }
		if (String.isBlank(commentText)) { throw new ZendeskException('commentText parameter must not be empty'); }
		if (status == null) { throw new ZendeskException('status parameter cannot be null'); }

		ZTicket ticket = new ZTicket();
		ticket.comment = new ZTicketComment();
		ticket.comment.body = commentText;
		ticket.comment.x_public = isPublic;
		ticket.status = status.status;

		HttpRequest req = zconn.createRequest('PUT', '/tickets/'+ticketId+'.json');
		req.setBody(unreplaceReservedWords(stripJsonNulls(JSON.serialize(new TicketWrapper(ticket)))));
		zconn.sendRequest(req);
	}

	public ZendeskTypes.ZJobStatus mergeTickets(Set<Long> sourceTicketIds, String sourceComment, Long targetTicketId, String targetComment) {
		if (sourceTicketIds == null || sourceTicketIds.isEmpty()) { throw new ZendeskException('sourceTicketIds parameter cannot be null or empty'); }
		if (targetTicketId == null) { throw new ZendeskException('targetTicketId parameter cannot be null'); }

		// { "ids": [123, 234], "target_comment": "Closing in favor of #111",, "source_comment": "Combining with #123, #456" }
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
        gen.writeObjectField('ids', sourceTicketIds);
		if (!String.isEmpty(targetComment)) { gen.writeStringField('target_comment', targetComment); }
        if (!String.isEmpty(sourceComment)) { gen.writeStringField('source_comment', sourceComment); }
        gen.writeEndObject();

		HttpRequest req = zconn.createRequest('POST', '/tickets/'+targetTicketId+'/merge.json');
		req.setBody(gen.getAsString());
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zconn.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public void deleteTicket(Long ticketId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

		zconn.sendRequest(zconn.createRequest('DELETE', '/tickets/'+ticketId+'.json'));
	}

	public void deleteTickets(Set<Long> ticketIds) {
		if (ticketIds == null || ticketIds.isEmpty()) { throw new ZendeskException('ticketIds parameter cannot be null or empty'); }

		zconn.sendRequest(zconn.createRequest('DELETE', '/tickets/destroy_many.json', new Map<String, Object>{'ids'=>toCSV(ticketIds)}));
	}

	public Map<String, Object> getTicketRelatedInfo(Long ticketId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/tickets/'+ticketId+'/related.json');
		return (Map<String, Object>)JSON.deserializeUntyped(zconn.sendRequest(req));
	}

	public void markTicketAsSpam(Long ticketId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

		zconn.sendRequest(zconn.createRequest('PUT', '/tickets/'+ticketId+'/mark_as_spam.json'));
	}

	public ZendeskTypes.ZJobStatus markTicketsAsSpam(Set<Long> ticketIds) {
		if (ticketIds == null || ticketIds.isEmpty()) { throw new ZendeskException('ticketIds parameter cannot be null or empty'); }

		HttpRequest req = zconn.createRequest('PUT', '/tickets/mark_many_as_spam.json', new Map<String, Object>{'ids'=>toCSV(ticketIds)});
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zconn.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public TicketsWrapper autocompleteProblems(String text) {
		if (String.isBlank(text) || text.length() < 2) { throw new ZendeskException('text parameter must at least 2 characters'); }

		HttpRequest req = zconn.createRequest('POST', '/problems/autocomplete.json', new Map<String, Object>{'text'=>text});
		return (TicketsWrapper)JSON.deserialize(zconn.sendRequest(req), TicketsWrapper.class);
    }

	// replace reserved keywords in the JSON string and map them to field names prefixed with "x_"
    // Use when calling deserialize()
	private String replaceReservedWords(String str) {
		str = str.replaceAll('"public"\\s*:', '"x_public":');
		return str;
	}

	// un-replace reserved keywords in the JSON string
    // Use when calling serialize()
	private String unreplaceReservedWords(String str) {
		str = str.replaceAll('"x_public"\\s*:', '"public":');
		return str;
	}

}
