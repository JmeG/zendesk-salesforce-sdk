public class ZendeskTicketSampleController {

    public String subdomain { get; set; }
    public String username { get; set; }
    public String pwdOrToken { get; set; }
    public String authType { get; set; }

    public Long requesterId { get; set; }
    public String newTicketSubject { get; set; }
    public String newTicketComment { get; set; }

    public ZendeskTypes.ZTicket[] tickets { get; set; }
    public String pageMessage { get; set; }

    public ZendeskTicketSampleController() {}

    public PageReference createTicket() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskTicketsAPI ztickets = new ZendeskTicketsAPI(zconn);

            Long newTicketId = ztickets.createTicket(ZendeskTypes.TicketType.question, newTicketSubject, newTicketComment, requesterId);

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
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);
            ZendeskTicketsAPI ztickets = new ZendeskTicketsAPI(zconn);

            ZendeskTicketsAPI.TicketsWrapper pagedTickets = ztickets.getTickets();
            tickets = pagedTickets.tickets;
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

}
