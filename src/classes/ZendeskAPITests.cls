// This class provides test coverage for the ZendeskAPI class
@isTest
public class ZendeskAPITests {

    public class MockUserResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"user":{"id":487700530,"url":"https://test.zendesk.com/api/v2/users/487700530.json","name":"Bob Smith","email":"bsmith1@test.com","created_at":"2014-07-02T21:57:13Z","updated_at":"2014-07-02T21:57:13Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null}}');
            return res;
        }
    }

    static testMethod void testCreateRequest() {
        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);
        HttpRequest req = zapi.createRequest('GET', '/users.json', new Map<String, Object>{'page'=>'1'});

        System.assertEquals('GET', req.getMethod());
    }

    static testMethod void testSendRequest() {
        Test.setMock(HttpCalloutMock.class, new MockUserResponse());
        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);
        zapi.debugAll = true;
        HttpRequest req = zapi.createRequest('GET', '/users.json');
        String resBody = zapi.sendRequest(req);

        System.assertNotEquals(null, resBody);
    }

    static testMethod void testCanLogin() {
        Test.setMock(HttpCalloutMock.class, new MockUserResponse());
        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        System.assertEquals(true, zapi.canLogin());
    }

    static testMethod void testConstructors() {
        ZendeskAPI zapi1 = new ZendeskAPI('s', 'u', 'p');
        ZendeskAPI zapi2 = new ZendeskAPI('s', 'u', 't', ZendeskAPI.AuthType.Token);

        System.assert(true);
    }

    static testMethod void testGetQueryStringMap() {
        String url = 'https://test.zendesk.com/api/v2/organizations/25378250/tickets.json?include=users%2Cgroups&page=2&per_page=10&sort_order=desc';
        Map<String, String> qmap = ZendeskAPI.getQueryStringMap(url);

        System.assertNotEquals(null, qmap);
        System.assertEquals(4, qmap.size());
        System.assertEquals(true, qmap.containsKey('per_page'));
        System.assertEquals('10', qmap.get('per_page'));
    }
}
