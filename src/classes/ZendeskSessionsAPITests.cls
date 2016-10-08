// This class provides test coverage for the ZendeskSessionsAPI class
@isTest
public class ZendeskSessionsAPITests {

    public class MockOKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    public class MockSessionResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"session": { "id":3432, "user_id":12345, "authenticated_at":"2014-11-18T17:24:29Z", "last_seen_at":"2014-11-18T17:30:52Z" }}');
            return res;
        }
    }

    public class MockSessionsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "sessions": [ { "id":3432, "user_id":12345, "authenticated_at":"2014-11-18T17:24:29Z", "last_seen_at":"2014-11-18T17:30:52Z" } ], "next_page": null, "previous_page": null, "count": 1 }');
            return res;
        }
    }

    @isTest static void testGetSession() {
        Test.setMock(HttpCalloutMock.class, new MockSessionResponse());

        Test.startTest();
        ZendeskSessionsAPI api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskSessionsAPI.SessionWrapper wrapper = api.getSession(12345, 3432);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.session);
        System.assertEquals(3432, wrapper.session.id);
    }

    @isTest static void testGetMySession() {
        Test.setMock(HttpCalloutMock.class, new MockSessionResponse());

        Test.startTest();
        ZendeskSessionsAPI api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskSessionsAPI.SessionWrapper wrapper = api.getMySession();
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.session);
        System.assertEquals(3432, wrapper.session.id);
    }

    @isTest static void testGetSessions() {
        Test.setMock(HttpCalloutMock.class, new MockSessionsResponse());

        Test.startTest();
        ZendeskSessionsAPI api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskSessionsAPI.SessionsWrapper wrapper = api.getSessions();
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.sessions);
        System.assertEquals(3432, wrapper.sessions[0].id);
    }

    @isTest static void testGetSessionsPage() {
        Test.setMock(HttpCalloutMock.class, new MockSessionsResponse());

        Test.startTest();
        ZendeskSessionsAPI api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));

        ZendeskSessionsAPI.SessionsWrapper wrapper = api.getSessions(new Map<String, Object>{'page'=>2});
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.sessions);
        System.assertEquals(3432, wrapper.sessions[0].id);
    }

    @isTest static void testGetUserSessions() {
        Test.setMock(HttpCalloutMock.class, new MockSessionsResponse());

        Test.startTest();
        ZendeskSessionsAPI api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskSessionsAPI.SessionsWrapper wrapper = api.getSessions(12345);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.sessions);
        System.assertEquals(3432, wrapper.sessions[0].id);
    }


    @isTest static void testDeleteMySession() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskSessionsAPI api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        api.deleteMySession();
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testDeleteSession() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskSessionsAPI api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        api.deleteSession(12345, 3432);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testDeleteSessions() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskSessionsAPI api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        api.deleteSessions(12345);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testZSession() {
        String testJson = '{'
          + '"id": 12345,'
          + '"user_id": 123,'
          + '"authenticated_at": "2014-09-26T01:43:11Z",'
          + '"last_seen_at": "2014-09-26T01:43:11Z"'
          + '}';

        ZendeskTypes.ZSession zobj = (ZendeskTypes.ZSession)JSON.deserialize(testJson, ZendeskTypes.ZSession.class);
        System.assertEquals(12345, zobj.id);
        System.assertEquals(123, zobj.user_id);
        System.assertNotEquals(null, zobj.authenticated_at);
        System.assertNotEquals(null, zobj.last_seen_at);
    }
}