// This class provides test coverage for the ZendeskGroupsAPI class
@isTest
public class ZendeskGroupsAPITests {

    public class MockOKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    public class MockGroupResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"group": { "url": "https://test.zendesk.com/api/v2/groups/123.json", "id": 123, "name": "Test", "deleted": false, "created_at": "2014-03-07T22:59:22Z", "updated_at": "2014-03-07T22:59:22Z"}}');
            return res;
        }
    }

    public class MockGroupsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "groups": [ { "url": "https://test.zendesk.com/api/v2/groups/123.json", "id": 123, "name": "Test", "deleted": false, "created_at": "2014-03-07T22:59:22Z", "updated_at": "2014-03-07T22:59:22Z" } ], "next_page": null, "previous_page": null, "count": 1 }');
            return res;
        }
    }

    @isTest static void testGetGroup() {
        Test.setMock(HttpCalloutMock.class, new MockGroupResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskGroupsAPI.GroupWrapper wrapper = zgroups_api.getGroup(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.x_group);
        System.assertEquals(123, wrapper.x_group.id);
    }

    @isTest static void testDeleteGroup() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        zgroups_api.deleteGroup(123);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testCreateGroup() {
        Test.setMock(HttpCalloutMock.class, new MockGroupResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Long groupId = zgroups_api.createGroup('foo');
        Test.stopTest();

        System.assertNotEquals(null, groupId);
    }

    @isTest static void testUpdateGroup() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        zgroups_api.updateGroupName(123, 'foo');
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testGetAllGroups() {
        Test.setMock(HttpCalloutMock.class, new MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Map<Long, ZendeskTypes.ZGroup> fieldsMap = zgroups_api.getAllGroups();
        Test.stopTest();

        System.assertNotEquals(null, fieldsMap.containsKey(123));
    }

    @isTest static void testGetGroups() {
        Test.setMock(HttpCalloutMock.class, new MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskGroupsAPI.GroupsWrapper wrapper = zgroups_api.getGroups();
        Test.stopTest();

        System.assertNotEquals(null, wrapper.groups);
        System.assertNotEquals(0, wrapper.groups.size());
    }

    @isTest static void testGetAssignableGroups() {
        Test.setMock(HttpCalloutMock.class, new MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskGroupsAPI.GroupsWrapper wrapper = zgroups_api.getAssignableGroups();
        Test.stopTest();

        System.assertNotEquals(null, wrapper.groups);
        System.assertNotEquals(0, wrapper.groups.size());
    }

    @isTest static void testGetUserGroups() {
        Test.setMock(HttpCalloutMock.class, new MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskGroupsAPI.GroupsWrapper wrapper = zgroups_api.getUserGroups(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper.groups);
        System.assertNotEquals(0, wrapper.groups.size());
    }

    @isTest static void testZGroup() {
        String groupJson = '{'
          + '"url": "https://test.zendesk.com/api/v2/groups/12345.json",'
          + '"id": 12345,'
          + '"name": "Marketing",'
          + '"deleted": false,'
          + '"created_at": "2014-09-26T01:43:11Z",'
          + '"updated_at": "2014-09-26T01:43:11Z"'
          + '}';

        ZendeskTypes.ZGroup zgroup = (ZendeskTypes.ZGroup)JSON.deserialize(groupJson, ZendeskTypes.ZGroup.class);
        System.assertEquals(12345, zgroup.id);
        System.assertEquals('Marketing', zgroup.name);
        System.assertEquals(false, zgroup.deleted);
        System.assertNotEquals(null, zgroup.created_at);
        System.assertNotEquals(null, zgroup.updated_at);
    }

}
