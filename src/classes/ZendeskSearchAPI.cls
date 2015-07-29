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

	public SearchResultsWrapper search(String query) {
		return search(query, null);
	}
	public SearchResultsWrapper search(String query, Map<String, Object> additionalParams) {
		if (String.isEmpty(query)) { throw new ZendeskException('query parameter cannot be null or empty'); }

		if (additionalParams == null) { additionalParams = new Map<String, Object>(); }
		additionalParams.put('query', urlEncode(searchString));
		HttpRequest req = zapi.createRequest('GET', '/search.json', additionalParams);
		return (SearchResultsWrapper)JSON.deserialize(zapi.sendRequest(req), SearchResultsWrapper.class);
	}

	public SearchResultsWrapper searchForums(String query) {
		return searchForums(query, null);
	}
	public SearchResultsWrapper searchForums(String query, Map<String, Object> additionalParams) {
		if (String.isEmpty(query)) { throw new ZendeskException('query parameter cannot be null or empty'); }

		if (additionalParams == null) { additionalParams = new Map<String, Object>(); }
		additionalParams.put('query', urlEncode(query));
		HttpRequest req = zapi.createRequest('GET', '/portal/search.json', additionalParams);
		return (SearchResultsWrapper)JSON.deserialize(zapi.sendRequest(req), SearchResultsWrapper.class);
	}

}
