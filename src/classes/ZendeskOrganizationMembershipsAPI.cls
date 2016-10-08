// This class provides functionality to call the Zendesk Organization Memberships API
global class ZendeskOrganizationMembershipsAPI extends ZendeskResourceBase {

    global class OrganizationMembershipWrapper extends ZendeskSideLoadingBase {
        global ZOrganizationMembership organization_membership {get;set;}
        global OrganizationMembershipWrapper(ZOrganizationMembership organizationMembership) { this.organization_membership = organization_membership; }
    }

    global class OrganizationMembershipsWrapper extends ZendeskPagingBase {
        global List<ZOrganizationMembership> organization_memberships {get;set;}
        global OrganizationMembershipsWrapper(List<ZOrganizationMembership> organizationMemberships) { this.organization_memberships = organizationMemberships; }
    }

    global ZendeskOrganizationMembershipsAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    // GET /api/v2/organization_memberships/{id}.json
    global OrganizationMembershipWrapper getMembership(Long membershipId) {
        if (membershipId == null) { throw new ZendeskException('membershipId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/organization_memberships/'+membershipId+'.json');
        return (OrganizationMembershipWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), OrganizationMembershipWrapper.class);
    }

    // GET /api/v2/users/{user_id}/organization_memberships/{id}.json
    global OrganizationMembershipWrapper getMembership(Long userId, Long membershipId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }
        if (membershipId == null) { throw new ZendeskException('membershipId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/users/'+userId+'/organization_memberships/'+membershipId+'.json');
        return (OrganizationMembershipWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), OrganizationMembershipWrapper.class);
    }

    // GET /api/v2/organization_memberships.json
    global OrganizationMembershipsWrapper getMemberships() {
        return getMemberships(null);
    }
    global OrganizationMembershipsWrapper getMemberships(Map<String, Object> queryParams) {
        return getMembershipsInternal(zconn.createRequest('GET', '/organization_memberships.json', queryParams));
    }

    // GET /api/v2/users/{user_id}/organization_memberships.json
    global OrganizationMembershipsWrapper getMembershipsByUser(Long userId) {
        return getMembershipsByUser(userId, null);
    }
    global OrganizationMembershipsWrapper getMembershipsByUser(Long userId, Map<String, Object> queryParams) {
        return getMembershipsInternal(zconn.createRequest('GET', '/users/'+userId+'/organization_memberships.json', queryParams));
    }

    // GET /api/v2/organizations/{organization_id}/memberships.json
    global OrganizationMembershipsWrapper getMembershipsByOrganization(Long organizationId) {
        return getMembershipsByOrganization(organizationId, null);
    }
    global OrganizationMembershipsWrapper getMembershipsByOrganization(Long organizationId, Map<String, Object> queryParams) {
        return getMembershipsInternal(zconn.createRequest('GET', '/organizations/'+organizationId+'/memberships.json', queryParams));
    }

    // GET /api/v2/organization_memberships/assignable.json
    global OrganizationMembershipsWrapper getAssignableMemberships() {
        return getAssignableMemberships(null);
    }
    global OrganizationMembershipsWrapper getAssignableMemberships(Map<String, Object> queryParams) {
        return getMembershipsInternal(zconn.createRequest('GET', '/organization_memberships/assignable.json', queryParams));
    }

    // GET /api/v2/organizations/{organization_id}/memberships/assignable.json
    global OrganizationMembershipsWrapper getAssignableMembershipsByOrganization(Long organizationId) {
        return getAssignableMembershipsByOrganization(organizationId, null);
    }
    global OrganizationMembershipsWrapper getAssignableMembershipsByOrganization(Long organizationId, Map<String, Object> queryParams) {
        return getMembershipsInternal(zconn.createRequest('GET', '/organizations/'+organizationId+'/memberships/assignable.json', queryParams));
    }

    // Private helper method to retrieve multiple organization memberships
    private OrganizationMembershipsWrapper getMembershipsInternal(HttpRequest req) {
        return (OrganizationMembershipsWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), OrganizationMembershipsWrapper.class);
    }

    // POST /api/v2/users/{user_id}/organization_memberships.json
    global Long createMembership(Long userId, Long organizationId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }
        if (organizationId == null) { throw new ZendeskException('organizationId parameter cannot be null'); }

        ZOrganizationMembership gm = new ZOrganizationMembership();
        gm.user_id = userId;
        gm.organization_id = organizationId;

        HttpRequest req = zconn.createRequest('POST', '/users/'+userId+'/organization_memberships.json');
        req.setBody(unreplaceReservedWords(JSON.serialize(new OrganizationMembershipWrapper(gm), true)));
        OrganizationMembershipWrapper resultWrapper = (OrganizationMembershipWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), OrganizationMembershipWrapper.class);
        return ((resultWrapper==null || resultWrapper.organization_membership == null) ? null : resultWrapper.organization_membership.id);
    }

    global Long createMembership(ZOrganizationMembership organizationMembership) {
        if (organizationMembership == null) { throw new ZendeskException('organizationMembership parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('POST', '/organization_memberships.json');
        req.setBody(unreplaceReservedWords(JSON.serialize(new OrganizationMembershipWrapper(organizationMembership), true)));
        OrganizationMembershipWrapper resultWrapper = (OrganizationMembershipWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), OrganizationMembershipWrapper.class);
        return ((resultWrapper==null || resultWrapper.organization_membership == null) ? null : resultWrapper.organization_membership.id);
    }

    // PUT /api/v2/users/{user_id}/organization_memberships/{id}/make_default.json
    global void makeDefault(Long userId, Long membershipId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }
        if (membershipId == null) { throw new ZendeskException('membershipId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/users/'+userId+'/organization_memberships/'+membershipId+'/make_default.json', '{}');
        zconn.sendRequest(req);
    }

    // DELETE /api/v2/users/{user_id}/organization_memberships/{id}.json
    global void deleteMembership(Long userId, Long membershipId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }
        if (membershipId == null) { throw new ZendeskException('membershipId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest('DELETE', '/users/'+userId+'/organization_memberships/'+membershipId+'.json'));
    }

    // DELETE /api/v2/organization_memberships/{id}.json
    global void deleteMembership(Long membershipId) {
        if (membershipId == null) { throw new ZendeskException('membershipId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest('DELETE', '/organization_memberships/'+membershipId+'.json'));
    }

    // POST /api/v2/organization_memberships/create_many.json
    global ZJobStatus createMemberships(List<ZOrganizationMembership> memberships) {
        if (memberships == null || memberships.isEmpty()) { throw new ZendeskException('memberships parameter cannot be null or empty'); }

        HttpRequest req = zconn.createRequest('POST', '/organization_memberships/create_many.json');
        req.setBody(JSON.serialize(new OrganizationMembershipsWrapper(memberships), true));
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    // DELETE /api/v2/organization_memberships/destroy_many.json?ids={ids}
    global ZJobStatus deleteMemberships(Set<Long> membershipIds) {
        if (membershipIds == null || membershipIds.isEmpty()) { throw new ZendeskException('membershipIds parameter cannot be null or empty'); }

        HttpRequest req = zconn.createRequest('DELETE', '/organization_memberships/destroy_many.json', new Map<String, Object>{'ids'=>toCSV(membershipIds)});
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    // replace reserved keywords in the JSON string and map them to field names prefixed with "x_"
    // Use when calling deserialize()
    private String replaceReservedWords(String str) {
        str = str.replaceAll('"default"\\s*:', '"x_default":');
        return str;
    }

    // un-replace reserved keywords in the JSON string
    // Use when calling serialize()
    private String unreplaceReservedWords(String str) {
        str = str.replaceAll('"x_default"\\s*:', '"default":');
        return str;
    }
}
