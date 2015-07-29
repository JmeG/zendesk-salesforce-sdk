// This class provides paging support for lists of records returned from the Zendesk API
public abstract class ZendeskPagingBase extends ZendeskSideLoadingBase {
    public String next_page;
    public Long nextPageNumber { get { return getPageNumber(next_page); } private set; }

    public String previous_page;
    public Long previousPageNumber { get { return getPageNumber(previous_page); } private set; }

    // Total number of records regardless of paging
    public Long count {get; set;}

    // URL could look like this
    // next_page":"https://test.zendesk.com/api/v2/organizations/25378250/tickets.json?include=users%2Cgroups&page=2&per_page=10&sort_order=desc"
    private static Long getPageNumber(String pageUrl) {
        Long page = null;
        if (!String.isEmpty(pageUrl)) {
            String qparams = pageUrl.substringAfter('?');
            String[] splits = qparams.split('&');
            for (String s : splits) {
                if (s.startsWith('page=')) {
                    page = Long.valueOf(s.substringAfter('page='));
                    break;
                }
            }
        }

        return page;
    }
}
