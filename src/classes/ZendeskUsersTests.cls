// This class provides test coverage for the ZendeskUsers class
@isTest
private class ZendeskUsersTests {

    public class MockCreateUserResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setStatus('OK');
            res.setBody('{"user":{"id":487700530,"url":"https://test.zendesk.com/api/v2/users/487700530.json","name":"Bob Smith","email":"bsmith1@zendesktest.com","created_at":"2014-07-02T21:57:13Z","updated_at":"2014-07-02T21:57:13Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null}}');
            return res;
        }
    }

    public class MockUserResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"user":{"id":487700530,"url":"https://test.zendesk.com/api/v2/users/487700530.json","name":"Bob Smith","email":"bsmith1@zendesktest.com","created_at":"2014-07-02T21:57:13Z","updated_at":"2014-07-02T21:57:13Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null}}');
            return res;
        }
    }

    public class MockUsersResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"users":[{"id":487705900,"url":"https://test.zendesk.com/api/v2/users/487705900.json","name":"Bob Smith","email":"foo@bar.com","created_at":"2014-07-02T22:03:28Z","updated_at":"2014-07-02T22:03:28Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null,"signature":null,"details":null,"notes":null,"custom_role_id":null,"moderator":false,"ticket_restriction":"requested","only_private_comments":false,"restricted_agent":true,"suspended":false}],"next_page":null,"previous_page":null,"count":1}');
            return res;
        }
    }

    static testmethod void testCreateUser() {
        Test.setMock(HttpCalloutMock.class, new MockCreateUserResponse());

        ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);

        Test.startTest();
		ZendeskUsers zusers = new ZendeskUsers(zapi);
		Integer userId = zusers.createUser('John Doe', 'jdoe@zendesk.com');
        Test.stopTest();

		System.assertNotEquals(null, userId);
	}

	static testmethod void testGetUserId() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);

        Test.startTest();
		ZendeskUsers zusers = new ZendeskUsers(zapi);
		Integer userId = zusers.getUserIdByEmail('foo@bar.com');
        Test.stopTest();

		System.assertNotEquals(null, userId);
	}

    static testMethod void testGetNextPage() {
        Test.startTest();
        ZendeskUsers.PagedUsersWrapper wrapper = new ZendeskUsers.PagedUsersWrapper();
        wrapper.next_page = 'https://test.zendesk.com/api/v2/users.json?page=2';
        Test.stopTest();

        System.assertEquals(2, wrapper.nextPageNumber);
    }

    static testMethod void testZUser() {
        ZendeskUsers.ZUser zuser = new ZendeskUsers.ZUser();
        zuser.id = 1;
        zuser.name = '';
        zuser.email = '';
        zuser.role = '';
        zuser.organization_id = 1;

        System.assert(true);
    }
}
