// This class provides test coverage for the ZendeskJobStatusesAPI class
@isTest
private class ZendeskJobStatusesTests {

    public class MockStatusResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"job_status": { "id": "31a2e47012e20", "url": "https://test.zendesk.com/api/v2/job_statuses/31a2e4701.json", "total": 2, "progress": 2, "status": "completed", "message": "Completed", "results": [ { "status": "Failed Creating User ", "errors": "Name:  is too short" } ] } }');
            return res;
        }
    }

    public class MockStatusesResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "job_statuses": [{ "id": "31a2e47012e", "url": "https://test.zendesk.com/api/v2/job_statuses/31a2e47012e.json", "total": 2, "progress": 2, "status": "completed", "message": "Completed", "results": [ { "status": "Failed Creating User ", "errors": "Name:  is too short" } ] } ,{ "id": "31a2e47012e201", "url": "https://test.zendesk.com/api/v2/job_statuses/31a2e47012e201.json", "total": 2, "progress": 2, "status": "completed", "message": "Completed", "results": [ { "status": "Failed Creating User ", "errors": "Name: is too short" } ] }  ] }');
            return res;
        }
    }

    static testMethod void testGetStatus() {
        Test.setMock(HttpCalloutMock.class, new MockStatusResponse());

        Test.startTest();
        ZendeskJobStatusesAPI zjobs_api = new ZendeskJobStatusesAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskJobStatusesAPI.ZJobStatus jstatus = zjobs_api.getJobStatus('abc123');
        Test.stopTest();

        System.assertNotEquals(null, jstatus);
        System.assertEquals('31a2e47012e20', jstatus.id);
    }

    static testMethod void testGetStatuses() {
        Test.setMock(HttpCalloutMock.class, new MockStatusesResponse());

        Test.startTest();
        ZendeskJobStatusesAPI zjobs_api = new ZendeskJobStatusesAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        List<ZendeskJobStatusesAPI.ZJobStatus> jobs = zjobs_api.getJobStatuses(new Set<String> {'abc123', 'abc345'});
        Test.stopTest();

        System.assertNotEquals(null, jobs);
        System.assertEquals(2, jobs.size());
    }

    static testMethod void testDeserialize() {
        String resBody = '{ "id": "31a2e47012e20", "url": "https://test.zendesk.com/api/v2/job_statuses/31a2e4701.json", "total": 2, "progress": 2, "status": "completed", "message": "Completed", "results": [ { "status": "Failed Creating User ", "errors": "Name:  is too short" } ] }';
        ZendeskJobStatusesAPI.ZJobStatus jstatus = (ZendeskJobStatusesAPI.ZJobStatus)JSON.deserialize(resBody, ZendeskJobStatusesAPI.ZJobStatus.class);

        System.assertNotEquals(null, jstatus);
        System.assertNotEquals(null, jstatus.id);
        System.assertNotEquals(null, jstatus.url);
        System.assertNotEquals(null, jstatus.total);
        System.assertNotEquals(null, jstatus.progress);
        System.assertNotEquals(null, jstatus.status);
        System.assertNotEquals(null, jstatus.message);
        System.assertNotEquals(null, jstatus.results);
        System.assertNotEquals(null, jstatus.results[0]);
        System.assertNotEquals(null, jstatus.results[0].status);
        System.assertNotEquals(null, jstatus.results[0].errors);
    }

}
