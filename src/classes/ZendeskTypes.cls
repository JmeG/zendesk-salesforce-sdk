// NOTE: I use  {get;set;} on the class attributes like "global String name {get;set;}"
// rather than just "global String name;" because you can't access those fields from within
// Visualforce without the {get;set;}. It's not important for deserialization but it's
// convienient in the Visualforce use case.
// NOTE: Any fields below prefixed with an "x_" is due to those fields being reserved words
// in Salesforce so we need to add custom serialization/deserialization logic around them.
global abstract class ZendeskTypes {

  //global abstract class BaseType {
  //    global Long id {get;set;}
  //    global String url {get;set;}
  //    global DateTime created_at {get; protected set;}
  //    global DateTime updated_at {get; protected set;}
  //}

    global enum TicketType { question, incident, problem, task }
    global enum TicketPriority { low, normal, high, urgent }

    private static TicketPriority getTicketPriority(String strval) {
        TicketPriority enumval;
        for (TicketPriority tp : TicketPriority.values()) {
            if (tp.name() == strval) {
                enumval = tp;
                break;
            }
        }
        return enumval;
    }

    private static TicketType getTicketType(String strval) {
        TicketType enumval;
        for (TicketType tp : TicketType.values()) {
            if (tp.name() == strval) {
                enumval = tp;
                break;
            }
        }
        return enumval;
    }

    // NOTE: we can't use "new" as an enum because it's a reserved keyword
    //global enum TicketStatus { new, open, pending, hold, solved, closed }
    global class TicketStatus {
        global String status {get; protected set;}
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
        global Long id {get; protected set;}
        global String name {get;set;}
        global String content_url {get;set;}
        global String content_type {get;set;}
        //global List<Object> thumbnails {get;set;}
        global Long size {get;set;}
    }

    global class ZGroup {
        global Long id {get; protected set;}
        global String name {get;set;}
        global Boolean deleted {get; protected set;}
        global DateTime created_at {get; protected set;}
        global DateTime updated_at {get; protected set;}
    }

    global class ZGroupMembership {
        global Long id {get; protected set;}
        global Long user_id {get;set;}
        global Long group_id {get;set;}
        global Boolean x_default {get; protected set;}  // NOTE: "default" is reserved word
    }

    global class ZJobStatus {
        global String id {get;set;}
        global String url {get;set;}
        global Integer total {get;set;}
        global Integer progress {get;set;}
        global String status {get;set;} // "queued", "working", "failed", "completed", "killed"
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
                        } else if (text == 'url') {
                            url = parser.getText();
                        } else if (text == 'total') {
                            total = parser.getIntegerValue();
                        } else if (text == 'progress') {
                            progress = parser.getIntegerValue();
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'message') {
                            message = parser.getText();
                        } else if (text == 'results') {
                            results = new List<ZJobStatusResults>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                results.add(new ZJobStatusResults(parser));
                            }
                        } else {
                            System.debug(LoggingLevel.WARN, 'ZJobStatus consuming unrecognized property: '+ text);
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
                        } else if (text == 'title') {
                            title = parser.getText();
                        } else if (text == 'action') {
                            action = parser.getText();
                        } else if (text == 'success') {
                            success = parser.getBooleanValue();
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'error' || text == 'errors') {
                            error = parser.getText();
                            errors = parser.getText();
                        } else if (text == 'external_id') {
                            external_id = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getIntegerValue();
                        } else if (text == 'details') {
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
                        } else {
                            System.debug(LoggingLevel.WARN, 'ZJobStatusResults consuming unrecognized property: ' + text);
                        }
                    }
                }
            }
        }
    }

    global class ZOrganizationField extends ZCustomField {}

    global class ZUserField extends ZCustomField {}

    global abstract class ZCustomField {
        global Long id {get; protected set;}
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
        global DateTime created_at {get; protected set;}
        global DateTime updated_at {get; protected set;}

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
        global DateTime created_at {get; protected set;}
        global DateTime updated_at {get; protected set;}
    }

    global class ZOrganizationMembership {
        global Long id {get; protected set;}
        global Long user_id {get;set;}
        global Long organization_id {get;set;}
        global Boolean x_default {get; protected set;}  // NOTE: "default" is reserved word
    }

    global class ZTicketComment {
        global Long id {get; protected set;}
        global String type {get;set;}
        global String body {get;set;}
        global String html_body {get;set;}
        global Boolean x_public {get;set;} // Use "x_public" in place of "public" which is a reserved keyword. Requires custom de/serialization.
        global Long author_id {get;set;}
        global List<ZAttachment> attachments {get;set;}
        global ZTicketVia via {get;set;}
        global DateTime created_at {get; protected set;}
        global String uploads {get;set;}
    }

    // Note that Ticket Field's are different than User and Organization Custom fields
    global class ZTicketField {
        global Long id {get; protected set;}
        global String type {get;set;}
        global String description {get;set;}
        global String raw_description {get;set;}
        global String title {get;set;}
        global String raw_title {get;set;}
        global String title_in_portal {get;set;}
        global String raw_title_in_portal {get;set;}
        global String regexp_for_validation {get;set;}
        global String tag {get;set;}
        global Long position {get;set;}
        global Boolean active {get;set;}
        global Boolean required {get;set;}
        global Boolean collapsed_for_agents {get;set;}
        global Boolean visible_in_portal {get;set;}
        global Boolean editable_in_portal {get;set;}
        global Boolean required_in_portal {get;set;}
        global Boolean removable {get; protected set;}
        global List<ZCustomFieldOption> custom_field_options {get;set;}
        global List<ZSystemFieldOption> system_field_options {get;set;}
        global DateTime created_at {get; protected set;}
        global DateTime updated_at {get; protected set;}

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
        global Long id {get; protected set;}
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
        global String raw_subject {get;set;}
        global TicketPriority priority {get;set;}
        global String status {get;set;}
        global String recipient {get;set;}
        global Long requester_id {get;set;}
        global ZTicketRequester requester {get;set;} // optional when creating a new ticket in place of requester_id
        global Long submitter_id {get;set;}
        global Long assignee_id {get;set;}
        global Long group_id {get;set;}
        global List<Long> collaborator_ids {get;set;}
        // TODO: how best to implement this which can be an array of different types. We may need a custom serializer for that
        //global List<String> collaborators {get;set;} // [ 562, "aa@example.com", { "name": "Someone Else", "email": "bb@example.com" } ]
        //global List<String> additional_collaborators {get;set;} // [ 562, "aa@example.com", { "name": "Someone Else", "email": "bb@example.com" } ]
        global Long forum_topic_id {get;set;}
        global Long problem_id {get;set;}
        global Boolean is_public {get;set;}
        global DateTime due_at {get;set;}
        global List<String> tags {get;set;}
        global List<ZTicketCustomField> custom_fields {get;set;}
        global Long ticket_form_id {get;set;}
        global Long brand_id {get;set;}
        global ZTicketComment comment {get;set;} // use for adding the ticket comment
        global String description {get; protected set;} // readonly. first comment on ticket
        global Long organization_id {get; protected set;}
        global ZTicketVia via {get; protected set;}
        global ZTicketSatisfactionRating satisfaction_rating {get; protected set;}
        global List<Long> sharing_agreement_ids {get; protected set;}
        global List<Long> followup_ids {get; protected set;}
        global Boolean has_incidents {get; protected set;}
        global Boolean allow_channelback {get;set;}
        global DateTime created_at {get; protected set;}
        global DateTime updated_at {get; protected set;}

        global ZTicket() {}

        global ZTicket(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'url') {
                            url = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getLongValue();
                        } else if (text == 'external_id') {
                            external_id = parser.getText();
                        } else if (text == 'via') {
                            via = (ZTicketVia)parser.readValueAs(ZTicketVia.class);
                        } else if (text == 'created_at') {
                            created_at = parser.getDateTimeValue();
                        } else if (text == 'updated_at') {
                            updated_at = parser.getDateTimeValue();
                        } else if (text == 'type') {
                            // Convert to enum
                            type = getTicketType(parser.getText());
                        } else if (text == 'subject') {
                            subject = parser.getText();
                        } else if (text == 'raw_subject') {
                            raw_subject = parser.getText();
                        } else if (text == 'description') {
                            description = parser.getText();
                        } else if (text == 'priority') {
                            // Convert to enum
                            priority = getTicketPriority(parser.getText());
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'recipient') {
                            recipient = parser.getText();
                        } else if (text == 'requester_id') {
                            requester_id = parser.getLongValue();
                        } else if (text == 'submitter_id') {
                            submitter_id = parser.getLongValue();
                        } else if (text == 'assignee_id') {
                            assignee_id = parser.getLongValue();
                        } else if (text == 'organization_id') {
                            organization_id = parser.getLongValue();
                        } else if (text == 'group_id') {
                            group_id = parser.getLongValue();
                        } else if (text == 'collaborator_ids') {
                            collaborator_ids = new List<Long>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                collaborator_ids.add(parser.getLongValue());
                            }
                        } else if (text == 'forum_topic_id') {
                            forum_topic_id = parser.getLongValue();
                        } else if (text == 'problem_id') {
                            problem_id = parser.getLongValue();
                        } else if (text == 'has_incidents') {
                            has_incidents = parser.getBooleanValue();
                        } else if (text == 'is_public') {
                            is_public = parser.getBooleanValue();
                        } else if (text == 'due_at') {
                            due_at = parser.getDateTimeValue();
                        } else if (text == 'tags') {
                            tags = new List<String>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                tags.add(parser.getText());
                            }
                        } else if (text == 'custom_fields') {
                            custom_fields = new List<ZTicketCustomField>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                custom_fields.add(new ZTicketCustomField(parser));
                            }
                        } else if (text == 'satisfaction_rating') {
                            satisfaction_rating = (ZTicketSatisfactionRating)parser.readValueAs(ZTicketSatisfactionRating.class);
                        } else if (text == 'sharing_agreement_ids') {
                            sharing_agreement_ids = new List<Long>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                sharing_agreement_ids.add(parser.getLongValue());
                            }
                        } else if (text == 'fields') {
                            // Consume and ignore for now
                            //fields = new List<ZTicketCustomField>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                //fields.add(new ZTicketCustomField(parser));
                                parserConsumeObject(parser);
                            }
                        } else if (text == 'ticket_form_id') {
                            ticket_form_id = parser.getLongValue();
                        } else if (text == 'brand_id') {
                            brand_id = parser.getLongValue();
                        } else if (text == 'satisfaction_probability') {
                            // ignore for now
                        } else if (text == 'allow_channelback') {
                            allow_channelback = parser.getBooleanValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'ZTicket consuming unrecognized property: ' + text);
                            parserConsumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    global class ZTicketCustomField {
        global Long id {get;set;}
        global List<String> value {get;set;}

        global ZTicketCustomField() {}
        global ZTicketCustomField(Long id, String value) { this.id = id; this.value = new List<String>{ value }; }
        global ZTicketCustomField(Long id, List<String> value) { this.id = id; this.value = value; }

        global ZTicketCustomField(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getLongValue();
                        } else if (text == 'value') {
                            value = new List<String>();
                            // Handle scenarios where the value is either a single string or an array
                            // "id": 80973768, "value": []
                            // "id": 24744223, "value": null
                            // "id": 24805666, "value": "foo"
                            // "id": 25323646, "value": ["aaa", "bbb"]
                            // "id": 24744183, "value": true
                            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                                while (parser.nextToken() != JSONToken.END_ARRAY) {
                                     value.add(parser.getText());
                                }
                            } else {
                                value.add(parser.getText());
                            }
                        } else {
                            System.debug(LoggingLevel.WARN, 'ZTicketCustomField consuming unrecognized property: ' + text);
                            parserConsumeObject(parser);
                        }
                    }
                }
            }
        }
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
        global Boolean shared_phone_number {get;set;}
        global String photo {get;set;}
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
        global Integer locale_id {get;set;}
        global Long organization_id {get;set;}
        global Long default_group_id {get;set;}
        global Long custom_role_id {get;set;}
        global List<String> tags {get;set;}
        global Map<String, String> user_fields {get;set;}
        global Boolean active {get; protected set;}
        global Boolean two_factor_auth_enabled {get; protected set;}
        global String ticket_restriction {get;set;}
        global DateTime last_login_at {get; protected set;}
        global DateTime created_at {get; protected set;}
        global DateTime updated_at {get; protected set;}
    }

    global class ZTag {
        global String name {get;set;}
        global Long count {get;set;}
    }

    global class ZTicketMetrics {
        global Long id {get; protected set;}
        global Long ticket_id {get; protected set;}
        global DateTime created_at {get; protected set;}
        global DateTime updated_at {get; protected set;}
        global Integer group_stations {get; protected set;}
        global Integer assignee_stations {get; protected set;}
        global Integer reopens {get; protected set;}
        global Integer replies {get; protected set;}
        global DateTime assignee_updated_at {get; protected set;}
        global DateTime requester_updated_at {get; protected set;}
        global DateTime status_updated_at {get; protected set;}
        global DateTime initially_assigned_at {get; protected set;}
        global DateTime assigned_at {get; protected set;}
        global DateTime solved_at {get; protected set;}
        global DateTime latest_comment_added_at {get; protected set;}
        global ZTicketMetricsTime reply_time_in_minutes {get; protected set;}
        global ZTicketMetricsTime first_resolution_time_in_minutes {get; protected set;}
        global ZTicketMetricsTime full_resolution_time_in_minutes {get; protected set;}
        global ZTicketMetricsTime agent_wait_time_in_minutes {get; protected set;}
        global ZTicketMetricsTime requester_wait_time_in_minutes {get; protected set;}
        global ZTicketMetricsTime on_hold_time_in_minutes {get; protected set;}
    }

    global class ZTicketMetricsTime {
        global Integer calendar {get; protected set;}
        global Integer business {get; protected set;}
    }

    global class ZSearchResult {
        global Long id {get; protected set;}
        global String name {get; protected set;}
        global DateTime created_at {get; protected set;}
        global DateTime updated_at {get; protected set;}
        global String result_type {get; protected set;}
        global String url {get; protected set;}
    }

    global class ZTopic {
        global Long id {get; protected set;}
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
        global DateTime created_at {get; protected set;}
        global DateTime updated_at {get; protected set;}
        global List<String> search_phrases {get;set;}
    }

    global class ZSatisfactionRating {
        global Long id {get; protected set;}
        global Long assignee_id {get; protected set;}
        global Long group_id {get; protected set;}
        global Long requester_id {get; protected set;}
        global Long ticket_id {get; protected set;}
        global String score {get;set;}
        global String comment {get;set;}
        global DateTime updated_at {get; protected set;}
        global DateTime created_at {get; protected set;}
    }

    global class ZSession {
        global Long id {get; protected set;}
        global Long user_id {get; protected set;}
        global DateTime authenticated_at {get; protected set;}
        global DateTime last_seen_at {get; protected set;}
    }

    public static void parserConsumeObject(JSONParser parser) {
        Integer depth = 0;
        do {
            JSONToken curr = parser.getCurrentToken();
            if (curr == JSONToken.START_OBJECT || curr == JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == JSONToken.END_OBJECT || curr == JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
}
