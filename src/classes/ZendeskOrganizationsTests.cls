// This class provides test coverage for the ZendeskOrganizations class
@isTest
private class ZendeskOrganizationsTests {

    public class MockOKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    public class MockOrganizationResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"organization":{"url":"https://test.zendesk.com/api/v2/organizations/123.json","id":123,"name":"Zendesk","shared_tickets":false,"shared_comments":false,"external_id":null,"created_at":"2014-03-08T18:29:33Z","updated_at":"2014-03-08T18:29:33Z","domain_names":["zendesk.com"],"details":"","notes":"","group_id":null,"tags":["tag1","tag2"],"organization_fields":{"city":null,"customer":false,"customer_since":null,"employee_number":null,"street_address_1":null,"street_address_2":null,"website":null,"zip":null}}}');
            return res;
        }
    }

    public class MockOrganizationsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"organizations":[{"url":"https://test.zendesk.com/api/v2/organizations/123.json","id":123,"name":"Zendesk","shared_tickets":false,"shared_comments":false,"external_id":null,"created_at":"2014-03-08T18:29:33Z","updated_at":"2014-03-08T18:29:33Z","domain_names":["zendesk.com"],"details":"","notes":"","group_id":null,"tags":["tag1","tag2"],"organization_fields":{"city":null,"customer":false,"customer_since":null,"employee_number":null,"street_address_1":null,"street_address_2":null,"website":null,"zip":null}}],"next_page":null,"previous_page":null,"count":1}');
            return res;
        }
    }

    static testMethod void testGetOrganizations() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizations.OrganizationsWrapper results = zorgs.getOrganizations();
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    static testMethod void testGetOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizations.ZOrganization org = zorgs.getOrganization(123);
        Test.stopTest();

		System.assertNotEquals(null, org);
        System.assertEquals(123, org.id);
    }

    static testMethod void testDeleteOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        zorgs.deleteOrganization(123);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testPaging() {
        Test.startTest();
        ZendeskOrganizations.OrganizationsWrapper wrapper = new ZendeskOrganizations.OrganizationsWrapper();
        wrapper.next_page = 'https://test.zendesk.com/api/v2/organizations.json?page=2';
        wrapper.previous_page = 'https://test.zendesk.com/api/v2/organizations.json?page=1';
        Test.stopTest();

        System.assertEquals(1, wrapper.previousPageNumber);
        System.assertEquals(2, wrapper.nextPageNumber);
    }

    static testMethod void testZOrganization() {
        String organizationJson = '{"url":"https://test.zendesk.com/api/v2/organizations/123.json","id":123,"name":"Zendesk","shared_tickets":false,"shared_comments":false,"external_id":null,"created_at":"2014-03-08T18:29:33Z","updated_at":"2014-03-08T18:29:33Z","domain_names":["zendesk.com"],"details":"","notes":"","group_id":null,"tags":["tag1","tag2"],"organization_fields":{"city":null,"customer":false,"customer_since":null,"employee_number":null,"street_address_1":null,"street_address_2":null,"website":null,"zip":null}}';
        ZendeskOrganizations.ZOrganization zorganization = (ZendeskOrganizations.ZOrganization)JSON.deserialize(organizationJson, ZendeskOrganizations.ZOrganization.class);

        System.assertEquals(123, zorganization.id);
        System.assertEquals(null, zorganization.external_id);
        System.assertEquals('Zendesk', zorganization.name);
        System.assertNotEquals(null, zorganization.created_at);
        System.assertNotEquals(null, zorganization.updated_at);
        System.assertEquals(1, zorganization.domain_names.size());
        System.assertNotEquals(null, zorganization.details);
        System.assertNotEquals(null, zorganization.notes);
        System.assertEquals(null, zorganization.group_id);
        System.assertEquals(false, zorganization.shared_tickets);
        System.assertEquals(false, zorganization.shared_comments);
        System.assertEquals(2, zorganization.tags.size());
        System.assertNotEquals(null, zorganization.organization_fields);
    }
}
