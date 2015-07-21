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

    static testMethod void testGetOrganizationsByPage() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizations.OrganizationsWrapper results = zorgs.getOrganizations(2);
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    static testMethod void testGetOrganizationsByIds() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizations.OrganizationsWrapper results = zorgs.getOrganizationsByIds(new Long[] {123, 456});
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    static testMethod void testGetOrganizationsByExternalIds() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizations.OrganizationsWrapper results = zorgs.getOrganizationsByExternalIds(new String[] {'123', '456'});
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    static testMethod void testGetOrganizationsAutocomplete() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizations.OrganizationsWrapper results = zorgs.getOrganizations('foo');
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    static testMethod void testSearchOrganizationsByExternalId() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizations.OrganizationsWrapper results = zorgs.searchOrganizations('abc123');
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    static testMethod void testGetUserOrganizations() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizations.OrganizationsWrapper results = zorgs.getUserOrganizations(123);
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    static testMethod void testGetOrganizationRelatedInfo() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		Map<String, Object> results = zorgs.getOrganizationRelatedInfo(123);
        Test.stopTest();

		System.assertNotEquals(null, results);
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

    static testMethod void testCreateOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        ZendeskOrganizations.ZOrganization zorg = new ZendeskOrganizations.ZOrganization();
        zorg.name = 'new org';

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		Long newOrgId = zorgs.createOrganization(zorg);
        Test.stopTest();

        System.assertEquals(123, newOrgId);
    }

    static testMethod void testCreateOrganizations() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        ZendeskOrganizations.ZOrganization zorg1 = new ZendeskOrganizations.ZOrganization();
        zorg1.name = 'new org 1';
        ZendeskOrganizations.ZOrganization zorg2 = new ZendeskOrganizations.ZOrganization();
        zorg2.name = 'new org 2';

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizations.ZOrganization[] createdOrgs = zorgs.createOrganizations(new ZendeskOrganizations.ZOrganization[] {zorg1, zorg2});
        Test.stopTest();

        System.assertNotEquals(null, createdOrgs);
    }

    static testMethod void testUpdateOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        ZendeskOrganizations.ZOrganization zorg = new ZendeskOrganizations.ZOrganization();
        zorg.name = 'new org name';

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		zorgs.updateOrganization(123, zorg);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testUpdateOrganizations() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        ZendeskOrganizations.ZOrganization zorg1 = new ZendeskOrganizations.ZOrganization();
        zorg1.id = 123;
        zorg1.name = 'new name 1';
        ZendeskOrganizations.ZOrganization zorg2 = new ZendeskOrganizations.ZOrganization();
        zorg2.external_id = 'abc456';
        zorg2.name = 'new name 2';

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		zorgs.updateOrganizations(new ZendeskOrganizations.ZOrganization[] {zorg1, zorg2});
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testUpdateOrganizationsById() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        ZendeskOrganizations.ZOrganization zorg = new ZendeskOrganizations.ZOrganization();
        zorg.notes = 'new notes';

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		zorgs.updateOrganizations(new Long[] {123, 456}, zorg);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testUpdateOrganizationsByExternalId() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        ZendeskOrganizations.ZOrganization zorg = new ZendeskOrganizations.ZOrganization();
        zorg.notes = 'new notes';

        Test.startTest();
		ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		zorgs.updateOrganizations(new String[] {'123', '456'}, zorg);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testDeleteOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        zorgs.deleteOrganization(123);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testDeleteOrganizationsById() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        zorgs.deleteOrganizations(new Long[] {123, 456});
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testDeleteOrganizationsByExternalId() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskOrganizations zorgs = new ZendeskOrganizations(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        zorgs.deleteOrganizations(new String[] {'123', '456'} );
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
