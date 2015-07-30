// This class provides functionality to call the Zendesk Ticket Metrics API
public class ZendeskTicketMetricsAPI extends ZendeskResourceBase {

	private class TicketMetricWrapper {
		public ZTicketMetrics ticket_metric {get;set;}
	}

	public class TicketMetricsWrapper extends ZendeskPagingBase {
		public List<ZTicketMetrics> ticket_metrics {get;set;}
	}

	public ZendeskTicketMetricsAPI(ZendeskConnection zconn) {
		super(zconn);
	}

	public TicketMetricsWrapper getTicketMetrics() {
		HttpRequest req = zconn.createRequest('GET', '/ticket_metrics.json');
		return (TicketMetricsWrapper)JSON.deserialize(zconn.sendRequest(req), TicketMetricsWrapper.class);
	}

	public ZTicketMetrics getTicketMetrics(Long ticketMetricId) {
		if (ticketMetricId == null) { throw new ZendeskException('ticketMetricId parameter cannot be null'); }

		HttpRequest req = zconn.createRequest('GET', '/ticket_metrics/'+ticketMetricId+'.json');
		TicketMetricWrapper wrapper = (TicketMetricWrapper)JSON.deserialize(zconn.sendRequest(req), TicketMetricWrapper.class);
		return wrapper.ticket_metric;
	}

	public ZTicketMetrics getTicketMetricsByTicketId(Long ticketId) {
		if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

		HttpRequest req = zconn.createRequest('GET', '/tickets/'+ticketId+'/metrics.json');
		TicketMetricWrapper wrapper = (TicketMetricWrapper)JSON.deserialize(zconn.sendRequest(req), TicketMetricWrapper.class);
		return wrapper.ticket_metric;
	}

}
