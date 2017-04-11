global abstract class ZendeskTypes {

  //global abstract class BaseType {
  //    global Long id {get;set;}
  //    global String url {get;set;}
  //    global DateTime created_at {get; private set;}
  //    global DateTime updated_at {get; private set;}
  //}

    global enum TicketType { question, incident, problem, task }
    global enum TicketPriority { low, normal, high, urgent }

    // NOTE: we can't use "new" since it's a reserved keyword
    //global enum TicketStatus { new, open, pending, hold, solved, closed }
    global class TicketStatus {
        global String status {get; private set;}
        global TicketStatus(String status) {
            if (status == 'new' || status == 'open' || status == 'pending'
            || status == 'hold' || status == 'solved' || status == 'closed') {
                this.status = status;
            } else {
                throw new ZendeskException('Invalid Ticket Status "' + status + '"');
            }
        }
    }

    global class ZAttachment {
        global Long id {get; private set;}
        global String name {get;set;}
        global String content_url {get;set;}
        global String content_type {get;set;}
        //global List<Object> thumbnails {get;set;}
        global Long size {get;set;}
    }

    global class ZGroup {
        global Long id {get; private set;}
        global String name {get;set;}
        global Boolean deleted {get; private set;}
        global DateTime created_at {get; private set;}
        global DateTime updated_at {get; private set;}
    }

    global class ZGroupMembership {
        global Long id {get; private set;}
        global Long user_id {get;set;}
        global Long group_id {get;set;}
        global Boolean x_default {get; private set;}
    }

    global class ZJobStatus {
        global String id {get;set;}
        global String url {get;set;}
        global Integer total {get;set;}
        global Integer progress {get;set;}
        global String status {get;set;}
        global String message {get;set;}
        global List<ZJobStatusResults> results {get;set;}

        // Using a custom parser because the response isn't consistent.
        // Sometimes results.details is a single string, sometimes it's an array of strings
        global ZJobStatus(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        }
                        else if (text == 'url') {
                            url = parser.getText();
                        }
                        else if (text == 'total') {
                            total = parser.getIntegerValue();
                        }
                        else if (text == 'progress') {
                            progress = parser.getIntegerValue();
                        }
                        else if (text == 'status') {
                            status = parser.getText();
                        }
                        else if (text == 'message') {
                            message = parser.getText();
                        }
                        else if (text == 'results') {
                            results = new List<ZJobStatusResults>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                results.add(new ZJobStatusResults(parser));
                            }
                        }
                        else {
                            System.debug(LoggingLevel.WARN, 'job_status consuming unrecognized property: '+ text);
                        }
                    }
                }
            }
        }
    }

    global class ZJobStatusResults {
        global Integer index {get;set;}
        global String error {get;set;}
        global String errors {get;set;}
        global String title {get;set;}
        global String action {get;set;}
        global String external_id {get;set;}
        global String status {get;set;}
        global List<String> details {get;set;}
        global Long id {get;set;}
        global Boolean success {set;get;}

        // Using a custom parser because the response isn't consistent
        // Sometimes results.details is a single string, sometimes it's an array of strings
        global ZJobStatusResults(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'index') {
                            index = parser.getIntegerValue();
                        }
                        else if (text == 'title') {
                            title = parser.getText();
                        }
                        else if (text == 'action') {
                            action = parser.getText();
                        }
                        else if (text == 'success') {
                            success = parser.getBooleanValue();
                        }
                        else if (text == 'status') {
                            status = parser.getText();
                        }
                        else if (text == 'error' || text == 'errors') {
                            error = parser.getText();
                            errors = parser.getText();
                        }
                        else if (text == 'external_id') {
                            external_id = parser.getText();
                        }
                        else if (text == 'id') {
                            id = parser.getIntegerValue();
                        }
                        else if (text == 'details') {
                            details = new List<String>();

                            // If we're in a start array "[" then loop through the values until we reach the end "]"
                            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                                // do this if array of strings
                                while (parser.nextToken() != JSONToken.END_ARRAY) {
                                    details.add(parser.getText());
                                }
                            } else {
                                // do this if single string
                                details.add(parser.getText());
                            }
                        }
                        else {
                            System.debug(LoggingLevel.WARN, 'Results consuming unrecognized property: ' + text);
                        }
                    }
                }
            }
        }
    }

    global class ZOrganizationField extends ZCustomField {}

    global class ZUserField extends ZCustomField {}

    global abstract class ZCustomField {
        global Long id {get; private set;}
        global String key {get;set;}
        global String type {get;set;} // "checkbox", "date", "decimal", "dropdown", "integer", "regexp", "text", or "textarea"
        global String title {get;set;}
        global String raw_title {get;set;}
        global Long position {get;set;}
        global Boolean active {get;set;}
        global String description {get;set;}
        global String raw_description {get;set;}
        global Boolean x_system {get;set;} // NOTE: "system" is reserved
        global String regexp_for_validation {get;set;}
        global String tag {get;set;}
        global List<ZCustomFieldOption> custom_field_options {get;set;}
        global DateTime created_at {get; private set;}
        global DateTime updated_at {get; private set;}

        // Get the picklist "value" matching the provided name
        global String getOptionValue(String optname) {
            return getOptionValue(optname, false);
        }

        global String getOptionValue(String optname, Boolean errorIfNotFound) {
            String val = null;
            if (custom_field_options != null) {
                for (ZCustomFieldOption fo : custom_field_options) {
                    if (fo.name.equalsIgnoreCase(optname)) {
                        val = fo.value;
                        break;
                    }
                }
            }

            if (String.isEmpty(val) && errorIfNotFound) {
                throw new ZendeskException('Option value "' + optname + '" not found for field "' + this.title + '"');
            }
            return val;
        }
    }

    global class ZCustomFieldOption {
        global Long id {get;set;}
        global String name {get;set;}
        global String raw_name {get;set;}
        global String value {get;set;}
    }

    global class ZSystemFieldOption {
        global String name {get;set;}
        global String value {get;set;}
    }

    global class ZOrganization {
        global Long id {get;set;}
        global String external_id {get;set;}
        global String name {get;set;}
        global List<String> domain_names {get;set;}
        global String details {get;set;}
        global String notes {get;set;}
        global Long group_id {get;set;}
        global Boolean shared_tickets {get;set;}
        global Boolean shared_comments {get;set;}
        global List<String> tags {get;set;}
        global Map<String, String> organization_fields {get;set;}
        global DateTime created_at {get; private set;}
        global DateTime updated_at {get; private set;}
    }

    global class ZOrganizationMembership {
        global Long id {get; private set;}
        global Long user_id {get;set;}
        global Long organization_id {get;set;}
        global Boolean x_default {get; private set;}
    }

    global class ZTicketComment {
        global Long id {get; private set;}
        global String type {get;set;}
        global String body {get;set;}
        global String html_body {get;set;}
        global Boolean x_public {get;set;} // Use "x_public" in place of "public" which is a reserved keyword. Requires custom de/serialization.
        global Long author_id {get;set;}
        global List<ZAttachment> attachments {get;set;}
        global ZTicketVia via {get;set;}
        global DateTime created_at {get; private set;}
        global String uploads {get;set;}
    }

    // Note that Ticket Field's are different than User and Organization Custom fields
    global class ZTicketField {
        global Long id {get; private set;}
        global String type {get;set;}
        global String description {get;set;}
        global String raw_description {get;set;}
        global String title {get;set;}
        global String raw_title {get;set;}
        global String title_in_portal {get;set;}
        global String raw_title_in_portal {get;set;}
        global String regexp_for_validation {get;set;}
        global String tag {get;set;}
        global Integer position {get;set;} // NOTE: this is stuck as a "integer" since it's part of managed package
        global Boolean active {get;set;}
        global Boolean required {get;set;}
        global Boolean collapsed_for_agents {get;set;}
        global Boolean visible_in_portal {get;set;}
        global Boolean editable_in_portal {get;set;}
        global Boolean required_in_portal {get;set;}
        global Boolean removable {get; private set;}
        global List<ZCustomFieldOption> custom_field_options {get;set;}
        global List<ZSystemFieldOption> system_field_options {get;set;}
        global DateTime created_at {get; private set;}
        global DateTime updated_at {get; private set;}

        // Get the picklist "value" matching the provided name
        global String getOptionValue(String optname) {
            return getOptionValue(optname, false);
        }
        global String getOptionValue(String optname, Boolean errorIfNotFound) {
            String val = null;
            if (custom_field_options != null) {
                for (ZCustomFieldOption fo : custom_field_options) {
                    if (fo.name.equalsIgnoreCase(optname)) {
                        val = fo.value;
                        break;
                    }
                }
            }

            if (String.isEmpty(val) && errorIfNotFound) {
                throw new ZendeskException('Option value "' + optname + '" not found for field "' + this.title + '"');
            }

            return val;
        }

        // Get the picklist "value" matching the provided name
        global String getSystemFieldOptionValue(String optname) {
            return getSystemFieldOptionValue(optname, false);
        }
        global String getSystemFieldOptionValue(String optname, Boolean errorIfNotFound) {
            String val = null;
            if (system_field_options != null) {
                for (ZSystemFieldOption fo : system_field_options) {
                    if (fo.name.equalsIgnoreCase(optname)) {
                        val = fo.value;
                        break;
                    }
                }
            }

            if (String.isEmpty(val) && errorIfNotFound) {
                throw new ZendeskException('Option value "' + optname + '" not found for field "' + this.title + '"');
            }

            return val;
        }
    }

    global class ZTicketForm {
        global Long id {get; private set;}
        global String name {get;set;}
        global String raw_name {get;set;}
        global String display_name {get;set;}
        global String raw_display_name {get;set;}
        global Boolean active {get;set;}
        global Boolean x_default {get;set;} // Use "x_default" in place of "default" which is a reserved keyword. Requires custom de/serialization.
        global Boolean end_user_visible {get;set;}
        global Long position {get;set;}
        global List<Long> ticket_field_ids {get;set;}
    }

    global class ZTicket {
        global Long id {get;set;}
        global String url {get;set;}
        global String external_id {get;set;}
        global TicketType type {get;set;}
        global String subject {get;set;}
        global TicketPriority priority {get;set;}
        global String status {get;set;}
        global String recipient {get;set;}
        global Long requester_id {get;set;}
        global ZTicketRequester requester {get;set;} // optional when creating a new ticket in place of requester_id
        global Long submitter_id {get;set;}
        global Long assignee_id {get;set;}
        global Long group_id {get;set;}
        global List<Long> collaborator_ids {get;set;}
        global Long forum_topic_id {get;set;}
        global Long problem_id {get;set;}
        global DateTime due_at {get;set;}
        global List<String> tags {get;set;}
        global List<ZTicketCustomField> custom_fields {get;set;}
        global Long ticket_form_id {get;set;}
        global Long brand_id {get;set;}
        global ZTicketComment comment {get;set;} // use for adding the ticket comment
        global String description {get; private set;} // readonly. first comment on ticket
        global Long organization_id {get; private set;}
        global ZTicketVia via {get; private set;}
        global ZTicketSatisfactionRating satisfaction_rating {get; private set;}
        global List<Long> sharing_agreement_ids {get; private set;}
        global List<Long> followup_ids {get; private set;}
        global Boolean has_incidents {get; private set;}
        global DateTime created_at {get; private set;}
        global DateTime updated_at {get; private set;}
    }

    global class ZTicketCustomField {
        global Long id {get;set;}
        global String value {get;set;}

        global ZTicketCustomField() {}
        global ZTicketCustomField(Long id, String value) { this.id = id; this.value = value; }
    }

    global class ZTicketVia {
        global String channel {get;set;}
        //global String source {get;set;}
    }

    global class ZTicketSatisfactionRating {
        global Long id {get;set;}
        global String score {get;set;}
        global String comment {get;set;}
    }

    global class ZTicketRequester {
        global Long locale_id {get;set;}
        global String name {get;set;}
        global String email {get;set;}
    }

    global class ZUser {
        global Long id {get;set;}
        global String name {get;set;}
        global String email {get;set;}
        global String phone {get;set;}
        global String external_id {get;set;}
        global String alias {get;set;}
        global Boolean verified {get;set;}
        global Boolean moderator {get;set;}
        global Boolean only_private_comments {get;set;}
        global Boolean restricted_agent {get;set;}
        global Boolean suspended {get;set;}
        global Boolean chat_only {get;set;}
        global Boolean shared {get;set;}
        global Boolean shared_agent {get;set;}
        global String role {get;set;}
        global String signature {get;set;}
        global String details {get;set;}
        global String notes {get;set;}
        global String time_zone {get;set;}
        global String locale {get;set;}
        global Long organization_id {get;set;}
        global List<String> tags {get;set;}
        global Map<String, String> user_fields {get;set;}
        global Boolean active {get; private set;}
        global DateTime last_login_at {get; private set;}
        global DateTime created_at {get; private set;}
        global DateTime updated_at {get; private set;}
    }

    global class ZTag {
        global String name {get;set;}
        global Long count {get;set;}
    }

    global class ZTicketMetrics {
        global Long id {get; private set;}
        global Long ticket_id {get; private set;}
        global DateTime created_at {get; private set;}
        global DateTime updated_at {get; private set;}
        global Integer group_stations {get; private set;}
        global Integer assignee_stations {get; private set;}
        global Integer reopens {get; private set;}
        global Integer replies {get; private set;}
        global DateTime assignee_updated_at {get; private set;}
        global DateTime requester_updated_at {get; private set;}
        global DateTime status_updated_at {get; private set;}
        global DateTime initially_assigned_at {get; private set;}
        global DateTime assigned_at {get; private set;}
        global DateTime solved_at {get; private set;}
        global DateTime latest_comment_added_at {get; private set;}
        global ZTicketMetricsTime reply_time_in_minutes {get; private set;}
        global ZTicketMetricsTime first_resolution_time_in_minutes {get; private set;}
        global ZTicketMetricsTime full_resolution_time_in_minutes {get; private set;}
        global ZTicketMetricsTime agent_wait_time_in_minutes {get; private set;}
        global ZTicketMetricsTime requester_wait_time_in_minutes {get; private set;}
        global ZTicketMetricsTime on_hold_time_in_minutes {get; private set;}
    }

    global class ZTicketMetricsTime {
        global Integer calendar {get; private set;}
        global Integer business {get; private set;}
    }

    global class ZSearchResult {
        global Long id {get; private set;}
        global String name {get; private set;}
        global DateTime created_at {get; private set;}
        global DateTime updated_at {get; private set;}
        global String result_type {get; private set;}
        global String url {get; private set;}
    }

    global class ZTopic {
        global Long id {get; private set;}
        global String title {get;set;}
        global String body {get;set;}
        global String topic_type {get;set;}
        global Long submitter_id {get;set;}
        global Long updater_id {get;set;}
        global Long forum_id {get;set;}
        global Boolean locked {get;set;}
        global Boolean pinned {get;set;}
        global Boolean highlighted {get;set;}
        global List<String> tags {get;set;}
        //global List<ZAttachment> attachments {get;set;}
        global Long comments_count {get;set;}
        global DateTime created_at {get; private set;}
        global DateTime updated_at {get; private set;}
        global List<String> search_phrases {get;set;}
    }

    global class ZSatisfactionRating {
        global Long id {get; private set;}
        global Long assignee_id {get; private set;}
        global Long group_id {get; private set;}
        global Long requester_id {get; private set;}
        global Long ticket_id {get; private set;}
        global String score {get;set;}
        global String comment {get;set;}
        global DateTime updated_at {get; private set;}
        global DateTime created_at {get; private set;}
    }

    global class ZSession {
        global Long id {get; private set;}
        global Long user_id {get; private set;}
        global DateTime authenticated_at {get; private set;}
        global DateTime last_seen_at {get; private set;}
    }
}
