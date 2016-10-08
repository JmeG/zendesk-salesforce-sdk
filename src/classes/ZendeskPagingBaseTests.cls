// This class provides test coverage for the ZendeskPagingBase class
@isTest
private class ZendeskPagingBaseTests {

    public class TestClass1 extends ZendeskPagingBase {
        public String[] fubar {get; set;}
    }

    @isTest static void testGetPageNumber() {
        String resJson = '{ "fubar": ["important", "customer"],"next_page":"https://test.zendesk.com/api/v2/test.json?page=3","previous_page":"https://test.zendesk.com/api/v2/test.json?page=1" }';
        TestClass1 tester = (TestClass1)JSON.deserialize(resJson, TestClass1.class);

        System.assertNotEquals(null, tester.next_page);
        System.assertEquals(3, tester.nextPageNumber);

        System.assertNotEquals(null, tester.previous_page);
        System.assertEquals(1, tester.previousPageNumber);
    }

    // Test with a more detailed next_page url
    @isTest static void testGetPageNumber2() {
        String resJson = '{ "fubar": ["important", "customer"],"next_page":"https://test.zendesk.com/api/v2/organizations/25378250/tickets.json?include=users%2Cgroups&page=3&per_page=10&sort_order=desc","previous_page":"https://test.zendesk.com/api/v2/test.json?page=1" }';
        TestClass1 tester = (TestClass1)JSON.deserialize(resJson, TestClass1.class);

        System.assertNotEquals(null, tester.next_page);
        System.assertEquals(3, tester.nextPageNumber);
    }
}
