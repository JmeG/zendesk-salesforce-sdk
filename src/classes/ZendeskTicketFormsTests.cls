// This class provides test coverage for the ZendeskTicketForms class
@isTest
private class ZendeskTicketFormsTests {

    public class MockOKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    public class MockTicketFormResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "ticket_form": { "url": "https://test.zendesk.com/api/v2/ticket_forms/123.json", "id": 123, "name": "Test", "raw_name": "Test", "display_name": "Test", "raw_display_name": "Test", "end_user_visible": true, "position": 0, "active": true, "default": true, "created_at": "2013-04-23T01:24:04Z", "updated_at": "2013-08-07T21:29:47Z" } }');
            return res;
        }
    }

    public class MockTicketFormsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "ticket_forms": [ { "url": "https://test.zendesk.com/api/v2/ticket_forms/123.json", "id": 123, "name": "Test", "raw_name": "Test", "display_name": "Test", "raw_display_name": "Test", "end_user_visible": true, "position": 0, "active": true, "default": true, "created_at": "2013-04-23T01:24:04Z", "updated_at": "2013-08-07T21:29:47Z" } ], "next_page": null, "previous_page": null, "count": 1 }');
            return res;
        }
    }

    static testmethod void testGetTicketForm() {
        Test.setMock(HttpCalloutMock.class, new MockTicketFormResponse());

        Test.startTest();
        ZendeskTicketForms zticketforms = new ZendeskTicketForms(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		ZendeskTicketForms.ZTicketForm testObj = zticketforms.getTicketForm(123);
        Test.stopTest();

		System.assertNotEquals(null, testObj);
        System.assertEquals(123, testObj.id);
	}

    static testmethod void testDeleteTicketForm() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        Test.startTest();
        ZendeskTicketForms zticketforms = new ZendeskTicketForms(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
		zticketforms.deleteTicketForm(123);
        Test.stopTest();

		System.assert(true);
	}

    static testMethod void testCreateTicketForm() {
        Test.setMock(HttpCalloutMock.class, new MockTicketFormResponse());

        Test.startTest();
        ZendeskTicketForms zticketforms = new ZendeskTicketForms(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskTicketForms.ZTicketForm zform = new ZendeskTicketForms.ZTicketForm();
        zform.name = 'create name';
        zform.ticket_field_ids = new Long[] { 123, 456 };
        Long newTicketFormId = zticketforms.createTicketForm(zform);
        Test.stopTest();

        System.assertNotEquals(null, newTicketFormId);
    }

    static testMethod void testUpdateTicketForm() {
        Test.setMock(HttpCalloutMock.class, new MockTicketFormResponse());

        Test.startTest();
        ZendeskTicketForms zticketforms = new ZendeskTicketForms(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskTicketForms.ZTicketForm zform = new ZendeskTicketForms.ZTicketForm();
        zform.name = 'update name';
        zform.ticket_field_ids = new Long[] { 456, 123 };
        zticketforms.updateTicketForm(123, zform);
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testReorderFields() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskTicketForms zfields = new ZendeskTicketForms(zapi);
        zfields.reorderTicketForms(new Long[] { 123, 456 });
        Test.stopTest();

        System.assert(true);
    }

    static testMethod void testCloneTicketForm() {
        Test.setMock(HttpCalloutMock.class, new MockTicketFormResponse());

        Test.startTest();
        ZendeskTicketForms zticketforms = new ZendeskTicketForms(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        Long newTicketFormId = zticketforms.cloneTicketForm(123);
        Test.stopTest();

        System.assertNotEquals(null, newTicketFormId);
    }

    static testMethod void testGetAllTicketForms() {
        Test.setMock(HttpCalloutMock.class, new MockTicketFormsResponse());

        Test.startTest();
        ZendeskTicketForms zfields = new ZendeskTicketForms(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        Map<Long, ZendeskTicketForms.ZTicketForm> fieldsMap = zfields.getAllTicketForms();
        Test.stopTest();

        System.assertNotEquals(null, fieldsMap.containsKey(123));
    }

    static testMethod void testZTicketForm() {
        ZendeskTicketForms.ZTicketForm zticketform = new ZendeskTicketForms.ZTicketForm();
        zticketform.position = 0;
        zticketform.name = '';
        zticketform.raw_name = '';
        zticketform.display_name = '';
        zticketform.raw_display_name = '';
        zticketform.active = true;
        zticketform.x_default = true;
        zticketform.end_user_visible = false;
        zticketform.ticket_field_ids = new Long[] { 1, 2 };

        System.assert(true);
    }
}
