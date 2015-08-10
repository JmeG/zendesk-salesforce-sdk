@isTest
public class ZendeskUsersControllerTests {

    public class MockAPIResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"users":[{"id":123,"url":"https://test.zendesk.com/api/v2/users/123.json","name":"Bob Smith","email":"foo@bar.com","created_at":"2014-07-02T22:03:28Z","updated_at":"2014-07-02T22:03:28Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null,"signature":null,"details":null,"notes":null,"custom_role_id":null,"moderator":false,"ticket_restriction":"requested","only_private_comments":false,"restricted_agent":true,"suspended":false}],"next_page":null,"previous_page":null,"count":1}');
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
        ApexPages.CurrentPage().getparameters().put('org_id', '123');
        ZendeskUsersController con = new ZendeskUsersController();

        con.init();
        Test.stopTest();

        System.assertNotEquals(null, con.ui_users);
        System.assertNotEquals(0, con.ui_users.size());
    }

    private @isTest static void testPaging() {
        Test.setMock(HttpCalloutMock.class, new MockAPIResponse());

        Test.startTest();
        ApexPages.CurrentPage().getparameters().put('org_id', '123');
        ZendeskUsersController con = new ZendeskUsersController();

        con.previous_page = 1;
        con.prevPage();
        System.assertNotEquals(null, con.ui_users);
        System.assertNotEquals(0, con.ui_users.size());

        con.next_page = 2;
        con.nextPage();
        System.assertNotEquals(null, con.ui_users);
        System.assertNotEquals(0, con.ui_users.size());

        Test.stopTest();
    }
}
