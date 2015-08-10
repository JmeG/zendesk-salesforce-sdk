// This class provides test coverage for the ZendeskTicketMetricsAPI class
@isTest
public class ZendeskTicketMetricsAPITests {

    public class MockTicketMetricResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "ticket_metric": {"id":33,"ticket_id":4343,"created_at":"2009-07-20T22:55:29Z","updated_at":"2011-05-05T10:38:52Z","group_stations":7,"assignee_stations":1,"reopens":55,"replies":322,"assignee_updated_at":"2011-05-06T10:38:52Z","requester_updated_at":"2011-05-07T10:38:52Z","status_updated_at":"2011-05-04T10:38:52Z","initially_assigned_at":"2011-05-03T10:38:52Z","assigned_at":"2011-05-05T10:38:52Z","solved_at":"2011-05-09T10:38:52Z","latest_comment_added_at":"2011-05-09T10:38:52Z","reply_time_in_minutes":{"calendar":2391,"business":737},"first_resolution_time_in_minutes":{"calendar":2391,"business":737},"full_resolution_time_in_minutes":{"calendar":2391,"business":737},"agent_wait_time_in_minutes":{"calendar":2391,"business":737},"requester_wait_time_in_minutes":{"calendar":2391,"business":737},"on_hold_time_in_minutes":{"calendar":2290,"business":637}}  }');
            return res;
        }
    }

    public class MockTicketMetricsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "ticket_metrics": [{"id":33,"ticket_id":4343,"created_at":"2009-07-20T22:55:29Z","updated_at":"2011-05-05T10:38:52Z","group_stations":7,"assignee_stations":1,"reopens":55,"replies":322},{"id":33,"ticket_id":4343,"created_at":"2009-07-20T22:55:29Z","updated_at":"2011-05-05T10:38:52Z","group_stations":7,"assignee_stations":1,"reopens":55,"replies":322}], "next_page": null, "previous_page": null, "count": 2 }');
            return res;
        }
    }

    @isTest static void testGetTicketMetrics() {
        Test.setMock(HttpCalloutMock.class, new MockTicketMetricsResponse());

        Test.startTest();
        ZendeskTicketMetricsAPI zmetrics_api = new ZendeskTicketMetricsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTicketMetricsAPI.TicketMetricsWrapper wrapper = zmetrics_api.getTicketMetrics();
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.ticket_metrics);
    }

    @isTest static void testGetTicketMetricsById() {
        Test.setMock(HttpCalloutMock.class, new MockTicketMetricResponse());

        Test.startTest();
        ZendeskTicketMetricsAPI zmetrics_api = new ZendeskTicketMetricsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZTicketMetrics tmetric = zmetrics_api.getTicketMetrics(1);
        Test.stopTest();

        System.assertNotEquals(null, tmetric);
    }

    @isTest static void testGetTicketMetricsByTicketId() {
        Test.setMock(HttpCalloutMock.class, new MockTicketMetricResponse());

        Test.startTest();
        ZendeskTicketMetricsAPI zmetrics_api = new ZendeskTicketMetricsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZTicketMetrics tmetric = zmetrics_api.getTicketMetricsByTicketId(1);
        Test.stopTest();

        System.assertNotEquals(null, tmetric);
    }


    @isTest static void testZTicketMetric() {
        String metricJson = '{"id":33,"ticket_id":4343,"created_at":"2009-07-20T22:55:29Z","updated_at":"2011-05-05T10:38:52Z","group_stations":7,"assignee_stations":1,"reopens":55,"replies":322,"assignee_updated_at":"2011-05-06T10:38:52Z","requester_updated_at":"2011-05-07T10:38:52Z","status_updated_at":"2011-05-04T10:38:52Z","initially_assigned_at":"2011-05-03T10:38:52Z","assigned_at":"2011-05-05T10:38:52Z","solved_at":"2011-05-09T10:38:52Z","latest_comment_added_at":"2011-05-09T10:38:52Z","reply_time_in_minutes":{"calendar":2391,"business":737},"first_resolution_time_in_minutes":{"calendar":2391,"business":737},"full_resolution_time_in_minutes":{"calendar":2391,"business":737},"agent_wait_time_in_minutes":{"calendar":2391,"business":737},"requester_wait_time_in_minutes":{"calendar":2391,"business":737},"on_hold_time_in_minutes":{"calendar":2290,"business":637}}';
        ZendeskTypes.ZTicketMetrics zmetric = (ZendeskTypes.ZTicketMetrics)JSON.deserialize(metricJson, ZendeskTypes.ZTicketMetrics.class);

        System.assertEquals(33, zmetric.id);
        System.assertNotEquals(null, zmetric.ticket_id);
        System.assertNotEquals(null, zmetric.created_at);
        System.assertNotEquals(null, zmetric.updated_at);
        System.assertNotEquals(null, zmetric.group_stations);
        System.assertNotEquals(null, zmetric.assignee_stations);
        System.assertNotEquals(null, zmetric.reopens);
        System.assertNotEquals(null, zmetric.replies);
        System.assertNotEquals(null, zmetric.assignee_updated_at);
        System.assertNotEquals(null, zmetric.requester_updated_at);
        System.assertNotEquals(null, zmetric.status_updated_at);
        System.assertNotEquals(null, zmetric.initially_assigned_at);
        System.assertNotEquals(null, zmetric.assigned_at);
        System.assertNotEquals(null, zmetric.solved_at);
        System.assertNotEquals(null, zmetric.latest_comment_added_at);
        System.assertNotEquals(null, zmetric.reply_time_in_minutes);
        System.assertNotEquals(null, zmetric.first_resolution_time_in_minutes);
        System.assertNotEquals(null, zmetric.full_resolution_time_in_minutes);
        System.assertNotEquals(null, zmetric.agent_wait_time_in_minutes);
        System.assertNotEquals(null, zmetric.requester_wait_time_in_minutes);
        System.assertNotEquals(null, zmetric.on_hold_time_in_minutes);

        ZendeskTypes.ZTicketMetricsTime metricTime = zmetric.first_resolution_time_in_minutes;
        System.assertNotEquals(null, metricTime.calendar);
        System.assertNotEquals(null, metricTime.business);
    }
}
