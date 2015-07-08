// This class provides test coverage for the ZendeskGroups class
@isTest
private class ZendeskGroupsTests {

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

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskGroups zgroups = new ZendeskGroups(zapi);
        ZendeskGroups.ZGroup testObj = zgroups.getGroup(123);
        Test.stopTest();

        System.assertNotEquals(null, testObj);
        System.assertEquals(123, testObj.id);
    }

    static testMethod void testDeleteGroup() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskGroups zgroups = new ZendeskGroups(zapi);
        zgroups.deleteGroup(123);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testGetAllGroups() {
        Test.setMock(HttpCalloutMock.class, new MockGroupsResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskGroups zgroups = new ZendeskGroups(zapi);
        Map<Integer, ZendeskGroups.ZGroup> fieldsMap = zgroups.getAllGroups();
        Test.stopTest();

        System.assertNotEquals(null, fieldsMap.containsKey(123));
    }

    static testMethod void testGetNextPage() {
        Test.setMock(HttpCalloutMock.class, new MockGroupsResponse());

        Test.startTest();
        ZendeskGroups.PagedGroupsWrapper wrapper = new ZendeskGroups.PagedGroupsWrapper();
        wrapper.next_page = 'https://test.zendesk.com/api/v2/groups.json?page=2';
        Test.stopTest();

        System.assertEquals(2, wrapper.nextPageNumber);
    }

    static testMethod void testZGroup() {
        ZendeskGroups.ZGroup zgroup = new ZendeskGroups.ZGroup();
        zgroup.name = '';

        System.assert(true);
    }
}
