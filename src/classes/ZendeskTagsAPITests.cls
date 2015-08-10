// This class provides test coverage for the ZendeskTagsAPI class
@isTest
public class ZendeskTagsAPITests {

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

    @isTest static void testListTags() {
        Test.setMock(HttpCalloutMock.class, new MockListTagsResponse());

        Test.startTest();
        ZendeskTagsAPI ztags_api = new ZendeskTagsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTagsAPI.ListTagsWrapper tagsResult = ztags_api.listTags();
        Test.stopTest();

        System.assertNotEquals(null, tagsResult);
    }

    @isTest static void testGetTags() {
        Test.setMock(HttpCalloutMock.class, new MockGetTagsResponse());

        Test.startTest();
        ZendeskTagsAPI ztags_api = new ZendeskTagsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTagsAPI.TagsWrapper wrapper = ztags_api.getTags(ZendeskTagsAPI.Resource.users, 123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertEquals(2, wrapper.tags.size());
    }

    @isTest static void testSetTags() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTagsAPI ztags_api = new ZendeskTagsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ztags_api.setTags(ZendeskTagsAPI.Resource.users, 123, new String[] {'tag1', 'tag2'});
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testAddTags() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTagsAPI ztags_api = new ZendeskTagsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ztags_api.addTags(ZendeskTagsAPI.Resource.users, 123, new String[] {'tag1', 'tag2'});
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testRemoveTags() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTagsAPI ztags_api = new ZendeskTagsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ztags_api.removeTags(ZendeskTagsAPI.Resource.users, 123, new String[] {'tag1', 'tag2'});
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testAutocompleteTags() {
        Test.setMock(HttpCalloutMock.class, new MockGetTagsResponse());

        Test.startTest();
        ZendeskTagsAPI ztags_api = new ZendeskTagsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTagsAPI.TagsWrapper wrapper = ztags_api.autocompleteTags('foo');
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertEquals(2, wrapper.tags.size());
    }

    @isTest static void testZTag() {
        String tagJson = '{"name":"important", "count":47}';
        ZendeskTypes.ZTag tag = (ZendeskTypes.ZTag)JSON.deserialize(tagJson, ZendeskTypes.ZTag.class);

        System.assertEquals(47, tag.count);
        System.assertEquals('important', tag.name);
    }
}
