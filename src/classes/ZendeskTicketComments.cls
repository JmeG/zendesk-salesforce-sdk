// This class provides functionality to call the Zendesk API to interact with Ticket Comment records
public with sharing class ZendeskTicketComments {

	private final ZendeskAPI zapi;

	public class ZTicketComment {
		public Long id {get; private set;}
		public String type {get; set;}
		public String body {get; set;}
		public String html_body {get; set;}
		//public Boolean public {get; set;} // TODO: can't use reserved keyword "public". Need to do custom serialization
		public Integer author_id {get; set;}
		public ZendeskAttachments.ZAttachment[] attachments {get; set;}
		public ZendeskTickets.ZTicketVia via {get; set;}
		public DateTime created_at {get; private set;}
	}

	public class PagedTicketCommentsWrapper {
		public ZTicketComment[] comments {get; set;}

		// Paging support
		public String next_page {get; set;}
		public Integer nextPageNumber { get { return ZendeskAPI.getPageNumber(next_page); } private set; }
		public String previous_page {get; set;}
		public Integer previousPageNumber { get { return ZendeskAPI.getPageNumber(previous_page); } private set; }
	}

	private class TicketCommentWrapper {
		public ZTicketComment comment {get;set;}
	}

	public ZendeskTicketComments(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

	// Get the first page of Ticket Comments
	public PagedTicketCommentsWrapper getTicketComments(Integer ticketId) {
		return getTicketComments(ticketId, null);
	}

	// Get a specific page of Ticket Comments
	public PagedTicketCommentsWrapper getTicketComments(Integer ticketId, Integer page) {
		HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/tickets/' + ticketId + '/comments.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
		HttpResponse res = new Http().send(queryReq);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error getting Ticket Comments (' + res.getStatusCode() + ')');
		}

		PagedTicketCommentsWrapper wrapper = (PagedTicketCommentsWrapper)JSON.deserialize(res.getBody(), PagedTicketCommentsWrapper.class);
		return wrapper;
	}

	public void redactStringInComment(Integer ticketId, Integer ticketCommentId, String redactText) {
		if (String.isBlank(redactText)) { throw new ZendeskException ('You must specify text to redact'); }
		HttpRequest req = zapi.createRequest('PUT', ZendeskAPI.BASE_PATH + '/tickets/' + String.valueOf(ticketId) + '/comments/' + String.valueOf(ticketCommentId) + '/redact.json');
		req.setBody('{"text": "' + redactText + '"}');
		HttpResponse res = new Http().send(req);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error redacting Ticket Comment ' + ticketCommentId + ' (' + res.getStatusCode() + ')');
		}
	}

	public void makeCommentPrivate(Integer ticketId, Integer ticketCommentId) {
		HttpRequest req = zapi.createRequest('PUT', ZendeskAPI.BASE_PATH + '/tickets/' + String.valueOf(ticketId) + '/comments/' + String.valueOf(ticketCommentId) + '/make_private.json');
		HttpResponse res = new Http().send(req);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error making Ticket Comment private ' + ticketCommentId + ' (' + res.getStatusCode() + ')');
		}
	}

}
