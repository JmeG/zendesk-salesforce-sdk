// This class provides test coverage for the ZendeskAutocompleteAPI class
@isTest
public class ZendeskAutocompleteAPITests {

    public class MockGetTagsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "tags": ["important", "customer"] }');
            return res;
        }
    }

    @isTest static void testAutocompleteTags() {
        Test.setMock(HttpCalloutMock.class, new MockGetTagsResponse());

        Test.startTest();
        ZendeskAutocompleteAPI zautocomplete_api = new ZendeskAutocompleteAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTagsAPI.TagsWrapper wrapper = zautocomplete_api.autocompleteTags('foo');
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertEquals(2, wrapper.tags.size());
    }

}
