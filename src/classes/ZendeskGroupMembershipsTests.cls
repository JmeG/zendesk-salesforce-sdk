// This class provides test coverage for the ZendeskGroupMembershipsAPI class
@isTest
public class ZendeskGroupMembershipsTests {

    public class MockOKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    public class MockGroupMembershipResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"group_membership": { "id":123, "user_id":29, "group_id":12, "default":true, "created_at":"2009-05-13T00:07:08Z", "updated_at":"2011-07-22T00:11:12Z" } }');
            return res;
        }
    }

    public class MockGroupMembershipsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "group_memberships": [ { "id":123, "user_id":29, "group_id":12, "default":true, "created_at":"2009-05-13T00:07:08Z", "updated_at":"2011-07-22T00:11:12Z" } ], "next_page": null, "previous_page": null, "count": 1 }');
            return res;
        }
    }

    static testMethod void testGetMembership1() {
        Test.setMock(HttpCalloutMock.class, new MockGroupMembershipResponse());

        Test.startTest();
        ZendeskGroupMembershipsAPI api = new ZendeskGroupMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskGroupMembershipsAPI.GroupMembershipWrapper wrapper = api.getMembership(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.group_membership);
        System.assertEquals(123, wrapper.group_membership.id);
    }

    static testMethod void testGetMembership2() {
        Test.setMock(HttpCalloutMock.class, new MockGroupMembershipResponse());

        Test.startTest();
        ZendeskGroupMembershipsAPI api = new ZendeskGroupMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskGroupMembershipsAPI.GroupMembershipWrapper wrapper = api.getMembership(123, 456);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.group_membership);
        System.assertEquals(123, wrapper.group_membership.id);
    }

    static testMethod void testDeleteMembership1() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskGroupMembershipsAPI api = new ZendeskGroupMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        api.deleteMembership(123);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testDeleteMembership2() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskGroupMembershipsAPI api = new ZendeskGroupMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        api.deleteMembership(123, 456);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testCreateMembership1() {
        Test.setMock(HttpCalloutMock.class, new MockGroupMembershipResponse());

        Test.startTest();
        ZendeskGroupMembershipsAPI api = new ZendeskGroupMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Long membershipId = api.createMembership(123, 456);
        Test.stopTest();

        System.assertNotEquals(null, membershipId);
    }

    static testMethod void testCreateMembership2() {
        Test.setMock(HttpCalloutMock.class, new MockGroupMembershipResponse());

        Test.startTest();
        ZendeskGroupMembershipsAPI api = new ZendeskGroupMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZGroupMembership gm = new ZendeskTypes.ZGroupMembership();
        gm.user_id = 123;
        gm.group_id = 456;
        Long membershipId = api.createMembership(gm);
        Test.stopTest();

        System.assertNotEquals(null, membershipId);
    }

    static testMethod void testMakeDefault() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskGroupMembershipsAPI api = new ZendeskGroupMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        api.makeDefault(123, 789);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testGetMemberships() {
        Test.setMock(HttpCalloutMock.class, new MockGroupMembershipsResponse());

        Test.startTest();
        ZendeskGroupMembershipsAPI api = new ZendeskGroupMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskGroupMembershipsAPI.GroupMembershipsWrapper wrapper = api.getMemberships();
        Test.stopTest();

        System.assertNotEquals(null, wrapper.group_memberships);
        System.assertNotEquals(0, wrapper.group_memberships.size());
    }

    static testMethod void testGetMembershipsByGroup() {
        Test.setMock(HttpCalloutMock.class, new MockGroupMembershipsResponse());

        Test.startTest();
        ZendeskGroupMembershipsAPI api = new ZendeskGroupMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskGroupMembershipsAPI.GroupMembershipsWrapper wrapper = api.getMembershipsByGroup(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper.group_memberships);
        System.assertNotEquals(0, wrapper.group_memberships.size());
    }

    static testMethod void testGetAssignableMembershipsByGroup() {
        Test.setMock(HttpCalloutMock.class, new MockGroupMembershipsResponse());

        Test.startTest();
        ZendeskGroupMembershipsAPI api = new ZendeskGroupMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskGroupMembershipsAPI.GroupMembershipsWrapper wrapper = api.getAssignableMembershipsByGroup(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper.group_memberships);
        System.assertNotEquals(0, wrapper.group_memberships.size());
    }

    static testMethod void testGetAssignableMemberships() {
        Test.setMock(HttpCalloutMock.class, new MockGroupMembershipsResponse());

        Test.startTest();
        ZendeskGroupMembershipsAPI api = new ZendeskGroupMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskGroupMembershipsAPI.GroupMembershipsWrapper wrapper = api.getAssignableMemberships();
        Test.stopTest();

        System.assertNotEquals(null, wrapper.group_memberships);
        System.assertNotEquals(0, wrapper.group_memberships.size());
    }

    static testMethod void testGetUserMemberships() {
        Test.setMock(HttpCalloutMock.class, new MockGroupMembershipsResponse());

        Test.startTest();
        ZendeskGroupMembershipsAPI api = new ZendeskGroupMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskGroupMembershipsAPI.GroupMembershipsWrapper wrapper = api.getMembershipsByUser(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper.group_memberships);
        System.assertNotEquals(0, wrapper.group_memberships.size());
    }

    static testMethod void testZGroupMembership() {
        String testJson = '{'
          + '"id": 123,'
          + '"user_id": 456,'
          + '"group_id": 789,'
          + '"x_default": true'
          + '}';

        ZendeskTypes.ZGroupMembership zobj = (ZendeskTypes.ZGroupMembership)JSON.deserialize(testJson, ZendeskTypes.ZGroupMembership.class);
        System.assertEquals(123, zobj.id);
        System.assertEquals(456, zobj.user_id);
        System.assertEquals(789, zobj.group_id);
        System.assertEquals(true, zobj.x_default);
    }
}
