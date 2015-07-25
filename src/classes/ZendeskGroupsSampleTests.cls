// This class provides test coverage for the ZendeskGroupsSampleController class
@isTest
private class ZendeskGroupsSampleTests {

    // Helrper method to get an initialized controller
    private static ZendeskGroupsSampleController getTestController() {
        ZendeskGroupsSampleController con = new ZendeskGroupsSampleController();
        con.subdomain = 'test';
        con.username = 'username';
        con.pwdOrToken = 'pwd';
        con.authType = 'Password';

        return con;
    }

    private static testmethod void testGetGroups() {
        Test.setMock(HttpCalloutMock.class, new ZendeskGroupsTests.MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsSampleController con = getTestController();
        con.getGroups();
        Test.stopTest();

        System.assertNotEquals(null, con.groupsMap);
        System.assertEquals(false, con.groupsMap.isEmpty());
    }

    private static testmethod void testGetGroupById() {
        Test.setMock(HttpCalloutMock.class, new ZendeskGroupsTests.MockGroupResponse());

        Test.startTest();
        ZendeskGroupsSampleController con = getTestController();
        con.groupId = 1;
        con.getGroupById();
        Test.stopTest();

        System.assertNotEquals(null, con.groupsMap);
        System.assertEquals(false, con.groupsMap.isEmpty());
    }

    private static testmethod void testGetAssignableGroups() {
        Test.setMock(HttpCalloutMock.class, new ZendeskGroupsTests.MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsSampleController con = getTestController();
        con.getAssignableGroups();
        Test.stopTest();

        System.assertNotEquals(null, con.groupsMap);
        System.assertEquals(false, con.groupsMap.isEmpty());
    }

    private static testmethod void testGetUserGroups() {
        Test.setMock(HttpCalloutMock.class, new ZendeskGroupsTests.MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsSampleController con = getTestController();
        con.userId = 1;
        con.getUserGroups();
        Test.stopTest();

        System.assertNotEquals(null, con.groupsMap);
        System.assertEquals(false, con.groupsMap.isEmpty());
    }

}
