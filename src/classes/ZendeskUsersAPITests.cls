// This class provides test coverage for the ZendeskUsersAPI class
@isTest
public class ZendeskUsersAPITests {

    public class MockOKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    public class MockUserResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"user":{"id":123,"url":"https://test.zendesk.com/api/v2/users/123.json","name":"Bob Smith","email":"bsmith1@test.com","created_at":"2014-07-02T21:57:13Z","updated_at":"2014-07-02T21:57:13Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null}}');
            return res;
        }
    }

    public class MockUsersResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"users":[{"id":123,"url":"https://test.zendesk.com/api/v2/users/123.json","name":"Bob Smith","email":"foo@bar.com","created_at":"2014-07-02T22:03:28Z","updated_at":"2014-07-02T22:03:28Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null,"signature":null,"details":null,"notes":null,"custom_role_id":null,"moderator":false,"ticket_restriction":"requested","only_private_comments":false,"restricted_agent":true,"suspended":false}],"next_page":null,"previous_page":null,"count":1}');
            return res;
        }
    }

    public class MockJobStatusResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{ "job_status": {"id": "31a2e47012e2013340b438ca3a5dc6c8", "url": "https://test.zendesk.com/api/v2/job_statuses/31a2e47012e2013340b438ca3a5dc6c8.json", "status": "queued" }}');
            return res;
        }
    }

    @isTest static void testCreateUsers() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZUser zu = new ZendeskTypes.ZUser();
        ZendeskTypes.ZJobStatus jobStatus = zusers_api.createUsers(new ZendeskTypes.ZUser[] { zu });
        Test.stopTest();

        System.assertNotEquals(null, jobStatus);
    }

    @isTest static void testUpdateUser() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZUser zu = new ZendeskTypes.ZUser();
        zusers_api.updateUser(123, zu);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testUpdateUsers1() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZUser zu = new ZendeskTypes.ZUser();
        zu.id = 123;
        zusers_api.updateUsers(new ZendeskTypes.ZUser[] {zu});
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testUpdateUsers2() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZUser zu = new ZendeskTypes.ZUser();
        zusers_api.updateUsers(new Set<Long> {123,456}, zu);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testUpdateUsers3() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZUser zu = new ZendeskTypes.ZUser();
        zusers_api.updateUsers(new Set<String> {'123','456'}, zu);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testMergeUsers() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZUser zu = new ZendeskTypes.ZUser();
        zusers_api.mergeUsers(123, 456);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testGetUsersByPage() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskUsersAPI.UsersWrapper results = zusers_api.getUsers(new Map<String, Object>{'page'=>'2'});
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.users);
        System.assertEquals(1, results.users.size());
    }

    @isTest static void testGetUsersByIds() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskUsersAPI.UsersWrapper results = zusers_api.getUsersByIds(new Set<Long> {123, 456});
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.users);
        System.assertEquals(1, results.users.size());
    }

    @isTest static void testGetUsersByExternalIds() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskUsersAPI.UsersWrapper results = zusers_api.getUsersByExternalIds(new Set<String> {'123', '456'});
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.users);
        System.assertEquals(1, results.users.size());
    }

    @isTest static void testGetUsersByGroup() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskUsersAPI.UsersWrapper results = zusers_api.getUsersByGroup(123);
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.users);
        System.assertEquals(1, results.users.size());
    }

    @isTest static void testGetUsersByOrg() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskUsersAPI.UsersWrapper results = zusers_api.getUsersByOrganization(123);
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.users);
        System.assertEquals(1, results.users.size());
    }

    @isTest static void testGetUsersAutocomplete() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskUsersAPI.UsersWrapper results = zusers_api.autocompleteSearch('foo');
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.users);
        System.assertEquals(1, results.users.size());
    }

    @isTest static void testAutocompleteSearch() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskUsersAPI.UsersWrapper results = zusers_api.autocompleteSearch('foo123');
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.users);
        System.assertEquals(1, results.users.size());
    }

    @isTest static void testGetUserRelatedInfo() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Map<String, Object> results = zusers_api.getUserRelatedInfo(123);
        Test.stopTest();

        System.assertNotEquals(null, results);
    }

    @isTest static void testDeleteUser() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        zusers_api.deleteUser(123);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testDeleteUsers1() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        zusers_api.deleteUsers(new Set<Long> {123,456});
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testDeleteUsers2() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        zusers_api.deleteUsers(new Set<String> {'123','456'});
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testCreateUser() {
        Test.setMock(HttpCalloutMock.class, new MockUserResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Long userId = zusers_api.createUser('John Doe', 'jdoe@zendesk.com');
        Test.stopTest();

        System.assertNotEquals(null, userId);
    }

    @isTest static void testGetUserId() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Long userId = zusers_api.getUserIdByEmail('foo@bar.com');
        Test.stopTest();

        System.assertNotEquals(null, userId);
    }

    @isTest static void testFindUsersByNameOrEmail() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskUsersAPI.UsersWrapper results = zusers_api.findUsersByNameOrEmail('foo@bar.com');
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.users);
        System.assertEquals(1, results.users.size());
    }

    @isTest static void testGetUsers() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskUsersAPI.UsersWrapper results = zusers_api.getUsers();
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.users);
        System.assertNotEquals(0, results.users.size());
    }

    @isTest static void testGetUser() {
        Test.setMock(HttpCalloutMock.class, new MockUserResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskUsersAPI.UserWrapper wrapper = zusers_api.getUser(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.user);
        System.assertEquals(123, wrapper.user.id);
    }

    @isTest static void testGetCurrentUser() {
        Test.setMock(HttpCalloutMock.class, new MockUserResponse());

        Test.startTest();
        ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZUser u = zusers_api.getCurrentUser();
        Test.stopTest();

        System.assertNotEquals(null, u);
    }

    @isTest static void testZUser() {
        String userJson = '{ "id": 35436, "name": "Johnny Agent", "external_id": "sai989sur98w9", "alias": "Mr. Johnny", "created_at": "2009-07-20T22:55:29Z", "updated_at": "2011-05-05T10:38:52Z", "active": true, "verified": true, "shared": false, "shared_agent": false, "locale": "en-US", "locale_id": 1, "time_zone": "Copenhagen", "last_login_at": "2011-05-05T10:38:52Z", "email": "johnny@example.com", "phone": "555-123-4567", "signature": "Have a nice day, Johnny", "details": "bla bla", "notes": "Johnny is a nice guy!", "organization_id": 57542, "role": "agent", "custom_role_id": 9373643, "moderator": true, "ticket_restriction": "assigned", "only_private_comments": false, "tags": ["enterprise", "other_tag"], "restricted_agent": true, "suspended": true, "user_fields": { "user_decimal": 5.1, "user_dropdown": "option_1", "user_date": "2012-07-23T00:00:00Z" } }';
        ZendeskTypes.ZUser zuser = (ZendeskTypes.ZUser)JSON.deserialize(userJson, ZendeskTypes.ZUser.class);
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
        System.assertEquals(true, zuser.verified);
        System.assertEquals(true, zuser.moderator);
        System.assertEquals(false, zuser.only_private_comments);
        System.assertEquals(true, zuser.restricted_agent);
        System.assertEquals(true, zuser.suspended);
        System.assertEquals(null, zuser.chat_only);
        System.assertEquals(false, zuser.shared);
        System.assertEquals(false, zuser.shared_agent);
        System.assertNotEquals(null, zuser.signature);
        System.assertNotEquals(null, zuser.details);
        System.assertNotEquals(null, zuser.notes);
        System.assertNotEquals(null, zuser.time_zone);
        System.assertNotEquals(null, zuser.locale);
        System.assertNotEquals(null, zuser.tags);
    }
}
