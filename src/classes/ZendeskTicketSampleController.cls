public class ZendeskTicketSampleController {

    public Long ticketId { get; set; }
    public Long assigneeId { get; set; }
    public Long requesterId { get; set; }
    public String newTicketSubject { get; set; }
    public String newTicketComment { get; set; }

    public ZendeskTypes.ZTicket[] tickets { get; set; }
    public String pageMessage { get; set; }

    public ZendeskTicketSampleController() {}

    public PageReference createTicket() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = ZendeskControllerSettings.getConnection();
            ZendeskTicketsAPI ztickets = new ZendeskTicketsAPI(zconn);

            Long newTicketId = ztickets.createTicket(ZendeskTypes.TicketType.question, newTicketSubject, newTicketComment, requesterId, null, assigneeId, null, null);

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
            ZendeskConnection zconn = ZendeskControllerSettings.getConnection();
            ZendeskTicketsAPI ztickets = new ZendeskTicketsAPI(zconn);

            ZendeskTicketsAPI.TicketsWrapper pagedTickets = ztickets.getTickets();
            tickets = pagedTickets.tickets;
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

    public PageReference getTicketById() {
        pageMessage = '';
        try {
            ZendeskConnection zconn = ZendeskControllerSettings.getConnection();
            zconn.debugAll = true;
            ZendeskTicketsAPI ztickets = new ZendeskTicketsAPI(zconn);

            tickets = new List<ZendeskTypes.ZTicket>();
            Map<String, Object> params = new Map<String, Object> { 'include'=>'users,groups,organizations,ticket_forms' };
            ZendeskTicketsAPI.TicketWrapper tw = ztickets.getTicket(ticketId, params);
            //ZendeskTicketsAPI.TicketWrapper tw = ztickets.getTicket(ticketId);
            if (tw != null && tw.ticket != null) {
                System.debug(tw);
                tickets.add(tw.ticket);
            }
            else {
                throw new ZendeskException('Ticket "' + ticketId + '" not found');
            }
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

}
