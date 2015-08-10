// This class provides test coverage for the ZendeskSatisfactionRatingsAPI class
@isTest
public class ZendeskSatisfactionRatingsAPITests {

    public class MockOKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    public class MockSatisfactionRatingResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"satisfaction_rating":{"id":35436,"url":"https://company.zendesk.com/api/v2/satisfaction_ratings/35436.json","assignee_id":135,"group_id":44,"requester_id":7881,"ticket_id":208,"score":"good","updated_at":"2011-07-20T22:55:29Z","created_at":"2011-07-20T22:55:29Z","comment":"my comment"}}');
            return res;
        }
    }

    public class MockSatisfactionRatingsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "satisfaction_ratings": [ {"id":35436,"url":"https://company.zendesk.com/api/v2/satisfaction_ratings/35436.json","assignee_id":135,"group_id":44,"requester_id":7881,"ticket_id":208,"score":"good","updated_at":"2011-07-20T22:55:29Z","created_at":"2011-07-20T22:55:29Z","comment":"my comment"} ], "next_page": null, "previous_page": null, "count": 1 }');
            return res;
        }
    }

    @isTest static void testGetSatisfactionRating() {
        Test.setMock(HttpCalloutMock.class, new MockSatisfactionRatingResponse());

        Test.startTest();
        ZendeskSatisfactionRatingsAPI zsat_api = new ZendeskSatisfactionRatingsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskSatisfactionRatingsAPI.SatisfactionRatingWrapper wrapper = zsat_api.getSatisfactionRating(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.satisfaction_rating);
        System.assertEquals(35436, wrapper.satisfaction_rating.id);
    }

    @isTest static void testGetSatisfactionRatings() {
        Test.setMock(HttpCalloutMock.class, new MockSatisfactionRatingsResponse());

        Test.startTest();
        ZendeskSatisfactionRatingsAPI zsat_api = new ZendeskSatisfactionRatingsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskSatisfactionRatingsAPI.SatisfactionRatingsWrapper wrapper = zsat_api.getSatisfactionRatings();
        Test.stopTest();

        System.assertNotEquals(null, wrapper.satisfaction_ratings);
        System.assertNotEquals(0, wrapper.satisfaction_ratings.size());
    }

    @isTest static void testCreateSatisfactionRating() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskSatisfactionRatingsAPI zsat_api = new ZendeskSatisfactionRatingsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZSatisfactionRating satRating = new ZendeskTypes.ZSatisfactionRating();
        satRating.score = 'good';
        satRating.comment = 'my comment';
        zsat_api.createSatisfactionRating(satRating, 456);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testZSatisfactionRating() {
        String satRatingJson = '{'
          + '"url": "https://test.zendesk.com/api/v2/satisfaction_ratings/12345.json",'
          + '"id": 12345,'
          + '"assignee_id": 135,'
          + '"group_id": 44,'
          + '"requester_id": 7881,'
          + '"ticket_id": 208,'
          + '"score": "good",'
          + '"comment": "my comment",'
          + '"created_at": "2014-09-26T01:43:11Z",'
          + '"updated_at": "2014-09-26T01:43:11Z"'
          + '}';

        ZendeskTypes.ZSatisfactionRating satRating = (ZendeskTypes.ZSatisfactionRating)JSON.deserialize(satRatingJson, ZendeskTypes.ZSatisfactionRating.class);
        System.assertEquals(12345, satRating.id);
        System.assertEquals('good', satRating.score);
        System.assertEquals('my comment', satRating.comment);
        System.assertEquals(135, satRating.assignee_id);
        System.assertEquals(44, satRating.group_id);
        System.assertEquals(7881, satRating.requester_id);
        System.assertEquals(208, satRating.ticket_id);
        System.assertNotEquals(null, satRating.created_at);
        System.assertNotEquals(null, satRating.updated_at);
    }

}
