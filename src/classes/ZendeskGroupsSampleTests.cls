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

    private @isTest static void testGetGroups() {
        Test.setMock(HttpCalloutMock.class, new ZendeskGroupsAPITests.MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsSampleController con = getTestController();
        con.getGroups();
        Test.stopTest();

        System.assertNotEquals(null, con.groupsMap);
        System.assertEquals(false, con.groupsMap.isEmpty());
    }

    private @isTest static void testGetGroupById() {
        Test.setMock(HttpCalloutMock.class, new ZendeskGroupsAPITests.MockGroupResponse());

        Test.startTest();
        ZendeskGroupsSampleController con = getTestController();
        con.groupId = 1;
        con.getGroupById();
        Test.stopTest();

        System.assertNotEquals(null, con.groupsMap);
        System.assertEquals(false, con.groupsMap.isEmpty());
    }

    private @isTest static void testGetAssignableGroups() {
        Test.setMock(HttpCalloutMock.class, new ZendeskGroupsAPITests.MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsSampleController con = getTestController();
        con.getAssignableGroups();
        Test.stopTest();

        System.assertNotEquals(null, con.groupsMap);
        System.assertEquals(false, con.groupsMap.isEmpty());
    }

    private @isTest static void testGetUserGroups() {
        Test.setMock(HttpCalloutMock.class, new ZendeskGroupsAPITests.MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsSampleController con = getTestController();
        con.userId = 1;
        con.getUserGroups();
        Test.stopTest();

        System.assertNotEquals(null, con.groupsMap);
        System.assertEquals(false, con.groupsMap.isEmpty());
    }

}
