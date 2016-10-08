// This class provides test coverage for the ZendeskOrganizations class
@isTest
public class ZendeskOrganizationsAPITests {

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

    @isTest static void testGetOrganizations() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationsAPI.OrganizationsWrapper results = zorgs_api.getOrganizations();
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    @isTest static void testGetOrganizationsByPage() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationsAPI.OrganizationsWrapper results = zorgs_api.getOrganizations(new Map<String, Object>{'page'=>2});
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    @isTest static void testGetOrganizationsByIds() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationsAPI.OrganizationsWrapper results = zorgs_api.getOrganizationsByIds(new Set<Long> {123, 456});
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    @isTest static void testGetOrganizationsByExternalIds() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationsAPI.OrganizationsWrapper results = zorgs_api.getOrganizationsByExternalIds(new Set<String> {'123', '456'});
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    @isTest static void testAutocompleteSearch() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationsAPI.OrganizationsWrapper results = zorgs_api.autocompleteSearch('foo');
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    @isTest static void testSearchOrganizationsByExternalId() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationsAPI.OrganizationsWrapper results = zorgs_api.searchOrganizationsByExternalId('abc123');
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    @isTest static void testGetUserOrganizations() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationsResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationsAPI.OrganizationsWrapper results = zorgs_api.getUserOrganizations(123);
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertNotEquals(null, results.organizations);
        System.assertNotEquals(0, results.organizations.size());
    }

    @isTest static void testGetOrganizationRelatedInfo() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Map<String, Object> results = zorgs_api.getOrganizationRelatedInfo(123);
        Test.stopTest();

        System.assertNotEquals(null, results);
    }

    @isTest static void testGetOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskOrganizationsAPI.OrganizationWrapper wrapper = zorgs_api.getOrganization(123);
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.organization);
        System.assertEquals(123, wrapper.organization.id);
    }

    @isTest static void testCreateOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        ZendeskTypes.ZOrganization zorg = new ZendeskTypes.ZOrganization();
        zorg.name = 'new org';

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Long newOrgId = zorgs_api.createOrganization(zorg);
        Test.stopTest();

        System.assertEquals(123, newOrgId);
    }

    @isTest static void testCreateOrganizations() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        ZendeskTypes.ZOrganization zorg1 = new ZendeskTypes.ZOrganization();
        zorg1.name = 'new org 1';
        ZendeskTypes.ZOrganization zorg2 = new ZendeskTypes.ZOrganization();
        zorg2.name = 'new org 2';

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZJobStatus jobStatus = zorgs_api.createOrganizations(new ZendeskTypes.ZOrganization[] {zorg1, zorg2});
        Test.stopTest();

        System.assertNotEquals(null, jobStatus);
    }

    @isTest static void testUpdateOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationResponse());

        ZendeskTypes.ZOrganization zorg = new ZendeskTypes.ZOrganization();
        zorg.name = 'new org name';

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        zorgs_api.updateOrganization(123, zorg);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testUpdateOrganizations() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        ZendeskTypes.ZOrganization zorg1 = new ZendeskTypes.ZOrganization();
        zorg1.id = 123;
        zorg1.name = 'new name 1';
        ZendeskTypes.ZOrganization zorg2 = new ZendeskTypes.ZOrganization();
        zorg2.external_id = 'abc456';
        zorg2.name = 'new name 2';

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZJobStatus jobStatus = zorgs_api.updateOrganizations(new ZendeskTypes.ZOrganization[] {zorg1, zorg2});
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testUpdateOrganizationsById() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        ZendeskTypes.ZOrganization zorg = new ZendeskTypes.ZOrganization();
        zorg.notes = 'new notes';

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZJobStatus jobStatus = zorgs_api.updateOrganizations(new Set<Long> {123, 456}, zorg);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testUpdateOrganizationsByExternalId() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        ZendeskTypes.ZOrganization zorg = new ZendeskTypes.ZOrganization();
        zorg.notes = 'new notes';

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZJobStatus jobStatus = zorgs_api.updateOrganizations(new Set<String> {'123', '456'}, zorg);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testDeleteOrganization() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        zorgs_api.deleteOrganization(123);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testDeleteOrganizationsById() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZJobStatus jobStatus = zorgs_api.deleteOrganizations(new Set<Long> {123, 456});
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testDeleteOrganizationsByExternalId() {
        Test.setMock(HttpCalloutMock.class, new MockJobStatusResponse());

        Test.startTest();
        ZendeskOrganizationsAPI zorgs_api = new ZendeskOrganizationsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZJobStatus jobStatus = zorgs_api.deleteOrganizations(new Set<String> {'123', '456'} );
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testZOrganization() {
        String organizationJson = '{"url":"https://test.zendesk.com/api/v2/organizations/123.json","id":123,"name":"Zendesk","shared_tickets":false,"shared_comments":false,"external_id":null,"created_at":"2014-03-08T18:29:33Z","updated_at":"2014-03-08T18:29:33Z","domain_names":["zendesk.com"],"details":"","notes":"","group_id":null,"tags":["tag1","tag2"],"organization_fields":{"city":null,"customer":false,"customer_since":null,"employee_number":null,"street_address_1":null,"street_address_2":null,"website":null,"zip":null}}';
        ZendeskTypes.ZOrganization zorganization = (ZendeskTypes.ZOrganization)JSON.deserialize(organizationJson, ZendeskTypes.ZOrganization.class);

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
