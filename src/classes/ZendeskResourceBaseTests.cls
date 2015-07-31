// This class provides test coverage for the ZendeskResourceBase class
@isTest
private class ZendeskResourceBaseTests {

    //public class Test1 extends ZendeskResourceBase {
    //    public Test1(ZendeskConnection zconn) {
    //		super(zconn);
    //	}
    //}

    static testMethod void testToCSV() {
        //Test1 t1 = new Test1(new ZendeskConnection('s','u','p'));

        Test.startTest();
        System.assertEquals('1,2,3', ZendeskResourceBase.toCSV(new Set<Long> { 1, 2, 3 }));
        System.assertEquals('1,2,3', ZendeskResourceBase.toCSV(new List<Long> { 1, 2, 3 }));
        System.assertEquals('1,2,3', ZendeskResourceBase.toCSV(new Set<String> { '1', '2', '3' }));
        Test.stopTest();
    }

    static testMethod void testStripJsonNulls() {
        Account acct = new Account();
        acct.Name = 'test';

        Test.startTest();
        String testJson = ZendeskResourceBase.stripJsonNulls(JSON.serialize(acct));
        Test.stopTest();

        System.assertEquals(false, testJson.containsIgnoreCase('null'));
    }

    static testMethod void testGetEpochTime() {
        DateTime dt = DateTime.newInstance(2015, 7, 1);

        Test.startTest();
        Long epoch = ZendeskResourceBase.getUnixEpochTime(dt);
        Test.stopTest();

        System.assertEquals(1435734000, epoch);
    }
}
