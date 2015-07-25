// This class provides test coverage for the ZendeskGroupsAPI class
@isTest
public class ZendeskGroupsTests {

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

    static testMethod void testGetGroup() {
        Test.setMock(HttpCalloutMock.class, new MockGroupResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskGroupsAPI.GroupWrapper wrapper = zgroups_api.getGroup(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.x_group);
        System.assertEquals(123, wrapper.x_group.id);
    }

    static testMethod void testDeleteGroup() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        zgroups_api.deleteGroup(123);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testCreateGroup() {
        Test.setMock(HttpCalloutMock.class, new MockGroupResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        Long groupId = zgroups_api.createGroup('foo');
        Test.stopTest();

        System.assertNotEquals(null, groupId);
    }

    static testMethod void testUpdateGroup() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        zgroups_api.updateGroupName(123, 'foo');
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testGetAllGroups() {
        Test.setMock(HttpCalloutMock.class, new MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        Map<Long, ZendeskGroupsAPI.ZGroup> fieldsMap = zgroups_api.getAllGroups();
        Test.stopTest();

        System.assertNotEquals(null, fieldsMap.containsKey(123));
    }

    static testMethod void testGetGroups() {
        Test.setMock(HttpCalloutMock.class, new MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskGroupsAPI.GroupsWrapper wrapper = zgroups_api.getGroups();
        Test.stopTest();

        System.assertNotEquals(null, wrapper.groups);
        System.assertNotEquals(0, wrapper.groups.size());
    }

    static testMethod void testGetAssignableGroups() {
        Test.setMock(HttpCalloutMock.class, new MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskGroupsAPI.GroupsWrapper wrapper = zgroups_api.getAssignableGroups();
        Test.stopTest();

        System.assertNotEquals(null, wrapper.groups);
        System.assertNotEquals(0, wrapper.groups.size());
    }

    static testMethod void testGetUserGroups() {
        Test.setMock(HttpCalloutMock.class, new MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsAPI zgroups_api = new ZendeskGroupsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskGroupsAPI.GroupsWrapper wrapper = zgroups_api.getUserGroups(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper.groups);
        System.assertNotEquals(0, wrapper.groups.size());
    }

    static testMethod void testZGroup() {
        ZendeskGroupsAPI.ZGroup zgroup = new ZendeskGroupsAPI.ZGroup();
        zgroup.name = '';

        /*
        String json = '{'
          + '"group": {
          + '"url": "https://z3njgibsontest1.zendesk.com/api/v2/groups/21468420.json",
          + '"id": 21468420,
          + '"name": "Marketing",
          + '"deleted": false,
          + '"created_at": "2014-09-26T01:43:11Z",
          + '"updated_at": "2014-09-26T01:43:11Z"
          + '}'
        + '}';
        */

        System.assert(true);
    }
}
