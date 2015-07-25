// This class provides test coverage for the ZendeskOrganizations class
@isTest
public class ZendeskOrganizationsTests {

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

    public class MockJobStatusResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{ "job_status": {"id": "31a2e47012e2013340b438ca3a5dc6c8", "url": "https://test.zendesk.com/api/v2/job_statuses/31a2e47012e2013340b438ca3a5dc6c8.json", "status": "queued" }}');
            return res;
        }
    }

    static testMethod void testGetOrganizations() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizationsAPI.OrganizationsWrapper results = zorgs.getOrganizations();
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    static testMethod void testGetOrganizationsByPage() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizationsAPI.OrganizationsWrapper results = zorgs.getOrganizations(new Map<String, Object>{'page'=>2});
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    static testMethod void testGetOrganizationsByIds() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizationsAPI.OrganizationsWrapper results = zorgs.getOrganizationsByIds(new Set<Long> {123, 456});
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    static testMethod void testGetOrganizationsByExternalIds() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizationsAPI.OrganizationsWrapper results = zorgs.getOrganizationsByExternalIds(new Set<String> {'123', '456'});
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    static testMethod void testGetOrganizationsAutocomplete() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizationsAPI.OrganizationsWrapper results = zorgs.getOrganizations('foo');
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    static testMethod void testSearchOrganizationsByExternalId() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizationsAPI.OrganizationsWrapper results = zorgs.searchOrganizations('abc123');
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    static testMethod void testGetUserOrganizations() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizationsAPI.OrganizationsWrapper results = zorgs.getUserOrganizations(123);
        Test.stopTest();

		System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    static testMethod void testGetOrganizationRelatedInfo() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		Map<String, Object> results = zorgs.getOrganizationRelatedInfo(123);
        Test.stopTest();

		System.assertNotEquals(null, results);
    }

    static testMethod void testGetOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskOrganizationsAPI.OrganizationWrapper wrapper = zorgs.getOrganization(123);
        Test.stopTest();

		System.assertNotEquals(null, wrapper);
		System.assertNotEquals(null, wrapper.organization);
        System.assertEquals(123, wrapper.organization.id);
    }

    static testMethod void testCreateOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        ZendeskOrganizationsAPI.ZOrganization zorg = new ZendeskOrganizationsAPI.ZOrganization();
        zorg.name = 'new org';

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		Long newOrgId = zorgs.createOrganization(zorg);
        Test.stopTest();

        System.assertEquals(123, newOrgId);
    }

    static testMethod void testCreateOrganizations() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        ZendeskOrganizationsAPI.ZOrganization zorg1 = new ZendeskOrganizationsAPI.ZOrganization();
        zorg1.name = 'new org 1';
        ZendeskOrganizationsAPI.ZOrganization zorg2 = new ZendeskOrganizationsAPI.ZOrganization();
        zorg2.name = 'new org 2';

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskJobStatusesAPI.ZJobStatus jobStatus = zorgs.createOrganizations(new ZendeskOrganizationsAPI.ZOrganization[] {zorg1, zorg2});
        Test.stopTest();

        System.assertNotEquals(null, jobStatus);
    }

    static testMethod void testUpdateOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        ZendeskOrganizationsAPI.ZOrganization zorg = new ZendeskOrganizationsAPI.ZOrganization();
        zorg.name = 'new org name';

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		zorgs.updateOrganization(123, zorg);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testUpdateOrganizations() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        ZendeskOrganizationsAPI.ZOrganization zorg1 = new ZendeskOrganizationsAPI.ZOrganization();
        zorg1.id = 123;
        zorg1.name = 'new name 1';
        ZendeskOrganizationsAPI.ZOrganization zorg2 = new ZendeskOrganizationsAPI.ZOrganization();
        zorg2.external_id = 'abc456';
        zorg2.name = 'new name 2';

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskJobStatusesAPI.ZJobStatus jobStatus = zorgs.updateOrganizations(new ZendeskOrganizationsAPI.ZOrganization[] {zorg1, zorg2});
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testUpdateOrganizationsById() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        ZendeskOrganizationsAPI.ZOrganization zorg = new ZendeskOrganizationsAPI.ZOrganization();
        zorg.notes = 'new notes';

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskJobStatusesAPI.ZJobStatus jobStatus = zorgs.updateOrganizations(new Set<Long> {123, 456}, zorg);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testUpdateOrganizationsByExternalId() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        ZendeskOrganizationsAPI.ZOrganization zorg = new ZendeskOrganizationsAPI.ZOrganization();
        zorg.notes = 'new notes';

        Test.startTest();
		ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskJobStatusesAPI.ZJobStatus jobStatus = zorgs.updateOrganizations(new Set<String> {'123', '456'}, zorg);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testDeleteOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        zorgs.deleteOrganization(123);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testDeleteOrganizationsById() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskJobStatusesAPI.ZJobStatus jobStatus = zorgs.deleteOrganizations(new Set<Long> {123, 456});
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testDeleteOrganizationsByExternalId() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs = new ZendeskOrganizationsAPI(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskJobStatusesAPI.ZJobStatus jobStatus = zorgs.deleteOrganizations(new Set<String> {'123', '456'} );
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testZOrganization() {
        String organizationJson = '{"url":"https://test.zendesk.com/api/v2/organizations/123.json","id":123,"name":"Zendesk","shared_tickets":false,"shared_comments":false,"external_id":null,"created_at":"2014-03-08T18:29:33Z","updated_at":"2014-03-08T18:29:33Z","domain_names":["zendesk.com"],"details":"","notes":"","group_id":null,"tags":["tag1","tag2"],"organization_fields":{"city":null,"customer":false,"customer_since":null,"employee_number":null,"street_address_1":null,"street_address_2":null,"website":null,"zip":null}}';
        ZendeskOrganizationsAPI.ZOrganization zorganization = (ZendeskOrganizationsAPI.ZOrganization)JSON.deserialize(organizationJson, ZendeskOrganizationsAPI.ZOrganization.class);

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
