// This class provides test coverage for the ZendeskUsers class
@isTest
private class ZendeskUsersTests {

    public class MockCreateUserResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setStatus('OK');
            res.setBody('{"user":{"id":487700530,"url":"https://test.zendesk.com/api/v2/users/487700530.json","name":"Bob Smith","email":"bsmith1@test.com","created_at":"2014-07-02T21:57:13Z","updated_at":"2014-07-02T21:57:13Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null}}');
            return res;
        }
    }

    public class MockUserResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"user":{"id":487700530,"url":"https://test.zendesk.com/api/v2/users/487700530.json","name":"Bob Smith","email":"bsmith1@test.com","created_at":"2014-07-02T21:57:13Z","updated_at":"2014-07-02T21:57:13Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null}}');
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

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
		ZendeskUsers zusers = new ZendeskUsers(zapi);
		Integer userId = zusers.createUser('John Doe', 'jdoe@zendesk.com');
        Test.stopTest();

		System.assertNotEquals(null, userId);
	}

	static testmethod void testGetUserId() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
		ZendeskUsers zusers = new ZendeskUsers(zapi);
		Integer userId = zusers.getUserIdByEmail('foo@bar.com');
        Test.stopTest();

		System.assertNotEquals(null, userId);
	}

    static testMethod void testFindUsersByNameOrEmail() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
		ZendeskUsers zusers = new ZendeskUsers(zapi);
		ZendeskUsers.PagedUsersWrapper results = zusers.findUsersByNameOrEmail('foo@bar.com');
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.users);
        System.assertEquals(1, results.users.size());
    }

    static testMethod void testGetUsers() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
		ZendeskUsers zusers = new ZendeskUsers(zapi);
		ZendeskUsers.PagedUsersWrapper results = zusers.getUsers();
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.users);
        System.assertNotEquals(0, results.users.size());
    }

    static testMethod void testGetNextPage() {
        Test.startTest();
        ZendeskUsers.PagedUsersWrapper wrapper = new ZendeskUsers.PagedUsersWrapper();
        wrapper.next_page = 'https://test.zendesk.com/api/v2/users.json?page=2';
        Test.stopTest();

        System.assertEquals(2, wrapper.nextPageNumber);
    }

    static testMethod void testZUser() {
        String userJson = '{ "id": 35436, "name": "Johnny Agent", "external_id": "sai989sur98w9", "alias": "Mr. Johnny", "created_at": "2009-07-20T22:55:29Z", "updated_at": "2011-05-05T10:38:52Z", "active": true, "verified": true, "shared": false, "shared_agent": false, "locale": "en-US", "locale_id": 1, "time_zone": "Copenhagen", "last_login_at": "2011-05-05T10:38:52Z", "email": "johnny@example.com", "phone": "555-123-4567", "signature": "Have a nice day, Johnny", "details": "", "notes": "Johnny is a nice guy!", "organization_id": 57542, "role": "agent", "custom_role_id": 9373643, "moderator": true, "ticket_restriction": "assigned", "only_private_comments": false, "tags": ["enterprise", "other_tag"], "restricted_agent": true, "suspended": true, "user_fields": { "user_decimal": 5.1, "user_dropdown": "option_1", "user_date": "2012-07-23T00:00:00Z" } }';
        ZendeskUsers.ZUser zuser = (ZendeskUsers.ZUser)JSON.deserialize(userJson, ZendeskUsers.ZUser.class);
        System.assertEquals(35436, zuser.id);
        System.assertEquals('Johnny Agent', zuser.name);
        System.assertEquals('johnny@example.com', zuser.email);
        System.assertEquals('agent', zuser.role);
        System.assertNotEquals(null, zuser.organization_id);
        System.assertNotEquals(null, zuser.phone);
        System.assertNotEquals(null, zuser.external_id);
        System.assertNotEquals(null, zuser.alias);
        System.assertNotEquals(null, zuser.active);
        System.assertNotEquals(null, zuser.verified);
        System.assertNotEquals(null, zuser.last_login_at);
        System.assertNotEquals(null, zuser.user_fields);
        System.assertNotEquals(null, zuser.created_at);
        System.assertNotEquals(null, zuser.updated_at);
    }
}
