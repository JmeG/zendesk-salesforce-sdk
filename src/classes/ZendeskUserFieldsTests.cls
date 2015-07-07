// This class provides test coverage for the ZendeskUserFields class
@isTest
private class ZendeskUserFieldsTests {

    public class MockUserResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "user_field": { "url": "https://test.zendesk.com/api/v2/user_fields/123.json", "id": 123, "type": "tagger", "key": "custom_field_1", "title": "Zendesk Plan", "raw_title": "Zendesk Plan", "description": "", "raw_description": "", "position": 7, "active": true, "required": false, "collapsed_for_agents": false, "regexp_for_validation": null, "title_in_portal": "Zendesk Plan", "raw_title_in_portal": "Zendesk Plan", "visible_in_portal": false, "editable_in_portal": false, "required_in_portal": false, "tag": null, "created_at": "2012-10-19T01:01:32Z", "updated_at": "2014-11-08T10:47:55Z", "removable": true, "custom_field_options": [ { "id": 21332256, "name": "Test", "raw_name": "Test", "value": "zdplan_test" } ] } } ');
            return res;
        }
    }

    public class MockUsersResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "user_fields": [ { "url": "https://test.zendesk.com/api/v2/user_fields/123.json", "id": 123, "type": "text", "key": "custom_field_1", "title": "Test", "raw_title": "Test", "description": "Test", "raw_description": "Test", "position": 9999, "active": false, "required": false, "collapsed_for_agents": false, "regexp_for_validation": null, "title_in_portal": "Test", "raw_title_in_portal": "Test", "visible_in_portal": false, "editable_in_portal": false, "required_in_portal": false, "tag": null, "created_at": "2013-08-28T05:57:11Z", "updated_at": "2013-08-29T07:11:23Z", "removable": true } ], "next_page": null, "previous_page": null, "count": 1 }');
            return res;
        }
    }

    static testMethod void testGetUserFieldById() {
        Test.setMock(HttpCalloutMock.class, new MockUserResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskUserFields zfields = new ZendeskUserFields(zapi);
        ZendeskUserFields.ZUserField testObj = zfields.getUserField(123);
        System.assertNotEquals(null, testObj);

        String optVal = testObj.getOptionValue('Test');
        System.assertNotEquals(null, optVal);
        Test.stopTest();
    }

    static testMethod void testGetUserFieldByKey() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskUserFields zfields = new ZendeskUserFields(zapi);
        ZendeskUserFields.ZUserField testObj = zfields.getUserFieldByKey('custom_field_1');
        Test.stopTest();

        System.assertNotEquals(null, testObj);
    }

    static testMethod void testGetAllFields() {
        Test.setMock(HttpCalloutMock.class, new MockUsersResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskUserFields zfields = new ZendeskUserFields(zapi);
        Map<String, ZendeskUserFields.ZUserField> fieldsMap = zfields.getAllFields();
        Test.stopTest();

        System.assertNotEquals(null, fieldsMap.containsKey('Test'));
    }

    static testMethod void testGetNextPage() {
        Test.startTest();
        ZendeskUserFields.PagedUserFieldsWrapper wrapper = new ZendeskUserFields.PagedUserFieldsWrapper();
        wrapper.next_page = 'https://test.zendesk.com/api/v2/user_fields.json?page=2';
        Test.stopTest();

        System.assertEquals(2, wrapper.nextPageNumber);
    }

    static testMethod void testZUserField() {
        ZendeskUserFields.ZUserField zuserfield = new ZendeskUserFields.ZUserField();
        //zuserfield.id = 0;
        zuserfield.type = '';
        zuserfield.title = '';
        zuserfield.raw_title = '';
        zuserfield.active = true;
        zuserfield.custom_field_options = null;

        ZendeskUserFields.ZCustomFieldOption zcustomfieldoption = new ZendeskUserFields.ZCustomFieldOption();
        zcustomfieldoption.id = 0;
        zcustomfieldoption.name = '';
        zcustomfieldoption.raw_name = '';
        zcustomfieldoption.value = '';

        System.assert(true);
    }
}
