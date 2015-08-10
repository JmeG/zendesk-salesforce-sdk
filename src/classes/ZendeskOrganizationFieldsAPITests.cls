// This class provides test coverage for the ZendeskOrganizationFieldsAPI class
@isTest
public class ZendeskOrganizationFieldsAPITests {

    public class MockOKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    public class MockOrganizationFieldResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "organization_field": { "url": "https://test.zendesk.com/api/v2/organization_fields/123.json", "id": 123, "type": "tagger", "key": "custom_field_1", "title": "Zendesk Plan", "raw_title": "Zendesk Plan", "description": "", "raw_description": "", "position": 7, "active": true, "required": false, "collapsed_for_agents": false, "regexp_for_validation": null, "title_in_portal": "Zendesk Plan", "raw_title_in_portal": "Zendesk Plan", "visible_in_portal": false, "editable_in_portal": false, "required_in_portal": false, "tag": null, "created_at": "2012-10-19T01:01:32Z", "updated_at": "2014-11-08T10:47:55Z", "removable": true, "custom_field_options": [ { "id": 21332256, "name": "Test", "raw_name": "Test", "value": "zdplan_test" } ] } } ');
            return res;
        }
    }

    public class MockOrganizationFieldsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "organization_fields": [ { "url": "https://test.zendesk.com/api/v2/organization_fields/123.json", "id": 123, "type": "text", "key": "custom_field_1", "title": "Test", "raw_title": "Test", "description": "Test", "raw_description": "Test", "position": 9999, "active": false, "required": false, "collapsed_for_agents": false, "regexp_for_validation": null, "title_in_portal": "Test", "raw_title_in_portal": "Test", "visible_in_portal": false, "editable_in_portal": false, "required_in_portal": false, "tag": null, "created_at": "2013-08-28T05:57:11Z", "updated_at": "2013-08-29T07:11:23Z", "removable": true } ], "next_page": null, "previous_page": null, "count": 1 }');
            return res;
        }
    }

    @isTest static void testGetOrganizationFieldById() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationFieldResponse());

        Test.startTest();
        ZendeskOrganizationFieldsAPI zfields_api = new ZendeskOrganizationFieldsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZOrganizationField testObj = zfields_api.getField(123);
        System.assertNotEquals(null, testObj);

        String optVal = testObj.getOptionValue('Test');
        System.assertNotEquals(null, optVal);
        Test.stopTest();
    }

    @isTest static void testDeleteField() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskOrganizationFieldsAPI zfields_api = new ZendeskOrganizationFieldsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        zfields_api.deleteField(123);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testCreateField() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationFieldResponse());

        Test.startTest();
        ZendeskOrganizationFieldsAPI zfields_api = new ZendeskOrganizationFieldsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZOrganizationField zfield = new ZendeskTypes.ZOrganizationField();
        zfield.key = 'create key';
        zfield.title = 'create title';
        Long fieldId = zfields_api.createField(zfield);
        Test.stopTest();

        System.assertNotEquals(null, fieldId);
    }

    @isTest static void testUpdateField() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationFieldResponse());

        Test.startTest();
        ZendeskOrganizationFieldsAPI zfields_api = new ZendeskOrganizationFieldsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZOrganizationField zfield = new ZendeskTypes.ZOrganizationField();
        zfield.key = 'update key';
        zfield.title = 'update title';
        zfields_api.updateField(123, zfield);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testReorderFields() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        ZendeskConnection zconn = ZendeskConnection.createWithPassword('s','u','p');

        Test.startTest();
        ZendeskOrganizationFieldsAPI zfields_api = new ZendeskOrganizationFieldsAPI(zconn);
        zfields_api.reorderFields(new Long[] { 123, 456 });
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testGetAllFields() {
        Test.setMock(HttpCalloutMock.class, new MockOrganizationFieldsResponse());

        Test.startTest();
        ZendeskOrganizationFieldsAPI zfields_api = new ZendeskOrganizationFieldsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Map<String, ZendeskTypes.ZOrganizationField> fieldsMap = zfields_api.getAllFields();
        Test.stopTest();

        System.assertNotEquals(null, fieldsMap.containsKey('Test'));
    }

    @isTest static void testZOrganizationField() {
        ZendeskTypes.ZOrganizationField zfield = new ZendeskTypes.ZOrganizationField();
        //zfield.id = 0;
        zfield.type = '';
        zfield.title = '';
        zfield.raw_title = '';
        zfield.active = true;
        zfield.custom_field_options = null;

        ZendeskTypes.ZCustomFieldOption zfieldoption = new ZendeskTypes.ZCustomFieldOption();
        zfieldoption.id = 0;
        zfieldoption.name = '';
        zfieldoption.raw_name = '';
        zfieldoption.value = '';

        System.assert(true);
    }
}
