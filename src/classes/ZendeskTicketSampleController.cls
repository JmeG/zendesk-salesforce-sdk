public with sharing class ZendeskTicketSampleController {

	public String subdomain {get;set;}
	public String username {get;set;}
	public String pwdOrToken {get;set;}
	public String authType {get;set;}

	public Long requesterId {get;set;}
	public String newTicketSubject {get;set;}
	public String newTicketComment {get;set;}

	public ZendeskTickets.ZTicket[] tickets {get;set;}
	public String pageMessage {get;set;}

	public ZendeskTicketSampleController() {}

	public PageReference createTicket() {
		pageMessage = '';
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskTickets ztickets = new ZendeskTickets(zapi);

			Long newTicketId = ztickets.createTicket(ZendeskTickets.TicketType.question, newTicketSubject, newTicketComment, requesterId);

			pageMessage = 'Ticket created with ID: ' + newTicketId;
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}

	public PageReference getTickets() {
		pageMessage = '';
		tickets = null;
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskTickets ztickets = new ZendeskTickets(zapi);

			ZendeskTickets.PagedTicketsWrapper pagedTickets = ztickets.getTickets();
			tickets = pagedTickets.tickets;
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}

}
