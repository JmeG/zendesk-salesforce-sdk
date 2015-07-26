public abstract class ZendeskTypes {

    public enum TicketType { question, incident, problem, task }
    public enum TicketPriority { low, normal, high, urgent }

    // NOTE: we can't use "new" since it's a reserved keyword
    //public enum TicketStatus { new, open, pending, hold, solved, closed }
    public class TicketStatus {
        public String status {get; private set;}
        public TicketStatus(String status) {
            if (status == 'new' || status == 'open' || status == 'pending'
            || status == 'hold' || status == 'solved' || status == 'closed') {
                this.status = status;
            } else {
                throw new ZendeskException('Invalid Ticket Status "' + status + '"');
            }
        }
    }

    public class ZAttachment {
        public Long id {get; private set;}
        public String name {get;set;}
        public String content_url {get;set;}
        public String content_type {get;set;}
        //public List<Object> thumbnails {get;set;}
        public Long size {get;set;}
    }

    public class ZGroup {
        public Long id {get; private set;}
        public String name {get;set;}
        public Boolean deleted {get; private set;}
        public DateTime created_at {get; private set;}
        public DateTime updated_at {get; private set;}
    }

    public class ZJobStatus {
        public String id {get;set;}
        public String url {get;set;}
        public Integer total {get;set;}
        public Integer progress {get;set;}
        public String status {get;set;}
        public String message {get;set;}
        public List<ZJobStatusResults> results {get;set;}
    }

    public class ZJobStatusResults {
        public Integer id {get;set;}
        public String title {get;set;}
        public String action {get;set;}
        public String errors {get;set;}
        public Boolean success {get;set;}
        public String status {get;set;}
    }

    public class ZOrganizationField extends ZCustomField {}

    public class ZUserField extends ZCustomField {}

    public abstract class ZCustomField {
        public Long id {get; private set;}
        public String key {get;set;}
        public String type {get;set;}
        public String title {get;set;}
        public String raw_title {get;set;}
        public Long position {get;set;}
        public Boolean active {get;set;}
        public String description {get;set;}
        public String raw_description {get;set;}
        //public Boolean x_system {get;set;} // NOTE: "system" is reserved
        //public String regexp_for_validation {get;set;}
        //public String tag {get;set;}
        public List<ZCustomFieldOption> custom_field_options {get;set;}
        public DateTime created_at {get; private set;}
        public DateTime updated_at {get; private set;}

        // Get the picklist "value" matching the provided name
        public String getOptionValue(String optname) {
            return getOptionValue(optname, false);
        }

        public String getOptionValue(String optname, Boolean errorIfNotFound) {
            String val = null;
            if (custom_field_options != null) {
                for (ZCustomFieldOption fo : custom_field_options) {
                    if (fo.name.equalsIgnoreCase(optname)) {
                        val = fo.value;
                        break;
                    }
                }
            }

            if (String.isEmpty(val) && errorIfNotFound) { throw new ZendeskException('Option value "' + optname + '" not found for field "' + this.title + '"'); }
            return val;
        }
    }

    public class ZCustomFieldOption {
        public Long id {get;set;}
        public String name {get;set;}
        public String raw_name {get;set;}
        public String value {get;set;}
    }

    public class ZOrganization {
        public Long id {get;set;}
        public String external_id {get;set;}
        public String name {get;set;}
        public List<String> domain_names {get;set;}
        public String details {get;set;}
        public String notes {get;set;}
        public Long group_id {get;set;}
        public Boolean shared_tickets {get;set;}
        public Boolean shared_comments {get;set;}
        public List<String> tags {get;set;}
        public Map<String, String> organization_fields {get;set;}
        public DateTime created_at {get; private set;}
        public DateTime updated_at {get; private set;}
    }

    public class ZTicketComment {
        public Long id {get; private set;}
        public String type {get;set;}
        public String body {get;set;}
        public String html_body {get;set;}
        public Boolean x_public {get;set;} // Use "x_public" in place of "public" which is a reserved keyword. Requires custom de/serialization.
        public Long author_id {get;set;}
        public List<ZAttachment> attachments {get;set;}
        public ZTicketVia via {get;set;}
        public DateTime created_at {get; private set;}
        public String uploads {get;set;}
    }

    /*
        public class ZTicketComment {
            public String body {get;set;}
            public Boolean x_public {get;set;}  // Use "x_public" in place of "public" which is a reserved keyword. Requires custom de/serialization.
            public String uploads {get;set;}
        }
    */

    // Note that Ticket Field's are different than User and Organization Custom fields
    public class ZTicketField {
        public Long id {get; private set;}
        public String type {get;set;}
        public String title {get;set;}
        public String raw_title {get;set;}
        public Boolean active {get;set;}
        public List<ZCustomFieldOption> custom_field_options {get;set;}
        public DateTime created_at {get; private set;}
        public DateTime updated_at {get; private set;}

        // Get the picklist "value" matching the provided name
        public String getOptionValue(String optname) {
            return getOptionValue(optname, false);
        }

        public String getOptionValue(String optname, Boolean errorIfNotFound) {
            String val = null;
            if (custom_field_options != null) {
                for (ZCustomFieldOption fo : custom_field_options) {
                    if (fo.name.equalsIgnoreCase(optname)) {
                        val = fo.value;
                        break;
                    }
                }
            }

            if (String.isEmpty(val) && errorIfNotFound) { throw new ZendeskException('Option value "' + optname + '" not found for field "' + this.title + '"'); }
            return val;
        }
    }

    public class ZTicketForm {
        public Long id {get; private set;}
        public String name {get;set;}
        public String raw_name {get;set;}
        public String display_name {get;set;}
        public String raw_display_name {get;set;}
        public Boolean active {get;set;}
        public Boolean x_default {get;set;} // Use "x_default" in place of "default" which is a reserved keyword. Requires custom de/serialization.
        public Boolean end_user_visible {get;set;}
        public Long position {get;set;}
        public List<Long> ticket_field_ids {get;set;}
    }

    public class ZTicket {
        public Long id {get;set;}
        public String url {get;set;}
        public String external_id {get;set;}
        public TicketType type {get;set;}
        public String subject {get;set;}
        public TicketPriority priority {get;set;}
        public String status {get;set;}
        public String recipient {get;set;}
        public Long requester_id {get;set;}
        public ZTicketRequester requester {get;set;} // optional when creating a new ticket in place of requester_id
        public Long submitter_id {get;set;}
        public Long assignee_id {get;set;}
        public Long group_id {get;set;}
        public List<Long> collaborator_ids {get;set;}
        public Long forum_topic_id {get;set;}
        public Long problem_id {get;set;}
        public DateTime due_at {get;set;}
        public List<String> tags {get;set;}
        public List<ZTicketCustomField> custom_fields {get;set;}
        public Long ticket_form_id {get;set;}
        public Long brand_id {get;set;}
        public ZTicketComment comment {get;set;} // use for adding the ticket comment
        public String description {get; private set;} // readonly. first comment on ticket
        public Long organization_id {get; private set;}
        public ZTicketVia via {get; private set;}
        public ZTicketSatisfactionRating satisfaction_rating {get; private set;}
        public List<Long> sharing_agreement_ids {get; private set;}
        public List<Long> followup_ids {get; private set;}
        public Boolean has_incidents {get; private set;}
        public DateTime created_at {get; private set;}
        public DateTime updated_at {get; private set;}
    }

    public class ZTicketCustomField {
        public Long id {get;set;}
        public String value {get;set;}

        public ZTicketCustomField() {}
        public ZTicketCustomField(Long id, String value) { this.id = id; this.value = value; }
    }

    public class ZTicketVia {
        public String channel {get;set;}
        //public String source {get;set;}
    }

    public class ZTicketSatisfactionRating {
        public Long id {get;set;}
        public String score {get;set;}
        public String comment {get;set;}
    }

    public class ZTicketRequester {
        public Long locale_id {get;set;}
        public String name {get;set;}
        public String email {get;set;}
    }

    public class ZUser {
        public Long id {get;set;}
        public String name {get;set;}
        public String email {get;set;}
        public String phone {get;set;}
        public String external_id {get;set;}
        public String alias {get;set;}
        public Boolean verified {get;set;}
        public String role {get;set;}
        public Long organization_id {get;set;}
        public Map<String, String> user_fields {get;set;}
        public Boolean active {get; private set;}
        public DateTime last_login_at {get; private set;}
        public DateTime created_at {get; private set;}
        public DateTime updated_at {get; private set;}
    }

    public class ZTag {
        public String name {get;set;}
        public Long count {get;set;}
    }

    public class ZTicketMetrics {
        public Long id {get; private set;}
        public Long ticket_id {get; private set;}
        public DateTime created_at {get; private set;}
        public DateTime updated_at {get; private set;}
        public Integer group_stations {get; private set;}
        public Integer assignee_stations {get; private set;}
        public Integer reopens {get; private set;}
        public Integer replies {get; private set;}
        public DateTime assignee_updated_at {get; private set;}
        public DateTime requester_updated_at {get; private set;}
        public DateTime status_updated_at {get; private set;}
        public DateTime initially_assigned_at {get; private set;}
        public DateTime assigned_at {get; private set;}
        public DateTime solved_at {get; private set;}
        public DateTime latest_comment_added_at {get; private set;}
        public ZTicketMetricsTime reply_time_in_minutes {get; private set;}
        public ZTicketMetricsTime first_resolution_time_in_minutes {get; private set;}
        public ZTicketMetricsTime full_resolution_time_in_minutes {get; private set;}
        public ZTicketMetricsTime agent_wait_time_in_minutes {get; private set;}
        public ZTicketMetricsTime requester_wait_time_in_minutes {get; private set;}
        public ZTicketMetricsTime on_hold_time_in_minutes {get; private set;}
    }

    public class ZTicketMetricsTime {
        public Integer calendar {get; private set;}
        public Integer business {get; private set;}
    }

    public class ZSearchResult {
        public Long id {get; private set;}
        public String name {get; private set;}
		public DateTime created_at {get; private set;}
		public DateTime updated_at {get; private set;}
		public String result_type {get; private set;}
		public String url {get; private set;}
    }
}
