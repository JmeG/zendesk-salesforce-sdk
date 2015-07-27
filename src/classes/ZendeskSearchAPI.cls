// This class provides functionality to call the Zendesk Search API
public class ZendeskSearchAPI extends ZendeskResourceBase {

    public ZendeskSearchAPI(ZendeskAPI zapi) {
        super(zapi);
    }

	public class SearchResultsWrapper extends ZendeskPagingBase {
		public List<ZSearchResult> results {get;set;}
	}

	// Optional query parameters:
	// sort_by => 'updated_at', 'created_at', 'priority', 'status', or 'ticket_type'. Defaults to sorting by relevance.
	// sort_order => 'asc' or 'desc'. Defaults to 'desc'.

	public SearchResultsWrapper search(String searchString) {
		return search(searchString, null);
	}

	public SearchResultsWrapper search(String searchString, Map<String, Object> queryParams) {
		if (String.isEmpty(searchString)) { throw new ZendeskException('searchString parameter must not be null or empty'); }

		if (queryParams == null) { queryParams = new Map<String, Object>(); }
		queryParams.put('query', urlEncode(searchString));
		HttpRequest req = zapi.createRequest('GET', '/search.json', queryParams);
		return (SearchResultsWrapper)JSON.deserialize(zapi.sendRequest(req), SearchResultsWrapper.class);
	}

	public SearchResultsWrapper searchForums(String searchString) {
		return searchForums(searchString, null);
	}

	public SearchResultsWrapper searchForums(String searchString, Map<String, Object> queryParams) {
		if (String.isEmpty(searchString)) { throw new ZendeskException('searchString parameter must not be null or empty'); }

		if (queryParams == null) { queryParams = new Map<String, Object>(); }
		queryParams.put('query', urlEncode(searchString));
		HttpRequest req = zapi.createRequest('GET', '/portal/search.json', queryParams);
		return (SearchResultsWrapper)JSON.deserialize(zapi.sendRequest(req), SearchResultsWrapper.class);
	}

}
