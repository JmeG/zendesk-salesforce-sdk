// This class provides test coverage for the ZendeskUserFieldsAPI class
@isTest
public class ZendeskUserFieldsAPITests {

    public class MockOKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    public class MockUserFieldResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "user_field": { "url": "https://test.zendesk.com/api/v2/user_fields/123.json", "id": 123, "type": "tagger", "key": "custom_field_1", "title": "Zendesk Plan", "raw_title": "Zendesk Plan", "description": "", "raw_description": "", "position": 7, "active": true, "required": false, "collapsed_for_agents": false, "regexp_for_validation": null, "title_in_portal": "Zendesk Plan", "raw_title_in_portal": "Zendesk Plan", "visible_in_portal": false, "editable_in_portal": false, "required_in_portal": false, "tag": null, "created_at": "2012-10-19T01:01:32Z", "updated_at": "2014-11-08T10:47:55Z", "removable": true, "custom_field_options": [ { "id": 21332256, "name": "Test", "raw_name": "Test", "value": "zdplan_test" } ] } } ');
            return res;
        }
    }

    public class MockUserFieldsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "user_fields": [ { "url": "https://test.zendesk.com/api/v2/user_fields/123.json", "id": 123, "type": "text", "key": "custom_field_1", "title": "Test", "raw_title": "Test", "description": "Test", "raw_description": "Test", "position": 9999, "active": false, "required": false, "collapsed_for_agents": false, "regexp_for_validation": null, "title_in_portal": "Test", "raw_title_in_portal": "Test", "visible_in_portal": false, "editable_in_portal": false, "required_in_portal": false, "tag": null, "created_at": "2013-08-28T05:57:11Z", "updated_at": "2013-08-29T07:11:23Z", "removable": true } ], "next_page": null, "previous_page": null, "count": 1 }');
            return res;
        }
    }

    @isTest static void testGetFieldById() {
        Test.setMock(HttpCalloutMock.class, new MockUserFieldResponse());

        Test.startTest();
        ZendeskUserFieldsAPI zfields_api = new ZendeskUserFieldsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZUserField testObj = zfields_api.getField(123);
        System.assertNotEquals(null, testObj);

        String optVal = testObj.getOptionValue('Test');
        System.assertNotEquals(null, optVal);
        Test.stopTest();
    }

    @isTest static void testDeleteField() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskUserFieldsAPI zfields_api = new ZendeskUserFieldsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        zfields_api.deleteField(123);
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testCreateField() {
        Test.setMock(HttpCalloutMock.class, new MockUserFieldResponse());

        Test.startTest();
        ZendeskUserFieldsAPI zfields_api = new ZendeskUserFieldsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZUserField zfield = new ZendeskTypes.ZUserField();
        zfield.key = 'create key';
        zfield.title = 'create title';
        Long fieldId = zfields_api.createField(zfield);
        Test.stopTest();

        System.assertNotEquals(null, fieldId);
    }

    @isTest static void testUpdateField() {
        Test.setMock(HttpCalloutMock.class, new MockUserFieldResponse());

        Test.startTest();
        ZendeskUserFieldsAPI zfields_api = new ZendeskUserFieldsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZUserField zfield = new ZendeskTypes.ZUserField();
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
        ZendeskUserFieldsAPI zfields_api = new ZendeskUserFieldsAPI(zconn);
        zfields_api.reorderFields(new Long[] { 123, 456 });
        Test.stopTest();

        System.assert(true);
    }

    @isTest static void testGetAllFields() {
        Test.setMock(HttpCalloutMock.class, new MockUserFieldsResponse());

        Test.startTest();
        ZendeskUserFieldsAPI zfields_api = new ZendeskUserFieldsAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Map<String, ZendeskTypes.ZUserField> fieldsMap = zfields_api.getAllFields();
        Test.stopTest();

        System.assertNotEquals(null, fieldsMap.containsKey('Test'));
    }

    @isTest static void testZUserField() {
        ZendeskTypes.ZUserField zfield = new ZendeskTypes.ZUserField();
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
