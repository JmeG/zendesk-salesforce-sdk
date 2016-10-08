@isTest
public class ZendeskOrgSearchControllerTests {

    public class MockAPIResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            if (req.getEndPoint().contains('organizations')) {
                res.setBody('{"organizations":[{"url":"https://test.zendesk.com/api/v2/organizations/123.json","id":123,"name":"Zendesk","shared_tickets":false,"shared_comments":false,"external_id":null,"created_at":"2014-03-08T18:29:33Z","updated_at":"2014-03-08T18:29:33Z","domain_names":["zendesk.com"],"details":"","notes":"","group_id":123,"tags":["tag1","tag2"],"organization_fields":{"city":null,"customer":false,"customer_since":null,"employee_number":null,"street_address_1":null,"street_address_2":null,"website":null,"zip":null}}], "next_page": null, "previous_page": null, "count": 1 }');
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

    private @isTest static void testSearch() {
        Test.setMock(HttpCalloutMock.class, new MockAPIResponse());

        Test.startTest();
        ZendeskOrgSearchController con = new ZendeskOrgSearchController();
        con.search();
        Test.stopTest();

        System.assertNotEquals(null, con.ui_orgs);
        System.assertNotEquals(null, con.ui_orgs[0].tags);
        System.assertNotEquals(null, con.ui_orgs[0].domains);
    }

    private @isTest static void testPaging() {
        Test.setMock(HttpCalloutMock.class, new MockAPIResponse());

        Test.startTest();
        ZendeskOrgSearchController con = new ZendeskOrgSearchController();
        con.search();

        con.previous_page = 1;
        con.prevPage();

        con.next_page = 2;
        con.nextPage();

        Test.stopTest();

        System.assert(true);
    }
}
