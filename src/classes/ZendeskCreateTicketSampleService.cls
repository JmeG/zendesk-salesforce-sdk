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
global class ZendeskCreateTicketSampleService {

    // Expose method as a webService so we can call it from a Javascript button on a Salesforce layout
    webService static String createNewZendeskTicket(String ticketSubject, String ticketComment) {
        try {
            // Retrieve the Zendesk API details from the custom settings object
            Zendesk_API__c settings = Zendesk_API__c.getInstance();
            if (settings == null) { throw new ZendeskException('Zendesk_API custom settings are null'); }

            // Create a new Ticket object
            ZendeskTypes.ZTicket zt = new ZendeskTypes.ZTicket();
            zt.type = ZendeskTypes.TicketType.question;
            zt.subject = ticketSubject;
            // Create a new requester if one doesn't exist with this email address
            zt.requester = new ZendeskTypes.ZTicketRequester();
            zt.requester.name = UserInfo.getName();
            zt.requester.email = UserInfo.getUserEmail();
            // Add a comment to the ticket
            zt.comment = new ZendeskTypes.ZTicketComment();
            zt.comment.body = ticketComment;

            String subdomain = settings.Subdomain__c;
            String username = settings.Username__c;
            String pwdOrToken = settings.Password_or_Token__c;
            String authType = settings.Authentication_Type__c;
            ZendeskConnection zconn = (authType=='Password') ? ZendeskConnection.createWithPassword(subdomain, username, pwdOrToken) : ZendeskConnection.createWithAPIToken(subdomain, username, pwdOrToken);

            ZendeskTicketsAPI zTickets = new ZendeskTicketsAPI(zconn);
            Long ticketNum = zTickets.createTicket(zt);

            // Return the newly created ticket number
            return 'Ticket # ' + ticketNum + ' created';
        }
        catch(Exception e) {
            return 'Error creating ticket: ' + e.getMessage();
        }
    }
}
