// This class provides functionality to call the Zendesk Organizations API
public class ZendeskOrganizationsAPI extends ZendeskResourceBase {

	public class OrganizationWrapper extends ZendeskSideLoadingBase {
		public ZOrganization organization {get;set;}
		public OrganizationWrapper(ZOrganization organization) { this.organization = organization; }
	}

	public class OrganizationsWrapper extends ZendeskPagingBase {
		public List<ZOrganization> organizations {get;set;}
		public OrganizationsWrapper(List<ZOrganization> organizations) { this.organizations = organizations; }
	}

	public ZendeskOrganizationsAPI(ZendeskConnection zconn) {
		super(zconn);
	}

	public OrganizationWrapper getOrganization(Long orgId) {
		return getOrganization(orgId, null);
    }
	public OrganizationWrapper getOrganization(Long orgId, Map<String, Object> queryParams) {
		if (orgId == null) { throw new ZendeskException('orgId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/organizations/'+orgId+'.json', queryParams);
        return (OrganizationWrapper)JSON.deserialize(zconn.sendRequest(req), OrganizationWrapper.class);
    }

	public OrganizationsWrapper getOrganizations() {
        return getOrganizationsHelper(zconn.createRequest('GET', '/organizations.json'));
    }
    public OrganizationsWrapper getOrganizations(Map<String, Object> queryParams) {
        return getOrganizationsHelper(zconn.createRequest('GET', '/organizations.json', queryParams));
    }

	public OrganizationsWrapper getOrganizationsByIds(Set<Long> orgIds) {
		if (orgIds == null || orgIds.isEmpty()) { throw new ZendeskException('orgIds parameter cannot be null or empty'); }

        return getOrganizationsHelper(zconn.createRequest('GET', '/organizations/show_many.json', new Map<String, Object>{'ids'=>toCSV(orgIds)}));
    }

	public OrganizationsWrapper getOrganizationsByExternalIds(Set<String> externalIds) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter cannot be null or empty'); }

        return getOrganizationsHelper(zconn.createRequest('GET', '/organizations/show_many.json', new Map<String, Object>{'external_ids'=>toCSV(externalIds)}));
    }

	public OrganizationsWrapper autocompleteSearch(String name) {
		return autocompleteSearch(name, null);
	}
	public OrganizationsWrapper autocompleteSearch(String name, Map<String, Object> additionalParams) {
		if (String.isBlank(name) || name.length() < 2) { throw new ZendeskException('name parameter must at least 2 characters'); }

		if (additionalParams == null) { additionalParams = new Map<String, Object>(); }
		additionalParams.put('name', urlEncode(name));
        return getOrganizationsHelper(zconn.createRequest('GET', '/organizations/autocomplete.json', additionalParams));
    }

	public OrganizationsWrapper searchOrganizationsByExternalId(String externalId) {
		if (String.isBlank(externalId)) { throw new ZendeskException('externalId parameter cannot be null or empty'); }

        return getOrganizationsHelper(zconn.createRequest('GET', '/organizations/search.json', new Map<String, Object>{'external_id'=>urlEncode(externalId)}));
    }

	public OrganizationsWrapper getUserOrganizations(Long userId) {
		if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }

        return getOrganizationsHelper(zconn.createRequest('GET', '/users/'+userId+'/organizations.json'));
    }

	// Helper method for GET Organization's
	private OrganizationsWrapper getOrganizationsHelper(HttpRequest req) {
        return (OrganizationsWrapper)JSON.deserialize(zconn.sendRequest(req), OrganizationsWrapper.class);
    }

	public Map<String, Object> getOrganizationRelatedInfo(Long orgId) {
		if (orgId == null) { throw new ZendeskException('orgId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/organizations/'+orgId+'/related.json');
		return (Map<String, Object>)JSON.deserializeUntyped(zconn.sendRequest(req));
	}

	public Long createOrganization(ZOrganization zorg) {
        if (zorg == null) { throw new ZendeskException('zorg parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('POST', '/organizations.json');
        req.setBody(stripJsonNulls(JSON.serialize(new OrganizationWrapper(zorg))));
        OrganizationWrapper resultWrapper = (OrganizationWrapper)JSON.deserialize(zconn.sendRequest(req), OrganizationWrapper.class);
		return ((resultWrapper==null || resultWrapper.organization==null) ? null : resultWrapper.organization.id);
    }

	public ZendeskTypes.ZJobStatus createOrganizations(List<ZOrganization> zorgs) {
        if (zorgs == null || zorgs.isEmpty()) { throw new ZendeskException('zorgs parameter cannot be null or empty'); }

        HttpRequest req = zconn.createRequest('POST', '/organizations/create_many.json');
        req.setBody(stripJsonNulls(JSON.serialize(new OrganizationsWrapper(zorgs))));
        return (ZendeskTypes.ZJobStatus)JSON.deserialize(zconn.sendRequest(req), ZendeskTypes.ZJobStatus.class);
    }

    public void updateOrganization(Long orgId, ZOrganization zorg) {
        if (orgId == null) { throw new ZendeskException('orgId parameter cannot be null'); }
        if (zorg == null) { throw new ZendeskException('zorg parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/organizations/'+orgId+'.json');
		req.setBody(stripJsonNulls(JSON.serialize(new OrganizationWrapper(zorg))));
		zconn.sendRequest(req);
    }

	public ZendeskTypes.ZJobStatus updateOrganizations(List<ZOrganization> zorgs) {
		if (zorgs == null || zorgs.isEmpty()) { throw new ZendeskException('zorgs parameter cannot be null or empty'); }
		for (ZOrganization zorg : zorgs) {
			if (zorg.id == null && String.isEmpty(zorg.external_id)) { throw new ZendeskException('Each org must have either an id or external_id populated'); }
		}

		HttpRequest req = zconn.createRequest('PUT', '/organizations/update_many.json');
		req.setBody(stripJsonNulls(JSON.serialize(new OrganizationsWrapper(zorgs))));
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zconn.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public ZendeskTypes.ZJobStatus updateOrganizations(Set<Long> orgIds, ZOrganization zorg) {
		if (orgIds == null || orgIds.isEmpty()) { throw new ZendeskException('orgIds parameter cannot be null or empty'); }
        if (zorg == null) { throw new ZendeskException('zorg parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/organizations/update_many.json', new Map<String, Object>{'ids'=>toCSV(orgIds)});
		req.setBody(stripJsonNulls(JSON.serialize(new OrganizationWrapper(zorg))));
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zconn.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public ZendeskTypes.ZJobStatus updateOrganizations(Set<String> externalIds, ZOrganization zorg) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter cannot be null or empty'); }
		if (zorg == null) { throw new ZendeskException('zorg parameter cannot be null'); }

		HttpRequest req = zconn.createRequest('PUT', '/organizations/update_many.json', new Map<String, Object>{'external_ids'=>toCSV(externalIds)});
		req.setBody(stripJsonNulls(JSON.serialize(new OrganizationWrapper(zorg))));
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zconn.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public void deleteOrganization(Long orgId) {
		if (orgId == null) { throw new ZendeskException('orgId parameter cannot be null'); }

		zconn.sendRequest(zconn.createRequest('DELETE', '/organizations/'+orgId+'.json'));
	}

	public ZendeskTypes.ZJobStatus deleteOrganizations(Set<Long> orgIds) {
		if (orgIds == null || orgIds.isEmpty()) { throw new ZendeskException('orgIds parameter cannot be null or empty'); }

		HttpRequest req = zconn.createRequest('DELETE', '/organizations/destroy_many.json', new Map<String, Object>{'ids'=>toCSV(orgIds)});
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zconn.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public ZendeskTypes.ZJobStatus deleteOrganizations(Set<String> externalIds) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter cannot be null or empty'); }

		HttpRequest req = zconn.createRequest('DELETE', '/organizations/destroy_many.json', new Map<String, Object>{'external_ids'=>toCSV(externalIds)});
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zconn.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}
}
