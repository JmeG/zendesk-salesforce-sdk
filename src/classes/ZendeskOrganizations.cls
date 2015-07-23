// This class provides functionality to call the Zendesk Organizations API
// Currently supports the following API endpoints:
// GET    /api/v2/organizations.json
// GET    /api/v2/organizations/{id}.json
// GET    /api/v2/organizations/show_many.json?ids={ids}
// GET    /api/v2/organizations/show_many.json?external_ids={external_ids}
// GET    /api/v2/organizations/autocomplete.json?name={name}
// GET    /api/v2/organizations/search.json?external_id={external_id}
// GET    /api/v2/organizations/{id}/related.json
// GET    /api/v2/users/{user_id}/organizations.json
// POST   /api/v2/organizations.json
// POST   /api/v2/organizations/create_many.json
// PUT    /api/v2/organizations/{id}.json
// PUT    /api/v2/organizations/update_many.json
// PUT    /api/v2/organizations/update_many.json?ids={ids}
// PUT    /api/v2/organizations/update_many.json?external_ids={external_ids}
// DELETE /api/v2/organizations/{id}.json
// DELETE /api/v2/organizations/destroy_many.json?ids={ids}
// DELETE /api/v2/organizations/destroy_many.json?external_ids={external_ids}
public class ZendeskOrganizations {

	private final ZendeskAPI zapi;

	public class ZOrganization {
		public Long id {get;set;}
		public String external_id {get;set;}
		public String name {get;set;}
		public String[] domain_names {get;set;}
		public String details {get;set;}
		public String notes {get;set;}
		public Long group_id {get;set;}
		public Boolean shared_tickets {get;set;}
		public Boolean shared_comments {get;set;}
		public String[] tags {get;set;}
		public Map<String, String> organization_fields {get;set;}
		public DateTime created_at {get; private set;}
		public DateTime updated_at {get; private set;}
	}

	public class OrganizationsWrapper extends ZendeskPagingSupport {
		public ZOrganization[] organizations {get;set;}
	}

	// Used to deserialize the result of a Organization create/update API call
	private class OrganizationWrapper {
		public ZOrganization organization {get;set;}
	}

	public ZendeskOrganizations(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

	public OrganizationsWrapper getOrganizations() {
        HttpRequest req = zapi.createRequest('GET', '/organizations.json');
        return getOrganizations(req);
    }

    public OrganizationsWrapper getOrganizations(Long page) {
        HttpRequest req = zapi.createRequest('GET', '/organizations.json' + (page==null ? '' : '?page=' + page));
        return getOrganizations(req);
    }

	public OrganizationsWrapper getOrganizationsByIds(Long[] orgIds) {
		if (orgIds == null || orgIds.isEmpty()) { throw new ZendeskException('orgIds parameter must not be null or empty'); }

        HttpRequest req = zapi.createRequest('GET', '/organizations/show_many.json?ids=' + ZendeskAPI.arrayToCSV(orgIds));
        return getOrganizations(req);
    }

	public OrganizationsWrapper getOrganizationsByExternalIds(String[] externalIds) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter must not be null or empty'); }

        HttpRequest req = zapi.createRequest('GET', '/organizations/show_many.json?external_ids=' + ZendeskAPI.arrayToCSV(externalIds));
        return getOrganizations(req);
    }

	public OrganizationsWrapper getOrganizations(String autoCompleteName) {
		if (String.isBlank(autoCompleteName) || autoCompleteName.length() < 2) { throw new ZendeskException('autoCompleteName parameter must at least 2 characters'); }

        HttpRequest req = zapi.createRequest('GET', '/organizations/autocomplete.json?name=' + autoCompleteName);
        return getOrganizations(req);
    }

	public OrganizationsWrapper searchOrganizations(String externalId) {
		if (String.isBlank(externalId)) { throw new ZendeskException('externalId parameter must not be null or empty'); }

        HttpRequest req = zapi.createRequest('GET', '/organizations/search.json?external_id=' + externalId);
        return getOrganizations(req);
    }

	public OrganizationsWrapper getUserOrganizations(Long userId) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/users/' + userId + '/organizations.json');
        return getOrganizations(req);
    }

	// Helper method for GET Organization's
	private OrganizationsWrapper getOrganizations(HttpRequest req) {
        String resBody = zapi.sendRequest(req);

        return (OrganizationsWrapper)JSON.deserialize(resBody, OrganizationsWrapper.class);
    }

	public ZOrganization getOrganization(Long orgId) {
		if (orgId == null) { throw new ZendeskException('orgId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/organizations/' + orgId + '.json');
        String resBody = zapi.sendRequest(req);

        OrganizationWrapper wrapper = (OrganizationWrapper)JSON.deserialize(resBody, OrganizationWrapper.class);
		return wrapper.organization;
    }

	public Map<String, Object> getOrganizationRelatedInfo(Long orgId) {
		if (orgId == null) { throw new ZendeskException('orgId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/organizations/' + orgId + '/related.json');
        String resBody = zapi.sendRequest(req);

		return (Map<String, Object>)JSON.deserializeUntyped(resBody);
	}

	public Long createOrganization(ZOrganization zorg) {
        if (zorg == null) { throw new ZendeskException('zorg parameter must not be null'); }

        HttpRequest req = zapi.createRequest('POST', '/organizations.json');
        req.setBody('{ "organization": ' + ZendeskAPI.stripJsonNulls(JSON.serialize(zorg)) + '}');
		String resBody = zapi.sendRequest(req);

        OrganizationWrapper resultWrapper = (OrganizationWrapper)JSON.deserialize(resBody, OrganizationWrapper.class);
		return ((resultWrapper==null || resultWrapper.organization==null) ? null : resultWrapper.organization.id);
    }

	public ZendeskJobStatuses.JobStatus createOrganizations(ZOrganization[] zorgs) {
        if (zorgs == null || zorgs.isEmpty()) { throw new ZendeskException('zorgs parameter must not be null or empty'); }

        HttpRequest req = zapi.createRequest('POST', '/organizations/create_many.json');
        req.setBody('{ "organizations": ' + ZendeskAPI.stripJsonNulls(JSON.serialize(zorgs)) + '}');
		String resBody = zapi.sendRequest(req);

        return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
    }

    public void updateOrganization(Long orgId, ZOrganization zorg) {
        if (orgId == null) { throw new ZendeskException('orgId parameter must not be null'); }
        if (zorg == null) { throw new ZendeskException('zorg parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', '/organizations/' + orgId + '.json');
		req.setBody('{ "organization": ' + ZendeskAPI.stripJsonNulls(JSON.serialize(zorg)) + ' }');
		zapi.sendRequest(req);
    }

	public ZendeskJobStatuses.JobStatus updateOrganizations(ZOrganization[] zorgs) {
		if (zorgs == null || zorgs.isEmpty()) { throw new ZendeskException('zorgs parameter must not be null or empty'); }
		for (ZOrganization zorg : zorgs) {
			if (zorg.id == null && String.isEmpty(zorg.external_id)) { throw new ZendeskException('Each org must have either an id or external_id populated'); }
		}

		HttpRequest req = zapi.createRequest('PUT', '/organizations/update_many.json');
		req.setBody('{ "organizations": ' + ZendeskAPI.stripJsonNulls(JSON.serialize(zorgs)) + ' }');
		String resBody = zapi.sendRequest(req);

		return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
	}

	public ZendeskJobStatuses.JobStatus updateOrganizations(Long[] orgIds, ZOrganization zorg) {
		if (orgIds == null || orgIds.isEmpty()) { throw new ZendeskException('orgIds parameter must not be null or empty'); }
        if (zorg == null) { throw new ZendeskException('zorg parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', '/organizations/update_many.json?ids=' + ZendeskAPI.arrayToCSV(orgIds));
		req.setBody('{ "organization": ' + ZendeskAPI.stripJsonNulls(JSON.serialize(zorg)) + ' }');
		String resBody = zapi.sendRequest(req);

		return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
	}

	public ZendeskJobStatuses.JobStatus updateOrganizations(String[] externalIds, ZOrganization zorg) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter must not be null or empty'); }
		if (zorg == null) { throw new ZendeskException('zorg parameter must not be null'); }

		HttpRequest req = zapi.createRequest('PUT', '/organizations/update_many.json?external_ids=' + ZendeskAPI.arrayToCSV(externalIds));
		req.setBody('{ "organization": ' + ZendeskAPI.stripJsonNulls(JSON.serialize(zorg)) + ' }');
		String resBody = zapi.sendRequest(req);

		return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
	}

	public void deleteOrganization(Long orgId) {
		if (orgId == null) { throw new ZendeskException('orgId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('DELETE', '/organizations/' + orgId + '.json');
		zapi.sendRequest(req);
	}

	public ZendeskJobStatuses.JobStatus deleteOrganizations(Long[] orgIds) {
		if (orgIds == null || orgIds.isEmpty()) { throw new ZendeskException('orgIds parameter must not be null or empty'); }

		HttpRequest req = zapi.createRequest('DELETE', '/organizations/destroy_many.json?ids=' + ZendeskAPI.arrayToCSV(orgIds));
		String resBody = zapi.sendRequest(req);

		return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
	}

	public ZendeskJobStatuses.JobStatus deleteOrganizations(String[] externalIds) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter must not be null or empty'); }

		HttpRequest req = zapi.createRequest('DELETE', '/organizations/destroy_many.json?external_ids=' + ZendeskAPI.arrayToCSV(externalIds));
		String resBody = zapi.sendRequest(req);

		return (ZendeskJobStatuses.JobStatus)JSON.deserialize(resBody, ZendeskJobStatuses.JobStatus.class);
	}

}
