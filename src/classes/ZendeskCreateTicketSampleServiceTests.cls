// This class provides test coverage for the ZendeskCreateTicketSampleService class
@isTest
public class ZendeskCreateTicketSampleServiceTests {

    public class MockTicketResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"ticket":{"url":"https://zendeskit.zendesk.com/api/v2/tickets/1234.json","id":1234,"external_id":null,"via":{"channel":"web","source":{"from":{},"to":{},"rel":null}},"created_at":"2013-07-24T23:19:49Z","updated_at":"2013-07-29T23:04:57Z","type":null,"subject":"testing api","description":"test","priority":null,"status":"closed","recipient":null,"requester_id":372418401,"submitter_id":372418401,"assignee_id":372418401,"organization_id":null,"group_id":20153691,"forum_topic_id":null,"problem_id":null,"has_incidents":false,"due_at":null,"ticket_form_id":null}}');
            return res;
        }
    }

    @testSetup static void setup() {
        Zendesk_API__c config = new Zendesk_API__c(Subdomain__c='s', Username__c='u', Password_or_Token__c='pwd', Authentication_Type__c='Password');
        insert config;
    }

    @isTest static void testWebserviceCall() {
        Test.setMock(HttpCalloutMock.class, new MockTicketResponse());

        Test.startTest();

        String msg = ZendeskCreateTicketSampleService.createNewZendeskTicket('subject', 'comment');
        Test.stopTest();

        System.assertNotEquals(null, msg);
    }

}
