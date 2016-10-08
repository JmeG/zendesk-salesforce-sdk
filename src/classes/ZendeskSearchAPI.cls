// This class provides functionality to call the Zendesk Search API
global class ZendeskSearchAPI extends ZendeskResourceBase {

    global ZendeskSearchAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    global class SearchResultsWrapper extends ZendeskPagingBase {
        // ZSearchResult has a limited number of fields supported
        global List<ZSearchResult> results { get; set; }

        // objresults requires you to cast the Object to a specific Zendesk type
        // example:
        // if (obj instanceOf ZendeskTypes.ZUser) {
        //   ZendeskTypes.ZUser zuser = (ZendeskTypes.ZUser)obj;
        // }
        global List<Object> objResults { get; set; }
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

        String jsonResult = zconn.sendRequest(req);
        SearchResultsWrapper wrapper = (SearchResultsWrapper)JSON.deserialize(jsonResult, SearchResultsWrapper.class);

        wrapper.objResults = new List<Object>();
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        if (resultMap.containsKey('results')) {
            List<Object> objs = (List<Object>)resultMap.get('results');
            for (Object obj : objs) {
                Map<String, Object> objMap = (Map<String, Object>)obj;
                if (objMap != null && objMap.containsKey('result_type')) {
                    String resultType = String.valueOf(objMap.get('result_type'));
                    if (resultType == 'ticket') {
                        wrapper.objResults.add((ZTicket)JSON.deserialize(JSON.serialize(obj), ZTicket.class));
                    } else if (resultType == 'user') {
                        wrapper.objResults.add((ZUser)JSON.deserialize(JSON.serialize(obj), ZUser.class));
                    } else if (resultType == 'organization') {
                        wrapper.objResults.add((ZOrganization)JSON.deserialize(JSON.serialize(obj), ZOrganization.class));
                    } else if (resultType == 'group') {
                        wrapper.objResults.add((ZGroup)JSON.deserialize(JSON.serialize(obj), ZGroup.class));
                    } else if (resultType == 'topic') {
                        wrapper.objResults.add((ZTopic)JSON.deserialize(JSON.serialize(obj), ZTopic.class));
                    }
                }
            }
        }

        return wrapper;
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
