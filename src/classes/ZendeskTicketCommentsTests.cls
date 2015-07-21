// This class provides test coverage for the ZendeskTicketComments class
@isTest
private class ZendeskTicketCommentsTests {

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

    static testMethod void testGetTicketComments() {
        Test.setMock(HttpCalloutMock.class, new MockTicketCommentsResponse());

        Test.startTest();
        ZendeskTicketComments zcomments = new ZendeskTicketComments(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskTicketComments.TicketCommentsWrapper wrapper = zcomments.getTicketComments(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.comments);
        System.assertEquals(1, wrapper.comments.size());
    }

    static testMethod void testRedactStringInComment() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTicketComments zcomments = new ZendeskTicketComments(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        zcomments.redactStringInComment(123, 456, 'redact me');
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testMakeCommentPrivate() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTicketComments zcomments = new ZendeskTicketComments(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        zcomments.makeCommentPrivate(123, 456);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testPaging() {
        Test.startTest();
        ZendeskTicketComments.TicketCommentsWrapper wrapper = new ZendeskTicketComments.TicketCommentsWrapper();
        wrapper.next_page = 'https://test.zendesk.com/api/v2/ticket_comments.json?page=2';
        wrapper.previous_page = 'https://test.zendesk.com/api/v2/ticket_comments.json?page=1';
        Test.stopTest();

        System.assertEquals(1, wrapper.previousPageNumber);
        System.assertEquals(2, wrapper.nextPageNumber);
    }

    static testMethod void testZTicketComment() {
        ZendeskTicketComments.ZTicketComment zcomment = new ZendeskTicketComments.ZTicketComment();
        zcomment.type = '';
        zcomment.body = '';
        zcomment.html_body = '';
        zcomment.author_id = 0;
        zcomment.x_public = true;
        zcomment.attachments = new ZendeskAttachments.ZAttachment[1];
        zcomment.via = new ZendeskTickets.ZTicketVia();

        System.assert(true);
    }
}
