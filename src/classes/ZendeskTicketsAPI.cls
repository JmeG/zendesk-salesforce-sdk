// This class provides functionality to call the Zendesk Tickets API
global class ZendeskTicketsAPI extends ZendeskResourceBase {

    global class TicketWrapper extends ZendeskSideLoadingBase {
        global ZTicket ticket {get;set;}
        global TicketWrapper(ZTicket ticket) { this.ticket = ticket; }

        global TicketWrapper(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'ticket') {
                            ticket = new ZTicket(parser);
                        }
                        // Sideloaded objects
                        // users, groups, organizations, metric_sets, sharing_agreements, incident_counts, ticket_forms
                        else if (text == 'users') {
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                if (users == null) { users = new List<ZUser>(); }
                                users.add((ZUser)parser.readValueAs(ZUser.class));
                            }
                        } else if (text == 'groups') {
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                if (groups == null) { groups = new List<ZGroup>(); }
                                groups.add((ZGroup)parser.readValueAs(ZGroup.class));
                            }
                        } else if (text == 'organizations') {
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                if (organizations == null) { organizations = new List<ZOrganization>(); }
                                organizations.add((ZOrganization)parser.readValueAs(ZOrganization.class));
                            }
                        } else if (text == 'ticket_forms') {
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                if (ticket_forms == null) { ticket_forms = new List<ZTicketForm>(); }
                                ticket_forms.add((ZTicketForm)parser.readValueAs(ZTicketForm.class));
                            }
                        } else {
                            System.debug(LoggingLevel.WARN, 'TicketWrapper consuming unrecognized property: ' + text);
                            parserConsumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    global class TicketsWrapper extends ZendeskPagingBase {
        global List<ZTicket> tickets {get;set;}
        global TicketsWrapper(List<ZTicket> tickets) { this.tickets = tickets; }

        global TicketsWrapper(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'tickets') {
                            tickets = new List<ZTicket>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                tickets.add(new ZTicket(parser));
                            }
                        }
                        // From ZendeskPagingBase.cls
                        else if (text == 'next_page') {
                            next_page = parser.getText();
                        } else if (text == 'previous_page') {
                            previous_page = parser.getText();
                        } else if (text == 'count') {
                            count = parser.getLongValue();
                        }
                        // Sideloaded objects
                        // users, groups, organizations, metric_sets, sharing_agreements, incident_counts, ticket_forms
                        else if (text == 'users') {
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                if (users == null) { users = new List<ZUser>(); }
                                users.add((ZUser)parser.readValueAs(ZUser.class));
                            }
                        } else if (text == 'groups') {
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                if (groups == null) { groups = new List<ZGroup>(); }
                                groups.add((ZGroup)parser.readValueAs(ZGroup.class));
                            }
                        } else if (text == 'organizations') {
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                if (organizations == null) { organizations = new List<ZOrganization>(); }
                                organizations.add((ZOrganization)parser.readValueAs(ZOrganization.class));
                            }
                        } else if (text == 'ticket_forms') {
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                if (ticket_forms == null) { ticket_forms = new List<ZTicketForm>(); }
                                ticket_forms.add((ZTicketForm)parser.readValueAs(ZTicketForm.class));
                            }
                        } else {
                            System.debug(LoggingLevel.WARN, 'TicketsWrapper consuming unrecognized property: ' + text);
                            parserConsumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    global ZendeskTicketsAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    global TicketWrapper getTicket(Long ticketId) {
        return getTicket(ticketId, null);
    }
    global TicketWrapper getTicket(Long ticketId, Map<String, Object> queryParams) {
        if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest(
            HTTP_GET,
            '/tickets/'+ticketId+'.json',
            queryParams
        );
        //return (TicketWrapper)JSON.deserialize(zconn.sendRequest(req), TicketWrapper.class);
        return new TicketWrapper(System.JSON.createParser(replaceReservedWords(zconn.sendRequest(req))));
    }

    // /api/v2/tickets.json
    global TicketsWrapper getTickets() {
        return getTickets(null);
    }
    global TicketsWrapper getTickets(Map<String, Object> queryParams) {
        return getTicketsHelper(zconn.createRequest(
            HTTP_GET,
            '/tickets.json',
            queryParams
        ));
    }

    // /api/v2/organizations/{organization_id}/tickets.json
    global TicketsWrapper getTicketsByOrgId(Long orgId) {
        return getTicketsByOrgId(orgId, null);
    }
    global TicketsWrapper getTicketsByOrgId(Long orgId, Map<String, Object> queryParams) {
        if (orgId == null) { throw new ZendeskException('orgId parameter cannot be null'); }

        return getTicketsHelper(zconn.createRequest(
            HTTP_GET,
            '/organizations/'+orgId+'/tickets.json',
            queryParams
        ));
    }

    // /api/v2/users/{user_id}/tickets/requested.json
    global TicketsWrapper getTicketsByRequesterId(Long requesterId) {
        return getTicketsByRequesterId(requesterId, null);
    }
    global TicketsWrapper getTicketsByRequesterId(Long requesterId, Map<String, Object> queryParams) {
        if (requesterId == null) { throw new ZendeskException('requesterId parameter cannot be null'); }

        return getTicketsHelper(zconn.createRequest(
            HTTP_GET,
            '/users/'+requesterId+'/tickets/requested.json',
            queryParams
        ));
    }

    // /api/v2/users/{user_id}/tickets/ccd.json
    global TicketsWrapper getTicketsByCCUserId(Long userId) {
        return getTicketsByCCUserId(userId, null);
    }
    global TicketsWrapper getTicketsByCCUserId(Long userId, Map<String, Object> queryParams) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }

        return getTicketsHelper(zconn.createRequest(
            HTTP_GET,
            '/users/'+userId+'/tickets/ccd.json',
            queryParams
        ));
    }

    // /api/v2/users/{user_id}/tickets/assigned.json
    global TicketsWrapper getTicketsByAssigneeId(Long assigneeId) {
        return getTicketsByAssigneeId(assigneeId, null);
    }
    global TicketsWrapper getTicketsByAssigneeId(Long assigneeId, Map<String, Object> queryParams) {
        if (assigneeId == null) { throw new ZendeskException('assigneeId parameter cannot be null'); }

        return getTicketsHelper(zconn.createRequest(
            HTTP_GET,
            '/users/'+assigneeId+'/tickets/assigned.json',
            queryParams
        ));
    }

    // /api/v2/tickets/recent.json
    global TicketsWrapper getRecentTickets() {
        return getRecentTickets(null);
    }
    global TicketsWrapper getRecentTickets(Map<String, Object> queryParams) {
        return getTicketsHelper(zconn.createRequest(
            HTTP_GET,
            '/users/tickets/recent.json',
            queryParams)
        );
    }

    // /api/v2/tickets/show_many.json?ids={ids}
    global TicketsWrapper getTicketsByIds(Set<Long> ticketIds) {
        if (ticketIds == null || ticketIds.isEmpty()) { throw new ZendeskException('ticketIds parameter cannot be null or empty'); }

        return getTicketsHelper(zconn.createRequest(
            HTTP_GET,
            '/tickets/show_many.json',
            new Map<String, Object>{'ids'=>toCSV(ticketIds)}
        ));
    }

    // /api/v2/tickets/{id}/incidents.json
    global TicketsWrapper getTicketIncidents(Long ticketId) {
        return getTicketIncidents(ticketId, null);
    }
    global TicketsWrapper getTicketIncidents(Long ticketId, Map<String, Object> queryParams) {
        if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

        return getTicketsHelper(zconn.createRequest(
            HTTP_GET,
            '/tickets/'+ticketId+'/incidents.json',
            queryParams
        ));
    }

    // /api/v2/problems.json
    global TicketsWrapper getTicketProblems() {
        return getTicketProblems(null);
    }
    global TicketsWrapper getTicketProblems(Map<String, Object> queryParams) {
        return getTicketsHelper(zconn.createRequest(
            HTTP_GET,
            '/tickets/problem.json',
            queryParams
        ));
    }

    // Helper method for getting tickets
    private TicketsWrapper getTicketsHelper(HttpRequest req) {
        //return (TicketsWrapper)JSON.deserialize(zconn.sendRequest(req), TicketsWrapper.class);
        return new TicketsWrapper(System.JSON.createParser(zconn.sendRequest(req)));
    }

    global ZendeskUsersAPI.UsersWrapper getTicketCollaborators(Long ticketId) {
        if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest(
            HTTP_GET,
            '/tickets/'+ticketId+'/collaborators.json'
        );
        return (ZendeskUsersAPI.UsersWrapper)JSON.deserialize(zconn.sendRequest(req), ZendeskUsersAPI.UsersWrapper.class);
    }

    global Map<String, Object> getTwicketStatus(Long ticketId) {
        if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest(
            HTTP_GET,
            '/channels/twitter/tickets/'+ticketId+'/statuses.json'
        );
        return (Map<String, Object>)JSON.deserializeUntyped(zconn.sendRequest(req));
    }

    global Long createTicket(TicketType type, String subject, String commentText, Long requesterId) {
        return createTicket(type, subject, commentText, null, requesterId, null, null, null, null);
    }

    global Long createTicket(TicketType type, String subject, String commentText, String attachmentToken, Long requesterId) {
        return createTicket(type, subject, commentText, attachmentToken, requesterId, null, null, null, null);
    }

    global Long createTicket(TicketType type, String subject, String commentText, Long requesterId, List<ZTicketCustomField> zcfList) {
        return createTicket(type, subject, commentText, null, requesterId, null, null, null, zcfList);
    }

    global Long createTicket(TicketType type, String subject, String commentText, String attachmentToken, Long requesterId, List<ZTicketCustomField> zcfList) {
        return createTicket(type, subject, commentText, attachmentToken, requesterId, null, null, null, zcfList);
    }

    global Long createTicket(TicketType type, String subject, String commentText, Long requesterId, Long groupId, Long assigneeId, Long ticketFormId, List<ZTicketCustomField> zcfList) {
        return createTicket(type, subject, commentText, null, requesterId, groupId, assigneeId, ticketFormId, zcfList);
    }

    global Long createTicket(TicketType type, String subject, String commentText, String attachmentToken, Long requesterId, Long groupId, Long assigneeId, Long ticketFormId, List<ZTicketCustomField> zcfList) {
        ZTicket zt = new ZTicket();
        zt.type = type;
        zt.subject = subject;
        zt.custom_fields = zcfList;
        zt.requester_id = requesterId;
        zt.assignee_id = assigneeId;
        zt.ticket_form_id = ticketFormId;
        zt.group_id = groupId;
        zt.comment = new ZTicketComment();
        zt.comment.body = commentText;
        zt.comment.uploads = attachmentToken;

        return createTicket(zt);
    }

    global Long createTicket(ZTicket zticket) {
        if (zticket == null) { throw new ZendeskException('zticket parameter cannot be null'); }

        HttpRequest req = zconn.createRequest(
            HTTP_POST,
            '/tickets.json',
            JSON.serialize(new TicketWrapper(zticket), true)
        );
        //TicketWrapper resultWrapper = (TicketWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), TicketWrapper.class);
        TicketWrapper resultWrapper = new TicketWrapper(System.JSON.createParser(replaceReservedWords(zconn.sendRequest(req))));

        return ((resultWrapper==null || resultWrapper.ticket == null) ? null : resultWrapper.ticket.id);
    }

    global Long createTicketFromTweet(Long twitterMessageId, Long monitoredTwitterHandleId) {
        if (twitterMessageId == null) { throw new ZendeskException('twitterMessageId parameter cannot be null'); }
        if (monitoredTwitterHandleId == null) { throw new ZendeskException('monitoredTwitterHandleId parameter cannot be null'); }

        // {"ticket": {"twitter_status_message_id": 8605426295771136, "monitored_twitter_handle_id": 45}}'
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('ticket');
        gen.writeStartObject();
        gen.writeNumberField('twitter_status_message_id', twitterMessageId);
        gen.writeNumberField('monitored_twitter_handle_id', monitoredTwitterHandleId);
        gen.writeEndObject();
        gen.writeEndObject();

        HttpRequest req = zconn.createRequest(
            HTTP_POST,
            '/channels/twitter/tickets.json',
            gen.getAsString()
        );
        //TicketWrapper resultWrapper = (TicketWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), TicketWrapper.class);
        TicketWrapper resultWrapper = new TicketWrapper(System.JSON.createParser(replaceReservedWords(zconn.sendRequest(req))));
        return ((resultWrapper==null || resultWrapper.ticket == null) ? null : resultWrapper.ticket.id);
    }

    global ZendeskTypes.ZJobStatus createTickets(List<ZTicket> ztickets) {
        if (ztickets == null || ztickets.isEmpty()) { throw new ZendeskException('ztickets parameter cannot be null or empty'); }

        HttpRequest req = zconn.createRequest(
            HTTP_POST,
            '/tickets/create_many.json',
            JSON.serialize(new TicketsWrapper(ztickets), true)
        );
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    global void updateTicket(Long ticketId, ZTicket zticket) {
        if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }
        if (zticket == null) { throw new ZendeskException('zticket parameter cannot be null'); }

        HttpRequest req = zconn.createRequest(
            HTTP_PUT,
            '/tickets/'+ticketId+'.json',
            JSON.serialize(new TicketWrapper(zticket), true)
        );
        zconn.sendRequest(req);
    }

    global ZendeskTypes.ZJobStatus updateTickets(List<ZTicket> ztickets) {
        if (ztickets == null || ztickets.isEmpty()) { throw new ZendeskException('ztickets parameter cannot be null or empty'); }
        for (ZTicket zticket : ztickets) {
            if (zticket.id == null) { throw new ZendeskException('Each Ticket must have an id populated'); }
        }

        HttpRequest req = zconn.createRequest(
            HTTP_PUT,
            '/tickets/update_many.json',
            JSON.serialize(new TicketsWrapper(ztickets), true)
        );
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    global ZendeskTypes.ZJobStatus updateTickets(Set<Long> ticketIds, ZTicket zticket) {
        if (ticketIds == null || ticketIds.isEmpty()) { throw new ZendeskException('ticketIds parameter cannot be null or empty'); }
        if (zticket == null) { throw new ZendeskException('zticket parameter cannot be null'); }

        HttpRequest req = zconn.createRequest(
            HTTP_PUT,
            '/tickets/update_many.json',
            JSON.serialize(new TicketWrapper(zticket), true),
            new Map<String, Object>{'ids'=>toCSV(ticketIds)}

        );
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    // helper method to add a new comment to a ticket
    global void addTicketComment(Long ticketId, String commentText, Boolean isPublic) {
        if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }
        if (String.isBlank(commentText)) { throw new ZendeskException('commentText parameter must not be empty'); }

        ZTicket ticket = new ZTicket();
        ticket.comment = new ZTicketComment();
        ticket.comment.body = commentText;
        ticket.comment.x_public = isPublic;

        HttpRequest req = zconn.createRequest(
            HTTP_PUT,
            '/tickets/'+ticketId+'.json',
            JSON.serialize(new TicketWrapper(ticket), true)
        );
        zconn.sendRequest(req);
    }

    // helper method to add a new comment to a ticket and change its status
    global void addTicketCommentAndChangeStatus(Long ticketId, String commentText, Boolean isPublic, TicketStatus status) {
        if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }
        if (String.isBlank(commentText)) { throw new ZendeskException('commentText parameter must not be empty'); }
        if (status == null) { throw new ZendeskException('status parameter cannot be null'); }

        ZTicket ticket = new ZTicket();
        ticket.comment = new ZTicketComment();
        ticket.comment.body = commentText;
        ticket.comment.x_public = isPublic;
        ticket.status = status.status;

        HttpRequest req = zconn.createRequest(
            HTTP_PUT,
            '/tickets/'+ticketId+'.json',
            JSON.serialize(new TicketWrapper(ticket), true)
        );
        zconn.sendRequest(req);
    }

    global ZendeskTypes.ZJobStatus mergeTickets(Set<Long> sourceTicketIds, String sourceComment, Long targetTicketId, String targetComment) {
        if (sourceTicketIds == null || sourceTicketIds.isEmpty()) { throw new ZendeskException('sourceTicketIds parameter cannot be null or empty'); }
        if (targetTicketId == null) { throw new ZendeskException('targetTicketId parameter cannot be null'); }

        // { "ids": [123, 234], "target_comment": "Closing in favor of #111",, "source_comment": "Combining with #123, #456" }
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeObjectField('ids', sourceTicketIds);
        if (!String.isEmpty(targetComment)) { gen.writeStringField('target_comment', targetComment); }
        if (!String.isEmpty(sourceComment)) { gen.writeStringField('source_comment', sourceComment); }
        gen.writeEndObject();

        HttpRequest req = zconn.createRequest(
            HTTP_POST,
            '/tickets/'+targetTicketId+'/merge.json',
            gen.getAsString()
        );
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    global void deleteTicket(Long ticketId) {
        if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest(
            HTTP_DELETE,
            '/tickets/'+ticketId+'.json')
        );
    }

    global void deleteTickets(Set<Long> ticketIds) {
        if (ticketIds == null || ticketIds.isEmpty()) { throw new ZendeskException('ticketIds parameter cannot be null or empty'); }

        zconn.sendRequest(zconn.createRequest(
            HTTP_DELETE,
            '/tickets/destroy_many.json',
            new Map<String, Object>{'ids'=>toCSV(ticketIds)})
        );
    }

    global Map<String, Object> getTicketRelatedInfo(Long ticketId) {
        if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest(
            HTTP_GET,
            '/tickets/'+ticketId+'/related.json'
        );
        return (Map<String, Object>)JSON.deserializeUntyped(zconn.sendRequest(req));
    }

    global void markTicketAsSpam(Long ticketId) {
        if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest(
            HTTP_PUT,
            '/tickets/'+ticketId+'/mark_as_spam.json'
        ));
    }

    global ZendeskTypes.ZJobStatus markTicketsAsSpam(Set<Long> ticketIds) {
        if (ticketIds == null || ticketIds.isEmpty()) { throw new ZendeskException('ticketIds parameter cannot be null or empty'); }

        HttpRequest req = zconn.createRequest(
            HTTP_PUT,
            '/tickets/mark_many_as_spam.json',
            new Map<String, Object>{'ids'=>toCSV(ticketIds)}
        );
        ZendeskJobStatusWrapper wrapper = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return wrapper.job_status;
    }

    global TicketsWrapper autocompleteProblems(String text) {
        if (String.isBlank(text) || text.length() < 2) { throw new ZendeskException('text parameter must at least 2 characters'); }

        HttpRequest req = zconn.createRequest(
            HTTP_POST,
            '/problems/autocomplete.json',
            new Map<String, Object>{'text'=>text}
        );
        //return (TicketsWrapper)JSON.deserialize(zconn.sendRequest(req), TicketsWrapper.class);
        return new TicketsWrapper(System.JSON.createParser(zconn.sendRequest(req)));
    }
}
