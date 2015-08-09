// This class provides test coverage for the ZendeskSessionsAPI class
@isTest
public class ZendeskSessionsTests {

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

    static testMethod void testGetSession() {
        Test.setMock(HttpCalloutMock.class, new MockSessionResponse());

        Test.startTest();
        ZendeskSessionsAPI sessions_api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskSessionsAPI.SessionWrapper wrapper = sessions_api.getSession(12345, 3432);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.session);
        System.assertEquals(3432, wrapper.session.id);
    }

    static testMethod void testGetMySession() {
        Test.setMock(HttpCalloutMock.class, new MockSessionResponse());

        Test.startTest();
        ZendeskSessionsAPI sessions_api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskSessionsAPI.SessionWrapper wrapper = sessions_api.getMySession();
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.session);
        System.assertEquals(3432, wrapper.session.id);
    }

    static testMethod void testGetSessions() {
        Test.setMock(HttpCalloutMock.class, new MockSessionsResponse());

        Test.startTest();
        ZendeskSessionsAPI sessions_api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskSessionsAPI.SessionsWrapper wrapper = sessions_api.getSessions();
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.sessions);
        System.assertEquals(3432, wrapper.sessions[0].id);
    }

    static testMethod void testGetSessionsPage() {
        Test.setMock(HttpCalloutMock.class, new MockSessionsResponse());

        Test.startTest();
        ZendeskSessionsAPI sessions_api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));

        ZendeskSessionsAPI.SessionsWrapper wrapper = sessions_api.getSessions(new Map<String, Object>{'page'=>2});
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.sessions);
        System.assertEquals(3432, wrapper.sessions[0].id);
    }

    static testMethod void testGetUserSessions() {
        Test.setMock(HttpCalloutMock.class, new MockSessionsResponse());

        Test.startTest();
        ZendeskSessionsAPI sessions_api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskSessionsAPI.SessionsWrapper wrapper = sessions_api.getSessions(12345);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.sessions);
        System.assertEquals(3432, wrapper.sessions[0].id);
    }


    static testMethod void testDeleteMySession() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskSessionsAPI sessions_api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        sessions_api.deleteMySession();
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testDeleteSession() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskSessionsAPI sessions_api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        sessions_api.deleteSession(12345, 3432);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testDeleteSessions() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskSessionsAPI sessions_api = new ZendeskSessionsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        sessions_api.deleteSessions(12345);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testZSession() {
        String sessionJson = '{'
          + '"id": 12345,'
          + '"user_id": 123,'
          + '"authenticated_at": "2014-09-26T01:43:11Z",'
          + '"last_seen_at": "2014-09-26T01:43:11Z"'
          + '}';

        ZendeskTypes.ZSession zsession = (ZendeskTypes.ZSession)JSON.deserialize(sessionJson, ZendeskTypes.ZSession.class);
        System.assertEquals(12345, zsession.id);
        System.assertEquals(123, zsession.user_id);
        System.assertNotEquals(null, zsession.authenticated_at);
        System.assertNotEquals(null, zsession.last_seen_at);
    }
}
