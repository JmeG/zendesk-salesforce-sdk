// This class provides test coverage for the ZendeskJobStatusesAPI class
@isTest
private class ZendeskJobStatusesAPITests {

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

	@isTest static void testGetStatus() {
		Test.setMock(HttpCalloutMock.class, new MockStatusResponse());

		Test.startTest();
		ZendeskJobStatusesAPI zjobs_api = new ZendeskJobStatusesAPI(ZendeskConnection.createWithPassword('s','u','p'));
		ZendeskTypes.ZJobStatus jstatus = zjobs_api.getJobStatus('abc123');
		Test.stopTest();

		System.assertNotEquals(null, jstatus);
		System.assertEquals('31a2e47012e20', jstatus.id);
	}

	@isTest static void testGetStatuses() {
		Test.setMock(HttpCalloutMock.class, new MockStatusesResponse());

		Test.startTest();
		ZendeskJobStatusesAPI zjobs_api = new ZendeskJobStatusesAPI(ZendeskConnection.createWithPassword('s','u','p'));
		List<ZendeskTypes.ZJobStatus> jobs = zjobs_api.getJobStatuses(new Set<String> {'abc123', 'abc345'});
		Test.stopTest();

		System.assertNotEquals(null, jobs);
		System.assertEquals(2, jobs.size());
	}

	@isTest static void testDeserialize() {
		String jsonStr = '{'+
		'	\"id\":	   \"8b726e606741012ffc2d782bcb7848fe\",'+
		'	\"url\":	  \"https://company.zendesk.com/api/v2/job_statuses/8b726e606741012ffc2d782bcb7848fe.json\",'+
		'	\"total\":	2,'+
		'	\"progress\": 2,'+
		'	\"status\":   \"completed\",'+
		'	\"message\":  \"Completed at Fri Apr 13 02:51:53 +0000 2012\",'+
		'	\"results\": ['+
		'	  {'+
		'		\"title\":   \"I accidentally the whole bottle\",'+
		'		\"action\":  \"update\",'+
		'		\"errors\":  \"\",'+
		'		\"id\":	  380,'+
		'		\"success\": true,'+
		'		\"status\":  \"Updated\"'+
		'	  },'+
		'	  {'+
		'		\"title\":   \"Printer on fire\",'+
		'		\"action\":  \"update\",'+
		'		\"errors\":  \"\",'+
		'		\"id\":	  90,'+
		'		\"success\": true,'+
		'		\"status\":  \"Updated\"'+
		'	  }'+
		'	]'+
		'  }';

		ZendeskTypes.ZJobStatus jstatus = (ZendeskTypes.ZJobStatus)JSON.deserialize(jsonStr, ZendeskTypes.ZJobStatus.class);

		System.assertNotEquals(null, jstatus);
		System.assertNotEquals(null, jstatus.id);
		System.assertNotEquals(null, jstatus.url);
		System.assertNotEquals(null, jstatus.total);
		System.assertNotEquals(null, jstatus.progress);
		System.assertNotEquals(null, jstatus.status);
		System.assertNotEquals(null, jstatus.message);
		System.assertNotEquals(null, jstatus.results);
		System.assertNotEquals(null, jstatus.results[0]);
		System.assertNotEquals(null, jstatus.results[0].title);
		System.assertNotEquals(null, jstatus.results[0].action);
		System.assertNotEquals(null, jstatus.results[0].errors);
		System.assertNotEquals(null, jstatus.results[0].id);
		System.assertNotEquals(null, jstatus.results[0].success);
		System.assertNotEquals(null, jstatus.results[0].status);
	}

}
