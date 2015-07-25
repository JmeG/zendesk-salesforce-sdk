// This class provides functionality to call the Zendesk Ticket Comments API
public class ZendeskTicketComments extends ZendeskResourceBase {

	public class ZTicketComment {
		public Long id {get; private set;}
		public String type {get;set;}
		public String body {get;set;}
		public String html_body {get;set;}
		public Boolean x_public {get;set;} // Use "x_public" in place of "public" which is a reserved keyword. Requires custom de/serialization.
		public Long author_id {get;set;}
		public List<ZendeskAttachments.ZAttachment> attachments {get;set;}
		public ZendeskTickets.ZTicketVia via {get;set;}
		public DateTime created_at {get; private set;}
	}

	public class TicketCommentsWrapper extends ZendeskPagingBase {
		public List<ZTicketComment> comments {get;set;}
	}

	private class TicketCommentWrapper {
		public ZTicketComment comment {get;set;}
	}

	public ZendeskTicketComments(ZendeskAPI zapi) {
		super(zapi);
	}

	public TicketCommentsWrapper getTicketComments(Long ticketId) {
		return getTicketComments(ticketId, null);
	}

	public TicketCommentsWrapper getTicketComments(Long ticketId, Map<String, Object> queryParams) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/tickets/'+ticketId+'/comments.json', queryParams);
		return (TicketCommentsWrapper)JSON.deserialize(replaceReservedWords(zapi.sendRequest(req)), TicketCommentsWrapper.class);
	}

	public void redactStringInComment(Long ticketId, Long ticketCommentId, String redactText) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }
		if (ticketCommentId == null) { throw new ZendeskException('ticketCommentId parameter must not be null'); }
		if (String.isBlank(redactText)) { throw new ZendeskException('redactText parameter must not be empty'); }

		HttpRequest req = zapi.createRequest('PUT', '/tickets/'+ticketId+'/comments/'+ticketCommentId+'/redact.json');
		req.setBody('{"text": "' + redactText + '"}');
		zapi.sendRequest(req);
	}

	public void makeCommentPrivate(Long ticketId, Long ticketCommentId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }
		if (ticketCommentId == null) { throw new ZendeskException('ticketCommentId parameter must not be null'); }

		zapi.sendRequest(zapi.createRequest('PUT', '/tickets/'+ticketId+'/comments/'+ticketCommentId+'/make_private.json'));
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
