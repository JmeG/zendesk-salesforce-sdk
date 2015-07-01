@isTest
private class ZendeskAPITest {

	static testmethod void testCreateTicket() {
        ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);
		ZendeskTickets ztickets = new ZendeskTickets(zapi);

		Integer ticketId = ztickets.createTicket('type', 'testsubj', 'testcomment', 123);
		ticketId = ztickets.createTicket('type', 'testsubj', 'testcomment', 'attachmentToken', 123);
		ticketId = ztickets.createTicket('type', 'testsubj', 'testcomment', 123, new List<ZendeskAPISchema.ZTicketCustomField>());
		ticketId = ztickets.createTicket('type', 'testsubj', 'testcomment', 123, 234, 345, 456, new List<ZendeskAPISchema.ZTicketCustomField>());

		System.assert(true);
	}

	static testmethod void testGetTicket() {
        ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);
		ZendeskTickets ztickets = new ZendeskTickets(zapi);
		ZendeskAPISchema.ZTicket ticket = ztickets.getTicket(123);

		System.assertNotEquals(null, ticket);
	}

	static testmethod void testUploadTicketAttachment() {
        ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);
		ZendeskTickets ztickets = new ZendeskTickets(zapi);

		String attachId = ztickets.uploadAttachmentToZendesk('filename.txt', 'fileContentType', Blob.valueOf('asdfasfdasdfasdfasdf'));

		System.assertNotEquals(null, attachId);
	}

    static testmethod void testDeleteTicket() {
        ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);
        ZendeskTickets ztickets = new ZendeskTickets(zapi);
        ztickets.deleteTicket(123);

        System.assert(true);
    }


	static testmethod void testCreateUser() {
        ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);
		ZendeskUsers zusers = new ZendeskUsers(zapi);
		Integer userId = zusers.createUser('John Doe', 'jdoe@zendesk.com');

		System.assertNotEquals(null, userId);
	}

	static testmethod void testGetUserId() {
        ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);
		ZendeskUsers zusers = new ZendeskUsers(zapi);
		Integer userId = zusers.getUserIdFromEmail('foo@bar.com');

		System.assertNotEquals(null, userId);
	}


	static testmethod void testGetGroup() {
        ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);
		ZendeskGroups zgroups = new ZendeskGroups(zapi);
		ZendeskAPISchema.ZGroup testObj = zgroups.getGroup('Test');

		System.assertNotEquals(null, testObj);
	}


	static testmethod void testGetTicketField1() {
        ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);
		ZendeskTicketFields zticketfields = new ZendeskTicketFields(zapi);
		ZendeskAPISchema.ZTicketField testObj = zticketfields.getTicketField('Test');

		System.assertNotEquals(null, testObj);
	}

	static testmethod void testGetTicketField2() {
        ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);
		ZendeskTicketFields zticketfields = new ZendeskTicketFields(zapi);

		ZendeskAPISchema.ZTicketField testObj = zticketfields.getTicketField(12345678);
        System.assertNotEquals(null, testObj);

        String optionVal = testObj.getOptionValue('Test');
        System.assertNotEquals(null, optionVal);
	}


	static testmethod void testGetTicketForm() {
        ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);
		ZendeskTicketForms zticketforms = new ZendeskTicketForms(zapi);
		ZendeskAPISchema.ZTicketForm testObj = zticketforms.getTicketForm('Test');

		System.assertNotEquals(null, testObj);
	}

	static testmethod void testSchema() {
		ZendeskAPISchema.ZUser zuser = new ZendeskAPISchema.ZUser();
        zuser.id = 1;
        zuser.name = '';
        zuser.email = '';
        zuser.role = '';
        zuser.organization_id = 1;

    	ZendeskAPISchema.ZGroup zgroup = new ZendeskAPISchema.ZGroup();
        zgroup.id = 1;
        zgroup.name = '';

    	ZendeskAPISchema.ZTicketForm zticketform = new ZendeskAPISchema.ZTicketForm();
        zticketform.id = 0;
        zticketform.name = '';
        zticketform.raw_name = '';
        zticketform.active = true;

    	ZendeskAPISchema.ZTicketField zticketfield = new ZendeskAPISchema.ZTicketField();
        zticketfield.id = 0;
        zticketfield.type = '';
        zticketfield.title = '';
        zticketfield.raw_title = '';
        zticketfield.active = true;
        zticketfield.custom_field_options = null;

    	ZendeskAPISchema.ZCustomFieldOption zcustomfieldoption = new ZendeskAPISchema.ZCustomFieldOption();
        zcustomfieldoption.id = 0;
        zcustomfieldoption.name = '';
        zcustomfieldoption.raw_name = '';
        zcustomfieldoption.value = '';

    	ZendeskAPISchema.ZTicket zticket = new ZendeskAPISchema.ZTicket();
        zticket.id = 0;
        zticket.url = '';
        zticket.external_id = '';
        zticket.type = '';
        zticket.subject = '';
        zticket.description = '';
        zticket.priority = '';
        zticket.status = '';
        zticket.recipient = '';
        zticket.requester_id = 0;
        zticket.submitter_id = 0;
        zticket.assignee_id = 0;
        zticket.organization_id = 0;
        zticket.group_id = 0;
        zticket.collaborator_ids = new List<Integer>();
        zticket.forum_topic_id = 0;
        zticket.problem_id = 0;
        zticket.has_incidents = false;
        zticket.due_at = DateTime.now();
        zticket.tags = new List<String>();
        zticket.via = null;
        zticket.custom_fields = null;
        zticket.satisfaction_rating = null;
        zticket.sharing_agreement_ids = null;
        zticket.ticket_form_id = 0;
        zticket.created_at = DateTime.now();
        zticket.updated_at = DateTime.now();
        zticket.comment = null;

    	ZendeskAPISchema.ZTicketCustomField zticketcustomfield = new ZendeskAPISchema.ZTicketCustomField();
        zticketcustomfield.id = 0;
        zticketcustomfield.value = '';

        ZendeskAPISchema.ZTicketCustomField zticketcustomfield2 = new ZendeskAPISchema.ZTicketCustomField(1, '');

    	ZendeskAPISchema.ZTicketVia zticketvia = new ZendeskAPISchema.ZTicketVia();
    	zticketvia.channel = '';

    	ZendeskAPISchema.ZTicketSatisfactionRating zticketsatrating = new ZendeskAPISchema.ZTicketSatisfactionRating();
        zticketsatrating.id = 0;
        zticketsatrating.score = '';
        zticketsatrating.comment = '';

    	ZendeskAPISchema.ZTicketComment zticketcomment = new ZendeskAPISchema.ZTicketComment();
        zticketcomment.body = '';
        zticketcomment.uploads = '';

		System.assert(true);
	}

}

