@isTest
public class ZendeskContactUserControllerTests {

    public class MockAPIResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            if (req.getEndPoint().contains('users')) {
                res.setBody('{"users":[{"id":123,"url":"https://test.zendesk.com/api/v2/users/123.json","name":"Bob Smith","email":"foobar@test.com","created_at":"2014-07-02T21:57:13Z","updated_at":"2014-07-02T21:57:13Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":123,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null}]}');
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

        Account acct = new Account(Name='TestAccount');
        insert acct;
        Contact contact = new Contact(FirstName='Foo', LastName='Bar', Email='foobar@test.com', AccountId=acct.Id);
        insert contact;

        Test.startTest();
        ApexPages.CurrentPage().getparameters().put('id', contact.Id);
        ZendeskContactUserController con = new ZendeskContactUserController(new ApexPages.standardController(contact));
        con.init();
        Test.stopTest();

        System.assertNotEquals(null, con.ui_user);
    }
}
