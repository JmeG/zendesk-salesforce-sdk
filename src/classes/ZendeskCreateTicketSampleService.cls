/*
Javascript Detail Page button added to an object layout in Salesforce
Set the following content in the button's OnClick JavaScript field.

{!requireScript("/soap/ajax/20.0/connection.js")}
{!requireScript("/soap/ajax/20.0/apex.js")}

var subject = 'my subject';
var description = 'my comment';
var custom1 = '{!Opportunity.customField1__c}';
var custom2 = '{!Opportunity.customField2__c}';

var retStr = sforce.apex.execute("ZendeskCreateTicketSampleService", "createNewZendeskTicket", {ticketSubject:subject, ticketDescription:description, customField1Text:custom1, customField2Text:custom2});
alert(retStr);
*/
global with sharing class ZendeskCreateTicketSampleService {

/*
  private static final String zendeskSubdomain = 'z3njgibsontest1';
  private static final String zendeskUsername = 'jgibson@zendesk.com';
  private static final String zendeskToken = 'Token';
  private static final ZendeskAPI.AuthType zendeskAuthType = ZendeskAPI.AuthType.Token;

	// Expose method as a webService so we can call it from a Javascript button on a Salesforce layout
	webService static String createNewZendeskTicket(String ticketSubject, String ticketDescription, String customField1Text, String customField2Text) {
		try {
			ZendeskAPI zapi = new ZendeskAPI(zendeskSubdomain, zendeskUsername, zendeskToken, zendeskAuthType);

			// Create a new user or get the existing id of the requesting user
			ZendeskUsers zUsers = new ZendeskUsers(zapi);
			Integer requesterId = zUsers.getUserIdFromEmail(UserInfo.getUserEmail());
			if (requesterId == null) {
				requesterId = zUsers.createUser(UserInfo.getName(), UserInfo.getUserEmail());
				if (requesterId == null) { throw new ZendeskException('Error creating user in ' + zendeskSubdomain); }
			}

			// Retrieve the Zendesk ID of two different custom ticket fields
			// The performance here can be improved by making use of the ZendeskAPICacheManager
			ZendeskTicketFields zTicketFields = new ZendeskTicketFields(zapi);
			String customFieldName = 'Custom Field Name 1';
			ZendeskTicketFields.ZTicketField zticketField1 = zTicketFields.getTicketField(customFieldName);
			if (zticketField1 == null) { throw new ZendeskException('Unable to find Ticket Field "' + customFieldName + '"'); }
			customFieldName = 'Custom Field Name 2';
			ZendeskTicketFields.ZTicketField zticketField2 = zTicketFields.getTicketField(customFieldName);
			if (zticketField2 == null) { throw new ZendeskException('Unable to find Ticket Field "' + customFieldName + '"'); }

			// Build list of custom fields and values
			List<ZendeskTicketFields.ZTicketCustomField> zcfList = new List<ZendeskTicketFields.ZTicketCustomField>();
			zcfList.add(new ZendeskTicketFields.ZTicketCustomField(zticketField1.Id, customField1Text));
			zcfList.add(new ZendeskTicketFields.ZTicketCustomField(zticketField2.Id, customField2Text));

			// Create the request
			ZendeskTickets zTickets = new ZendeskTickets(zapi);
			Integer ticketNum = zTickets.createTicket('question', ticketSubject, ticketDescription, requesterId, zcfList);

			// Return the newly created ticket number
			return 'Ticket # ' + ticketNum + ' created.';
		}
		catch(Exception e) {
			return 'Error creating ticket: ' + e.getMessage();
		}
	}
*/
	/*
	// Additional sample code that shows how you can cache and reuse the Zendesk ID's of custom fields and forms rather than
	// having to call the API each time you create a ticket.
	private static void BuildCache() {
		ZendeskAPICacheManager cache = new ZendeskAPICacheManager();

		ZendeskAPI zapi = new ZendeskAPI(zendeskSubdomain, zendeskUsername, zendeskToken, zendeskAuthType);

		// --------------------
		// Custom Ticket Forms
		Set<String> formNames = new Set<String>();
		formNames.add('Form Name 1');
		formNames.add('Form Name 2');

		ZendeskTicketForms zTicketForms = new ZendeskTicketForms(zapi);
		for (String formName : formNames) {
			ZendeskTicketForms.ZTicketForm zticketForm = zTicketForms.getTicketForm(formName);
			if (zticketForm == null) { throw new ZendeskException('Unable to find Ticket Form "' + formName + '"'); }
			cache.add(zendeskSubdomain, ZendeskAPICacheManager.TICKET_FORM, formName, zticketForm.id);
		}

		// --------------------
		// Custom Ticket Fields
		Set<String> fieldNames = new Set<String>();
		fieldNames.add('Custom Field Name 1');
		fieldNames.add('Custom Field Name 2');
		fieldNames.add('Custom Field Name 3');

		ZendeskTicketFields zTicketFields = new ZendeskTicketFields(zapi);
		for (String fieldName : fieldNames) {
			ZendeskTickets.ZTicketField zticketField = zTicketFields.getTicketField(fieldName);
			if (zticketField == null) { throw new ZendeskException('Unable to find Ticket Field "' + fieldName + '"'); }
			cache.add(zendeskSubdomain, ZendeskAPICacheManager.TICKET_FIELD, fieldName, zticketField.id);
		}

		// --------------------
		// Save the new records to the cache
		cache.saveUncommitted();
	}
	*/
}
