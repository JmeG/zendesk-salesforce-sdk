@isTest
public class ZendeskUserDetailControllerTests {

    public class MockAPIResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            if (req.getEndPoint().contains('/users/')) {
                res.setBody('{"user":{"id":123,"url":"https://test.zendesk.com/api/v2/users/123.json","name":"Bob Smith","email":"bsmith1@test.com","created_at":"2014-07-02T21:57:13Z","updated_at":"2014-07-02T21:57:13Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":123,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null}}');
            } else if (req.getEndPoint().contains('/organizations/')) {
                res.setBody('{"organization":{"url":"https://test.zendesk.com/api/v2/organizations/123.json","id":123,"name":"Zendesk","shared_tickets":false,"shared_comments":false,"external_id":null,"created_at":"2014-03-08T18:29:33Z","updated_at":"2014-03-08T18:29:33Z","domain_names":["zendesk.com"],"details":"","notes":"","group_id":null,"tags":["tag1","tag2"],"organization_fields":{"city":null,"customer":false,"customer_since":null,"employee_number":null,"street_address_1":null,"street_address_2":null,"website":null,"zip":null}}}');
            } else {
                throw new ZendeskException('Unknown Mock Request');
            }
            return res;
        }
    }

    private static testmethod void testInit() {
        Test.setMock(HttpCalloutMock.class, new MockAPIResponse());

        Zendesk_API__c config = new Zendesk_API__c(Subdomain__c='s', Username__c='u', Password_or_Token__c='pwd', Authentication_Type__c='Password');
        insert config;

        Test.startTest();
        ApexPages.CurrentPage().getparameters().put('id', '123');
        ZendeskUserDetailController con = new ZendeskUserDetailController();

        con.init();
        Test.stopTest();

        System.assertNotEquals(null, con.ui_user);
        System.assertNotEquals(null, con.ui_user.orgName);
        System.assertNotEquals(null, con.ui_user.tags);
    }
}
