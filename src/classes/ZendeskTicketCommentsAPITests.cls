// This class provides test coverage for the ZendeskTicketCommentsAPI class
@isTest
private class ZendeskTicketCommentsAPITests {

    public class MockOKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    public class MockTicketCommentsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"comments": [{"id": 39786981890, "type": "Comment", "author_id": 364488860, "body": "here are my comments", "html_body": "body", "created_at": "2015-07-04T04:12:00Z"}],"count": 1}');
            return res;
        }
    }

    @isTest static void testGetTicketComments() {
        Test.setMock(HttpCalloutMock.class, new MockTicketCommentsResponse());

        Test.startTest();
        ZendeskTicketCommentsAPI zcomments = new ZendeskTicketCommentsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTicketCommentsAPI.TicketCommentsWrapper wrapper = zcomments.getTicketComments(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.comments);
        System.assertEquals(1, wrapper.comments.size());
    }

    @isTest static void testRedactStringInComment() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTicketCommentsAPI zcomments = new ZendeskTicketCommentsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        zcomments.redactStringInComment(123, 456, 'redact me');
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testMakeCommentPrivate() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTicketCommentsAPI zcomments = new ZendeskTicketCommentsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        zcomments.makeCommentPrivate(123, 456);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testZTicketComment() {
        ZendeskTypes.ZTicketComment zcomment = new ZendeskTypes.ZTicketComment();
        zcomment.type = '';
        zcomment.body = '';
        zcomment.html_body = '';
        zcomment.author_id = 0;
        zcomment.x_public = true;
        zcomment.attachments = new ZendeskTypes.ZAttachment[1];
        zcomment.via = new ZendeskTypes.ZTicketVia();

        System.assert(true);
    }
}
