// This class provides test coverage for the ZendeskAPI class
@isTest
private class ZendeskAPITests {

    static testMethod void testcreateRequest() {
        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/users.json');
        Test.stopTest();

        System.assertEquals('GET', req.getMethod());
    }

    static testMethod void testGetPageNumber() {
        Test.startTest();
        System.assertEquals(3, ZendeskAPI.getPageNumber('https://test.zendesk.com/api/v2/tickets.json?page=3'));
        System.assertEquals(3, ZendeskAPI.getPageNumber('https://test.zendesk.com/api/v2/tickets.json?page=3&foo=bar'));
        Test.stopTest();
    }
}
