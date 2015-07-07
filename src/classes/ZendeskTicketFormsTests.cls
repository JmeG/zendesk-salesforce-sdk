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

    public class MockTicketFormsResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "ticket_forms": [ { "url": "https://test.zendesk.com/api/v2/ticket_forms/466.json", "id": 466, "name": "Test", "raw_name": "Test", "display_name": "Test", "raw_display_name": "Test", "end_user_visible": true, "position": 0, "active": true, "default": true, "created_at": "2013-04-23T01:24:04Z", "updated_at": "2013-08-07T21:29:47Z" } ], "next_page": null, "previous_page": null, "count": 1 }');
            return res;
        }
    }

    static testmethod void testGetTicketForm() {
        Test.setMock(HttpCalloutMock.class, new MockTicketFormsResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskTicketForms zticketforms = new ZendeskTicketForms(zapi);
		ZendeskTicketForms.ZTicketForm testObj = zticketforms.getTicketForm('Test');
        Test.stopTest();

		System.assertNotEquals(null, testObj);
	}

    static testmethod void testDeleteTicketForm() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskTicketForms zticketforms = new ZendeskTicketForms(zapi);
		zticketforms.deleteTicketForm(123);
        Test.stopTest();

		System.assert(true);
	}

    static testMethod void testGetNextPage() {
        Test.startTest();
        ZendeskTicketForms.PagedTicketFormsWrapper wrapper = new ZendeskTicketForms.PagedTicketFormsWrapper();
        wrapper.next_page = 'https://test.zendesk.com/api/v2/ticket_forms.json?page=2';
        Test.stopTest();

        System.assertEquals(2, wrapper.nextPageNumber);
    }

    static testMethod void testGetAllTicketForms() {
        Test.setMock(HttpCalloutMock.class, new MockTicketFormsResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskTicketForms zfields = new ZendeskTicketForms(zapi);
        Map<String, ZendeskTicketForms.ZTicketForm> fieldsMap = zfields.getAllTicketForms();
        Test.stopTest();

        System.assertNotEquals(null, fieldsMap.containsKey('Test'));
    }

    static testMethod void testZTicketForm() {
        ZendeskTicketForms.ZTicketForm zticketform = new ZendeskTicketForms.ZTicketForm();
        //zticketform.id = 0;
        zticketform.name = '';
        zticketform.raw_name = '';
        zticketform.active = true;

        System.assert(true);
    }
}
