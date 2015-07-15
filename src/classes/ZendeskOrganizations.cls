// This class provides functionality to call the Zendesk Organizations API
// Currently upports the following API endpoints:

public with sharing class ZendeskOrganizations {

	private final ZendeskAPI zapi;

	public class ZOrganization {
		public Long id {get; private set;}
		public String external_id {get; set;}
		public String name {get; set;}
		public DateTime created_at {get; private set;}
		public DateTime updated_at {get; private set;}
		public String[] domain_names {get; set;}
		public String details {get; set;}
		public String notes {get; set;}
		public Long group_id {get; set;}
		public Boolean shared_tickets {get; set;}
		public Boolean shared_comments {get; set;}
		public String[] tags {get; set;}
		public Map<String, String> organization_fields {get; set;}
	}

	public class PagedOrganizationsWrapper {
		public ZOrganization[] organizations {get;set;}

		// Paging support
		public String next_page {get; set;}
		public Long nextPageNumber { get { return ZendeskAPI.getPageNumber(next_page); } private set; }
		public String previous_page {get; set;}
		public Long previousPageNumber { get { return ZendeskAPI.getPageNumber(previous_page); } private set; }
	}

	// Used to deserialize the result of a Organization create/update API call
	private class OrganizationWrapper {
		public ZOrganization organization {get;set;}
	}

	public ZendeskOrganizations(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

	public PagedOrganizationsWrapper getOrganizations() {
        return getOrganizations(null);
    }

    public PagedOrganizationsWrapper getOrganizations(Long page) {
        HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/organizations.json' + (page==null ? '' : '?page=' + page));
        HttpResponse res = new Http().send(queryReq);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error getting organizations (' + res.getStatusCode() + ')');
		}

        PagedOrganizationsWrapper wrapper = (PagedOrganizationsWrapper)JSON.deserialize(res.getBody(), PagedOrganizationsWrapper.class);
        return wrapper;
    }

	public ZOrganization getOrganization(Long organizationId) {
		if (organizationId == null) { throw new ZendeskException('organizationId parameter must not be null'); }

        HttpRequest queryReq = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/organizations/' + organizationId + '.json');
        HttpResponse res = new Http().send(queryReq);

		if (!ZendeskAPI.isSuccess(res)) {
			throw new ZendeskException('Error getting organization ' + organizationId + ' (' + res.getStatusCode() + ')');
		}

        OrganizationWrapper wrapper = (OrganizationWrapper)JSON.deserialize(res.getBody(), OrganizationWrapper.class);
        return wrapper.organization;
    }

}
