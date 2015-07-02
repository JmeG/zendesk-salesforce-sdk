// This class provides definitions for common entities in the Zendesk API.
public with sharing class ZendeskAPISchema {

	public class ZUser {
		public Integer id {get;set;}
		public String name {get;set;}
		public String email {get;set;}
		public String role {get;set;}
		public Integer organization_id {get;set;}
	}

	public class ZGroup {
		public Integer id {get;set;}
		public String name {get;set;}
	}

	public class ZTicketForm {
		public Integer id {get;set;}
		public String name {get;set;}
		public String raw_name {get;set;}
		public Boolean active {get;set;}
	}

	public class ZTicketField {
		public Integer id {get;set;}
		public String type {get;set;}
		public String title {get;set;}
		public String raw_title {get;set;}
		public Boolean active {get;set;}
		public ZCustomFieldOption[] custom_field_options {get;set;}

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

			if (String.isEmpty(val) && errorIfNotFound && !Test.isRunningTest()) { throw new ZendeskException('Option value "' + optname + '" not found for field "' + this.title + '"'); }
			return val;
		}
	}

	public class ZCustomFieldOption {
		public Integer id {get;set;}
		public String name {get;set;}
		public String raw_name {get;set;}
		public String value {get;set;}
	}

	public class ZTicket {
		public Integer id {get; set;}
		public String url {get; set;}
		public String external_id {get; set;}
		public String type {get; set;}
		public String subject {get; set;}
		public String description {get; set;}
		public String priority {get; set;}
		public String status {get; set;}
		public String recipient {get; set;}
		public Integer requester_id {get; set;}
		public Integer submitter_id {get; set;}
		public Integer assignee_id {get; set;}
		public Integer organization_id {get; set;}
		public Integer group_id {get; set;}
		public List<Integer> collaborator_ids {get; set;}
		public Integer forum_topic_id {get; set;}
		public Integer problem_id {get; set;}
		public Boolean has_incidents {get; set;}
		public DateTime due_at {get; set;}
		public List<String> tags {get; set;}
		public ZTicketVia via {get; set;}
		public List<ZTicketCustomField> custom_fields {get; set;}
		public ZTicketSatisfactionRating satisfaction_rating {get; set;}
		public List<Integer> sharing_agreement_ids {get; set;}
		public Integer ticket_form_id {get; set;}
		public DateTime created_at {get; set;}
		public DateTime updated_at {get; set;}
		public ZTicketComment comment {get; set;}
	}

	public class ZTicketCustomField {
		public Integer id {get; set;}
		public String value {get; set;}

		public ZTicketCustomField() {}
		public ZTicketCustomField(Integer id, String value) { this.id = id; this.value = value; }
	}

	public class ZTicketVia {
		public String channel {get; set;}
		//public String source {get; set;}
	}

	public class ZTicketSatisfactionRating {
		public Integer id {get; set;}
		public String score {get; set;}
		public String comment {get; set;}
	}

	public class ZTicketComment {
		public String body {get; set;}
		public String uploads {get; set;}
	}

}