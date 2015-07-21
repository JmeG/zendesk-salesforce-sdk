/*
Javascript Detail Page button added to an Account object layout in Salesforce
Set the following content in the button's OnClick JavaScript field.

{!requireScript("/soap/ajax/25.0/connection.js")}
{!requireScript("/soap/ajax/25.0/apex.js")}

var subject = '{!Account.Name}';
var comment = '{!Account.Description}';

// NOTE: if your org has a namespace you must put that before "ZendeskCreateTicketSampleService" in the below call.
// "<ns>.ZendeskCreateTicketSampleService"
var result = sforce.apex.execute("ZendeskCreateTicketSampleService", "createNewZendeskTicket", {ticketSubject: subject, ticketComment: comment});

alert(result);
*/
global with sharing class ZendeskCreateTicketSampleService {

	// Expose method as a webService so we can call it from a Javascript button on a Salesforce layout
	webService static String createNewZendeskTicket(String ticketSubject, String ticketComment) {
		try {
            // Retrieve the Zendesk API details from the custom settings object
            Zendesk_API__c settings = Zendesk_API__c.getOrgDefaults();
    		if (settings == null) { throw new ZendeskException('Zendesk_API custom settings are null'); }
			ZendeskAPI.AuthType zdAuthType = (settings.Authentication_Type__c=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token);

			// Create a new Ticket object
            ZendeskTickets.ZTicket zt = new ZendeskTickets.ZTicket();
            zt.type = ZendeskTickets.TicketType.question;
    		zt.subject = ticketSubject;
            // Create a new requester if one doesn't exist with this email address
    		zt.requester = new ZendeskTickets.ZTicketRequester();
            zt.requester.name = UserInfo.getName();
            zt.requester.email = UserInfo.getUserEmail();
            // Add a comment to the ticket
            zt.comment = new ZendeskTickets.ZTicketComment();
    		zt.comment.body = ticketComment;

			ZendeskAPI zapi = new ZendeskAPI(settings.Subdomain__c, settings.Username__c, settings.Password_or_Token__c, zdAuthType);
			ZendeskTickets zTickets = new ZendeskTickets(zapi);
			Long ticketNum = zTickets.createTicket(zt);

			// Return the newly created ticket number
			return 'Ticket # ' + ticketNum + ' created.';
		}
		catch(Exception e) {
			return 'Error creating ticket: ' + e.getMessage();
		}
	}
}
