// This class provides side-loading support for certain get requests to the Zendesk API
public abstract class ZendeskSideLoadingBase {

    // Sideloadable fields; users, groups, organizations, last_audits, metric_sets, sharing_agreements, incident_counts, ticket_forms

    public List<ZendeskUsersAPI.ZUser> users {get; private set;}
    public List<ZendeskGroupsAPI.ZGroup> groups {get; private set;}
    public List<ZendeskOrganizationsAPI.ZOrganization> organizations {get; private set;}
}