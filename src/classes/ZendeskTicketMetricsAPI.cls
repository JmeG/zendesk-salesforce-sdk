// This class provides functionality to call the Zendesk Ticket Metrics API
global class ZendeskTicketMetricsAPI extends ZendeskResourceBase {

    global class TicketMetricWrapper {
        global ZTicketMetrics ticket_metric { get; set; }
    }

    global class TicketMetricsWrapper extends ZendeskPagingBase {
        global List<ZTicketMetrics> ticket_metrics { get; set; }
    }

    global ZendeskTicketMetricsAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    global TicketMetricsWrapper getTicketMetrics() {
        HttpRequest req = zconn.createRequest('GET', '/ticket_metrics.json');
        return (TicketMetricsWrapper)JSON.deserialize(zconn.sendRequest(req), TicketMetricsWrapper.class);
    }

    global ZTicketMetrics getTicketMetrics(Long ticketMetricId) {
        if (ticketMetricId == null) { throw new ZendeskException('ticketMetricId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/ticket_metrics/'+ticketMetricId+'.json');
        TicketMetricWrapper wrapper = (TicketMetricWrapper)JSON.deserialize(zconn.sendRequest(req), TicketMetricWrapper.class);
        return wrapper.ticket_metric;
    }

    global ZTicketMetrics getTicketMetricsByTicketId(Long ticketId) {
        if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/tickets/'+ticketId+'/metrics.json');
        TicketMetricWrapper wrapper = (TicketMetricWrapper)JSON.deserialize(zconn.sendRequest(req), TicketMetricWrapper.class);
        return wrapper.ticket_metric;
    }

}
