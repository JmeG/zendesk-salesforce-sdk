@isTest
public class ZendeskTicketDetailControllerTests {

    public class MockAPIResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            if (req.getEndPoint().contains('comments.json')) {
                res.setBody('{"comments":[{"id":123,"type":"Comment","author_id":123,"body":"test","public":true,"attachments":[],"audit_id":13239342224,"via":{"channel":"email"},"created_at":"2014-04-15T04:25:37Z"}],"users":[{"id":123,"url":"https://test.zendesk.com/api/v2/users/123.json","name":"Test User","email":"testuser@test.com","created_at":"2014-03-02T19:52:32Z","updated_at":"2015-07-20T23:57:27Z","time_zone":"Pacific Time (US & Canada)","phone":"111-222-2233","photo":null,"locale_id":1,"locale":"en-US","organization_id":123,"role":"end-user","verified":false,"external_id":null,"tags":["canada"],"alias":"","active":true,"shared":false,"shared_agent":false,"last_login_at":null,"two_factor_auth_enabled":false,"signature":null,"details":"","notes":"","custom_role_id":null,"moderator":false,"ticket_restriction":"requested","only_private_comments":false,"restricted_agent":true,"suspended":false,"chat_only":false}],"next_page":null,"previous_page":null,"count":1}');
            } else if (req.getEndPoint().contains('/tickets/')) {
                res.setBody('{"ticket":{"url":"https://test.zendesk.com/api/v2/tickets/123.json","id":123,"external_id":null,"via":{"channel":"email"},"created_at":"2014-04-15T04:25:37Z","updated_at":"2014-04-15T04:25:37Z","type":null,"subject":"test","raw_subject":"test","description":"test","priority":null,"status":"open","recipient":"support@test.zendesk.com","requester_id":123,"submitter_id":123,"assignee_id":123,"organization_id":123,"group_id":123,"collaborator_ids":[],"forum_topic_id":null,"problem_id":null,"has_incidents":false,"due_at":null,"tags":["canada"],"satisfaction_rating":null,"sharing_agreement_ids":[],"ticket_form_id":null,"brand_id":123,"metric_set":{"url":"https://test.zendesk.com/api/v2/ticket_metrics/123.json","id":123,"ticket_id":123,"created_at":"2014-04-15T04:25:37Z","updated_at":"2014-04-15T04:25:37Z","group_stations":1,"assignee_stations":1,"reopens":0,"replies":0,"assignee_updated_at":null,"requester_updated_at":"2014-04-15T04:25:37Z","status_updated_at":"2014-04-15T04:25:37Z","initially_assigned_at":"2014-04-15T04:25:37Z","assigned_at":"2014-04-15T04:25:37Z","solved_at":null,"latest_comment_added_at":"2014-04-15T04:25:37Z","reply_time_in_minutes":{"calendar":null,"business":null},"first_resolution_time_in_minutes":{"calendar":null,"business":null},"full_resolution_time_in_minutes":{"calendar":null,"business":null},"agent_wait_time_in_minutes":{"calendar":null,"business":null},"requester_wait_time_in_minutes":{"calendar":null,"business":null},"on_hold_time_in_minutes":{"calendar":0,"business":0}}},"users":[{"id":123,"url":"https://test.zendesk.com/api/v2/users/123.json","name":"Test User","email":"testuser@test.com","created_at":"2014-03-02T19:52:32Z","updated_at":"2015-07-20T23:57:27Z","time_zone":"Pacific Time (US & Canada)","phone":"111-222-2233","photo":null,"locale_id":1,"locale":"en-US","organization_id":24973954,"role":"end-user","verified":false,"external_id":null,"tags":["canada"],"alias":"","active":true,"shared":false,"shared_agent":false,"last_login_at":null,"two_factor_auth_enabled":false,"signature":null,"details":"","notes":"","custom_role_id":null,"moderator":false,"ticket_restriction":"requested","only_private_comments":false,"restricted_agent":true,"suspended":false,"chat_only":false}],"groups":[{"url":"https://test.zendesk.com/api/v2/groups/123.json","id":123,"name":"Support","deleted":false,"created_at":"2014-03-02T16:35:15Z","updated_at":"2014-03-02T16:35:15Z"}],"metric_sets":[{"url":"https://test.zendesk.com/api/v2/ticket_metrics/123.json","id":123,"ticket_id":123,"created_at":"2014-04-15T04:25:37Z","updated_at":"2014-04-15T04:25:37Z","group_stations":1,"assignee_stations":1,"reopens":0,"replies":0,"assignee_updated_at":null,"requester_updated_at":"2014-04-15T04:25:37Z","status_updated_at":"2014-04-15T04:25:37Z","initially_assigned_at":"2014-04-15T04:25:37Z","assigned_at":"2014-04-15T04:25:37Z","solved_at":null,"latest_comment_added_at":"2014-04-15T04:25:37Z","reply_time_in_minutes":{"calendar":null,"business":null},"first_resolution_time_in_minutes":{"calendar":null,"business":null},"full_resolution_time_in_minutes":{"calendar":null,"business":null},"agent_wait_time_in_minutes":{"calendar":null,"business":null},"requester_wait_time_in_minutes":{"calendar":null,"business":null},"on_hold_time_in_minutes":{"calendar":0,"business":0}}]}');
            } else if (req.getEndPoint().contains('/organizations/')) {
                res.setBody('{"organization":{"url":"https://test.zendesk.com/api/v2/organizations/123.json","id":123,"name":"Zendesk","shared_tickets":false,"shared_comments":false,"external_id":null,"created_at":"2014-03-08T18:29:33Z","updated_at":"2014-03-08T18:29:33Z","domain_names":["zendesk.com"],"details":"","notes":"","group_id":null,"tags":["tag1","tag2"],"organization_fields":{"city":null,"customer":false,"customer_since":null,"employee_number":null,"street_address_1":null,"street_address_2":null,"website":null,"zip":null}}}');
            } else {
                throw new ZendeskException('Unknown Mock Request');
            }
            return res;
        }
    }

    @testSetup static void setup() {
        Zendesk_API__c config = new Zendesk_API__c(Subdomain__c='s', Username__c='u', Password_or_Token__c='pwd', Authentication_Type__c='Password');
        insert config;
    }

    private @isTest static void testInit() {
        Test.setMock(HttpCalloutMock.class, new MockAPIResponse());

        Test.startTest();
        ApexPages.CurrentPage().getparameters().put('id', '123');
        ZendeskTicketDetailController con = new ZendeskTicketDetailController();
        con.init();
        Test.stopTest();

        System.assertNotEquals(null, con.ui_ticket);
        System.assertNotEquals(null, con.ui_ticket.orgName);
        System.assertEquals('canada', con.ui_ticket.tags);
        System.assertEquals('Test User', con.ui_ticket.requestedBy);
        System.assertEquals('Test User', con.ui_ticket.assignedTo);
        System.assertEquals('Support', con.ui_ticket.groupName);
        System.assertEquals('email', con.ui_ticket.createdVia);
    }

    private @isTest static void testPaging() {
        Test.setMock(HttpCalloutMock.class, new MockAPIResponse());

        Test.startTest();
        ApexPages.CurrentPage().getparameters().put('id', '123');
        ZendeskTicketDetailController con = new ZendeskTicketDetailController();

        con.previous_page = 1;
        con.prevCommentsPage();
        System.assertNotEquals(null, con.ui_ticketComments);
        System.assertNotEquals(0, con.ui_ticketComments.size());

        con.next_page = 2;
        con.nextCommentsPage();
        System.assertNotEquals(null, con.ui_ticketComments);
        System.assertNotEquals(0, con.ui_ticketComments.size());

        Test.stopTest();
    }
}
