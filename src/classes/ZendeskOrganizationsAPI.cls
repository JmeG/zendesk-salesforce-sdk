// This class provides functionality to call the Zendesk Organizations API
global class ZendeskOrganizationsAPI extends ZendeskResourceBase {

    global class OrganizationWrapper extends ZendeskSideLoadingBase {
        global ZOrganization organization {get;set;}
        global OrganizationWrapper(ZOrganization organization) { this.organization = organization; }
    }

    global class OrganizationsWrapper extends ZendeskPagingBase {
        global List<ZOrganization> organizations {get;set;}
        global OrganizationsWrapper(List<ZOrganization> organizations) { this.organizations = organizations; }
    }

    global ZendeskOrganizationsAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    global OrganizationWrapper getOrganization(Long orgId) {
        return getOrganization(orgId, null);
    }
    global OrganizationWrapper getOrganization(Long orgId, Map<String, Object> queryParams) {
        if (orgId == null) { throw new ZendeskException('orgId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/organizations/'+orgId+'.json', queryParams);
        return (OrganizationWrapper)JSON.deserialize(zconn.sendRequest(req), OrganizationWrapper.class);
    }

    global OrganizationsWrapper getOrganizations() {
        return getOrganizationsHelper(zconn.createRequest('GET', '/organizations.json'));
    }
    global OrganizationsWrapper getOrganizations(Map<String, Object> queryParams) {
        return getOrganizationsHelper(zconn.createRequest('GET', '/organizations.json', queryParams));
    }

    global OrganizationsWrapper getOrganizationsByIds(Set<Long> orgIds) {
        if (orgIds == null || orgIds.isEmpty()) { throw new ZendeskException('orgIds parameter cannot be null or empty'); }

        return getOrganizationsHelper(zconn.createRequest('GET', '/organizations/show_many.json', new Map<String, Object>{'ids'=>toCSV(orgIds)}));
    }

    global OrganizationsWrapper getOrganizationsByExternalIds(Set<String> externalIds) {
        return getOrganizationsByExternalIds(externalIds, null);
    }
    global OrganizationsWrapper getOrganizationsByExternalIds(Set<String> externalIds, Map<String, Object> additionalParams) {
        if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter cannot be null or empty'); }

        if (additionalParams == null) { additionalParams = new Map<String, Object>(); }
        additionalParams.put('external_ids', toCSV(externalIds));
        return getOrganizationsHelper(zconn.createRequest('GET', '/organizations/show_many.json', additionalParams));
    }

    global OrganizationsWrapper autocompleteSearch(String name) {
        return autocompleteSearch(name, null);
    }
    global OrganizationsWrapper autocompleteSearch(String name, Map<String, Object> additionalParams) {
        if (String.isBlank(name) || name.length() < 2) { throw new ZendeskException('name parameter must at least 2 characters'); }

        if (additionalParams == null) { additionalParams = new Map<String, Object>(); }
        additionalParams.put('name', urlEncode(name));
        return getOrganizationsHelper(zconn.createRequest('GET', '/organizations/autocomplete.json', additionalParams));
    }

    global OrganizationsWrapper searchOrganizationsByExternalId(String externalId) {
        return searchOrganizationsByExternalId(externalId, null);
    }
    global OrganizationsWrapper searchOrganizationsByExternalId(String externalId, Map<String, Object> additionalParams) {
        if (String.isBlank(externalId)) { throw new ZendeskException('externalId parameter cannot be null or empty'); }

        if (additionalParams == null) { additionalParams = new Map<String, Object>(); }
        additionalParams.put('external_id', urlEncode(externalId));
        return getOrganizationsHelper(zconn.createRequest('GET', '/organizations/search.json', additionalParams));
    }

    global OrganizationsWrapper getUserOrganizations(Long userId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }

        return getOrganizationsHelper(zconn.createRequest('GET', '/users/'+userId+'/organizations.json'));
    }

    // Helper method for GET Organization's
    private OrganizationsWrapper getOrganizationsHelper(HttpRequest req) {
        return (OrganizationsWrapper)JSON.deserialize(zconn.sendRequest(req), OrganizationsWrapper.class);
    }

    global Map<String, Object> getOrganizationRelatedInfo(Long orgId) {
        if (orgId == null) { throw new ZendeskException('orgId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/organizations/'+orgId+'/related.json');
        return (Map<String, Object>)JSON.deserializeUntyped(zconn.sendRequest(req));
    }

    global Long createOrganization(ZOrganization zorg) {
        if (zorg == null) { throw new ZendeskException('zorg parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('POST', '/organizations.json');
        req.setBody(JSON.serialize(new OrganizationWrapper(zorg), true));
        OrganizationWrapper resultWrapper = (OrganizationWrapper)JSON.deserialize(zconn.sendRequest(req), OrganizationWrapper.class);
        return ((resultWrapper==null || resultWrapper.organization==null) ? null : resultWrapper.organization.id);
    }

    global ZendeskTypes.ZJobStatus createOrganizations(List<ZOrganization> zorgs) {
        if (zorgs == null || zorgs.isEmpty()) { throw new ZendeskException('zorgs parameter cannot be null or empty'); }

        HttpRequest req = zconn.createRequest('POST', '/organizations/create_many.json');
        req.setBody(JSON.serialize(new OrganizationsWrapper(zorgs), true));
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    global void updateOrganization(Long orgId, ZOrganization zorg) {
        if (orgId == null) { throw new ZendeskException('orgId parameter cannot be null'); }
        if (zorg == null) { throw new ZendeskException('zorg parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/organizations/'+orgId+'.json');
        req.setBody(JSON.serialize(new OrganizationWrapper(zorg), true));
        zconn.sendRequest(req);
    }

    global ZendeskTypes.ZJobStatus updateOrganizations(List<ZOrganization> zorgs) {
        if (zorgs == null || zorgs.isEmpty()) { throw new ZendeskException('zorgs parameter cannot be null or empty'); }
        for (ZOrganization zorg : zorgs) {
            if (zorg.id == null && String.isEmpty(zorg.external_id)) { throw new ZendeskException('Each org must have either an id or external_id populated'); }
        }

        HttpRequest req = zconn.createRequest('PUT', '/organizations/update_many.json');
        req.setBody(JSON.serialize(new OrganizationsWrapper(zorgs), true));
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    global ZendeskTypes.ZJobStatus updateOrganizations(Set<Long> orgIds, ZOrganization zorg) {
        if (orgIds == null || orgIds.isEmpty()) { throw new ZendeskException('orgIds parameter cannot be null or empty'); }
        if (zorg == null) { throw new ZendeskException('zorg parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/organizations/update_many.json', new Map<String, Object>{'ids'=>toCSV(orgIds)});
        req.setBody(JSON.serialize(new OrganizationWrapper(zorg), true));
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    global ZendeskTypes.ZJobStatus updateOrganizations(Set<String> externalIds, ZOrganization zorg) {
        if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter cannot be null or empty'); }
        if (zorg == null) { throw new ZendeskException('zorg parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/organizations/update_many.json', new Map<String, Object>{'external_ids'=>toCSV(externalIds)});
        req.setBody(JSON.serialize(new OrganizationWrapper(zorg), true));
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    global void deleteOrganization(Long orgId) {
        if (orgId == null) { throw new ZendeskException('orgId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest('DELETE', '/organizations/'+orgId+'.json'));
    }

    global ZendeskTypes.ZJobStatus deleteOrganizations(Set<Long> orgIds) {
        if (orgIds == null || orgIds.isEmpty()) { throw new ZendeskException('orgIds parameter cannot be null or empty'); }

        HttpRequest req = zconn.createRequest('DELETE', '/organizations/destroy_many.json', new Map<String, Object>{'ids'=>toCSV(orgIds)});
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    global ZendeskTypes.ZJobStatus deleteOrganizations(Set<String> externalIds) {
        if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter cannot be null or empty'); }

        HttpRequest req = zconn.createRequest('DELETE', '/organizations/destroy_many.json', new Map<String, Object>{'external_ids'=>toCSV(externalIds)});
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }
}
