// This class provides test coverage for the ZendeskTicketsAPI class
@isTest
public class ZendeskTicketsAPITests {

    public class MockTicketResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"ticket":{"url":"https://zendeskit.zendesk.com/api/v2/tickets/1234.json","id":1234,"external_id":null,"via":{"channel":"web","source":{"from":{},"to":{},"rel":null}},"created_at":"2013-07-24T23:19:49Z","updated_at":"2013-07-29T23:04:57Z","type":null,"subject":"testing api","description":"test","priority":null,"status":"closed","recipient":null,"requester_id":372418401,"submitter_id":372418401,"assignee_id":372418401,"organization_id":null,"group_id":20153691,"forum_topic_id":null,"problem_id":null,"has_incidents":false,"due_at":null,"ticket_form_id":null}}');
            return res;
        }
    }

    public class MockTicketsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"tickets":[{"url":"https://zendeskit.zendesk.com/api/v2/tickets/1234.json","id":1234,"external_id":null,"via":{"channel":"web","source":{"from":{},"to":{},"rel":null}},"created_at":"2013-07-24T23:19:49Z","updated_at":"2013-07-29T23:04:57Z","type":null,"subject":"testing api","description":"test","priority":null,"status":"closed","recipient":null,"requester_id":372418401,"submitter_id":372418401,"assignee_id":372418401,"organization_id":null,"group_id":20153691,"forum_topic_id":null,"problem_id":null,"has_incidents":false,"due_at":null,"ticket_form_id":null}],"next_page":null,"previous_page":null,"count":1}');
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

    public class MockUsersResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"users":[{"id":123,"url":"https://test.zendesk.com/api/v2/users/123.json","name":"Bob Smith","email":"foo@bar.com","created_at":"2014-07-02T22:03:28Z","updated_at":"2014-07-02T22:03:28Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null,"signature":null,"details":null,"notes":null,"custom_role_id":null,"moderator":false,"ticket_restriction":"requested","only_private_comments":false,"restricted_agent":true,"suspended":false}],"next_page":null,"previous_page":null,"count":1}');
            return res;
        }
    }

    public class MockJobStatusResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{ "job_status": {"id": "31a2e47012e2013340b438ca3a5dc6c8", "url": "https://test.zendesk.com/api/v2/job_statuses/31a2e47012e2013340b438ca3a5dc6c8.json", "status": "queued" }}');
            return res;
        }
    }

    @isTest static void testCreateTicketFromTweet() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Long newTicketId = ztickets_api.createTicketFromTweet(123123, 456456);
        Test.stopTest();

        System.assertNotEquals(null, newTicketId);
    }

    @isTest static void testCreateMultipleTickets1() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZTicket zt = new ZendeskTypes.ZTicket();
        ZendeskTypes.ZJobStatus jobStatus = ztickets_api.createTickets(new ZendeskTypes.ZTicket[] { zt });
        Test.stopTest();

        System.assertNotEquals(null, jobStatus);
    }

    @isTest static void testGetTicketsWithParams() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTicketsAPI.TicketsWrapper results = ztickets_api.getTickets(new Map<String, Object>{'page'=>2});
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    @isTest static void testGetTicketsByIds() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTicketsAPI.TicketsWrapper results = ztickets_api.getTicketsByIds(new Set<Long> {1,2});
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    @isTest static void testGetTicketsIncidents() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTicketsAPI.TicketsWrapper results = ztickets_api.getTicketIncidents(123);
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    @isTest static void testGetTicketProblems() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTicketsAPI.TicketsWrapper results = ztickets_api.getTicketProblems();
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    @isTest static void testGetTicketCollaborators() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskUsersAPI.UsersWrapper results = ztickets_api.getTicketCollaborators(123);
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.users);
        System.assertNotEquals(0, results.users.size());
    }

    @isTest static void testGetTwicketStatus() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Map<String, Object> results = ztickets_api.getTwicketStatus(123);
        Test.stopTest();

        System.assertNotEquals(null, results);
    }

    @isTest static void testUpdateMultipleTickets1() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZTicket zt = new ZendeskTypes.ZTicket();
        zt.id = 123;
        ztickets_api.updateTickets(new ZendeskTypes.ZTicket[] { zt });
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testUpdateMultipleTickets2() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZTicket zt = new ZendeskTypes.ZTicket();
        ZendeskTypes.ZJobStatus jobStatus = ztickets_api.updateTickets(new Set<Long> { 123, 456 }, zt);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testMergeTickets() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZTicket zt = new ZendeskTypes.ZTicket();
        ZendeskTypes.ZJobStatus jobStatus = ztickets_api.mergeTickets(new Set<Long> { 123, 456 }, 'comment1', 789, 'comment2');
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testDeleteTickets() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZTicket zt = new ZendeskTypes.ZTicket();
        ztickets_api.deleteTickets(new Set<Long> { 123, 456 });
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testTicketRelatedInfo() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Map<String, Object> results = ztickets_api.getTicketRelatedInfo(123);
        Test.stopTest();

        System.assertNotEquals(null, results);
    }

    @isTest static void testMarkTicketAsSpam() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZTicket zt = new ZendeskTypes.ZTicket();
        ztickets_api.markTicketAsSpam(123);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testMarkTicketsAsSpam() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZTicket zt = new ZendeskTypes.ZTicket();
        ztickets_api.markTicketsAsSpam(new Set<Long> {123, 456});
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testAutocompleteProblems() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTicketsAPI.TicketsWrapper results = ztickets_api.autocompleteProblems('foo');
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    @isTest static void testGetTicketById() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTicketsAPI.TicketWrapper wrapper = ztickets_api.getTicket(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
    }

    @isTest static void testDeleteTicket() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ztickets_api.deleteTicket(123);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testCreateTicket1() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Long newTicketId = ztickets_api.createTicket(ZendeskTypes.TicketType.question, 'subject', 'comment', 999);

        Test.stopTest();

        System.assertNotEquals(null, newTicketId);
    }

    @isTest static void testCreateTicket2() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Long newTicketId = ztickets_api.createTicket(ZendeskTypes.TicketType.question, 'testsubj', 'testcomment', 'attachmentToken', 123);

        Test.stopTest();

        System.assertNotEquals(null, newTicketId);
    }

    @isTest static void testCreateTicket3() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Long newTicketId = ztickets_api.createTicket(ZendeskTypes.TicketType.question, 'testsubj', 'testcomment', 123, new List<ZendeskTypes.ZTicketCustomField>());

        Test.stopTest();

        System.assertNotEquals(null, newTicketId);
    }

    @isTest static void testCreateTicket4() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Long newTicketId = ztickets_api.createTicket(ZendeskTypes.TicketType.question, 'testsubj', 'testcomment', 123, 234, 345, 456, new List<ZendeskTypes.ZTicketCustomField>());

        Test.stopTest();

        System.assertNotEquals(null, newTicketId);
    }

    @isTest static void testCreateTicket5() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Long newTicketId = ztickets_api.createTicket(ZendeskTypes.TicketType.question, 'testsubj', 'testcomment', 'token', 123,  new List<ZendeskTypes.ZTicketCustomField>());

        Test.stopTest();

        System.assertNotEquals(null, newTicketId);
    }

    @isTest static void testGetTickets() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTicketsAPI.TicketsWrapper results = ztickets_api.getTickets();
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    @isTest static void testGetTickets2() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTicketsAPI.TicketsWrapper results = ztickets_api.getTicketsByOrgId(123);
        results = ztickets_api.getTicketsByRequesterId(123);
        results = ztickets_api.getTicketsByCCUserId(123);
        results = ztickets_api.getTicketsByAssigneeId(123);
        results = ztickets_api.getRecentTickets();
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    @isTest static void testUpdateTicket() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZTicket obj = new ZendeskTypes.ZTicket();
        obj.assignee_id = 555;
        ztickets_api.updateTicket(123, obj);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testAddTicketComment() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ztickets_api.addTicketComment(123, 'new comment', true);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testAddTicketCommentAndChangeStatus() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTicketsAPI ztickets_api = new ZendeskTicketsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ztickets_api.addTicketCommentAndChangeStatus(123, 'new comment', true, new ZendeskTypes.TicketStatus('open'));
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testZTicket() {
        String ticketJson = '{ "id": 35436, "url": "https://company.zendesk.com/api/v2/tickets/35436.json", "external_id": "ahg35h3jh", "created_at": "2009-07-20T22:55:29Z", "updated_at": "2011-05-05T10:38:52Z", "type": "incident", "subject": "Help, my printer is on fire!", "raw_subject": "{{dc.printer_on_fire}}", "description": "The fire is very colorful.", "priority": "high", "status": "open", "recipient": "support@company.com", "requester_id": 20978392, "submitter_id": 76872, "assignee_id": 235323, "organization_id": 509974, "group_id": 98738, "collaborator_ids": [35334, 234], "forum_topic_id": 72648221, "problem_id": 9873764, "has_incidents": false, "due_at": null, "tags": ["enterprise", "other_tag"], "via": { "channel": "web" }, "custom_fields": [ { "id": 27642, "value": "745" }, { "id": 27648, "value": "yes" } ], "satisfaction_rating": { "id": 1234, "score": "good", "comment": "Great support!" }, "sharing_agreement_ids": [84432] }';
        ZendeskTypes.ZTicket zticket = (ZendeskTypes.ZTicket)JSON.deserialize(ticketJson, ZendeskTypes.ZTicket.class);
        System.assertEquals(35436, zticket.id);
        System.assertNotEquals(null, zticket.url);
        System.assertNotEquals(null, zticket.external_id);
        System.assertNotEquals(null, zticket.type);
        System.assertNotEquals(null, zticket.subject);
        System.assertNotEquals(null, zticket.description);
        System.assertNotEquals(null, zticket.priority);
        System.assertNotEquals(null, zticket.status);
        System.assertNotEquals(null, zticket.recipient);
        System.assertNotEquals(null, zticket.requester_id);
        System.assertNotEquals(null, zticket.submitter_id);
        System.assertNotEquals(null, zticket.assignee_id);
        System.assertNotEquals(null, zticket.organization_id);
        System.assertNotEquals(null, zticket.group_id);
        System.assertNotEquals(null, zticket.collaborator_ids);
        System.assertNotEquals(null, zticket.forum_topic_id);
        System.assertNotEquals(null, zticket.problem_id);
        System.assertEquals(false, zticket.has_incidents);
        System.assertEquals(null, zticket.due_at);
        System.assertNotEquals(null, zticket.tags);
        System.assertNotEquals(null, zticket.via);
        System.assertNotEquals(null, zticket.via.channel);
        System.assertNotEquals(null, zticket.custom_fields);
        System.assertNotEquals(null, zticket.custom_fields[0].id);
        System.assertNotEquals(null, zticket.custom_fields[0].value);
        System.assertNotEquals(null, zticket.satisfaction_rating);
        System.assertNotEquals(null, zticket.satisfaction_rating.id);
        System.assertNotEquals(null, zticket.satisfaction_rating.score);
        System.assertNotEquals(null, zticket.satisfaction_rating.comment);
        System.assertNotEquals(null, zticket.sharing_agreement_ids);
        System.assertEquals(null, zticket.ticket_form_id);
        System.assertNotEquals(null, zticket.created_at);
        System.assertNotEquals(null, zticket.updated_at);

        System.assertNotEquals(null, new ZendeskTypes.ZTicketCustomField());
        System.assertNotEquals(null, new ZendeskTypes.ZTicketCustomField(1, 'val'));

        ZendeskTypes.ZTicketRequester tr = new ZendeskTypes.ZTicketRequester();
        tr.locale_id = 123;
        tr.name = 'Name';
        tr.email = 'email@test.com';
    }

}
