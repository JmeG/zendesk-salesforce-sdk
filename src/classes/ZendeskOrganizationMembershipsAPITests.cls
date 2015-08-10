// This class provides test coverage for the ZendeskOrganizationMembershipsAPI class
@isTest
public class ZendeskOrganizationMembershipsAPITests {

    public class MockOKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    public class MockOrganizationMembershipResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"organization_membership": { "id":123, "user_id":29, "organization_id":12, "default":true, "created_at":"2009-05-13T00:07:08Z", "updated_at":"2011-07-22T00:11:12Z" } }');
            return res;
        }
    }

    public class MockOrganizationMembershipsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "organization_memberships": [ { "id":123, "user_id":29, "organization_id":12, "default":true, "created_at":"2009-05-13T00:07:08Z", "updated_at":"2011-07-22T00:11:12Z" } ], "next_page": null, "previous_page": null, "count": 1 }');
            return res;
        }
    }

    static testMethod void testGetMembership1() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationMembershipResponse());

        Test.startTest();
        ZendeskOrganizationMembershipsAPI api = new ZendeskOrganizationMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationMembershipsAPI.OrganizationMembershipWrapper wrapper = api.getMembership(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.organization_membership);
        System.assertEquals(123, wrapper.organization_membership.id);
    }

    static testMethod void testGetMembership2() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationMembershipResponse());

        Test.startTest();
        ZendeskOrganizationMembershipsAPI api = new ZendeskOrganizationMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationMembershipsAPI.OrganizationMembershipWrapper wrapper = api.getMembership(123, 456);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.organization_membership);
        System.assertEquals(123, wrapper.organization_membership.id);
    }

    static testMethod void testDeleteMembership1() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskOrganizationMembershipsAPI api = new ZendeskOrganizationMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        api.deleteMembership(123);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testDeleteMembership2() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskOrganizationMembershipsAPI api = new ZendeskOrganizationMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        api.deleteMembership(123, 456);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testCreateMembership1() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationMembershipResponse());

        Test.startTest();
        ZendeskOrganizationMembershipsAPI api = new ZendeskOrganizationMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Long membershipId = api.createMembership(123, 456);
        Test.stopTest();

        System.assertNotEquals(null, membershipId);
    }

    static testMethod void testCreateMembership2() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationMembershipResponse());

        Test.startTest();
        ZendeskOrganizationMembershipsAPI api = new ZendeskOrganizationMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZOrganizationMembership gm = new ZendeskTypes.ZOrganizationMembership();
        gm.user_id = 123;
        gm.organization_id = 456;
        Long membershipId = api.createMembership(gm);
        Test.stopTest();

        System.assertNotEquals(null, membershipId);
    }

    static testMethod void testMakeDefault() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskOrganizationMembershipsAPI api = new ZendeskOrganizationMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        api.makeDefault(123, 789);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testGetMemberships() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationMembershipsResponse());

        Test.startTest();
        ZendeskOrganizationMembershipsAPI api = new ZendeskOrganizationMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationMembershipsAPI.OrganizationMembershipsWrapper wrapper = api.getMemberships();
        Test.stopTest();

        System.assertNotEquals(null, wrapper.organization_memberships);
        System.assertNotEquals(0, wrapper.organization_memberships.size());
    }

    static testMethod void testGetMembershipsByOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationMembershipsResponse());

        Test.startTest();
        ZendeskOrganizationMembershipsAPI api = new ZendeskOrganizationMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationMembershipsAPI.OrganizationMembershipsWrapper wrapper = api.getMembershipsByOrganization(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper.organization_memberships);
        System.assertNotEquals(0, wrapper.organization_memberships.size());
    }

    static testMethod void testGetAssignableMembershipsByOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationMembershipsResponse());

        Test.startTest();
        ZendeskOrganizationMembershipsAPI api = new ZendeskOrganizationMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationMembershipsAPI.OrganizationMembershipsWrapper wrapper = api.getAssignableMembershipsByOrganization(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper.organization_memberships);
        System.assertNotEquals(0, wrapper.organization_memberships.size());
    }

    static testMethod void testGetAssignableMemberships() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationMembershipsResponse());

        Test.startTest();
        ZendeskOrganizationMembershipsAPI api = new ZendeskOrganizationMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationMembershipsAPI.OrganizationMembershipsWrapper wrapper = api.getAssignableMemberships();
        Test.stopTest();

        System.assertNotEquals(null, wrapper.organization_memberships);
        System.assertNotEquals(0, wrapper.organization_memberships.size());
    }

    static testMethod void testGetUserMemberships() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationMembershipsResponse());

        Test.startTest();
        ZendeskOrganizationMembershipsAPI api = new ZendeskOrganizationMembershipsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationMembershipsAPI.OrganizationMembershipsWrapper wrapper = api.getMembershipsByUser(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper.organization_memberships);
        System.assertNotEquals(0, wrapper.organization_memberships.size());
    }

    static testMethod void testZOrganizationMembership() {
        String testJson = '{'
          + '"id": 123,'
          + '"user_id": 456,'
          + '"organization_id": 789,'
          + '"x_default": true'
          + '}';

        ZendeskTypes.ZOrganizationMembership zobj = (ZendeskTypes.ZOrganizationMembership)JSON.deserialize(testJson, ZendeskTypes.ZOrganizationMembership.class);
        System.assertEquals(123, zobj.id);
        System.assertEquals(456, zobj.user_id);
        System.assertEquals(789, zobj.organization_id);
        System.assertEquals(true, zobj.x_default);
    }
}
