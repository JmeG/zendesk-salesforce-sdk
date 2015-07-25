// This class provides test coverage for the ZendeskTagsAPI class
@isTest
public class ZendeskTagsTests {

    public class MockOKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    public class MockListTagsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "tags": [{"name":"important", "count":47}, {"name":"customer", "count":11}] }');
            return res;
        }
    }

    public class MockGetTagsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "tags": ["important", "customer"] }');
            return res;
        }
    }

    static testMethod void testListTags() {
        Test.setMock(HttpCalloutMock.class, new MockListTagsResponse());

        Test.startTest();
        ZendeskTagsAPI ztags_api = new ZendeskTagsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskTagsAPI.ListTagsWrapper tagsResult = ztags_api.listTags();
        Test.stopTest();

        System.assertNotEquals(null, tagsResult);
    }

    static testMethod void testGetTags() {
        Test.setMock(HttpCalloutMock.class, new MockGetTagsResponse());

        Test.startTest();
        ZendeskTagsAPI ztags_api = new ZendeskTagsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskTagsAPI.TagsWrapper wrapper = ztags_api.getTags(ZendeskTagsAPI.Resource.users, 123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertEquals(2, wrapper.tags.size());
    }

    static testMethod void testSetTags() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTagsAPI ztags_api = new ZendeskTagsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ztags_api.setTags(ZendeskTagsAPI.Resource.users, 123, new String[] {'tag1', 'tag2'});
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testAddTags() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTagsAPI ztags_api = new ZendeskTagsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ztags_api.addTags(ZendeskTagsAPI.Resource.users, 123, new String[] {'tag1', 'tag2'});
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testRemoveTags() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTagsAPI ztags_api = new ZendeskTagsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ztags_api.removeTags(ZendeskTagsAPI.Resource.users, 123, new String[] {'tag1', 'tag2'});
        Test.stopTest();

        System.assert(true);
    }
}
