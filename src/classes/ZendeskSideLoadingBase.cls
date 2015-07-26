// This class provides side-loading support for certain get requests to the Zendesk API
public abstract class ZendeskSideLoadingBase extends ZendeskTypes {

    // Tickets => users, groups, organizations, last_audits, metric_sets, sharing_agreements, incident_counts, ticket_forms
    // Audits => users, organizations, groups, tickets
    // Users => organizations, abilities, roles, identities, groups
    // Groups => users
    // Group Memberships => users, groups
    // Organizations => abilities
    // Topics => users, forums
    // Topic Comments => users
    // Requests => users, organizations

    public List<ZUser> users {get; private set;}
    public List<ZGroup> groups {get; private set;}
    public List<ZOrganization> organizations {get; private set;}
    public List<ZTicketMetrics> metric_sets {get; private set;}
    public List<ZTicketForm> ticket_forms {get; private set;}
    public List<ZTicket> tickets {get; private set;}
}
