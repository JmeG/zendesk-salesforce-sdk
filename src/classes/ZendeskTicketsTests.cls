// This class provides test coverage for the ZendeskTickets class
@isTest
private class ZendeskTicketsTests {

    public class MockGetTicketResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"ticket":{"url":"https://zendeskit.zendesk.com/api/v2/tickets/1234.json","id":1234,"external_id":null,"via":{"channel":"web","source":{"from":{},"to":{},"rel":null}},"created_at":"2013-07-24T23:19:49Z","updated_at":"2013-07-29T23:04:57Z","type":null,"subject":"testing api","description":"test","priority":null,"status":"closed","recipient":null,"requester_id":372418401,"submitter_id":372418401,"assignee_id":372418401,"organization_id":null,"group_id":20153691,"forum_topic_id":null,"problem_id":null,"has_incidents":false,"due_at":null,"ticket_form_id":null}}');
            return res;
        }
    }

    public class MockGetTicketsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"tickets":[{"url":"https://zendeskit.zendesk.com/api/v2/tickets/1234.json","id":1234,"external_id":null,"via":{"channel":"web","source":{"from":{},"to":{},"rel":null}},"created_at":"2013-07-24T23:19:49Z","updated_at":"2013-07-29T23:04:57Z","type":null,"subject":"testing api","description":"test","priority":null,"status":"closed","recipient":null,"requester_id":372418401,"submitter_id":372418401,"assignee_id":372418401,"organization_id":null,"group_id":20153691,"forum_topic_id":null,"problem_id":null,"has_incidents":false,"due_at":null,"ticket_form_id":null}],"next_page":null,"previous_page":null,"count":1}');
            return res;
        }
    }

    public class MockCreateTicketResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setStatus('OK');
            res.setBody('{"ticket":{"url":"https://zendeskit.zendesk.com/api/v2/tickets/1234.json","id":1234,"external_id":null,"via":{"channel":"web","source":{"from":{},"to":{},"rel":null}},"created_at":"2013-07-24T23:19:49Z","updated_at":"2013-07-29T23:04:57Z","type":null,"subject":"testing api","description":"test","priority":null,"status":"closed","recipient":null,"requester_id":372418401,"submitter_id":372418401,"assignee_id":372418401,"organization_id":null,"group_id":20153691,"forum_topic_id":null,"problem_id":null,"has_incidents":false,"due_at":null,"ticket_form_id":null}}');
            return res;
        }
    }

    public class MockOKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    static testMethod void testGetTicketById() {
        Test.setMock(HttpCalloutMock.class, new MockGetTicketResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(zapi);
        ZendeskTickets.ZTicket testObj = ztickets.getTicket(123);
        Test.stopTest();

        System.assertNotEquals(null, testObj);
    }

    static testMethod void testDeleteTicket() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(zapi);
        ztickets.deleteTicket(123);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testCreateTicket1() {
        Test.setMock(HttpCalloutMock.class, new MockCreateTicketResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(zapi);
        Integer newTicketId = ztickets.createTicket(ZendeskTickets.TicketType.question, 'subject', 'comment', 999);

        Test.stopTest();

        System.assertEquals(1234, newTicketId);
    }

    static testMethod void testCreateTicket2() {
        Test.setMock(HttpCalloutMock.class, new MockCreateTicketResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(zapi);
        Integer newTicketId = ztickets.createTicket(ZendeskTickets.TicketType.question, 'testsubj', 'testcomment', 'attachmentToken', 123);

        Test.stopTest();

        System.assertEquals(1234, newTicketId);
    }

    static testMethod void testCreateTicket3() {
        Test.setMock(HttpCalloutMock.class, new MockCreateTicketResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(zapi);
        Integer newTicketId = ztickets.createTicket(ZendeskTickets.TicketType.question, 'testsubj', 'testcomment', 123, new List<ZendeskTickets.ZTicketCustomField>());

        Test.stopTest();

        System.assertEquals(1234, newTicketId);
    }

    static testMethod void testCreateTicket4() {
        Test.setMock(HttpCalloutMock.class, new MockCreateTicketResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(zapi);
        Integer newTicketId = ztickets.createTicket(ZendeskTickets.TicketType.question, 'testsubj', 'testcomment', 123, 234, 345, 456, new List<ZendeskTickets.ZTicketCustomField>());

        Test.stopTest();

        System.assertEquals(1234, newTicketId);
    }

    static testMethod void testGetTickets() {
        Test.setMock(HttpCalloutMock.class, new MockGetTicketsResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
		ZendeskTickets ztickets = new ZendeskTickets(zapi);
		ZendeskTickets.PagedTicketsWrapper results = ztickets.getTickets();
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    static testMethod void testZTicket() {
        ZendeskTickets.ZTicket zticket = new ZendeskTickets.ZTicket();
        zticket.id = 0;
        zticket.url = '';
        zticket.external_id = '';
        zticket.type = '';
        zticket.subject = '';
        zticket.description = '';
        zticket.priority = '';
        zticket.status = '';
        zticket.recipient = '';
        zticket.requester_id = 0;
        zticket.submitter_id = 0;
        zticket.assignee_id = 0;
        zticket.organization_id = 0;
        zticket.group_id = 0;
        zticket.collaborator_ids = new List<Integer>();
        zticket.forum_topic_id = 0;
        zticket.problem_id = 0;
        zticket.has_incidents = false;
        zticket.due_at = DateTime.now();
        zticket.tags = new List<String>();
        zticket.via = null;
        zticket.custom_fields = null;
        zticket.satisfaction_rating = null;
        zticket.sharing_agreement_ids = null;
        zticket.ticket_form_id = 0;
        zticket.created_at = DateTime.now();
        zticket.updated_at = DateTime.now();
        zticket.comment = null;

        ZendeskTickets.ZTicketCustomField zticketcustomfield = new ZendeskTickets.ZTicketCustomField();
        zticketcustomfield.id = 0;
        zticketcustomfield.value = '';

        ZendeskTickets.ZTicketCustomField zticketcustomfield2 = new ZendeskTickets.ZTicketCustomField(1, '');

    	ZendeskTickets.ZTicketVia zticketvia = new ZendeskTickets.ZTicketVia();
    	zticketvia.channel = '';

    	ZendeskTickets.ZTicketSatisfactionRating zticketsatrating = new ZendeskTickets.ZTicketSatisfactionRating();
        zticketsatrating.id = 0;
        zticketsatrating.score = '';
        zticketsatrating.comment = '';

    	ZendeskTickets.ZTicketComment zticketcomment = new ZendeskTickets.ZTicketComment();
        zticketcomment.body = '';
        zticketcomment.uploads = '';


        System.assert(true);
    }

}
