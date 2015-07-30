// This class provides functionality to call the Zendesk Ticket Comments API
public class ZendeskTicketCommentsAPI extends ZendeskResourceBase {

	private class TicketCommentWrapper {
		public ZTicketComment comment {get;set;}
	}
	
	public class TicketCommentsWrapper extends ZendeskPagingBase {
		public List<ZTicketComment> comments {get;set;}
	}

	public ZendeskTicketCommentsAPI(ZendeskConnection zconn) {
		super(zconn);
	}

	public TicketCommentsWrapper getTicketComments(Long ticketId) {
		return getTicketComments(ticketId, null);
	}

	public TicketCommentsWrapper getTicketComments(Long ticketId, Map<String, Object> queryParams) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

		HttpRequest req = zconn.createRequest('GET', '/tickets/'+ticketId+'/comments.json', queryParams);
		return (TicketCommentsWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), TicketCommentsWrapper.class);
	}

	public void redactStringInComment(Long ticketId, Long ticketCommentId, String redactText) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }
		if (ticketCommentId == null) { throw new ZendeskException('ticketCommentId parameter cannot be null'); }
		if (String.isBlank(redactText)) { throw new ZendeskException('redactText parameter must not be empty'); }

		HttpRequest req = zconn.createRequest('PUT', '/tickets/'+ticketId+'/comments/'+ticketCommentId+'/redact.json');
		req.setBody('{"text": "' + redactText + '"}');
		zconn.sendRequest(req);
	}

	public void makeCommentPrivate(Long ticketId, Long ticketCommentId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }
		if (ticketCommentId == null) { throw new ZendeskException('ticketCommentId parameter cannot be null'); }

		zconn.sendRequest(zconn.createRequest('PUT', '/tickets/'+ticketId+'/comments/'+ticketCommentId+'/make_private.json'));
	}

	// replace reserved keywords in the JSON string and map them to field names prefixed with "x_"
    // Use when calling deserialize()
	private String replaceReservedWords(String str) {
		str = str.replaceAll('"public"\\s*:', '"x_public":');
		return str;
	}

	// un-replace reserved keywords in the JSON string
    // Use when calling serialize()
	//private String unreplaceReservedWords(String str) {
	//	str = str.replaceAll('"x_public"\\s*:', '"public":');
	//	return str;
	//}

}
