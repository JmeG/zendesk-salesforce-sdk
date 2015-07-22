// This class provides paging support for lists of records returned from the Zendesk API
public abstract class ZendeskPagingSupport {
	public String next_page;
	public Long nextPageNumber { get { return getPageNumber(next_page); } private set; }

	public String previous_page;
	public Long previousPageNumber { get { return getPageNumber(previous_page); } private set; }

	private static Long getPageNumber(String pageUrl) {
		return (String.isEmpty(pageUrl) ? null : Long.valueOf(pageUrl.substringAfterLast('page=').substringBefore('&')));
	}
}
