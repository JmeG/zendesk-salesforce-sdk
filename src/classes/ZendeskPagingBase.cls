// This class provides paging support for lists of records returned from the Zendesk API
global abstract class ZendeskPagingBase extends ZendeskSideLoadingBase {
    global String next_page;
    global Long nextPageNumber { get { return getPageNumber(next_page); } private set; }

    global String previous_page;
    global Long previousPageNumber { get { return getPageNumber(previous_page); } private set; }

    // Total number of records regardless of paging
    global Long count {get; set;}

    // URL could look like this
    // next_page":"https://test.zendesk.com/api/v2/organizations/25378250/tickets.json?include=users%2Cgroups&page=2&per_page=10&sort_order=desc"
    private static Long getPageNumber(String pageUrl) {
        Long page = null;
        if (!String.isEmpty(pageUrl)) {
            Map<String, String> qmap = ZendeskConnection.getQueryStringMap(pageUrl);
            if (qmap.containsKey('page')) {
                page = Long.valueOf(qmap.get('page'));
            }
        }

        return page;
    }
}
