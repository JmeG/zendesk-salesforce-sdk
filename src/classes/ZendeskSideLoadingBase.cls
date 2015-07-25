// This class provides side-loading support for certain get requests to the Zendesk API
public abstract class ZendeskSideLoadingBase extends ZendeskTypes {

    // Sideloadable fields; users, groups, organizations, last_audits, metric_sets, sharing_agreements, incident_counts, ticket_forms

    public List<ZUser> users {get; private set;}
    public List<ZGroup> groups {get; private set;}
    public List<ZOrganization> organizations {get; private set;}
}
