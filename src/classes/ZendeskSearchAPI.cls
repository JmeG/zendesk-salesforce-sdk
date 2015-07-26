// This class provides functionality to call the Zendesk Search API
public class ZendeskSearchAPI extends ZendeskResourceBase {

    public ZendeskSearchAPI(ZendeskAPI zapi) {
        super(zapi);
    }

	public class SearchResultsWrapper {
		public List<ZSearchResult> results {get;set;}
	}

	// Optional query parameters:
	// sort_by => 'updated_at', 'created_at', 'priority', 'status', or 'ticket_type'. Defaults to sorting by relevance.
	// sort_order => 'asc' or 'desc'. Defaults to 'desc'.

	// GET /api/v2/search.json?query={search_string}
	public SearchResultsWrapper search(String searchString, Map<String, Object> queryParams) {
		if (String.isEmpty(searchString)) { throw new ZendeskException('query parameter must not be null or empty'); }

		if (queryParams == null) { queryParams = new Map<String, Object>(); }
		queryParams.put('query', searchString);
		HttpRequest req = zapi.createRequest('GET', '/search.json', queryParams);
		return (SearchResultsWrapper)JSON.deserialize(zapi.sendRequest(req), SearchResultsWrapper.class);
	}

	// GET /api/v2/portal/search.json?query={search_string}
	public SearchResultsWrapper searchForums(String searchString, Map<String, Object> queryParams) {
		if (String.isEmpty(searchString)) { throw new ZendeskException('query parameter must not be null or empty'); }

		if (queryParams == null) { queryParams = new Map<String, Object>(); }
		queryParams.put('query', searchString);
		HttpRequest req = zapi.createRequest('GET', '/portal/search.json', queryParams);
		return (SearchResultsWrapper)JSON.deserialize(zapi.sendRequest(req), SearchResultsWrapper.class);
	}

}
