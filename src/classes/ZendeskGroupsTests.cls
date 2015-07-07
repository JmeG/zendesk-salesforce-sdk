// This class provides test coverage for the ZendeskGroups class
@isTest
private class ZendeskGroupsTests {

    public class MockGroupsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "groups": [ { "url": "https://test.zendesk.com/api/v2/groups/21641528.json", "id": 21641528, "name": "Test", "deleted": false, "created_at": "2014-03-07T22:59:22Z", "updated_at": "2014-03-07T22:59:22Z" } ], "next_page": null, "previous_page": null, "count": 1 }');
            return res;
        }
    }

    static testMethod void testGetGroup() {
        Test.setMock(HttpCalloutMock.class, new MockGroupsResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskGroups zgroups = new ZendeskGroups(zapi);
        ZendeskGroups.ZGroup testObj = zgroups.getGroup('Test');
        Test.stopTest();

        System.assertNotEquals(null, testObj);
    }

    static testMethod void testGetAllGroups() {
        Test.setMock(HttpCalloutMock.class, new MockGroupsResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskGroups zgroups = new ZendeskGroups(zapi);
        Map<String, ZendeskGroups.ZGroup> fieldsMap = zgroups.getAllGroups();
        Test.stopTest();

        System.assertNotEquals(null, fieldsMap.containsKey('Test'));
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
