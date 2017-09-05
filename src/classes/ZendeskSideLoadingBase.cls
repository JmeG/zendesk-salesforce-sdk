// This class provides side-loading support for certain get requests to the Zendesk API
global abstract class ZendeskSideLoadingBase extends ZendeskTypes {

    // Tickets => users, groups, organizations, last_audits, metric_sets, sharing_agreements, incident_counts, ticket_forms
    // Audits => users, organizations, groups, tickets
    // Users => organizations, abilities, roles, identities, groups
    // Groups => users
    // Group Memberships => users, groups
    // Organizations => abilities
    // Topics => users, forums
    // Topic Comments => users
    // Requests => users, organizations

    global List<ZUser> users {get; protected set;}
    global List<ZGroup> groups {get; protected set;}
    global List<ZOrganization> organizations {get; protected set;}
    global List<ZTicketMetrics> metric_sets {get; protected set;}
    global List<ZTicketForm> ticket_forms {get; protected set;}
    global List<ZTicket> tickets {get; protected set;}
}
