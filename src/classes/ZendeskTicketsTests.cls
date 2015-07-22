// This class provides test coverage for the ZendeskTickets class
@isTest
private class ZendeskTicketsTests {

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

    static testMethod void testCreateTicketFromTweet() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        Long newTicketId = ztickets.createTicketFromTweet(123123, 456456);
        Test.stopTest();

        System.assertNotEquals(null, newTicketId);
    }

    static testMethod void testCreateMultipleTickets1() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskTickets.ZTicket zt = new ZendeskTickets.ZTicket();
        ZendeskJobStatuses.JobStatus jobStatus = ztickets.createTickets(new ZendeskTickets.ZTicket[] { zt });
        Test.stopTest();

        System.assertNotEquals(null, jobStatus);
    }

    static testMethod void testGetTicketsPage() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
		ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskTickets.TicketsWrapper results = ztickets.getTickets(2);
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    static testMethod void testGetTicketsByIds() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
		ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskTickets.TicketsWrapper results = ztickets.getTicketsByIds(new Long[] {1,2});
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    static testMethod void testGetTicketsIncidents() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
		ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskTickets.TicketsWrapper results = ztickets.getTicketIncidents(123);
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    static testMethod void testGetTicketProblems() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
		ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskTickets.TicketsWrapper results = ztickets.getTicketProblems();
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    static testMethod void testGetTicketCollaborators() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
		ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskUsers.UsersWrapper results = ztickets.getTicketCollaborators(123);
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.users);
        System.assertNotEquals(0, results.users.size());
    }

    static testMethod void testGetTwicketStatus() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        Test.startTest();
		ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		Map<String, Object> results = ztickets.getTwicketStatus(123);
        Test.stopTest();

		System.assertNotEquals(null, results);
    }

    static testMethod void testUpdateMultipleTickets1() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskTickets.ZTicket zt = new ZendeskTickets.ZTicket();
        zt.id = 123;
        ztickets.updateTickets(new ZendeskTickets.ZTicket[] { zt });
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testUpdateMultipleTickets2() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskTickets.ZTicket zt = new ZendeskTickets.ZTicket();
        ZendeskJobStatuses.JobStatus jobStatus = ztickets.updateTickets(new Long[] { 123, 456 }, zt);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testMergeTickets() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskTickets.ZTicket zt = new ZendeskTickets.ZTicket();
        ZendeskJobStatuses.JobStatus jobStatus = ztickets.mergeTickets(new Long[] { 123, 456 }, 'comment1', 789, 'comment2');
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testDeleteTickets() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskTickets.ZTicket zt = new ZendeskTickets.ZTicket();
        ztickets.deleteTickets(new Long[] { 123, 456 });
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testTicketRelatedInfo() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
		ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		Map<String, Object> results = ztickets.getTicketRelatedInfo(123);
        Test.stopTest();

		System.assertNotEquals(null, results);
    }

    static testMethod void testMarkTicketAsSpam() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskTickets.ZTicket zt = new ZendeskTickets.ZTicket();
        ztickets.markTicketAsSpam(123);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testMarkTicketsAsSpam() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskTickets.ZTicket zt = new ZendeskTickets.ZTicket();
        ztickets.markTicketsAsSpam(new Long[] {123, 456});
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testAutoCompleteProblems() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
		ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskTickets.TicketsWrapper results = ztickets.autocompleteProblems('foo');
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    static testMethod void testGetTicketById() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskTickets.ZTicket testObj = ztickets.getTicket(123);
        Test.stopTest();

        System.assertNotEquals(null, testObj);
    }

    static testMethod void testDeleteTicket() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ztickets.deleteTicket(123);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testCreateTicket1() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        Long newTicketId = ztickets.createTicket(ZendeskTickets.TicketType.question, 'subject', 'comment', 999);

        Test.stopTest();

        System.assertNotEquals(null, newTicketId);
    }

    static testMethod void testCreateTicket2() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        Long newTicketId = ztickets.createTicket(ZendeskTickets.TicketType.question, 'testsubj', 'testcomment', 'attachmentToken', 123);

        Test.stopTest();

        System.assertNotEquals(null, newTicketId);
    }

    static testMethod void testCreateTicket3() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        Long newTicketId = ztickets.createTicket(ZendeskTickets.TicketType.question, 'testsubj', 'testcomment', 123, new List<ZendeskTickets.ZTicketCustomField>());

        Test.stopTest();

        System.assertNotEquals(null, newTicketId);
    }

    static testMethod void testCreateTicket4() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        Long newTicketId = ztickets.createTicket(ZendeskTickets.TicketType.question, 'testsubj', 'testcomment', 123, 234, 345, 456, new List<ZendeskTickets.ZTicketCustomField>());

        Test.stopTest();

        System.assertNotEquals(null, newTicketId);
    }

    static testMethod void testCreateTicket5() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();
        ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        Long newTicketId = ztickets.createTicket(ZendeskTickets.TicketType.question, 'testsubj', 'testcomment', 'token', 123,  new List<ZendeskTickets.ZTicketCustomField>());

        Test.stopTest();

        System.assertNotEquals(null, newTicketId);
    }

    static testMethod void testGetTickets() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
		ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskTickets.TicketsWrapper results = ztickets.getTickets();
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    static testMethod void testGetTickets2() {
        Test.setMock(HttpCalloutMock.class, new MockTicketsResponse());

        Test.startTest();
		ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskTickets.TicketsWrapper results = ztickets.getTicketsByOrgId(123);
        results = ztickets.getTicketsByRequesterId(123);
        results = ztickets.getTicketsByCCUserId(123);
        results = ztickets.getTicketsByAssigneeId(123);
        results = ztickets.getRecentTickets();
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.tickets);
        System.assertNotEquals(0, results.tickets.size());
    }

    static testMethod void testUpdateTicket() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
		ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskTickets.ZTicket obj = new ZendeskTickets.ZTicket();
        obj.assignee_id = 555;
        ztickets.updateTicket(123, obj);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testAddTicketComment() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
		ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ztickets.addTicketComment(123, 'new comment', true);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testAddTicketCommentAndChangeStatus() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
		ZendeskTickets ztickets = new ZendeskTickets(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ztickets.addTicketCommentAndChangeStatus(123, 'new comment', true, new ZendeskTickets.TicketStatus('open'));
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testZTicket() {
        String ticketJson = '{ "id": 35436, "url": "https://company.zendesk.com/api/v2/tickets/35436.json", "external_id": "ahg35h3jh", "created_at": "2009-07-20T22:55:29Z", "updated_at": "2011-05-05T10:38:52Z", "type": "incident", "subject": "Help, my printer is on fire!", "raw_subject": "{{dc.printer_on_fire}}", "description": "The fire is very colorful.", "priority": "high", "status": "open", "recipient": "support@company.com", "requester_id": 20978392, "submitter_id": 76872, "assignee_id": 235323, "organization_id": 509974, "group_id": 98738, "collaborator_ids": [35334, 234], "forum_topic_id": 72648221, "problem_id": 9873764, "has_incidents": false, "due_at": null, "tags": ["enterprise", "other_tag"], "via": { "channel": "web" }, "custom_fields": [ { "id": 27642, "value": "745" }, { "id": 27648, "value": "yes" } ], "satisfaction_rating": { "id": 1234, "score": "good", "comment": "Great support!" }, "sharing_agreement_ids": [84432] }';
        ZendeskTickets.ZTicket zticket = (ZendeskTickets.ZTicket)JSON.deserialize(ticketJson, ZendeskTickets.ZTicket.class);
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

        System.assertNotEquals(null, new ZendeskTickets.ZTicketCustomField());
        System.assertNotEquals(null, new ZendeskTickets.ZTicketCustomField(1, 'val'));
    }

}
