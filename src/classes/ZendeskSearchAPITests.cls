// This class provides test coverage for the ZendeskSearchAPI class
@isTest
public class ZendeskSearchAPITests {

    public class MockSearchResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"results":[{"name":"Hello DJs","created_at":"2009-05-13T00:07:08Z","updated_at":"2011-07-22T00:11:12Z","id":211,"result_type":"group","url":"https://test.zendesk.com/api/v2/groups/211.json"},{"name":"Hello MCs","created_at":"2009-08-26T00:07:08Z","updated_at":"2010-05-13T00:07:08Z","id":122,"result_type":"group","url":"https://test.zendesk.com/api/v2/groups/122.json"}],"facets":null,"next_page":"https://test.zendesk.com/api/v2/search.json?query=type:Group&nbsp;hello&sort_by=created_at&sort_order=desc&page=2","prev_page":null,"count":2}');
            return res;
        }
    }

    @isTest static void testSearch() {
        Test.setMock(HttpCalloutMock.class, new MockSearchResponse());

        Test.startTest();
        ZendeskSearchAPI search_api = new ZendeskSearchAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskSearchAPI.SearchResultsWrapper searchWrapper = search_api.search('foo');
        Test.stopTest();

        System.assertNotEquals(null, searchWrapper);
    }

    @isTest static void testSearchForums() {
        Test.setMock(HttpCalloutMock.class, new MockSearchResponse());

        Test.startTest();
        ZendeskSearchAPI search_api = new ZendeskSearchAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskSearchAPI.SearchResultsWrapper searchWrapper = search_api.searchForums('foo');
        Test.stopTest();

        System.assertNotEquals(null, searchWrapper);
    }

    @isTest static void testZSearchResult() {
        String resultJson = '{ "id": 111, "url": "https://test.zendesk.com/api/v2/groups/211.json", "created_at": "2009-07-20T22:55:29Z", "updated_at": "2011-05-05T10:38:52Z", "result_type": "groups", "name": "foo"}';
        ZendeskTypes.ZSearchResult sresult = (ZendeskTypes.ZSearchResult)JSON.deserialize(resultJson, ZendeskTypes.ZSearchResult.class);
        System.assertEquals(111, sresult.id);
        System.assertNotEquals(null, sresult.url);
        System.assertNotEquals(null, sresult.created_at);
        System.assertNotEquals(null, sresult.updated_at);
        System.assertNotEquals(null, sresult.result_type);
        System.assertNotEquals(null, sresult.name);
    }

}
