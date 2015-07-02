public with sharing class ZendeskAPICacheManager {

	//public Enum ItemType {
	//    TicketField,
	//    TicketForm
	//}

	public static final String TICKET_FIELD = 'TicketField';
	public static final String TICKET_FORM = 'TicketForm';

	private Map<String, Zendesk_API_Cache__c> cacheMap = null;

	private List<Zendesk_API_Cache__c> uncommitedRecords = null;

	public ZendeskAPICacheManager() {
		uncommitedRecords = new List<Zendesk_API_Cache__c>();

		cacheMap = Zendesk_API_Cache__c.getAll();
	}

	public Integer getID(String subdomain, String itemType, String itemName) {
		return getID(subdomain, itemType, itemName, false);
	}

	public Integer getID(String subdomain, String itemType, String itemName, Boolean throwErrorIfNotFound) {
		Integer itemID = null;
		for (String key : cacheMap.keySet()) {
			Zendesk_API_Cache__c cached = cacheMap.get(key);
			if (cached.Subdomain__c == subdomain && cached.Item_Type__c == itemType && cached.Item_Name__c == itemName) {
				itemID = Integer.valueOf(cached.Item_ID__c);
				break;
			}
		}

		if (itemID == null && throwErrorIfNotFound) {
			throw new ZendeskException('Cached ID for "' + subdomain + '.' + itemType + '.' + itemName + '" was not found');
		}

		return itemID;
	}

	public void deleteCache(String subdomain) {
		List<Zendesk_API_Cache__c> deleteList = new List<Zendesk_API_Cache__c>();

		for (String key : cacheMap.keySet()) {
			Zendesk_API_Cache__c cached = cacheMap.get(key);
			if (cached.Subdomain__c == subdomain) {
				deleteList.add(cached);
			}
		}

		if (!deleteList.isEmpty()) {
			delete deleteList;

			// Refetch the cache if we've changed it
			cacheMap = Zendesk_API_Cache__c.getAll();
		}
	}

	public void add(String subdomain, String itemType, String itemName, Integer itemID) {
		if (getID(subdomain, itemType, itemName) != null) {
			throw new ZendeskException('The data you are trying to add is not unique [Saved] ' + subdomain + '.' + itemType + '.' + itemName + '"');
		}

		// Check the uncommited List to make sure there isn't a duplicate there
		for (Zendesk_API_Cache__c c : uncommitedRecords) {
			if (c.Subdomain__c == subdomain && c.Item_Type__c == itemType && c.Item_Name__c == itemName) {
				throw new ZendeskException('The data you are trying to add is not unique [Uncommited] ' + subdomain + '.' + itemType + '.' + itemName + '"');
			}
		}

		Zendesk_API_Cache__c newObj = new Zendesk_API_Cache__c(
			Name=getUniqueId(),
			Subdomain__c=subdomain,
			Item_Type__c=itemType,
			Item_Name__c=itemName,
			Item_ID__c=itemID
		);

		uncommitedRecords.add(newObj);
	}

	public void saveUncommitted() {
		insert uncommitedRecords;

		// Clear the list of uncommitted records
		uncommitedRecords = new List<Zendesk_API_Cache__c>();

		// Refetch the cache if we've changed it
		cacheMap = Zendesk_API_Cache__c.getAll();
	}

	private String getUniqueId() {
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
		return guid;
	}
}
