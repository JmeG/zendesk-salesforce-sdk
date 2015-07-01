@isTest
private class ZendeskAPICacheManagerTests {

	// Test class containing a test setup method cannot have any methods annotated with @isTest(​SeeAllData=​true)
	// https://success.salesforce.com/issues_view?id=a1p300000008Xx7AAE
	/*
	@testSetup static void setup() {
        Zendesk_API_Cache__c newObj = new Zendesk_API_Cache__c(
            Name='uniqueName1',
            Subdomain__c='unittestdomain',
            Item_Type__c='testtype',
            Item_Name__c='name1',
            Item_ID__c=12345
        );
        insert newObj;
    }
    */

	@isTest
	static void testGetIDNotFound() {
		Test.startTest();

		ZendeskAPICacheManager cache = new ZendeskAPICacheManager();
		Integer cacheId = cache.getID('unittestdomain', 'testtype', 'not to be found', false);

		Test.stopTest();

		System.assertEquals(null, cacheId);
	}

	@isTest
	static void testGetIDFound() {
		Zendesk_API_Cache__c newObj = new Zendesk_API_Cache__c(
            Name='uniqueName1',
            Subdomain__c='unittestdomain',
            Item_Type__c='testtype',
            Item_Name__c='name1',
            Item_ID__c=12345
        );
        insert newObj;

		Test.startTest();

		ZendeskAPICacheManager cache = new ZendeskAPICacheManager();
		Integer cacheId = cache.getID('unittestdomain', 'testtype', 'name1', false);

		Test.stopTest();

		System.assertEquals(12345, cacheId);
	}

	@isTest
	static void testDeleteCache() {
		Zendesk_API_Cache__c newObj = new Zendesk_API_Cache__c(
            Name='uniqueName1',
            Subdomain__c='unittestdomain',
            Item_Type__c='testtype',
            Item_Name__c='name1',
            Item_ID__c=12345
        );
        insert newObj;

		Test.startTest();

		ZendeskAPICacheManager cache = new ZendeskAPICacheManager();
		cache.deleteCache('unittestdomain');

		Test.stopTest();

		List<Zendesk_API_Cache__c> cached = [SELECT Id FROM Zendesk_API_Cache__c WHERE Subdomain__c = 'unittestdomain'];

		System.assertEquals(0, cached.size());
	}

	@isTest
	static void testAddToCache() {
		Zendesk_API_Cache__c newObj = new Zendesk_API_Cache__c(
            Name='uniqueName1',
            Subdomain__c='unittestdomain',
            Item_Type__c='testtype',
            Item_Name__c='name1',
            Item_ID__c=12345
        );
        insert newObj;

		Test.startTest();

		ZendeskAPICacheManager cache = new ZendeskAPICacheManager();
		cache.add('unittestdomain', 'testtype', 'name2', 2000);
		cache.add('unittestdomain', 'testtype', 'name3', 3000);
		cache.add('unittestdomain', 'testtype', 'name4', 4000);
		cache.saveUncommitted();

		Test.stopTest();

		List<Zendesk_API_Cache__c> cached = [SELECT Id FROM Zendesk_API_Cache__c WHERE Subdomain__c = 'unittestdomain'];

		System.assertEquals(4, cached.size());
	}
}