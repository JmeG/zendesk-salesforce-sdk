// This class provides functionality to call the Zendesk Search API
global class ZendeskSearchAPI extends ZendeskResourceBase {

    global ZendeskSearchAPI(ZendeskConnection zconn) {
        super(zconn);
    }

	global class SearchResultsWrapper extends ZendeskPagingBase {
		global List<ZSearchResult> results {get;set;}
	}

	// Optional query parameters:
	// sort_by => 'updated_at', 'created_at', 'priority', 'status', or 'ticket_type'. Defaults to sorting by relevance.
	// sort_order => 'asc' or 'desc'. Defaults to 'desc'.

	global SearchResultsWrapper search(String query) {
		return search(query, null);
	}
	global SearchResultsWrapper search(String query, Map<String, Object> additionalParams) {
		if (String.isEmpty(query)) { throw new ZendeskException('query parameter cannot be null or empty'); }

		if (additionalParams == null) { additionalParams = new Map<String, Object>(); }
		additionalParams.put('query', urlEncode(query));
		HttpRequest req = zconn.createRequest('GET', '/search.json', additionalParams);
		return (SearchResultsWrapper)JSON.deserialize(zconn.sendRequest(req), SearchResultsWrapper.class);
	}

	global SearchResultsWrapper searchForums(String query) {
		return searchForums(query, null);
	}
	global SearchResultsWrapper searchForums(String query, Map<String, Object> additionalParams) {
		if (String.isEmpty(query)) { throw new ZendeskException('query parameter cannot be null or empty'); }

		if (additionalParams == null) { additionalParams = new Map<String, Object>(); }
		additionalParams.put('query', urlEncode(query));
		HttpRequest req = zconn.createRequest('GET', '/portal/search.json', additionalParams);
		return (SearchResultsWrapper)JSON.deserialize(zconn.sendRequest(req), SearchResultsWrapper.class);
	}

}
