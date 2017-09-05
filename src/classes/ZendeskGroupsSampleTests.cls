// This class provides test coverage for the ZendeskGroupsSampleController class
@isTest
private class ZendeskGroupsSampleTests {

    @isTest
    static void testGetGroups() {
        Test.setMock(HttpCalloutMock.class, new ZendeskGroupsAPITests.MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsSampleController con = new ZendeskGroupsSampleController();
        con.getGroups();
        Test.stopTest();

        System.assertNotEquals(null, con.groupsMap);
        System.assertEquals(false, con.groupsMap.isEmpty());
    }

    @isTest
    static void testGetGroupById() {
        Test.setMock(HttpCalloutMock.class, new ZendeskGroupsAPITests.MockGroupResponse());

        Test.startTest();
        ZendeskGroupsSampleController con = new ZendeskGroupsSampleController();
        con.groupId = 1;
        con.getGroupById();
        Test.stopTest();

        System.assertNotEquals(null, con.groupsMap);
        System.assertEquals(false, con.groupsMap.isEmpty());
    }

    @isTest
    static void testGetAssignableGroups() {
        Test.setMock(HttpCalloutMock.class, new ZendeskGroupsAPITests.MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsSampleController con = new ZendeskGroupsSampleController();
        con.getAssignableGroups();
        Test.stopTest();

        System.assertNotEquals(null, con.groupsMap);
        System.assertEquals(false, con.groupsMap.isEmpty());
    }

    @isTest
    static void testGetUserGroups() {
        Test.setMock(HttpCalloutMock.class, new ZendeskGroupsAPITests.MockGroupsResponse());

        Test.startTest();
        ZendeskGroupsSampleController con = new ZendeskGroupsSampleController();
        con.userId = 1;
        con.getUserGroups();
        Test.stopTest();

        System.assertNotEquals(null, con.groupsMap);
        System.assertEquals(false, con.groupsMap.isEmpty());
    }

}
