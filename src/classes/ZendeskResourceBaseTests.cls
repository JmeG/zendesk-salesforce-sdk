// This class provides test coverage for the ZendeskResourceBase class
@isTest
private class ZendeskResourceBaseTests {

    //public class Test1 extends ZendeskResourceBase {
    //    public Test1(ZendeskAPI zapi) {
    //		super(zapi);
    //	}
    //}

    static testMethod void testToCSV() {
        //Test1 t1 = new Test1(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));

        Test.startTest();
        System.assertEquals('1,2,3', ZendeskResourceBase.toCSV(new Set<Long> { 1, 2, 3 }));
        System.assertEquals('1,2,3', ZendeskResourceBase.toCSV(new List<Long> { 1, 2, 3 }));
        System.assertEquals('1,2,3', ZendeskResourceBase.toCSV(new Set<String> { '1', '2', '3' }));
        Test.stopTest();
    }

}
